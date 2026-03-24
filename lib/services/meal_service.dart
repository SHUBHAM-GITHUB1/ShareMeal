import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharemeal/models/food_post.dart';
import 'package:sharemeal/services/nutrition_service.dart';
import 'package:sharemeal/services/image_service.dart';
import 'package:sharemeal/services/notification_service.dart';

// ── History entry model ───────────────────────────────────────────
class HistoryEntry {
  final String id;
  final String mealId;
  final String item;
  final String qty;
  final bool isVeg;
  final DateTime completedAt;
  final String partnerName;
  final String? locationAddress;

  const HistoryEntry({
    required this.id,
    required this.mealId,
    required this.item,
    required this.qty,
    required this.isVeg,
    required this.completedAt,
    required this.partnerName,
    this.locationAddress,
  });

  factory HistoryEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HistoryEntry(
      id:              doc.id,
      mealId:          d['mealId']          as String? ?? '',
      item:            d['item']            as String? ?? '',
      qty:             d['qty']             as String? ?? '',
      isVeg:           d['isVeg']           as bool?   ?? true,
      completedAt:     (d['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      partnerName:     d['partnerName']     as String? ?? '',
      locationAddress: d['locationAddress'] as String?,
    );
  }
}

class MealService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Donor marks food as picked up → writes history for both sides ──
  Future<void> confirmPickup(String mealId) async {
    // 1. Fetch the meal
    final mealDoc = await _db.collection('meals').doc(mealId).get();
    if (!mealDoc.exists) throw Exception('Meal not found');
    final d = mealDoc.data()!;

    final donorId   = d['donorId']   as String?;
    final ngoUid    = d['claimedBy'] as String?;
    final donorName = d['donorName'] as String? ?? '';
    final item      = d['item']      as String? ?? '';
    final qty       = d['qty']       as String? ?? '';
    final isVeg     = d['isVeg']     as bool?   ?? true;
    final locAddr   = d['locationAddress'] as String?;
    final now       = Timestamp.now();

    // 2. Fetch NGO org name
    String ngoName = 'Unknown NGO';
    if (ngoUid != null && ngoUid.isNotEmpty) {
      final ngoDoc = await _db.collection('users').doc(ngoUid).get();
      if (ngoDoc.exists) {
        ngoName = (ngoDoc.data()?['orgName'] as String?) ?? 'Unknown NGO';
      }
    }

    // 3. Mark meal completed (do this first, separately — not in batch)
    await _db.collection('meals').doc(mealId).update({
      'status':      'completed',
      'completedAt': now,
    });

    // 4. Write donor history
    if (donorId != null && donorId.isNotEmpty) {
      await _db
          .collection('users')
          .doc(donorId)
          .collection('donation_history')
          .add({
        'mealId':          mealId,
        'item':            item,
        'qty':             qty,
        'isVeg':           isVeg,
        'partnerName':     ngoName,
        'locationAddress': locAddr,
        'completedAt':     now,
      });
    }

    // 5. Write NGO history
    if (ngoUid != null && ngoUid.isNotEmpty) {
      await _db
          .collection('users')
          .doc(ngoUid)
          .collection('pickup_history')
          .add({
        'mealId':          mealId,
        'item':            item,
        'qty':             qty,
        'isVeg':           isVeg,
        'partnerName':     donorName,
        'locationAddress': locAddr,
        'completedAt':     now,
      });
    }
  }

  // ── Stream donor's donation history ──────────────────────────────
  Stream<List<HistoryEntry>> streamDonationHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('donation_history')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(HistoryEntry.fromDoc).toList());
  }

  // ── Stream NGO's pickup history ───────────────────────────────────
  Stream<List<HistoryEntry>> streamPickupHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('pickup_history')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(HistoryEntry.fromDoc).toList());
  }

  // ── NGO marks food as physically picked up → pending donor approval
  Future<void> markPickedUp(String mealId) async {
    await _db.collection('meals').doc(mealId).update({
      'status':     'picked_up',
      'pickedUpAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Post a new food donation ──────────────────────────────────────
  Future<void> postMeal({
    required String item,
    required String qty,
    required bool isVeg,
    required String donorName,
    String? imageBase64,
    double? lat,
    double? lng,
    String? locationAddress,
    DateTime? expiryTime,  // ⏰ NEW: Food expiry time
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final nutrients = await NutritionService().getNutrients(item);
    final bool hasCustomImg = imageBase64 != null && imageBase64.isNotEmpty;
    final String imageUrl = hasCustomImg ? imageBase64 : await ImageService.foodImageUrl(item);

    final userDoc = await _db.collection('users').doc(uid).get();
    final donorPhone = userDoc.data()?['phone'] as String? ?? '';

    final ref = await _db.collection('meals').add({
      'donorId':         uid,
      'donorName':       donorName,
      'donorPhone':      donorPhone,
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
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime),  // ⏰ NEW
    });

    if (lat != null && lng != null) {
      await NotificationService().notifyNearbyNGOs(
        mealId:          ref.id,
        donorName:       donorName,
        item:            item,
        qty:             '$qty Kg',
        donorLat:        lat,
        donorLng:        lng,
        locationAddress: locationAddress,
        expiryTime:      expiryTime,  // ⏰ NEW: Pass expiry to notification
      );
    }
  }

  // ── Available meals stream (NGO feed) ─────────────────────────────
  Stream<List<FoodPost>> streamAvailableMeals() {
    return _db
        .collection('meals')
        .where('status', isEqualTo: 'available')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FoodPost.fromFirestore(doc)).toList());
  }

  // ── Donor's own meals: active + claimed ────────────────────────────
  Stream<List<FoodPost>> streamMyMeals() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('meals')
        .where('donorId', isEqualTo: uid)
        .where('status', whereIn: ['available', 'claimed'])
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FoodPost.fromFirestore(doc)).toList());
  }

  // ── NGO's active pickups: claimed + picked_up ─────────────────────
  // orderBy('claimedAt') + whereIn requires a composite Firestore index.
  // To avoid silent failures on fresh projects, we sort client-side.
  Stream<List<FoodPost>> streamMyClaimedMeals() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('meals')
        .where('claimedBy', isEqualTo: uid)
        .where('status', isEqualTo: 'claimed')
        .snapshots()
        .map((snap) {
          final posts = snap.docs
              .map((doc) => FoodPost.fromFirestore(doc))
              .toList();
          posts.sort((a, b) => b.time.compareTo(a.time));
          return posts;
        });
  }

  // ── NGO claims a meal ─────────────────────────────────────────────
  Future<void> claimMeal(String mealId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _db.collection('meals').doc(mealId).update({
      'status':    'claimed',
      'claimedBy': uid,
      'claimedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Donor deletes their own meal post ─────────────────────────────
  Future<void> deleteMeal(String mealId) async {
    await _db.collection('meals').doc(mealId).delete();
  }
}
