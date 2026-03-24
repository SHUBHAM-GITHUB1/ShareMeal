import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sharemeal/models/unsplash_image.dart';

/// Custom exception for API errors with user-friendly messages
class ImageApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? technicalDetails;

  const ImageApiException({
    required this.message,
    this.statusCode,
    this.technicalDetails,
  });

  @override
  String toString() => message;
}

/// Service layer for Unsplash API integration
/// Handles all network requests, error handling, and response parsing
class UnsplashApiService {
  // API Configuration - In production, load from flutter_dotenv
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _apiKey = '8S-mnXGLCl_xqZbLPaVih2GNHTo2vWtkZGimxB3soyE';
  
  // Timeout configuration
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 2;

  final http.Client _client;

  UnsplashApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Search for food images with automatic retry on failure
  /// Returns UnsplashSearchResult or throws ImageApiException
  Future<UnsplashSearchResult> searchFoodImages({
    required String query,
    int page = 1,
    int perPage = 10,
    String orientation = 'landscape',
  }) async {
    return _executeWithRetry(() async {
      final queryParams = {
        'query': '$query food',
        'page': page.toString(),
        'per_page': perPage.toString(),
        'orientation': orientation,
      };

      final uri = Uri.parse('$_baseUrl/search/photos')
          .replace(queryParameters: queryParams);

      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(),
          )
          .timeout(_timeout);

      return _handleResponse<UnsplashSearchResult>(
        response,
        (json) => UnsplashSearchResult.fromJson(json),
      );
    });
  }

  /// Get a random food image
  Future<UnsplashImage> getRandomFoodImage({
    String? query,
    String orientation = 'landscape',
  }) async {
    return _executeWithRetry(() async {
      final queryParams = {
        'query': query != null ? '$query food' : 'food',
        'orientation': orientation,
      };

      final uri = Uri.parse('$_baseUrl/photos/random')
          .replace(queryParameters: queryParams);

      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(),
          )
          .timeout(_timeout);

      return _handleResponse<UnsplashImage>(
        response,
        (json) => UnsplashImage.fromJson(json),
      );
    });
  }

  /// Build request headers with authorization
  Map<String, String> _buildHeaders() => {
    'Authorization': 'Client-ID $_apiKey',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Generic response handler with error mapping
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    // Success case
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return parser(json);
      } catch (e) {
        throw ImageApiException(
          message: 'Failed to parse response',
          statusCode: response.statusCode,
          technicalDetails: e.toString(),
        );
      }
    }

    // Error cases with specific handling
    switch (response.statusCode) {
      case 401:
        throw const ImageApiException(
          message: 'Invalid API key. Please check your credentials.',
          statusCode: 401,
        );
      case 403:
        throw const ImageApiException(
          message: 'Access forbidden. API key may be restricted.',
          statusCode: 403,
        );
      case 404:
        throw const ImageApiException(
          message: 'No images found for this search.',
          statusCode: 404,
        );
      case 429:
        throw const ImageApiException(
          message: 'Rate limit exceeded. Please try again later.',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
        throw ImageApiException(
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      default:
        throw ImageApiException(
          message: 'Failed to load images. Please try again.',
          statusCode: response.statusCode,
          technicalDetails: response.body,
        );
    }
  }

  /// Execute request with automatic retry on transient failures
  Future<T> _executeWithRetry<T>(Future<T> Function() request) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        return await request();
      } on SocketException {
        // No internet connection
        throw const ImageApiException(
          message: 'No internet connection. Please check your network.',
        );
      } on TimeoutException {
        attempts++;
        if (attempts >= _maxRetries) {
          throw const ImageApiException(
            message: 'Request timed out. Please check your connection.',
          );
        }
        // Wait before retry
        await Future.delayed(_retryDelay);
      } on ImageApiException {
        // Don't retry on API errors (401, 404, etc.)
        rethrow;
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          throw ImageApiException(
            message: 'An unexpected error occurred',
            technicalDetails: e.toString(),
          );
        }
        await Future.delayed(_retryDelay);
      }
    }

    throw const ImageApiException(
      message: 'Failed after multiple attempts',
    );
  }

  /// Clean up resources
  void dispose() {
    _client.close();
  }
}
