import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../constants.dart';
class MedicineDetectorService {
  final String apiKey = Constants.deepSeekKey;
  final String baseUrl = "https://api.deepseek.com/v1/chat/completions";

  // Теперь принимаем Uint8List (байты) вместо File
  Future<String> detectMedicines(Uint8List imageBytes) async {

    // Конвертируем байты в Base64 строку
    final String base64Image = base64Encode(imageBytes);

    final String prompt = """
    Ты выступаешь в роли профессионального детектора медикаментов. Рассмотри отправленную мной фотографию, найди все возможные медикаменты. 
    Для каждого медикамента определи: Название, Срок годности, Дозировка, Категория.
    Категории: Анальгетики, НПВП, антибиотики, антигистаминные, спазмолитики, муколитики, отхаркивающие, антисептики, сорбенты, антациды, ферменты, прокинетики, противовирусные, антимикотики, гипотензивные, антиагреганты, седативные, ноотропы, витамины, диуретики, гормональные препараты.
    
    Ответ верни СТРОГО в формате JSON массива:
    [{'name': 'название', 'dosage': 'дозировка', 'date': 'срок годности', 'category': 'категория'}]
    
    Если параметр не найден, ставь пустую строку. Не пиши никакого лишнего текста, только чистый JSON.
    """;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "deepseek-vl2", // Используйте актуальную мультимодальную модель
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image" // Передаем base64
                  }
                }
              ]
            }
          ],
          "temperature": 0.1,
        }),
      );

      if (response.statusCode == 200) {
        // Декодируем UTF-8, чтобы корректно отображалась кириллица
        final String responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        String content = data['choices'][0]['message']['content'];

        // Очистка от возможных markdown-тегов (```json ... ```)
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();

        return jsonDecode(content);
      } else {
        throw Exception("Ошибка API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Ошибка при детекции: $e");
      return e.toString();
    }
  }
}