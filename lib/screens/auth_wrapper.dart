import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/app_state.dart';
import 'login_screen.dart';
import 'donor_dashboard.dart';
import 'ngo_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No user → always show login, no exceptions
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        // User logged in → fetch profile and route
        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService().getUserProfile(),
          builder: (context, profileSnapshot) {

            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.data == null) {
              return const LoginScreen();
            }

            final data = profileSnapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Provider.of<AppState>(context, listen: false)
                    .setUser(UserProfile.fromMap(data));
              }
            });

            return data['role'] == 'Donor'
                ? const DonorDashboard()
                : const NGODashboard();
          },
        );
      },
    );
  }
}