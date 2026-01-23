import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../constants.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: Constants.geminiVersion,
      apiKey: Constants.geminiKey,
    );
  }

  Future<String> scanMedicine(Uint8List bytes) async {
    final content = [
      Content.multi([
        TextPart(Constants.prompt),
        DataPart('image/jpeg', bytes),
      ])
    ];

    final response = await _model.generateContent(content);
    return response.text ?? "Error";
  }
}