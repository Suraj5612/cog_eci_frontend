import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CsvService {
  static Future<String> downloadCSV(String token) async {
    final response = await http.get(
      Uri.parse("https://cog-eci-backend.onrender.com/api/voters/download"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/voters.csv');

      await file.writeAsBytes(response.bodyBytes);

      return file.path;
    } else {
      throw Exception("Failed to download CSV");
    }
  }
}
