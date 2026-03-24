import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> showFoodNotification({
    required int id,
    required String donorName,
    required String item,
    required String qty,
    required double distanceKm,
  }) async {
    const details = AndroidNotificationDetails(
      'sharemeal_food',
      'Food Donations',
      channelDescription: 'Nearby food donation alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    await _plugin.show(
      id,
      '🍽️ Food available nearby (${distanceKm.toStringAsFixed(1)} km)',
      '$donorName is donating $qty of $item',
      const NotificationDetails(android: details),
    );
  }
}
