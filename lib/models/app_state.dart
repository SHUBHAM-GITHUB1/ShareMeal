import 'package:flutter/material.dart';
import 'package:sharemeal/services/auth_service.dart';

class UserProfile {
  final String email;
  final String orgName;
  final String address;
  final String role;
  final String phone;

  const UserProfile({
    required this.email,
    required this.orgName,
    required this.address,
    required this.role,
    this.phone = '',
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) => UserProfile(
        email:   data['email']   as String? ?? '',
        orgName: data['orgName'] as String? ?? '',
        address: data['address'] as String? ?? '',
        role:    data['role']    as String? ?? 'Donor',
        phone:   data['phone']   as String? ?? '',
      );
}

class AppState with ChangeNotifier {
  UserProfile? _currentUser;
  bool _isDarkMode = false;

  final _authService = AuthService();

  UserProfile? get currentUser => _currentUser;
  bool get isDarkMode => _isDarkMode;

  void setUser(UserProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
