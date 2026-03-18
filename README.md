# ShareMeal 🍽️

A Flutter-based food rescue application that bridges the gap between food donors and NGOs, reducing food waste while helping those in need.

## 📱 Overview

ShareMeal is a comprehensive food donation platform that enables:
- **Donors** to post surplus food with location and nutritional information
- **NGOs** to discover and claim nearby food donations
- **Real-time notifications** for NGOs within a 10km radius of new donations
- **Interactive maps** for pickup location coordination
- **Nutritional analysis** using multiple API sources

## ✨ Key Features

### 🎯 Core Functionality
- **Dual User Roles**: Separate dashboards for Donors and NGOs
- **Real-time Food Feed**: Live updates of available donations
- **Location-based Matching**: 10km radius notification system
- **Interactive Maps**: OpenStreetMap integration for pickup coordination
- **Nutritional Analysis**: Multi-tier API system for accurate food data
- **Image Integration**: Unsplash API for dynamic food imagery

### 🔐 Authentication
- **Firebase Authentication** with Google Sign-In
- **Role-based Access Control** (Donor/NGO)
- **Persistent User Sessions**
- **Profile Management**

### 📍 Location Services
- **Automatic Location Detection** for NGOs
- **Interactive Map Picker** for donors
- **Reverse Geocoding** for address display
- **Distance Calculation** using Haversine formula
- **Pickup Location Visualization**

### 🔔 Smart Notifications
- **Proximity-based Alerts**: Notify NGOs within 10km of new donations
- **Real-time Updates**: Firestore-powered notification system
- **Unread Badge Counters**: Visual notification indicators
- **Notification History**: Persistent notification panel

### 📊 Nutrition Intelligence
- **Multi-API Integration**: Calorie Ninja + Open Food Facts + Local DB
- **Per 100g Normalization**: Consistent nutritional data
- **Minimum Value Enforcement**: No zero-value nutrients
- **Smart Fallbacks**: 4-tier data retrieval system

## 🛠️ Technical Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Material Design** - UI components

### Backend & Services
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Hosting** - Web deployment

### APIs & Integrations
- **Calorie Ninja API** - Primary nutrition data
- **Open Food Facts API** - Secondary nutrition source
- **Unsplash API** - Dynamic food imagery
- **OpenStreetMap** - Map tiles and geocoding
- **Geolocator** - Device location services
- **Geocoding** - Address resolution

### Key Packages
```yaml
dependencies:
  flutter_map: ^7.0.2          # Interactive maps
  latlong2: ^0.9.1             # Geographic coordinates
  geolocator: ^13.0.2          # Location services
  geocoding: ^3.0.0            # Address geocoding
  firebase_core: ^3.15.2       # Firebase SDK
  firebase_auth: ^5.7.0        # Authentication
  cloud_firestore: ^5.6.12     # Database
  google_sign_in: ^6.3.0       # Google OAuth
  image_picker: ^1.2.1         # Camera/gallery access
  http: ^1.6.0                 # API requests
  provider: ^6.1.5             # State management
  intl: ^0.19.0                # Internationalization
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── constants/
│   ├── app_constants.dart    # App-wide constants
│   └── app_theme.dart        # Theme and styling
├── models/
│   ├── app_state.dart        # Global app state
│   ├── food_post.dart        # Food donation model
│   └── nutrient_data.dart    # Nutrition data models
├── screens/
│   ├── auth_wrapper.dart     # Authentication routing
│   ├── login_screen.dart     # Login interface
│   ├── donor_dashboard.dart  # Donor interface
│   ├── ngo_dashboard.dart    # NGO interface
│   └── map_picker_screen.dart # Location picker
├── services/
│   ├── auth_service.dart     # Authentication logic
│   ├── meal_service.dart     # Food CRUD operations
│   ├── nutrition_service.dart # Nutrition API integration
│   ├── notification_service.dart # Proximity notifications
│   └── image_service.dart    # Image handling
├── widgets/
│   └── food_card.dart        # Reusable food display
└── main.dart                 # App entry point
```

### Data Flow
1. **Authentication**: Firebase Auth → User Profile → Role-based Routing
2. **Food Posting**: Form Input → Nutrition API → Image API → Firestore → Proximity Notifications
3. **Food Discovery**: Firestore Stream → Real-time UI Updates → Claim Actions
4. **Notifications**: Location Monitoring → Distance Calculation → Notification Creation → UI Alerts

## 🔧 API Configuration

### Environment Variables
The app uses the following API keys (configured in respective service files):

```dart
// Calorie Ninja API (nutrition_service.dart)
static const _ninjaKey = '4OpMPEqxMXFUpzzDAW61MohatdTYuLCw5kbjVsTv';

// Unsplash API (image_service.dart)
static const _unsplashApiKey = '8S-mnXGLCl_xqZbLPaVih2GNHTo2vWtkZGimxB3soyE';
```

### Firebase Configuration
Firebase project: `sharemeal-47aac`
- **Authentication**: Google Sign-In enabled
- **Firestore**: Real-time database with security rules
- **Hosting**: Web deployment ready

## 📊 Database Schema

### Collections

#### `users`
```json
{
  "uid": "string",
  "email": "string",
  "orgName": "string",
  "address": "string", 
  "role": "Donor|NGO",
  "lat": "number",      // NGO location
  "lng": "number",      // NGO location
  "createdAt": "timestamp"
}
```

