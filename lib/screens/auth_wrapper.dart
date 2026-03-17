import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/app_state.dart';
import 'login_screen.dart';
import 'donor_dashboard.dart';
import 'ngo_dashboard.dart';

// AuthWrapper is the FIRST screen the app opens
// It checks if someone is already logged in and sends them
// to the right place automatically — no manual check needed
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {

    // StreamBuilder listens to Firebase's auth state continuously
    // It rebuilds automatically when login state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // ConnectionState.waiting means Firebase is still
        // figuring out if someone is logged in — show a loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // snapshot.hasData means a user IS logged in
        // snapshot.data is the Firebase User object
        if (!snapshot.hasData) {
          // Nobody logged in → go to Login screen
          return const LoginScreen();
        }

        // Someone IS logged in — but we need to know their ROLE
        // (Donor or NGO) to send them to the right dashboard
        // Role is stored in Firestore, not in Firebase Auth
        // So we do a second async call to fetch it
        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService().getUserProfile(),
          builder: (context, profileSnapshot) {

            // Still fetching profile from Firestore
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Something went wrong or no profile found
            if (!profileSnapshot.hasData || profileSnapshot.data == null) {
              return const LoginScreen();
            }

            final data = profileSnapshot.data!;

            // Save the profile into AppState so all screens
            // can access user info (name, email, role etc.)
            // listen: false because we're not inside build()
            // we're just setting data, not reading it
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<AppState>(context, listen: false)
                  .setUser(UserProfile.fromMap(data));
            });

            // Route to the correct dashboard based on role
            if (data['role'] == 'Donor') {
              return const DonorDashboard();
            } else {
              return const NGODashboard();
            }
          },
        );
      },
    );
  }
}