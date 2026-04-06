import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin      = FlutterLocalNotificationsPlugin();
  static bool  _initialized = false;

  static const _foodChannel = AndroidNotificationChannel(
    'sharemeal_food', 'Food Donations',
    description:    'Nearby food donation alerts',
    importance:      Importance.max,
    playSound:       true,
    enableVibration: true,
  );

  static const _claimChannel = AndroidNotificationChannel(
    'sharemeal_claim', 'Claim Alerts',
    description: 'Alerts when an NGO claims your donation',
    importance:  Importance.max,
    playSound:   true,
  );

  static const _completeChannel = AndroidNotificationChannel(
    'sharemeal_complete', 'Donation Complete',
    description: 'Alerts when a donation is fully completed',
    importance:  Importance.max,
    playSound:   true,
  );

  static Future<void> init() async {
    if (_initialized) return;
    const android  = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.createNotificationChannel(_foodChannel);
    await impl?.createNotificationChannel(_claimChannel);
    await impl?.createNotificationChannel(_completeChannel);
    await impl?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> showFoodNotification({
    required int    id,
    required String donorName,
    required String item,
    required String qty,
    required double distanceKm,
  }) async {
    await init();
    final body = '$donorName is donating $qty of $item';
    await _plugin.show(
      id,
      '🍽️ Food available nearby (${distanceKm.toStringAsFixed(1)} km)',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _foodChannel.id, _foodChannel.name,
          channelDescription: _foodChannel.description,
          importance: Importance.max, priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  static Future<void> showClaimNotification({
    required int    id,
    required String ngoName,
    required String item,
    required String qty,
  }) async {
    await init();
    final body = '$ngoName will collect $qty of $item';
    await _plugin.show(
      id,
      '✅ Your donation was claimed!',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _claimChannel.id, _claimChannel.name,
          channelDescription: _claimChannel.description,
          importance: Importance.max, priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  static Future<void> showCompleteNotification({
    required int    id,
    required String item,
    required String qty,
    required String partnerName,
    required bool   isDonor,
  }) async {
    await init();
    final title = isDonor ? '🎉 Donation complete!' : '🎉 Pickup confirmed!';
    final body  = isDonor
        ? '$partnerName collected $qty of $item. Thank you for sharing!'
        : 'Donor confirmed $qty of $item has been handed over. Great work!';
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _completeChannel.id, _completeChannel.name,
          channelDescription: _completeChannel.description,
          importance: Importance.max, priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }
}