#### `meals`
```json
{
  "donorId": "string",
  "donorName": "string",
  "item": "string",
  "qty": "string",
  "isVeg": "boolean",
  "img": "string",           // Base64 or URL
  "imgIsBase64": "boolean",
  "status": "available|claimed|completed",
  "claimedBy": "string",
  "lat": "number",           // Pickup location
  "lng": "number",
  "locationAddress": "string",
  "nutrients": {
    "calories": "number",
    "protein": "number",
    "carbs": "number",
    "fat": "number",
    "fiber": "number",
    "sugar": "number", 
    "sodium": "number",
    "cholesterol": "number",
    "servingSize": "number",
    "source": "api|local"
  },
  "postedAt": "timestamp"
}
```

#### `notifications`
```json
{
  "toUid": "string",         // NGO user ID
  "mealId": "string",
  "donorName": "string",
  "item": "string",
  "qty": "string",
  "distanceKm": "number",
  "locationAddress": "string",
  "donorLat": "number",
  "donorLng": "number", 
  "read": "boolean",
  "createdAt": "timestamp"
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0+
- Dart SDK 3.10.0+
- Android Studio / VS Code
- Firebase CLI (for deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ShareMeal/ShareMeal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication (Google Sign-In)
   - Create Firestore database
   - Download `google-services.json` to `android/app/`
   - Update `firebase_options.dart` with your config

4. **API Keys Setup**
   - Get Calorie Ninja API key from API-Ninjas
   - Get Unsplash API key from Unsplash Developers
   - Update keys in respective service files

5. **Run the application**
   ```bash
   flutter run
   ```

### Platform-specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions: Internet, Location, Camera, Storage

#### Web
- Requires HTTPS for location services
- CORS configured for API calls
- PWA-ready with manifest.json

#### iOS
- iOS 12.0+
- Location permissions in Info.plist
- Camera/Photo library permissions

## 🎯 Usage Guide

### For Donors
1. **Sign up** with Google account, select "Donor" role
2. **Post food** by filling the donation form:
   - Enter food item name
   - Specify quantity in kg
   - Choose veg/non-veg
   - Optionally add custom photo
   - Set pickup location on map
3. **Monitor status** in your dashboard
4. **Confirm pickup** when NGO collects the food

### For NGOs  
1. **Sign up** with Google account, select "NGO" role
2. **Browse available food** in the live feed
3. **View details** including nutrition facts and location
4. **Claim food** items you want to collect
5. **Navigate to pickup** using the integrated map
6. **Receive notifications** for nearby new donations

## 🔍 Key Features Deep Dive

### Nutrition Intelligence System

**4-Tier Data Retrieval:**
1. **Calorie Ninja API** (Primary) - Comprehensive nutrition database
2. **Open Food Facts** (Secondary) - Community-driven food database  
3. **Local Database** (Tertiary) - 40+ common Indian foods
4. **Smart Defaults** (Fallback) - Scientifically reasonable minimums

**Data Processing:**
- All values normalized to per 100g
- Minimum value enforcement (no zero nutrients)
- Multi-item aggregation and averaging
- Source tracking for transparency

### Proximity Notification System

**How it works:**
1. NGO locations automatically saved on app launch
2. When donor posts with location, system queries all NGOs
3. Haversine distance calculation for each NGO
4. Notifications created for NGOs within 10km radius
5. Real-time notification delivery via Firestore streams

**Features:**
- 10km optimal radius for urban food rescue
- Batch notification creation for efficiency
- Unread count badges in UI
- Persistent notification history
- Auto-mark as read when panel opened

### Interactive Mapping

**Map Picker (Donors):**
- Tap-to-pin location selection
- "My Location" button with GPS
- Zoom controls for precision
- Reverse geocoding for address display
- Visual confirmation before saving

**Location Viewer (NGOs):**
- Pickup location visualization
- Custom pin with food icon
- Address and coordinates display
- Integrated with food details

## 🔒 Security & Privacy

### Authentication
- Firebase Auth with Google OAuth
- Role-based access control
- Secure token management
- Session persistence

### Data Protection
- Firestore security rules
- Input validation and sanitization
- API key protection
- Location data encryption

### Privacy Features
- Optional location sharing
- User-controlled data visibility
- Secure image handling (Base64 encoding)
- GDPR-compliant data practices

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
firebase deploy --only hosting
```

### Android Release
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Code Analysis
```bash
flutter analyze
```

## 📈 Performance Optimizations

### Image Handling
- Automatic image compression (75% quality)
- Base64 encoding for Firestore storage
- Lazy loading with error fallbacks
- Unsplash CDN for external images

### Database Optimization
- Firestore composite indexes
- Efficient query patterns
- Real-time listener management
- Batch operations for notifications

### API Efficiency
- Request timeouts and retries
- Smart caching strategies
- Fallback API chains
- Rate limiting compliance

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Code Standards
- Follow Dart/Flutter style guide
- Add documentation for public APIs
- Include unit tests for new features
- Ensure cross-platform compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Firebase** for backend infrastructure
- **OpenStreetMap** for free mapping services
- **Unsplash** for high-quality food imagery
- **API-Ninjas** for nutrition data
- **Open Food Facts** for community food database
- **Flutter Team** for the amazing framework

## 📞 Support

For support, email [your-email@domain.com] or create an issue in the repository.

---

**ShareMeal** - *Connecting surplus food with those who need it most* 🤝