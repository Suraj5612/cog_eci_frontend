import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class OcrService {
  static bool _isProcessing = false;
  Future<String> extractSingleFieldText(String imagePath) async {
    return await extractTextFromImage(imagePath);
  }

  Future<String> extractTextFromImage(String imagePath) async {
    if (_isProcessing) {
      throw Exception('OCR already in progress');
    }

    _isProcessing = true;

    try {
      print('DEBUG: Starting Sarvam OCR for: $imagePath');

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: $imagePath');
      }

      // STEP 1 — Create OCR Job
      final jobResponse = await _requestWithRetry(() {
        return http.post(
          Uri.parse('${dotenv.env['SARVAM_BASE_URL']}/doc-digitization/job/v1'),
          headers: {
            'api-subscription-key': dotenv.env['SARVAM_API_KEY']!,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'job_parameters': {'language': 'hi-IN', 'output_format': 'md'},
          }),
        );
      });

      print('DEBUG: Job response status: ${jobResponse.statusCode}');
      print('DEBUG: Job response body: ${jobResponse.body}');

      if (jobResponse.statusCode != 200 && jobResponse.statusCode != 202) {
        throw Exception('Job creation failed: ${jobResponse.body}');
      }

      final jobData = jsonDecode(jobResponse.body) as Map<String, dynamic>;
      final jobId = jobData['job_id']?.toString();

      if (jobId == null || jobId.isEmpty) {
        throw Exception('Job ID not returned');
      }

      print('DEBUG: Job created successfully: $jobId');

      // STEP 2 — Convert image to ZIP
      final zipFile = await _createZipFromImage(imageFile);

      // STEP 3 — Get upload URL
      final uploadLinkResponse = await _requestWithRetry(() {
        return http.post(
          Uri.parse(
            '${dotenv.env['SARVAM_BASE_URL']}/doc-digitization/job/v1/upload-files',
          ),
          headers: {
            'api-subscription-key': dotenv.env['SARVAM_API_KEY']!,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'job_id': jobId,
            'files': ['input.zip'],
          }),
        );
      });

      print(
        'DEBUG: Upload URL response status: ${uploadLinkResponse.statusCode}',
      );
      print('DEBUG: Upload URL response body: ${uploadLinkResponse.body}');

      if (uploadLinkResponse.statusCode != 200 &&
          uploadLinkResponse.statusCode != 202) {
        throw Exception(
          'Upload URL generation failed: ${uploadLinkResponse.body}',
        );
      }

      final uploadData =
          jsonDecode(uploadLinkResponse.body) as Map<String, dynamic>;

      String? uploadUrl;

      if (uploadData['upload_urls'] is Map<String, dynamic>) {
        final urls = uploadData['upload_urls'] as Map<String, dynamic>;

        if (urls.containsKey('input.zip')) {
          final zipEntry = urls['input.zip'];
          if (zipEntry is Map<String, dynamic>) {
            uploadUrl = zipEntry['file_url']?.toString();
          }
        } else if (urls.isNotEmpty) {
          final first = urls.values.first;
          if (first is Map<String, dynamic>) {
            uploadUrl = first['file_url']?.toString();
          }
        }
      }

      if (uploadUrl == null || uploadUrl.isEmpty) {
        throw Exception('Upload URL missing: ${uploadLinkResponse.body}');
      }

      print('DEBUG: Upload URL extracted');

      // STEP 4 — Upload ZIP to Azure
      final zipBytes = await zipFile.readAsBytes();

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'x-ms-blob-type': 'BlockBlob'},
        body: zipBytes,
      );

      print('DEBUG: ZIP upload status: ${uploadResponse.statusCode}');
      print('DEBUG: ZIP upload body: ${uploadResponse.body}');

      if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
        throw Exception(
          'ZIP upload failed: ${uploadResponse.statusCode} ${uploadResponse.body}',
        );
      }

      // Small pause before start to reduce 429s
      await Future.delayed(const Duration(seconds: 2));

      // STEP 5 — Start OCR Job
      final startResponse = await _requestWithRetry(() {
        return http.post(
          Uri.parse(
            '${dotenv.env['SARVAM_BASE_URL']}/doc-digitization/job/v1/$jobId/start',
          ),
          headers: {'api-subscription-key': dotenv.env['SARVAM_API_KEY']!},
        );
      });

      print('DEBUG: Start job response: ${startResponse.statusCode}');
      print('DEBUG: Start job response body: ${startResponse.body}');

      if (startResponse.statusCode != 200 && startResponse.statusCode != 202) {
        throw Exception('Failed to start job: ${startResponse.body}');
      }

      // STEP 6 — Poll Job Status
      for (int attempt = 0; attempt < 30; attempt++) {
        await Future.delayed(const Duration(seconds: 4));

        final statusResponse = await _requestWithRetry(() {
          return http.get(
            Uri.parse(
              '${dotenv.env['SARVAM_BASE_URL']}/doc-digitization/job/v1/$jobId/status',
            ),
            headers: {'api-subscription-key': dotenv.env['SARVAM_API_KEY']!},
          );
        });

        print('DEBUG: Status check ${attempt + 1}');
        print('DEBUG: Status response code: ${statusResponse.statusCode}');
        print('DEBUG: Status response body: ${statusResponse.body}');

        if (statusResponse.statusCode != 200) continue;

        final statusData =
            jsonDecode(statusResponse.body) as Map<String, dynamic>;
        final state = statusData['job_state']?.toString();

        if (state == 'Completed' || state == 'PartiallyCompleted') {
          print('DEBUG: OCR job completed');

          // STEP 7 — Get download links
          final downloadLinksResponse = await _requestWithRetry(() {
            return http.post(
              Uri.parse(
                '${dotenv.env['SARVAM_BASE_URL']}/doc-digitization/job/v1/$jobId/download-files',
              ),
              headers: {'api-subscription-key': dotenv.env['SARVAM_API_KEY']!},
            );
          });

          print(
            'DEBUG: Download links status: ${downloadLinksResponse.statusCode}',
          );
          print('DEBUG: Download links body: ${downloadLinksResponse.body}');

          if (downloadLinksResponse.statusCode != 200 &&
              downloadLinksResponse.statusCode != 202) {
            throw Exception(
              'Failed to get download links: ${downloadLinksResponse.body}',
            );
          }

          final downloadLinksData =
              jsonDecode(downloadLinksResponse.body) as Map<String, dynamic>;

          String? downloadUrl;

          if (downloadLinksData['download_urls'] is Map<String, dynamic>) {
            final urls =
                downloadLinksData['download_urls'] as Map<String, dynamic>;

            if (urls.containsKey('document.zip')) {
              final zipEntry = urls['document.zip'];
              if (zipEntry is Map<String, dynamic>) {
                downloadUrl =
                    zipEntry['file_url']?.toString() ??
                    zipEntry['download_url']?.toString() ??
                    zipEntry['url']?.toString();
              }
            } else if (urls.isNotEmpty) {
              final first = urls.values.first;
              if (first is Map<String, dynamic>) {
                downloadUrl =
                    first['file_url']?.toString() ??
                    first['download_url']?.toString() ??
                    first['url']?.toString();
              }
            }
          }

          if (downloadUrl == null || downloadUrl.isEmpty) {
            throw Exception(
              'No download URL returned: ${downloadLinksResponse.body}',
            );
          }

          print('DEBUG: Output download URL extracted');

          // STEP 8 — Download output ZIP from signed URL
          final outputZipResponse = await http.get(Uri.parse(downloadUrl));

          print(
            'DEBUG: Output ZIP download status: ${outputZipResponse.statusCode}',
          );

          if (outputZipResponse.statusCode != 200) {
            throw Exception(
              'Failed to download OCR output ZIP: ${outputZipResponse.statusCode}',
            );
          }

          // STEP 9 — Extract OCR text from .md file
          final archive = ZipDecoder().decodeBytes(outputZipResponse.bodyBytes);

          for (final file in archive) {
            if (file.name.endsWith('.md')) {
              final content = file.content;
              if (content is List<int>) {
                final rawText = utf8.decode(content);
                final cleanedText = rawText
                    .replaceAll(RegExp(r'!\[Image\]\(data:image\/[^\)]+\)'), '')
                    .trim();

                print('=========== CLEANED OCR TEXT START ===========');
                print(cleanedText);
                print('=========== CLEANED OCR TEXT END ===========');

                return cleanedText;
              }
            }
          }

          throw Exception('No .md file found in OCR output ZIP');
        }

        if (state == 'Failed') {
          throw Exception('OCR job failed: ${statusResponse.body}');
        }
      }

      throw Exception('OCR job timeout');
    } catch (e, stackTrace) {
      print('DEBUG: Error: $e');
      print('DEBUG: Stack: $stackTrace');
      throw Exception('OCR failed: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);

    while (true) {
      final response = await request();

      if (response.statusCode != 429) {
        return response;
      }

      attempt++;
      if (attempt > maxRetries) {
        throw Exception(
          'Rate limit exceeded after $maxRetries retries: ${response.body}',
        );
      }

      print('DEBUG: Got 429, retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  Future<File> _createZipFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    final archive = Archive();

    final ext = p.extension(imageFile.path).toLowerCase();
    final name = ext == '.png' ? 'page_1.png' : 'page_1.jpg';

    archive.addFile(ArchiveFile(name, bytes.length, bytes));

    final zipData = ZipEncoder().encode(archive);

    final tempDir = await getTemporaryDirectory();
    final zipPath =
        '${tempDir.path}/sarvam_upload_${DateTime.now().millisecondsSinceEpoch}.zip';

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData, flush: true);

    print('DEBUG: Created ZIP at: $zipPath');
    return zipFile;
  }

  void dispose() {}
}
