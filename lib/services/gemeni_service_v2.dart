import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../constants.dart';

class MedicineScannerService {


  final String _apiKey = Constants.geminiKey;

  Future<List<dynamic>> scanImage(Uint8List imageBytes) async {
    final String url = Constants.geminiUrl;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          "contents": [{
            "parts": [
              {"text": Constants.prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Encode(imageBytes)
                }
              }
            ]
          }],
          "generationConfig": {
            "temperature": 0.1,
            "response_mime_type": "application/json"
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final String textResponse = data['candidates'][0]['content']['parts'][0]['text'];
        return jsonDecode(textResponse);
      } else {
        print("Ошибка API: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Ошибка сети: $e");
      return [];
    }
  }
}