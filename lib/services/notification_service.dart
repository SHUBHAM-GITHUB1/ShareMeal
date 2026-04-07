import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static const double _radiusKm = 10.0;

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Haversine distance (km) between two lat/lng points ──────────
  static double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;

  // ── Save / update this user's location in their Firestore profile ─
  Future<void> saveMyLocation(double lat, double lng) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'lat': lat, 'lng': lng});
  }

  // ── Called right after a donor posts a meal ──────────────────────
  // Finds all NGOs within 10 km and writes a notification doc for each.
  Future<void> notifyNearbyNGOs({
    required String mealId,
    required String donorName,
    required String item,
    required String qty,
    required double donorLat,
    required double donorLng,
    String? locationAddress,
    DateTime? expiryTime,  // ⏰ NEW: Food expiry time
  }) async {
    // Fetch all NGO profiles that have a stored location
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'NGO')
        .get();

    final batch = _db.batch();
    int count = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final ngoLat = (data['lat'] as num?)?.toDouble();
      final ngoLng = (data['lng'] as num?)?.toDouble();
      if (ngoLat == null || ngoLng == null) continue;

      final dist = _distanceKm(donorLat, donorLng, ngoLat, ngoLng);
      if (dist > _radiusKm) continue;

      final ref = _db.collection('notifications').doc();
      batch.set(ref, {
        'toUid':           doc.id,
        'mealId':          mealId,
        'donorName':       donorName,
        'item':            item,
        'qty':             qty,
        'distanceKm':      double.parse(dist.toStringAsFixed(2)),
        'locationAddress': locationAddress,
        'donorLat':        donorLat,
        'donorLng':        donorLng,
        'read':            false,
        'createdAt':       FieldValue.serverTimestamp(),
        if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime),  // ⏰ NEW
      });
      count++;
    }

    if (count > 0) await batch.commit();
  }

  // ── Stream of notifications for the current NGO (unread only) ─────
  Stream<List<MealNotification>> streamMyNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) {
          final list = s.docs.map(MealNotification.fromDoc).toList();
          list.sort((a, b) => b.time.compareTo(a.time));
          return list;
        });
  }

  // ── Mark a single NGO notification as read ────────────────────
  Future<void> markRead(String id) =>
      _db.collection('notifications').doc(id).update({'read': true});

  Future<void> markDonorNotifRead(String id) =>
      _db.collection('donor_notifications').doc(id).update({'read': true});

  Future<void> markCompletionRead(String id) =>
      _db.collection('completion_notifications').doc(id).update({'read': true});

  // ── Mark all NGO notifications as read ─────────────────────────
  Future<void> markAllRead(List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_db.collection('notifications').doc(id), {'read': true});
    }
    await batch.commit();
  }

  // ── Called when an NGO claims a meal — notifies the donor ────────
  Future<void> notifyDonor({
    required String donorId,
    required String mealId,
    required String ngoName,
    required String item,
    required String qty,
  }) async {
    await _db.collection('donor_notifications').add({
      'toUid':    donorId,
      'mealId':   mealId,
      'ngoName':  ngoName,
      'item':     item,
      'qty':      qty,
      'read':     false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Stream of donor notifications (unread only) ─────────────────
  Stream<List<DonorNotification>> streamMyDonorNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('donor_notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) {
          final list = s.docs.map(DonorNotification.fromDoc).toList();
          list.sort((a, b) => b.time.compareTo(a.time));
          return list;
        });
  }

  // ── Called when donor confirms pickup — notifies both donor + NGO ───
  Future<void> notifyCompletion({
    required String donorId,
    required String ngoUid,
    required String mealId,
    required String item,
    required String qty,
    required String donorName,
    required String ngoName,
  }) async {
    final batch = _db.batch();
    // Notify donor
    final donorRef = _db.collection('completion_notifications').doc();
    batch.set(donorRef, {
      'toUid':       donorId,
      'mealId':      mealId,
      'item':        item,
      'qty':         qty,
      'partnerName': ngoName,
      'isDonor':     true,
      'read':        false,
      'createdAt':   FieldValue.serverTimestamp(),
    });
    // Notify NGO
    final ngoRef = _db.collection('completion_notifications').doc();
    batch.set(ngoRef, {
      'toUid':       ngoUid,
      'mealId':      mealId,
      'item':        item,
      'qty':         qty,
      'partnerName': donorName,
      'isDonor':     false,
      'read':        false,
      'createdAt':   FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  // ── Stream completion notifications (unread only) ────────────────
  Stream<List<CompletionNotification>> streamMyCompletionNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('completion_notifications')
        .where('toUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) {
          final list = s.docs.map(CompletionNotification.fromDoc).toList();
          list.sort((a, b) => b.time.compareTo(a.time));
          return list;
        });
  }
}

// ── Notification model ────────────────────────────────────────────
class MealNotification {
  final String id;
  final String mealId;
  final String donorName;
  final String item;
  final String qty;
  final double distanceKm;
  final String? locationAddress;
  final double? donorLat;
  final double? donorLng;
  final bool read;
  final DateTime time;
  final DateTime? expiryTime;  // ⏰ NEW: Food expiry time

  const MealNotification({
    required this.id,
    required this.mealId,
    required this.donorName,
    required this.item,
    required this.qty,
    required this.distanceKm,
    this.locationAddress,
    this.donorLat,
    this.donorLng,
    required this.read,
    required this.time,
    this.expiryTime,
  });

  factory MealNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MealNotification(
      id:              doc.id,
      mealId:          d['mealId']          as String? ?? '',
      donorName:       d['donorName']        as String? ?? '',
      item:            d['item']             as String? ?? '',
      qty:             d['qty']              as String? ?? '',
      distanceKm:      (d['distanceKm'] as num?)?.toDouble() ?? 0,
      locationAddress: d['locationAddress']  as String?,
      donorLat:        (d['donorLat']   as num?)?.toDouble(),
      donorLng:        (d['donorLng']   as num?)?.toDouble(),
      read:            d['read']             as bool?   ?? false,
      time:            (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      expiryTime:      (d['expiryTime'] as Timestamp?)?.toDate(),
    );
  }
}

// ── Donor notification model ──────────────────────────────────────
class DonorNotification {
  final String id;
  final String mealId;
  final String ngoName;
  final String item;
  final String qty;
  final bool read;
  final DateTime time;

  const DonorNotification({
    required this.id,
    required this.mealId,
    required this.ngoName,
    required this.item,
    required this.qty,
    required this.read,
    required this.time,
  });

  factory DonorNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonorNotification(
      id:       doc.id,
      mealId:   d['mealId']  as String? ?? '',
      ngoName:  d['ngoName'] as String? ?? '',
      item:     d['item']    as String? ?? '',
      qty:      d['qty']     as String? ?? '',
      read:     d['read']    as bool?   ?? false,
      time:     (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

// ── Completion notification model ────────────────────────────────
class CompletionNotification {
  final String id;
  final String mealId;
  final String item;
  final String qty;
  final String partnerName;
  final bool   isDonor;
  final bool   read;
  final DateTime time;

  const CompletionNotification({
    required this.id,
    required this.mealId,
    required this.item,
    required this.qty,
    required this.partnerName,
    required this.isDonor,
    required this.read,
    required this.time,
  });

  factory CompletionNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CompletionNotification(
      id:          doc.id,
      mealId:      d['mealId']      as String? ?? '',
      item:        d['item']        as String? ?? '',
      qty:         d['qty']         as String? ?? '',
      partnerName: d['partnerName'] as String? ?? '',
      isDonor:     d['isDonor']     as bool?   ?? true,
      read:        d['read']        as bool?   ?? false,
      time:        (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
