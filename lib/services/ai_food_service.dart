import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiFoodService {
  // Get a free API key at: https://aistudio.google.com/app/apikey
  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  /// Identifies the food item from a base64-encoded image.
  /// Returns a short food name (e.g. "Biryani") or null on failure.
  static Future<String?> identifyFood(String imageBase64) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final imageBytes = base64Decode(imageBase64);
      final prompt = TextPart(
        'Identify the food in this image. '
        'Reply with ONLY the food name (1-4 words, e.g. "Chicken Biryani"). '
        'If no food is visible, reply "Unknown".',
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty || text == 'Unknown') return null;
      return text;
    } catch (_) {
      return null;
    }
  }
}
