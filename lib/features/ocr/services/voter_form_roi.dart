import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VoterFormRoiExtractor {
  static Future<File> extractTopInfoBand(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception('Failed to decode image for ROI extraction');
    }

    final width = original.width;
    final height = original.height;

    // Full-page crop tuned for this voter form
    final cropX = (width * 0.03).round();
    final cropY = (height * 0.11).round();
    final cropW = (width * 0.77).round();
    final cropH = (height * 0.20).round();

    final cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    final grayscale = img.grayscale(cropped);

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      'roi_top_band_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final outFile = File(outPath);
    await outFile.writeAsBytes(
      img.encodeJpg(grayscale, quality: 95),
      flush: true,
    );

    return outFile;
  }
}
