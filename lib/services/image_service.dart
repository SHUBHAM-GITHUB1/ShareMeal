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
    
    return getFallbackImageUrl(foodName);
  }

  /// Fallback image URLs for common food items
  static String getFallbackImageUrl(String foodName) {
    final food = foodName.toLowerCase().trim();
    
    final foodImageMap = {
      'rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      'bread': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      'pasta': 'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=400',
      'pizza': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      'burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      'sandwich': 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=400',
      'salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      'soup': 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
      'chicken': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
      'fish': 'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400',
      'vegetables': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
      'fruits': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
      'apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
      'banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
      'milk': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
      'cheese': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
      'eggs': 'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=400',
      'curry': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
      'biryani': 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400',
    };

    // Try exact match
    if (foodImageMap.containsKey(food)) {
      return foodImageMap[food]!;
    }

    // Try partial matches
    for (final key in foodImageMap.keys) {
      if (food.contains(key) || key.contains(food)) {
        return foodImageMap[key]!;
      }
    }

    // Default generic food image
    return 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400';
  }
}
