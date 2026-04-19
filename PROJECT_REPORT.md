# ShareMeal — Project Report
### MCA Final Year Project | Flutter × Firebase Food Rescue Application

---

## 1. Team Details

| Field | Details |
|---|---|
| **Developer** | Shubham | Sindhuja | Tejo
| **Project Type** | MCA Final Year Project |
| **Platform** | Flutter (Android · iOS · Web) |
| **Backend** | Firebase (Auth + Firestore) |
| **Repository** | ShareMeal |

---

## 2. Introduction

- **ShareMeal** is a cross-platform mobile application built with Flutter that acts as a real-time bridge between food donors (restaurants, households, caterers) and NGOs/charities, enabling rapid rescue of surplus food before it goes to waste.
- The app implements a **dual-role architecture** — a Donor portal for posting surplus food and an NGO portal for discovering, claiming, and tracking pickups — each with a dedicated, role-specific dashboard and workflow.
- A **proximity-based notification engine** (Haversine formula + Firestore batch writes) automatically alerts all NGOs within a 10 km radius the moment a donor posts food with a location, ensuring time-critical donations reach the right hands fast.
- A **4-tier nutrition intelligence system** (Calorie Ninja API → Open Food Facts API → 60+ item local Indian food database → smart defaults) enriches every food post with per-100g nutritional data, giving NGOs full visibility into what they are collecting and distributing.

---

## 3. Problem Statement

India wastes approximately **68.7 million tonnes** of food annually while **194 million people** remain food insecure. The core disconnect is not a shortage of food but a **logistics and information gap**:

1. Surplus food at events, restaurants, and households expires within hours, yet no real-time channel exists to connect donors with nearby NGOs.
2. NGOs operate reactively — they have no way to know when and where food becomes available until it is too late.
3. Existing solutions are either manual (phone calls, WhatsApp groups) or require expensive infrastructure, making them inaccessible to small NGOs.
4. There is no standardised way to communicate food quantity, type, nutritional value, pickup location, and expiry window in a single, structured post.

**ShareMeal** solves all four problems through a structured, real-time, location-aware mobile platform that requires nothing more than a smartphone and a Google account.

---

## 4. References

| # | Reference |
|---|---|
| 1 | Flutter Documentation — https://docs.flutter.dev |
| 2 | Firebase Documentation (Auth, Firestore) — https://firebase.google.com/docs |
| 3 | OpenStreetMap Nominatim API — https://nominatim.org/release-docs/latest/ |
| 4 | Calorie Ninja (API Ninjas) — https://api-ninjas.com/api/nutrition |
| 5 | Open Food Facts API — https://world.openfoodfacts.org/data |
| 6 | Unsplash Developer API — https://unsplash.com/developers |
| 7 | Geolocator Flutter Package — https://pub.dev/packages/geolocator |
| 8 | flutter_map Package — https://pub.dev/packages/flutter_map |
| 9 | Google Generative AI (Gemini) — https://ai.google.dev |
| 10 | IFCT / USDA Nutritional Database — https://www.ifct.in |

---

## 5. Objectives

1. **Reduce food waste** by creating a real-time digital channel between food donors and NGOs, minimising the time between surplus generation and rescue.
2. **Automate proximity matching** — use GPS coordinates and the Haversine formula to automatically notify only the NGOs within a 10 km radius, eliminating manual outreach.
3. **Provide nutritional transparency** — enrich every food post with accurate per-100g macronutrient data using a multi-tier API fallback system so NGOs can make informed distribution decisions.
4. **Enable location-aware coordination** — integrate interactive OpenStreetMap-based map picker and pickup viewer so donors can pin exact locations and NGOs can navigate directly to them.
5. **Track the full donation lifecycle** — implement a status workflow (available → claimed → picked_up → completed) with history logs for both donors and NGOs, enabling accountability and impact measurement.
6. **Support offline resilience** — detect network loss and present an offline game screen so the app degrades gracefully rather than crashing.
7. **Deliver a production-quality UX** — implement dark/light theming, responsive layouts, animated transitions, local push notifications, and AI-assisted food identification via Gemini Vision.

---

## 6. Project File Structure

