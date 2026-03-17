import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // These are the two Firebase tools we'll use
  // FirebaseAuth  → handles login, signup, logout
  // FirebaseFirestore → saves/reads user data from the database
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // ── Who is currently logged in? ──────────────────────────────────
  // Returns the logged-in user, or null if nobody is logged in
  User? get currentUser => _auth.currentUser;

  // This is a STREAM — it keeps watching and fires every time
  // login state changes (login → logout → login etc.)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── SIGN UP (create new account) ─────────────────────────────────
  Future<User?> signUp({
    required String email,
    required String password,
    required String orgName,
    required String address,
    required String role,     // 'Donor' or 'NGO'
  }) async {
    try {
      // Step 1: Create the account in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Set their display name (shows up in Firebase console)
      await cred.user!.updateDisplayName(orgName);

      // Step 3: Save their profile info in Firestore database
      // Firebase Auth only stores email+password
      // Everything else (name, role, address) goes in Firestore
      await _saveUserToFirestore(cred.user!, orgName, address, role);

      return cred.user;

    } on FirebaseAuthException catch (e) {
      // If anything goes wrong, convert the error code to a readable message
      throw _handleError(e);
    }
  }

  // ── SIGN IN (existing account) ───────────────────────────────────
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Authenticate with Firebase
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Fetch their profile from Firestore
      // We need role, orgName etc. which aren't in Firebase Auth
      final doc = await _db
          .collection('users')        // go to 'users' collection
          .doc(cred.user!.uid)        // find doc with their unique ID
          .get();

      return doc.data() ?? {};        // return the data as a Map

    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ── GOOGLE SIGN IN ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> signInWithGoogle({
    required String role,     // role they selected on screen (Donor/NGO)
  }) async {
    try {
      // Step 1: Open Google's login popup
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;   // user cancelled

      // Step 2: Get the auth tokens from Google
      final googleAuth = await googleUser.authentication;

      // Step 3: Use those tokens to sign into Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);

      // Step 4: Check if this person has signed in before
      final doc = await _db.collection('users').doc(result.user!.uid).get();

      if (!doc.exists) {
        // First time — save their profile to Firestore
        await _saveUserToFirestore(
          result.user!,
          result.user!.displayName ?? 'User',
          '',
          role,
        );
        return {
          'email':   result.user!.email,
          'orgName': result.user!.displayName ?? 'User',
          'address': '',
          'role':    role,
        };
      }

      // Returning user — just return their existing profile
      return doc.data();

    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ── GET USER PROFILE ─────────────────────────────────────────────
  // Used by AuthWrapper to fetch role after app restarts
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── SIGN OUT ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await GoogleSignIn().signOut();   // sign out of Google too
    await _auth.signOut();
  }

  // ── PRIVATE HELPERS ──────────────────────────────────────────────

  // Saves user info to Firestore 'users' collection
  Future<void> _saveUserToFirestore(
    User user, String orgName, String address, String role,
  ) async {
    await _db.collection('users').doc(user.uid).set({
      'uid':       user.uid,
      'email':     user.email,
      'orgName':   orgName,
      'address':   address,
      'role':      role,             // 'Donor' or 'NGO'
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Converts Firebase error codes into human-readable messages
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':        return 'No account found with this email.';
      case 'wrong-password':        return 'Incorrect password.';
      case 'email-already-in-use':  return 'Email already registered.';
      case 'weak-password':         return 'Password must be at least 6 characters.';
      case 'invalid-email':         return 'Invalid email address.';
      case 'invalid-credential':    return 'Incorrect email or password.';
      default:                      return 'Something went wrong. Please try again.';
    }
  }

  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }
}
