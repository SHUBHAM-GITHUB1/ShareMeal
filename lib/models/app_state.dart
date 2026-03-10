import 'package:flutter/material.dart';
import 'food_post.dart';
import 'nutrient_data.dart';

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
}

class AppState with ChangeNotifier {
  UserProfile? _currentUser;
  bool _isDarkMode = false;
  final List<FoodPost> _allPosts = [];

  UserProfile? get currentUser => _currentUser;
  bool get isDarkMode => _isDarkMode;
  List<FoodPost> get allPosts => _allPosts;

  ThemeData get currentTheme => _isDarkMode
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  void setUser(UserProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void addPost(FoodPost post) {
    _allPosts.add(post);
    notifyListeners();
  }

  void removePost(int index) {
    if (index >= 0 && index < _allPosts.length) {
      _allPosts.removeAt(index);
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}