```
ShareMeal/
├── android/                          # Android platform code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/example/sharemeal/
│   │   │   │   └── MainActivity.kt   # Android entry point
│   │   │   └── AndroidManifest.xml   # Permissions: Internet, Location, Camera
│   │   ├── build.gradle.kts
│   │   └── google-services.json      # Firebase Android config
│   └── build.gradle.kts
│
├── ios/                              # iOS platform code
│   └── Runner/
│       └── Info.plist                # Location & camera permissions
│
├── web/                              # Web platform
│   ├── index.html
│   └── manifest.json                 # PWA manifest
│
├── lib/                              # ★ All Dart source code
│   │
│   ├── constants/                    # App-wide constants & theming
│   │   ├── app_constants.dart        # Shared string/numeric constants
│   │   ├── app_responsive.dart       # Responsive layout helpers (screen size)
│   │   └── app_theme.dart            # Light/dark themes, colors, gradients,
│   │                                 #   text styles, decorations
│   │
│   ├── models/                       # Data models (pure Dart classes)
│   │   ├── app_state.dart            # Global state: UserProfile, dark mode,
│   │   │                             #   logout — uses Provider/ChangeNotifier
│   │   ├── food_post.dart            # FoodPost model: Firestore ↔ Dart,
│   │   │                             #   expiry helpers, nutrient refetch
│   │   ├── history_entry.dart        # Donation/pickup history record model
│   │   ├── nutrient_data.dart        # NutrientInfo model + local DB of
│   │   │                             #   60+ Indian & international foods
│   │   └── unsplash_image.dart       # Unsplash image result model
│   │
│   ├── providers/                    # Additional Provider classes
│   │   └── image_provider.dart       # Image state provider
│   │
│   ├── screens/                      # UI screens (one file per screen)
│   │   ├── auth_wrapper.dart         # Checks Firebase auth state on app start;
│   │   │                             #   routes to Login or Dashboard
│   │   ├── splash_screen.dart        # Animated splash → AuthWrapper
│   │   ├── login_screen.dart         # Sign in / Sign up / Google OAuth;
│   │   │                             #   role toggle (Donor / NGO)
│   │   ├── donor_dashboard.dart      # Donor portal: Active & Pending tabs,
│   │   │                             #   post food form, confirm pickup,
│   │   │                             #   donation history drawer
│   │   ├── ngo_dashboard.dart        # NGO portal: Available & My Pickups tabs,
│   │   │                             #   claim food, nutrition dialog,
│   │   │                             #   pickup history drawer
│   │   ├── map_picker_screen.dart    # Interactive OSM map for donors to pin
│   │   │                             #   pickup location; place search;
│   │   │                             #   Nominatim reverse geocoding
│   │   ├── pickup_map_screen.dart    # Read-only map for NGOs to view
│   │   │                             #   pickup location of claimed food
│   │   ├── image_search_screen.dart  # Unsplash image search & selection
│   │   └── offline_game_screen.dart  # Shown when network is unavailable;
│   │                                 #   wraps app with connectivity check
│   │
│   ├── services/                     # Business logic & external integrations
│   │   │
│   │   ├── widgets/                  # Service-coupled reusable widgets
│   │   │   ├── expiry_timer_widget.dart  # ExpiryBadge, ExpiryTimestamp,
│   │   │   │                             #   ExpirySelector (quick-pick chips)
│   │   │   ├── food_card.dart            # Reusable food post card widget
│   │   │   └── food_image_picker.dart    # Camera/gallery picker widget
│   │   │
│   │   ├── auth_service.dart         # Firebase Auth: signUp, signIn,
│   │   │                             #   signInWithGoogle, signOut,
│   │   │                             #   getUserProfile, passwordReset
│   │   ├── meal_service.dart         # Firestore CRUD: postMeal, claimMeal,
│   │   │                             #   confirmPickup, deleteMeal;
│   │   │                             #   real-time streams for feeds & history
│   │   ├── notification_service.dart # Proximity notifications (Haversine);
│   │   │                             #   NGO / donor / completion notif streams;
│   │   │                             #   MealNotification, DonorNotification,
│   │   │                             #   CompletionNotification models
│   │   ├── nutrition_service.dart    # 4-tier nutrition fetch:
│   │   │                             #   Calorie Ninja → Open Food Facts
│   │   │                             #   → Local DB → defaults
│   │   ├── image_service.dart        # Unsplash API fetch; camera/gallery
│   │   │                             #   pick & Base64 encode; fallback URLs
│   │   ├── ai_food_service.dart      # Gemini 1.5 Flash Vision: identify
│   │   │                             #   food name from Base64 image
│   │   ├── expiry_service.dart       # Expiry countdown, status labels
│   │   │                             #   (Fresh/Soon/Expired), formatting
│   │   ├── local_notification_service.dart   # flutter_local_notifications:
│   │   │                                     #   food, claim, completion alerts
│   │   ├── background_notification_service.dart  # WorkManager background
│   │   │                                         #   task registration
│   │   └── unsplash_api_service.dart # Unsplash search API wrapper
│   │
│   ├── firebase_options.dart         # Auto-generated Firebase config
│   │                                 #   (per-platform API keys)
│   └── main.dart                     # App entry point: Firebase init,
│                                     #   LocalNotification init, Provider
│                                     #   setup, OfflineWrapper, MaterialApp
│
├── test/
│   └── widget_test.dart              # Flutter widget smoke test
│
├── tool/
│   └── generate_icon.py              # Script to generate app launcher icons
│
├── firestore.rules                   # Firestore security rules
├── firestore.indexes.json            # Composite index definitions
├── firebase.json                     # Firebase hosting config
├── pubspec.yaml                      # Dependencies & Flutter config
└── PROJECT_REPORT.md                 # This document
```

