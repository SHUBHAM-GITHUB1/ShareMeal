import 'package:flutter/foundation.dart';
import 'package:sharemeal/models/unsplash_image.dart';
import 'package:sharemeal/services/unsplash_api_service.dart';

/// Represents the current state of image fetching
enum ImageLoadingState {
  initial,
  loading,
  success,
  error,
}

/// Provider for managing image search state
/// Follows clean architecture by separating state management from UI
class ImageProvider extends ChangeNotifier {
  final UnsplashApiService _apiService;

  ImageProvider({UnsplashApiService? apiService})
      : _apiService = apiService ?? UnsplashApiService();

  // State variables
  ImageLoadingState _state = ImageLoadingState.initial;
  List<UnsplashImage> _images = [];
  String? _errorMessage;
  String _lastQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  ImageLoadingState get state => _state;
  List<UnsplashImage> get images => List.unmodifiable(_images);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ImageLoadingState.loading;
  bool get hasError => _state == ImageLoadingState.error;
  bool get hasImages => _images.isNotEmpty;
  bool get hasMore => _hasMore;
  String get lastQuery => _lastQuery;

  /// Search for food images
  Future<void> searchImages(String query, {bool refresh = true}) async {
    if (query.trim().isEmpty) return;

    // Reset state if new search
    if (refresh) {
      _currentPage = 1;
      _images = [];
      _hasMore = true;
    }

    _lastQuery = query;
    _state = ImageLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.searchFoodImages(
        query: query,
        page: _currentPage,
        perPage: 20,
      );

      if (result.isEmpty && _currentPage == 1) {
        _state = ImageLoadingState.error;
        _errorMessage = 'No images found for "$query"';
      } else {
        _images.addAll(result.images);
        _hasMore = _currentPage < result.totalPages;
        _state = ImageLoadingState.success;
      }
    } on ImageApiException catch (e) {
      _state = ImageLoadingState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = ImageLoadingState.error;
      _errorMessage = 'An unexpected error occurred';
      debugPrint('Image search error: $e');
    }

    notifyListeners();
  }

  /// Load next page of results
  Future<void> loadMore() async {
    if (!_hasMore || _state == ImageLoadingState.loading) return;

    _currentPage++;
    await searchImages(_lastQuery, refresh: false);
  }

  /// Get a single random image for a food item
  Future<UnsplashImage?> getRandomImage(String foodName) async {
    try {
      return await _apiService.getRandomFoodImage(query: foodName);
    } on ImageApiException catch (e) {
      debugPrint('Failed to get random image: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error getting random image: $e');
      return null;
    }
  }

  /// Retry last failed request
  Future<void> retry() async {
    if (_lastQuery.isNotEmpty) {
      await searchImages(_lastQuery);
    }
  }

  /// Clear all images and reset state
  void clear() {
    _images = [];
    _state = ImageLoadingState.initial;
    _errorMessage = null;
    _lastQuery = '';
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
