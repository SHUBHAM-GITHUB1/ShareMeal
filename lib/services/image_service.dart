import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageService {
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

  /// Returns a free food image URL for the given food item.
  /// Uses LoremFlickr — free, no API key, searches Flickr by keyword.
  static String foodImageUrl(String foodItem) {
    final query = Uri.encodeComponent(foodItem.toLowerCase().trim());
    return 'https://loremflickr.com/400/300/$query,food/all';
  }
}