### Key File Relationships

```
main.dart
  └── OfflineWrapper (offline_game_screen.dart)
        └── ShareMealApp
              └── SplashScreen
                    └── AuthWrapper
                          ├── LoginScreen
                          │     ├── AuthService
                          │     ├── DonorDashboard
                          │     └── NGODashboard
                          ├── DonorDashboard
                          │     ├── MealService (stream + post + confirm)
                          │     ├── NotificationService (donor notifs)
                          │     ├── MapPickerScreen
                          │     │     └── Nominatim API (reverse geocode)
                          │     ├── NutritionService (4-tier fetch)
                          │     ├── ImageService (Unsplash + Base64)
                          │     ├── AiFoodService (Gemini Vision)
                          │     └── ExpiryService + ExpiryTimerWidget
                          └── NGODashboard
                                ├── MealService (stream + claim)
                                ├── NotificationService (NGO notifs)
                                ├── PickupMapScreen
                                └── ExpiryTimerWidget
```

---

## 7. System Architecture — Functional Modules (DFD / Block Diagram)

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         SHAREMEAL SYSTEM ARCHITECTURE                       ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│  INPUT LAYER                                                                │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │  User Login  │   │  Food Form   │   │  GPS / Map   │   │  Camera /   │ │
│  │  (Email /    │   │  (Item, Qty, │   │  (Lat, Lng,  │   │  Gallery    │ │
│  │   Google)    │   │   Veg, Expiry│   │   Address)   │   │  (Base64)   │ │
│  └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   └──────┬──────┘ │
└─────────┼──────────────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │                  │
          ▼                  ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  PROCESSING LAYER                                                           │
│                                                                             │
│  ┌─────────────────────┐    ┌──────────────────────┐                       │
│  │   AUTH MODULE        │    │   MEAL SERVICE        │                      │
│  │  ─────────────────  │    │  ──────────────────── │                      │
│  │  • Firebase Auth     │    │  • postMeal()         │                      │
│  │  • Google Sign-In    │    │  • claimMeal()        │                      │
│  │  • Role Assignment   │    │  • confirmPickup()    │                      │
│  │    (Donor / NGO)     │    │  • deleteMeal()       │                      │
│  │  • Session Persist   │    │  • streamMyMeals()    │                      │
│  └─────────────────────┘    └──────────────────────┘                       │
│                                                                             │
│  ┌─────────────────────┐    ┌──────────────────────┐                       │
│  │  NUTRITION MODULE    │    │  NOTIFICATION MODULE  │                      │
│  │  ─────────────────  │    │  ──────────────────── │                      │
│  │  Tier 1: Calorie     │    │  • Haversine distance │                      │
│  │    Ninja API         │    │    calculation        │                      │
│  │  Tier 2: Open Food   │    │  • 10 km radius query │                      │
│  │    Facts API         │    │  • Batch Firestore    │                      │
│  │  Tier 3: Local DB    │    │    writes             │                      │
│  │    (60+ Indian foods)│    │  • NGO / Donor /      │                      │
│  │  Tier 4: Defaults    │    │    Completion notifs  │                      │
│  └─────────────────────┘    └──────────────────────┘                       │
│                                                                             │
│  ┌─────────────────────┐    ┌──────────────────────┐                       │
│  │  IMAGE MODULE        │    │  EXPIRY MODULE        │                      │
│  │  ─────────────────  │    │  ──────────────────── │                      │
│  │  • Unsplash API      │    │  • Countdown timer    │                      │
│  │  • Camera / Gallery  │    │  • Status badges      │                      │
│  │  • Base64 encoding   │    │    (Fresh / Soon /    │                      │
│  │  • AI Gemini Vision  │    │     Expired)          │                      │
│  │    food identifier   │    │  • Auto-expiry alerts │                      │
│  └─────────────────────┘    └──────────────────────┘                       │
│                                                                             │
│  ┌─────────────────────┐    ┌──────────────────────┐                       │
│  │  MAP MODULE          │    │  LOCATION MODULE      │                      │
│  │  ─────────────────  │    │  ──────────────────── │                      │
│  │  • flutter_map +     │    │  • Geolocator GPS     │                      │
│  │    OpenStreetMap     │    │  • Nominatim reverse  │                      │
│  │  • Tap-to-pin        │    │    geocoding          │                      │
│  │  • Place search      │    │  • NGO location save  │                      │
│  │  • Pickup viewer     │    │  • Distance display   │                      │
│  └─────────────────────┘    └──────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
          │                  │                  │                  │
          ▼                  ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STORAGE LAYER (Cloud Firestore)                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │   /users     │   │   /meals     │   │/notifications│   │/donor_notifs│ │
│  │  uid, role,  │   │  item, qty,  │   │  toUid,      │   │  toUid,     │ │
│  │  orgName,    │   │  nutrients,  │   │  mealId,     │   │  ngoName,   │ │
│  │  lat, lng    │   │  lat, lng,   │   │  distanceKm, │   │  item, qty  │ │
│  │              │   │  expiryTime  │   │  read        │   │             │ │
│  └──────────────┘   └──────────────┘   └──────────────┘   └─────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  OUTPUT LAYER                                                               │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │  Donor       │   │  NGO Live    │   │  Push        │   │  History    │ │
│  │  Dashboard   │   │  Feed        │   │  Notifications│  │  Logs       │ │
│  │  (Active /   │   │  (Available /│   │  (Local +    │   │  (Donation/ │ │
│  │   Pending)   │   │   My Pickups)│   │   Firestore) │   │   Pickup)   │ │
│  └──────────────┘   └──────────────┘   └──────────────┘   └─────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram (Level 1)

```
  [DONOR]                                              [NGO]
     │                                                   │
     │  1. Login (Firebase Auth)                         │  1. Login (Firebase Auth)
     │  2. Fill food form                                │  2. GPS location saved
     │  3. Pick map location                             │     to Firestore
     │  4. Set expiry time                               │
     │                                                   │
     ▼                                                   │
  [postMeal()]                                           │
     │                                                   │
     ├──► NutritionService.getNutrients()                │
     │       └─► Calorie Ninja API                       │
     │       └─► Open Food Facts API                     │
     │       └─► Local DB (60+ foods)                    │
     │       └─► Default minimums                        │
     │                                                   │
     ├──► ImageService.foodImageUrl()                    │
     │       └─► Unsplash API / Base64                   │
     │                                                   │
     ├──► Firestore: /meals (add doc)                    │
     │                                                   │
     └──► NotificationService.notifyNearbyNGOs()         │
              │                                          │
              │  Query all NGOs with lat/lng             │
              │  Haversine(donorLat, ngoLat) ≤ 10km      │
              │  Batch write to /notifications           │
              │                                          ▼
              └─────────────────────────────► [NGO receives push notification]
                                                         │
                                                         ▼
                                              [NGO Dashboard — Live Feed]
                                                         │
                                              ├─► View nutrition facts
                                              ├─► View pickup map
                                              ├─► Claim food
                                              │       └─► notifyDonor()
                                              └─► Mark picked up
                                                      └─► confirmPickup()
                                                              └─► Write history
                                                                  both sides
```

---

### 6.1 Module Extensions — Highlighted with Syllabus Mapping

| Module | Key Classes / Files | Syllabus Topic Mapping |
|---|---|---|
| **Authentication** | `auth_service.dart`, `login_screen.dart` | Security, OAuth 2.0, Session Management, Role-Based Access Control |
| **State Management** | `app_state.dart` (Provider + ChangeNotifier) | Design Patterns (Observer), MVC/MVVM Architecture |
| **Real-time Database** | `meal_service.dart`, `notification_service.dart` | NoSQL Databases, Firestore Streams, CRUD Operations |
| **Geolocation & Maps** | `map_picker_screen.dart`, `pickup_map_screen.dart` | GIS, REST APIs, Coordinate Systems, Reverse Geocoding |
| **Proximity Algorithm** | `notification_service.dart` → `_distanceKm()` | Computational Geometry, Haversine Formula, Spherical Trigonometry |
| **API Integration** | `nutrition_service.dart`, `image_service.dart` | RESTful Web Services, JSON Parsing, HTTP Client, Fallback Chains |
| **AI / ML Integration** | `ai_food_service.dart` | Machine Learning APIs, Multimodal AI (Gemini Vision), Prompt Engineering |
| **Push Notifications** | `local_notification_service.dart`, `background_notification_service.dart` | Mobile OS Services, Background Processing, WorkManager |
| **Data Modelling** | `food_post.dart`, `nutrient_data.dart`, `history_entry.dart` | Object-Oriented Design, Serialization, Factory Patterns |
| **Expiry Management** | `expiry_service.dart`, `expiry_timer_widget.dart` | Real-time UI, Timer-based State, DateTime Arithmetic |
| **Offline Handling** | `offline_game_screen.dart`, `connectivity_plus` | Network Programming, Graceful Degradation, UX Design |
| **Responsive UI** | `app_responsive.dart`, `app_theme.dart` | Human-Computer Interaction, Adaptive Layouts, Material Design |

---

## 7. Tools & Technology Stack

### Frontend Framework
| Tool | Version | Purpose |
|---|---|---|
| Flutter | 3.x (SDK ^3.10.0) | Cross-platform UI framework (Android, iOS, Web) |
| Dart | ^3.10.0 | Programming language |
| Material Design 3 | Built-in | UI component system |
| Provider | ^6.1.1 | Lightweight state management (ChangeNotifier) |

### Backend & Cloud Services
| Service | Purpose |
|---|---|
| Firebase Authentication | Email/password + Google OAuth sign-in, session persistence |
| Cloud Firestore | Real-time NoSQL database — meals, users, notifications, history |
| Firebase Hosting | Web deployment target |

### APIs & External Services
| API | Usage |
|---|---|
| Calorie Ninja (API Ninjas) | Primary nutrition data — per-100g macros for any food query |
| Open Food Facts | Secondary nutrition source — community-driven food database |
| Unsplash API | Dynamic food imagery fetched by food name |
| OpenStreetMap Nominatim | Free reverse geocoding (lat/lng → human-readable address) |
| Google Gemini 1.5 Flash | AI food identification from camera/gallery images |

### Key Flutter Packages
| Package | Version | Role |
|---|---|---|
| `flutter_map` | ^7.0.2 | Interactive OpenStreetMap tiles + marker layer |
| `latlong2` | ^0.9.1 | Geographic coordinate types |
| `geolocator` | ^13.0.2 | Device GPS, permission handling |
| `http` | ^1.2.0 | REST API calls (Nominatim, Calorie Ninja, Unsplash) |
| `firebase_core` | ^3.6.0 | Firebase SDK initialisation |
| `firebase_auth` | ^5.3.1 | Authentication |
| `cloud_firestore` | ^5.4.4 | Firestore CRUD + real-time streams |
| `google_sign_in` | ^6.2.1 | Google OAuth flow |
| `image_picker` | ^1.1.2 | Camera and gallery access |
| `flutter_local_notifications` | ^18.0.1 | On-device push notifications |
| `google_generative_ai` | ^0.4.6 | Gemini Vision API for food identification |
| `connectivity_plus` | ^6.0.3 | Network state detection (offline mode) |
| `workmanager` | 0.9.0+3 | Background task scheduling |
| `intl` | ^0.19.0 | Date/time formatting, internationalisation |
| `cached_network_image` | ^3.3.1 | Efficient network image loading with cache |

### Development Tools
| Tool | Purpose |
|---|---|
| Android Studio / VS Code | IDE |
| Firebase CLI | Firestore rules deployment, hosting |
| flutter_launcher_icons | App icon generation for all platforms |
| flutter_lints | Static analysis and code quality |

---

## 8. Output Screenshots

> Screenshots are taken from the running application. Descriptions below correspond to each screen.

### 8.1 Splash & Login Screen
```
┌─────────────────────────┐
│  ❤️ ShareMeal            │
│  REDUCING WASTE ·        │
│  FEEDING HOPE            │
│                          │
│  [1.3B tonnes wasted]    │
│  [828M hungry/day]       │
│  [2hr rescue window]     │
│                          │
│  ○ Donor   ○ NGO         │
│  ┌──────────────────┐    │
│  │ Email            │    │
│  └──────────────────┘    │
│  ┌──────────────────┐    │
│  │ Password         │    │
│  └──────────────────┘    │
│  [ SIGN IN ]             │
│  ─── or continue with ── │
│  [ G  Google ]           │
└─────────────────────────┘
```
- Animated hero section with pulsing logo rings
- Real-world food waste statistics displayed
- Role toggle (Donor / NGO) before login
- Google Sign-In + Email/Password support
- Forgot password flow with email reset

### 8.2 Donor Dashboard
```
┌─────────────────────────┐
│ 🍽 Donor Portal          │
│ [Active] [Pending]       │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ [Food Image]        │ │
│ │ Biryani        ●Veg │ │
│ │ 5 Kg  10:30 AM      │ │
│ │ ⏳ Expires in 2h    │ │
│ │ Cal·200 Pro·8g      │ │
│ │ 📍 MG Road, Pune    │ │
│ │ [Active ●]  [🗑]    │ │
│ └─────────────────────┘ │
│                          │
│         [+ Post Surplus] │
└─────────────────────────┘
```
- Active tab: live food posts with status badges
- Pending tab: claimed items awaiting pickup confirmation
- Expiry countdown badge on each card
- Nutrient chips (Cal, Protein, Carbs, Fat)
- Delete post and confirm pickup actions

### 8.3 Post Food Form (Bottom Sheet)
```
┌─────────────────────────┐
│ 📡 Broadcast Donation    │
│ Notify nearby NGOs       │
│                          │
│ FOOD ITEM                │
│ [🍴 e.g. Rice, Bread]    │
│                          │
│ QUANTITY (KG)            │
│ [⚖ e.g. 5]              │
│                          │
│ FOOD PHOTO               │
│ [📷 Tap to add photo]    │
│                          │
│ PICKUP LOCATION          │
│ [📍 Set on map ›]        │
│                          │
│ EXPIRY TIME              │
│ [30min][1h][2h][4h][8h]  │
│                          │
│ ○ Veg   ○ Non-Veg        │
│                          │
│ [Cancel] [Post Donation] │
└─────────────────────────┘
```
- AI auto-identifies food from uploaded photo (Gemini Vision)
- Expiry quick-pick chips (30 min to 1 day)
- Map picker integration for precise location
- Nutrition auto-fetched on post

### 8.4 NGO Live Feed
```
┌─────────────────────────┐
│ 🍽 NGO Live Feed  ● LIVE │
│ [Available] [My Pickups] │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ [Food Image]        │ │
│ │ ●Veg        📍1.2km │ │
│ │ Dal Chawal    5 Kg  │ │
│ │ From: Sharma Caterers│ │
│ │ ⏳ Expires in 1h 20m│ │
│ │ Cal·116 Pro·9g      │ │
│ │ 📍 Koregaon Park    │ │
│ │ [ CLAIM FOOD ]      │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```
- Real-time Firestore stream of available donations
- Distance from NGO's current GPS position shown
- Expiry warning banner for items expiring < 30 min
- Full nutrition facts dialog on tap
- Map view button to navigate to pickup

### 8.5 Interactive Map Picker
```
┌─────────────────────────┐
│ ← Pick Pickup Location  │
│ [🔍 Search place...]    │
│                          │
│  ┌───────────────────┐  │
│  │                   │  │
│  │   [OSM Map Tiles] │  │
│  │                   │  │
│  │      📍           │  │
│  │   (green pin)     │  │
│  │                   │  │
│  └───────────────────┘  │
│                          │
│ 📍 Selected Location     │
│ 12 MG Road, Koregaon     │
│ Park, Pune 411001        │
│ Maharashtra, India       │
│                          │
│ Tap map to move pin      │
└─────────────────────────┘
```
- OpenStreetMap tiles (free, no Google API key)
- Tap-to-pin with animated food marker
- Place search via Nominatim
- Structured address breakdown (street, area, city, PIN, state)
- "My Location" GPS button

### 8.6 Notification System
```
┌─────────────────────────┐
│ 🔔 Notifications         │
├─────────────────────────┤
│ 🍽 New food nearby!      │
│ Sharma Caterers posted   │
│ Dal Chawal (5 Kg)        │
│ 📍 1.2 km away           │
│ ⏰ Expires in 2h         │
│ 2 min ago                │
├─────────────────────────┤
│ ✅ NGO claimed your food │
│ Hope Foundation claimed  │
│ Biryani (3 Kg)           │
│ 5 min ago                │
└─────────────────────────┘
```
- NGO notifications: new food within 10 km radius
- Donor notifications: NGO claimed their food
- Completion notifications: pickup confirmed by both sides
- Local push notifications via flutter_local_notifications

---

## 9. Validation

### 9.1 Input Validation

| Field | Validation Rule | Implementation |
|---|---|---|
| Food Item | Min 3 characters, non-empty | `TextFormField` validator in `donor_dashboard.dart` |
| Quantity | Positive integer only | `FilteringTextInputFormatter.digitsOnly` + range check |
| Email | RFC-compliant regex | `RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$')` |
| Password | Minimum 8 characters | Length check in `_FocusField` validator |
| Organization Name | Non-empty | Required field validator |
| Phone Number | Non-empty | Required field validator |
| Address | Non-empty | Required field validator |

### 9.2 Authentication Validation

| Scenario | Handling |
|---|---|
| Wrong password | `FirebaseAuthException` → "Incorrect password." |
| User not found | `FirebaseAuthException` → "No account found with this email." |
| Email already in use | `FirebaseAuthException` → "Email already registered." |
| Weak password | `FirebaseAuthException` → "Password must be at least 6 characters." |
| Invalid email format | `FirebaseAuthException` → "Invalid email address." |
| Google Sign-In cancelled | Returns `null`, no navigation |

### 9.3 API & Network Validation

| Layer | Validation |
|---|---|
| Calorie Ninja API | HTTP 200 check + non-empty list check; falls back to Open Food Facts on failure |
| Open Food Facts | HTTP 200 + `energy-kcal_100g > 0` check; falls back to local DB |
| Local Nutrition DB | Exact key match → partial/longest-key match → returns `null` |
| Unsplash API | HTTP 200 + non-empty results; falls back to static food-name map → generic image |
| Nominatim Geocoding | HTTP 200 + `address` field check; falls back to raw coordinates string |
| All API calls | `.timeout(Duration(seconds: 8))` with `catch(_)` silent fallback |

### 9.4 Business Logic Validation

| Rule | Implementation |
|---|---|
| Only authenticated users can post | `_auth.currentUser?.uid` null check in `MealService.postMeal()` |
| Only available meals can be claimed | Firestore `where('status', isEqualTo: 'available')` query |
| Only the donor can confirm pickup | `confirmPickup()` reads `donorId` from meal doc and writes to that user's history |
| NGO location required for proximity notifications | `ngoLat == null \|\| ngoLng == null` → skip in `notifyNearbyNGOs()` |
| Nutrient values never zero | `_ensureMinimum(value, minimum)` enforces floor values across all API tiers |
| Expiry status computed in real-time | `ExpiryService.getExpiryStatus()` called on every card render with live `DateTime.now()` |
| Duplicate notifications prevented | `Set<String> _seenIds` in dashboard state tracks already-shown notification IDs |

### 9.5 Test Coverage

```bash
# Static analysis
flutter analyze
# Result: No issues found (0 errors, 0 warnings)

# Unit tests
flutter test
# test/widget_test.dart — app smoke test passes

# Manual test scenarios validated:
# ✅ Donor signup → post food → NGO notified → NGO claims → Donor confirms → History logged
# ✅ Offline detection → offline game screen shown → reconnect → normal flow resumes
# ✅ Food expiry countdown → "Expires Soon" badge at < 30 min → "Expired" badge at 0
# ✅ AI food identification from camera image → food name auto-filled in form
# ✅ Map picker → tap location → address resolved → saved to Firestore with meal
# ✅ Dark mode toggle → persists across screens within session
```

---

*ShareMeal — Connecting surplus food with those who need it most* 🤝
