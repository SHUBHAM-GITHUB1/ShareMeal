import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sharemeal/firebase_options.dart';
import 'package:sharemeal/services/local_notification_service.dart';

const _kTaskName = 'sharemeal_check_notifications';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _kTaskName) return true;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return true;

      final prefs = await SharedPreferences.getInstance();
      final db    = FirebaseFirestore.instance;

      // ── Helper: poll a collection and show notifications ──────────
      Future<void> poll({
        required String collection,
        required String prefKey,
        required Future<void> Function(Map<String, dynamic> d, String docId) show,
      }) async {
        final lastMs  = prefs.getInt(prefKey) ?? 0;
        final lastDt  = DateTime.fromMillisecondsSinceEpoch(lastMs);
        int   latest  = lastMs;

        final snap = await db
            .collection(collection)
            .where('toUid', isEqualTo: uid)
            .where('read',  isEqualTo: false)
            .orderBy('createdAt', descending: false)
            .get();

        for (final doc in snap.docs) {
          final d  = doc.data();
          final ts = (d['createdAt'] as Timestamp?)?.toDate();
          if (ts == null || !ts.isAfter(lastDt)) continue;
          await show(d, doc.id);
          if (ts.millisecondsSinceEpoch > latest) latest = ts.millisecondsSinceEpoch;
        }
        if (latest > lastMs) await prefs.setInt(prefKey, latest);
      }

      // 1. NGO food notifications
      await poll(
        collection: 'notifications',
        prefKey:    'last_ngo_notif_ts',
        show: (d, id) => LocalNotificationService.showFoodNotification(
          id:         id.hashCode,
          donorName:  d['donorName']  as String? ?? 'A donor',
          item:       d['item']       as String? ?? 'food',
          qty:        d['qty']        as String? ?? '',
          distanceKm: (d['distanceKm'] as num?)?.toDouble() ?? 0.0,
        ),
      );

      // 2. Donor claim notifications
      await poll(
        collection: 'donor_notifications',
        prefKey:    'last_donor_notif_ts',
        show: (d, id) => LocalNotificationService.showClaimNotification(
          id:      id.hashCode,
          ngoName: d['ngoName'] as String? ?? 'An NGO',
          item:    d['item']    as String? ?? 'food',
          qty:     d['qty']     as String? ?? '',
        ),
      );

      // 3. Completion notifications (both donor + NGO)
      await poll(
        collection: 'completion_notifications',
        prefKey:    'last_complete_notif_ts',
        show: (d, id) => LocalNotificationService.showCompleteNotification(
          id:          id.hashCode,
          item:        d['item']        as String? ?? 'food',
          qty:         d['qty']         as String? ?? '',
          partnerName: d['partnerName'] as String? ?? '',
          isDonor:     d['isDonor']     as bool?   ?? true,
        ),
      );
    } catch (_) {}
    return true;
  });
}

class BackgroundNotificationService {
  static Future<void> register() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      _kTaskName,
      _kTaskName,
      frequency:          const Duration(minutes: 15),
      initialDelay:       const Duration(seconds: 10),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints:        Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_kTaskName);
  }
}
