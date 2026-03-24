import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin      = FlutterLocalNotificationsPlugin();
  static bool  _initialized = false;

  // Android channel must be created before any notification is shown.
  // If the channel doesn't exist, Android silently drops the notification.
  static const _channel = AndroidNotificationChannel(
    'sharemeal_food',          // id  — must match what showFoodNotification uses
    'Food Donations',          // name shown in system settings
    description:    'Nearby food donation alerts',
    importance:      Importance.high,
    playSound:       true,
    enableVibration: true,
  );

  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Create the channel on Android (safe to call repeatedly — no-op if exists).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Request POST_NOTIFICATIONS permission (Android 13+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> showFoodNotification({
    required int    id,
    required String donorName,
    required String item,
    required String qty,
    required double distanceKm,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance:         Importance.high,
        priority:           Priority.high,
        icon:               '@mipmap/ic_launcher',
        // Show full text even if it's long
        styleInformation: BigTextStyleInformation(
          '$donorName is donating $qty of $item',
        ),
      ),
    );

    await _plugin.show(
      id,
      '🍽️ Food available nearby (${distanceKm.toStringAsFixed(1)} km)',
      '$donorName is donating $qty of $item',
      details,
    );
  }
}
