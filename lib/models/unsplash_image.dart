/// Represents an image from Unsplash API
/// Follows clean architecture by keeping data models separate from business logic
class UnsplashImage {
  final String id;
  final String description;
  final String regularUrl;
  final String smallUrl;
  final String thumbUrl;
  final String photographerName;
  final String photographerUsername;

  const UnsplashImage({
    required this.id,
    required this.description,
    required this.regularUrl,
    required this.smallUrl,
    required this.thumbUrl,
    required this.photographerName,
    required this.photographerUsername,
  });

  /// Factory constructor to parse JSON response from Unsplash API
  /// Handles null values gracefully with fallback defaults
  factory UnsplashImage.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};

    return UnsplashImage(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? 
                   json['alt_description'] as String? ?? 
                   'Food image',
      regularUrl: urls['regular'] as String? ?? '',
      smallUrl: urls['small'] as String? ?? '',
      thumbUrl: urls['thumb'] as String? ?? '',
      photographerName: user['name'] as String? ?? 'Unknown',
      photographerUsername: user['username'] as String? ?? '',
    );
  }

  /// Convert to JSON for caching or storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'urls': {
      'regular': regularUrl,
      'small': smallUrl,
      'thumb': thumbUrl,
    },
    'user': {
      'name': photographerName,
      'username': photographerUsername,
    },
  };

  /// Attribution text for displaying photographer credit
  String get attribution => 'Photo by $photographerName on Unsplash';
}

/// Wrapper for Unsplash search results
class UnsplashSearchResult {
  final int total;
  final int totalPages;
  final List<UnsplashImage> images;

  const UnsplashSearchResult({
    required this.total,
    required this.totalPages,
    required this.images,
  });

  factory UnsplashSearchResult.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    
    return UnsplashSearchResult(
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      images: results
          .map((item) => UnsplashImage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isEmpty => images.isEmpty;
  bool get isNotEmpty => images.isNotEmpty;
}
