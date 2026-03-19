# 🚀 Quick Start: Image API Integration

## ✅ What's Been Created

### 1. **Model Layer** (`lib/models/unsplash_image.dart`)
- `UnsplashImage` - Complete image data model
- `UnsplashSearchResult` - Search results wrapper
- JSON serialization with null-safety

### 2. **Service Layer** (`lib/services/unsplash_api_service.dart`)
- `UnsplashApiService` - API client with retry logic
- `ImageApiException` - Custom error handling
- Automatic timeout (10s) and retry (2 attempts)
- Handles all HTTP errors (401, 403, 404, 429, 500+)
- Network error detection (SocketException)

### 3. **State Management** (`lib/providers/image_provider.dart`)
- `ImageProvider` - Provider-based state management
- States: initial, loading, success, error
- Methods: searchImages, loadMore, getRandomImage, retry, clear
- Pagination support

### 4. **UI Components**
- `ImageSearchScreen` - Full search interface with grid
- `FoodImagePickerButton` - Reusable picker for forms
- `QuickImageSelector` - Inline horizontal selector
- All with loading/error states and retry buttons

### 5. **Documentation**
- `IMAGE_API_INTEGRATION.md` - Complete guide
- `QUICK_START.md` - This file

## 🔧 Immediate Setup (3 Steps)

### Step 1: Register Provider in main.dart

Add this import:
```dart
import 'package:sharemeal/providers/image_provider.dart' as app;
```

Wrap your app with MultiProvider:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.ImageProvider()),
        // Add other providers here
      ],
      child: const MyApp(),
    ),
  );
}
```

### Step 2: Test the Integration

Create a test button anywhere in your app:
```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImageSearchScreen(),
      ),
    );
  },
  child: const Text('Search Food Images'),
)
```

### Step 3: Integrate in Food Post Form

Replace your current image picker with:
```dart
import 'package:sharemeal/services/widgets/food_image_picker.dart';

// In your form:
FoodImagePickerButton(
  foodName: _foodNameController.text,
  initialImageUrl: _currentImageUrl,
  onImageSelected: (imageUrl) {
    setState(() {
      _currentImageUrl = imageUrl;
    });
  },
)
```

## 📱 Usage Examples

### Example 1: Get Random Image (Simplest)
```dart
final provider = context.read<app.ImageProvider>();
final image = await provider.getRandomImage('biryani');

if (image != null) {
  print('Image URL: ${image.regularUrl}');
  print('Photographer: ${image.photographerName}');
}
```

### Example 2: Search with UI Updates
```dart
Consumer<app.ImageProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (provider.hasError) {
      return Column(
        children: [
          Text(provider.errorMessage ?? 'Error'),
          ElevatedButton(
            onPressed: () => provider.retry(),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    
    if (provider.hasImages) {
      return GridView.builder(
        itemCount: provider.images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          final image = provider.images[index];
          return CachedNetworkImage(
            imageUrl: image.smallUrl,
            fit: BoxFit.cover,
          );
        },
      );
    }
    
    return const Text('Search for images');
  },
)
```

### Example 3: Trigger Search
```dart
// From a search button or text field
final provider = context.read<app.ImageProvider>();
await provider.searchImages('samosa');
```

## 🎯 Integration Points in ShareMeal

### 1. Donor Dashboard (Post Meal Screen)
Replace the current image picker:
```dart
// OLD CODE (in donor_dashboard.dart or post_meal_screen.dart)
// Remove or comment out old image picker

// NEW CODE
FoodImagePickerButton(
  foodName: _itemController.text,
  onImageSelected: (imageUrl) {
    setState(() {
      _imageUrl = imageUrl;
      _isBase64 = false; // It's a URL, not base64
    });
  },
)
```

### 2. Food Card Widget
Already using CachedNetworkImage? Great! If not:
```dart
// Replace Image.network with:
CachedNetworkImage(
  imageUrl: post.img,
  fit: BoxFit.cover,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### 3. Add Search Button to App Bar
```dart
AppBar(
  title: const Text('ShareMeal'),
  actions: [
    IconButton(
      icon: const Icon(Icons.image_search),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ImageSearchScreen(),
          ),
        );
      },
    ),
  ],
)
```

## 🔍 Testing Checklist

- [ ] Run `flutter pub get` (Already done ✅)
- [ ] Add ImageProvider to main.dart
- [ ] Test ImageSearchScreen navigation
- [ ] Search for "biryani" - should show results
- [ ] Test error state (turn off internet)
- [ ] Test retry button
- [ ] Test pagination (scroll to bottom)
- [ ] Integrate in food post form
- [ ] Test random image button
- [ ] Verify image caching works

## 🐛 Common Issues & Solutions

### Issue: "ImageProvider is not a type"
**Solution**: Import with alias:
```dart
import 'package:sharemeal/providers/image_provider.dart' as app;
```

### Issue: "CachedNetworkImage not found"
**Solution**: Already added to pubspec.yaml and installed ✅

### Issue: "No images found"
**Solution**: 
- Check internet connection
- Try different search terms
- Verify API key is valid

### Issue: "Rate limit exceeded"
**Solution**: 
- Unsplash free tier: 50 requests/hour
- Wait 1 hour or use fallback images

## 📊 API Limits & Fallbacks

### Unsplash Free Tier
- 50 requests per hour
- 5000 requests per month
- Demo API key included (replace in production)

### Fallback Strategy
The old `ImageService.getFallbackImageUrl()` still works as backup:
```dart
final image = await provider.getRandomImage('biryani');
final url = image?.regularUrl ?? ImageService.getFallbackImageUrl('biryani');
```

## 🎨 Customization

### Change Grid Columns
In `image_search_screen.dart`:
```dart
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3, // Change from 2 to 3
),
```

### Change Timeout Duration
In `unsplash_api_service.dart`:
```dart
static const Duration _timeout = Duration(seconds: 15); // Change from 10
```

### Change Images Per Page
In `image_provider.dart`:
```dart
await _apiService.searchFoodImages(
  query: query,
  page: _currentPage,
  perPage: 30, // Change from 20
);
```

## 🚀 Next Steps

1. **Test the integration** - Follow testing checklist above
2. **Replace old image picker** - In donor dashboard
3. **Add to other screens** - Wherever images are needed
4. **Customize UI** - Match your app's theme
5. **Add local database** - 100+ Indian food items (next task)

## 📞 Need Help?

Check these files:
- `IMAGE_API_INTEGRATION.md` - Detailed documentation
- `lib/services/unsplash_api_service.dart` - API implementation
- `lib/screens/image_search_screen.dart` - UI examples

## ✨ Features Included

✅ Clean architecture (Model-Service-Provider-UI)
✅ Comprehensive error handling
✅ Automatic retry on failure
✅ Network error detection
✅ Loading states
✅ Error states with retry button
✅ Pagination support
✅ Image caching
✅ Null-safe code
✅ User-friendly error messages
✅ Photographer attribution
✅ Multiple UI components
✅ Complete documentation

**You're ready to go! Start with Step 1 above.** 🎉
