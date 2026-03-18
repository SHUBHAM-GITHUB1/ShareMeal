import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/services/nutrition_service.dart';
import 'package:sharemeal/services/image_service.dart';
import 'package:sharemeal/services/notification_service.dart';

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
    String? imageBase64,
    double? lat,
    double? lng,
    String? locationAddress,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final nutrients = await NutritionService().getNutrients(item);
    final bool hasCustomImg = imageBase64 != null && imageBase64.isNotEmpty;
    final String imageUrl = hasCustomImg ? imageBase64 : await ImageService.foodImageUrl(item);

    final ref = await _db.collection('meals').add({
      'donorId':         uid,
      'donorName':       donorName,
      'item':            item,
      'qty':             '$qty Kg',
      'isVeg':           isVeg,
      'img':             imageUrl,
      'imgIsBase64':     hasCustomImg,
      'status':          'available',
      'claimedBy':       null,
      'postedAt':        FieldValue.serverTimestamp(),
      'nutrients':       nutrients.toMap(),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (locationAddress != null) 'locationAddress': locationAddress,
    });

    // Notify nearby NGOs if donor provided a location
    if (lat != null && lng != null) {
      await NotificationService().notifyNearbyNGOs(
        mealId:          ref.id,
        donorName:       donorName,
        item:            item,
        qty:             '$qty Kg',
        donorLat:        lat,
        donorLng:        lng,
        locationAddress: locationAddress,
      );
    }
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
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