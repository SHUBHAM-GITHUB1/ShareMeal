import 'package:flutter/material.dart';
import '../services/auth_service.dart';



// UserProfile is just a simple container for the logged-in user's info
// We use this throughout the app to show name, email, role etc.
class UserProfile {
  final String email;
  final String orgName;
  final String address;
  final String role;

  const UserProfile({
    required this.email,
    required this.orgName,
    required this.address,
    required this.role,
  });

  // This is a factory constructor — it builds a UserProfile from
  // a Firestore map (the data we get back from the database)
  factory UserProfile.fromMap(Map<String, dynamic> data) => UserProfile(
    email:   data['email']   ?? '',   // ?? '' means "if null, use empty string"
    orgName: data['orgName'] ?? '',
    address: data['address'] ?? '',
    role:    data['role']    ?? 'Donor',
  );
}

// AppState is the "shared memory" of your app
// Any widget can read from it or update it
// When it changes, all listening widgets automatically rebuild
class AppState with ChangeNotifier {
  UserProfile? _currentUser;   // null = nobody logged in
  bool _isDarkMode = false;
  final _authService = AuthService();

  // Temporary stubs — will be replaced in Phase 3
  final List<dynamic> allPosts = [];
  void addPost(dynamic post) {}//dflsjdlfijdslfjlsdfa
  void removePost(int index) {}

  // ── Getters (read-only access to private variables) ──────────────
  UserProfile? get currentUser => _currentUser;
  bool get isDarkMode => _isDarkMode;

  // ── Set user after login ─────────────────────────────────────────
  // Called right after login/signup succeeds
  void setUser(UserProfile user) {
    _currentUser = user;
    notifyListeners();   // tells all widgets "hey, data changed, rebuild!"
  }

  // ── Toggle dark/light mode ───────────────────────────────────────
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ── Logout ───────────────────────────────────────────────────────
  // Signs out from Firebase AND clears local state
  Future<void> logout() async {
    await _authService.signOut();   // Firebase signout
    _currentUser = null;            // clear local user
    notifyListeners();              // rebuild all widgets
  }
}