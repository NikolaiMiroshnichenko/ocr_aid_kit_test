import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ocr_aid_kit_test/constants.dart';

class CloudOCRService {


  Future<String> recognizeText(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    final String url = "https://vision.googleapis.com/v1/images:annotate?key=${Constants.googleKey}";

    final Map<String, dynamic> requestBody = {
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "TEXT_DETECTION"}
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responses'][0]['fullTextAnnotation']['text'] ?? " Text not Found";
    } else {
      throw Exception("Request Error: ${response.body}");
    }
  }
}