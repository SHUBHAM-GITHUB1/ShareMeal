import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _unsplashApiKey = '8S-mnXGLCl_xqZbLPaVih2GNHTo2vWtkZGimxB3soyE';
  static const String _unsplashBaseUrl = 'https://api.unsplash.com';
  static final _picker = ImagePicker();

  static Future<String?> _pickAndEncode(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 75,
    );
    if (xfile == null) return null;
    final bytes = await xfile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Pick image from gallery. Returns base64 string or null if cancelled.
  static Future<String?> pickFromGallery() =>
      _pickAndEncode(ImageSource.gallery);

  /// Pick image from camera. Returns base64 string or null if cancelled.
  static Future<String?> pickFromCamera() =>
      _pickAndEncode(ImageSource.camera);

  /// Get food image URL from Unsplash API with fallback
  static Future<String> foodImageUrl(String foodName) async {
    try {
      final query = Uri.encodeComponent('$foodName food');
      final url = '$_unsplashBaseUrl/search/photos?query=$query&per_page=1&orientation=landscape';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Client-ID $_unsplashApiKey'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['urls']['regular'] as String;
        }
      }
    } catch (_) {
      // Fallback if API fails
    }
    
    final foodData = _fallbackImageUrl(foodName);
    if (foodData != null) return foodData;

    // Default generic food image
    return 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400';
  }

  static String? _fallbackImageUrl(String foodName) {
    const map = <String, String>{
      'rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      'roti': 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400',
      'dal':  'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
      'biryani': 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400',
      'chicken': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
      'bread': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      'fruit': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
    };
    final key = foodName.toLowerCase().trim();
    for (final entry in map.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static String getFallbackImageUrl(String foodName) =>
      _fallbackImageUrl(foodName) ??
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400';
}
