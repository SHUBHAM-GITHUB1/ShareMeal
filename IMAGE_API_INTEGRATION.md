# Image API Integration Guide - ShareMeal

## 📋 Overview
Complete Unsplash API integration with clean architecture, proper error handling, and efficient state management using Provider.

## 🏗️ Architecture

```
lib/
├── models/
│   └── unsplash_image.dart          # Data models
├── services/
│   └── unsplash_api_service.dart    # API client & error handling
├── providers/
│   └── image_provider.dart          # State management
├── screens/
│   └── image_search_screen.dart     # Full search UI
└── services/widgets/
    └── food_image_picker.dart       # Reusable components
```

## 🚀 Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Register Provider in main.dart
```dart
import 'package:provider/provider.dart';
import 'package:sharemeal/providers/image_provider.dart' as app;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.ImageProvider()),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. (Optional) Use Environment Variables
For production, store API key in `.env`:
```
UNSPLASH_API_KEY=your_api_key_here
```

Then load with flutter_dotenv:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

## 💡 Usage Examples

### Example 1: Full Image Search Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ImageSearchScreen(),
  ),
);
```

### Example 2: Get Random Image
```dart
final provider = context.read<app.ImageProvider>();
final image = await provider.getRandomImage('biryani');
if (image != null) {
  print('Image URL: ${image.regularUrl}');
}
```

### Example 3: Search with State Management
```dart
Consumer<app.ImageProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    if (provider.hasError) {
      return Text(provider.errorMessage ?? 'Error');
    }
    return ListView.builder(
      itemCount: provider.images.length,
      itemBuilder: (context, index) {
        final image = provider.images[index];
        return ListTile(
          leading: CachedNetworkImage(imageUrl: image.thumbUrl),
          title: Text(image.description),
        );
      },
    );
  },
)
```

### Example 4: Integrate in Food Post Form
```dart
FoodImagePickerButton(
  foodName: 'samosa',
  onImageSelected: (imageUrl) {
    setState(() {
      _selectedImageUrl = imageUrl;
    });
  },
)
```

## 🔧 API Service Features

### Error Handling
- ✅ Network errors (SocketException)
- ✅ Timeout errors (10s timeout)
- ✅ HTTP status codes (401, 403, 404, 429, 500+)
- ✅ Automatic retry (2 attempts with 2s delay)
- ✅ User-friendly error messages

### Response Parsing
- ✅ Null-safe JSON parsing
- ✅ Fallback values for missing fields
- ✅ Type-safe model conversion

### Performance
- ✅ Connection pooling (http.Client)
- ✅ Request timeout (10s)
- ✅ Pagination support
- ✅ Image caching (cached_network_image)

## 📊 State Management

### States
- `initial` - No search performed
- `loading` - Fetching data
- `success` - Data loaded
- `error` - Request failed

### Provider Methods
```dart
// Search images
await provider.searchImages('pizza');

// Load more results
await provider.loadMore();

// Get random image
final image = await provider.getRandomImage('burger');

// Retry failed request
await provider.retry();

// Clear all data
provider.clear();
```

## 🎨 UI Components

### ImageSearchScreen
Full-featured search screen with:
- Search bar with clear button
- Grid layout (2 columns)
- Infinite scroll pagination
- Loading states
- Error states with retry
- Image detail modal

### FoodImagePickerButton
Reusable component for forms:
- Random image button
- Search button
- Image preview
- Loading indicator

### QuickImageSelector
Inline horizontal image selector:
- Horizontal scrolling
- Quick preview
- Refresh button
- Error handling

## 🔒 Security Best Practices

1. **API Key Management**
   - Never commit API keys to version control
   - Use environment variables in production
   - Rotate keys regularly

2. **Rate Limiting**
   - Unsplash free tier: 50 requests/hour
   - Handle 429 errors gracefully
   - Implement client-side caching

3. **Image Attribution**
   - Always display photographer credit
   - Use `image.attribution` property
   - Follow Unsplash guidelines

## 🐛 Troubleshooting

### Issue: "No internet connection"
**Solution**: Check device network settings and retry

### Issue: "Rate limit exceeded"
**Solution**: Wait 1 hour or upgrade Unsplash plan

### Issue: "Invalid API key"
**Solution**: Verify API key in unsplash_api_service.dart

### Issue: Images not loading
**Solution**: Check cached_network_image configuration

## 📈 Performance Tips

1. **Use appropriate image sizes**
   - `thumbUrl` for thumbnails (200px)
   - `smallUrl` for cards (400px)
   - `regularUrl` for full view (1080px)

2. **Implement pagination**
   - Load 20 images per page
   - Use infinite scroll
   - Show loading indicator

3. **Cache images**
   - cached_network_image handles this automatically
   - Configure cache duration if needed

4. **Optimize searches**
   - Debounce search input
   - Cancel previous requests
   - Use specific food terms

## 🔄 Migration from Old ImageService

Replace old code:
```dart
// OLD
final url = await ImageService.foodImageUrl('biryani');
```

With new code:
```dart
// NEW
final provider = context.read<app.ImageProvider>();
final image = await provider.getRandomImage('biryani');
final url = image?.regularUrl ?? ImageService.getFallbackImageUrl('biryani');
```

## 📝 Testing

### Unit Tests
```dart
test('UnsplashImage.fromJson parses correctly', () {
  final json = {...};
  final image = UnsplashImage.fromJson(json);
  expect(image.id, 'test-id');
});
```

### Widget Tests
```dart
testWidgets('ImageSearchScreen shows loading state', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => app.ImageProvider(),
      child: MaterialApp(home: ImageSearchScreen()),
    ),
  );
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 📚 Additional Resources

- [Unsplash API Documentation](https://unsplash.com/documentation)
- [Provider Package](https://pub.dev/packages/provider)
- [Cached Network Image](https://pub.dev/packages/cached_network_image)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

## 🎯 Next Steps

1. ✅ Implement local image database (100+ Indian foods)
2. ⬜ Add image upload functionality
3. ⬜ Implement image compression
4. ⬜ Add offline mode support
5. ⬜ Create image favorites feature
