import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_post.dart';

class MealService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Donor confirms food was picked up ───────────────────────────
Future<void> confirmPickup(String mealId) async {
  await _db.collection('meals').doc(mealId).update({
    'status':      'completed',
    'completedAt': FieldValue.serverTimestamp(),
  });
}
  // ── Post a new food donation to Firestore ────────────────────────
  Future<void> postMeal({
    required String item,
    required String qty,
    required bool isVeg,
    required String donorName,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _db.collection('meals').add({
      'donorId':   uid,
      'donorName': donorName,
      'item':      item,
      'qty':       '$qty Kg',
      'isVeg':     isVeg,
      'img':       'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      'status':    'available',
      'claimedBy': null,
      'postedAt':  FieldValue.serverTimestamp(),
    });
  }

  // ── Live stream of available meals (NGO sees this) ───────────────
  // .snapshots() means it updates in REAL TIME automatically
  Stream<List<FoodPost>> streamAvailableMeals() {
    return _db
        .collection('meals')
        .where('status', isEqualTo: 'available')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => FoodPost.fromFirestore(doc)).toList());
  }

  // ── Live stream of THIS donor's meals only ───────────────────────
  Stream<List<FoodPost>> streamMyMeals() {
  final uid = _auth.currentUser!.uid;
  return _db
      .collection('meals')
      .where('donorId', isEqualTo: uid)
      .where('status', whereIn: ['available', 'claimed'])
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => FoodPost.fromFirestore(doc)).toList());
}

  // ── NGO claims a meal ────────────────────────────────────────────
  Future<void> claimMeal(String mealId) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('meals').doc(mealId).update({
      'status':    'claimed',
      'claimedBy': uid,
      'claimedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Donor deletes their own meal post ────────────────────────────
  Future<void> deleteMeal(String mealId) async {
    await _db.collection('meals').doc(mealId).delete();
  }
}