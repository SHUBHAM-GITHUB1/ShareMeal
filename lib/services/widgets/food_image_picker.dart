import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sharemeal/providers/image_provider.dart' as app;
import 'package:sharemeal/screens/image_search_screen.dart';
import 'package:sharemeal/constants/app_theme.dart';

/// Simple image picker button for food posts
class FoodImagePickerButton extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String imageUrl) onImageSelected;
  final String foodName;

  const FoodImagePickerButton({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.foodName = '',
  });

  @override
  State<FoodImagePickerButton> createState() => _FoodImagePickerButtonState();
}

class _FoodImagePickerButtonState extends State<FoodImagePickerButton> {
  String? _selectedImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImageUrl = widget.initialImageUrl;
  }

  Future<void> _fetchRandomImage() async {
    if (widget.foodName.isEmpty) return;

    setState(() => _isLoading = true);

    final provider = context.read<app.ImageProvider>();
    final image = await provider.getRandomImage(widget.foodName);

    if (image != null && mounted) {
      setState(() {
        _selectedImageUrl = image.regularUrl;
        _isLoading = false;
      });
      widget.onImageSelected(image.regularUrl);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openImageSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImageSearchScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedImageUrl = result.regularUrl);
      widget.onImageSelected(result.regularUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedImageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _selectedImageUrl!,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _fetchRandomImage,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shuffle),
                label: const Text('Random Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sage,
                  side: const BorderSide(color: AppColors.sage),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openImageSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Inline image selector with quick preview
class QuickImageSelector extends StatelessWidget {
  final String foodName;
  final Function(String imageUrl) onImageSelected;

  const QuickImageSelector({
    super.key,
    required this.foodName,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<app.ImageProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await provider.searchImages(foodName);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        provider.errorMessage ?? 'Failed to load images',
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () => provider.retry(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.hasImages)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.images.length,
                  itemBuilder: (context, index) {
                    final image = provider.images[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onImageSelected(image.regularUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: image.thumbUrl,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
