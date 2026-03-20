import 'package:intl/intl.dart';

/// Handles food expiry time calculations and formatting
class ExpiryService {
  /// Calculate remaining time in hours until expiry
  static int getRemainingHours(DateTime expiryTime) {
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) return 0;
    return expiryTime.difference(now).inHours;
  }

  /// Calculate remaining time as Duration
  static Duration getRemainingDuration(DateTime expiryTime) {
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) return Duration.zero;
    return expiryTime.difference(now);
  }

  /// Format remaining time as human-readable string
  /// Example: "2h 30min", "30min", "1d 5h"
  static String formatRemainingTime(DateTime expiryTime) {
    final remaining = getRemainingDuration(expiryTime);
    
    if (remaining.inSeconds <= 0) {
      return 'Expired';
    }
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Get expiry status with emoji and color hint
  static ExpiryStatus getExpiryStatus(DateTime expiryTime) {
    final remaining = getRemainingDuration(expiryTime);
    
    if (remaining.inSeconds <= 0) {
      return ExpiryStatus(
        label: 'Expired ⏰',
        color: 0xFFE07856,  // Coral red
        isExpired: true,
        minutesRemaining: 0,
      );
    }
    
    final minutesRemaining = remaining.inMinutes;
    
    if (minutesRemaining < 30) {
      return ExpiryStatus(
        label: 'Expires Soon ⚠️',
        color: 0xFFFF6B35,  // Orange red
        isExpired: false,
        minutesRemaining: minutesRemaining,
      );
    }
    
    if (minutesRemaining < 180) {  // 3 hours
      return ExpiryStatus(
        label: 'Expires in ${formatRemainingTime(expiryTime)} ⏳',
        color: 0xFFFFA500,  // Orange
        isExpired: false,
        minutesRemaining: minutesRemaining,
      );
    }
    
    return ExpiryStatus(
      label: 'Fresh ✓',
      color: 0xFF6B9080,  // Sage green (default theme color)
      isExpired: false,
      minutesRemaining: minutesRemaining,
    );
  }

  /// Format expiry DateTime as display string (e.g., "2:30 PM")
  static String formatExpiryTime(DateTime expiryTime) {
    return DateFormat('h:mm a').format(expiryTime);
  }

  /// Format expiry DateTime with date (e.g., "Today 2:30 PM" or "Mar 21 2:30 PM")
  static String formatExpiryDateTime(DateTime expiryTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final expiryDate = DateTime(expiryTime.year, expiryTime.month, expiryTime.day);

    String datePrefix = '';
    if (expiryDate == today) {
      datePrefix = 'Today';
    } else if (expiryDate == tomorrow) {
      datePrefix = 'Tomorrow';
    } else {
      datePrefix = DateFormat('MMM d').format(expiryTime);
    }

    final timeStr = DateFormat('h:mm a').format(expiryTime);
    return '$datePrefix $timeStr';
  }

  /// Check if food is expired
  static bool isExpired(DateTime expiryTime) {
    return DateTime.now().isAfter(expiryTime);
  }

  /// Check if food is expiring soon (within 30 minutes)
  static bool isExpiringSoon(DateTime expiryTime) {
    final remaining = getRemainingDuration(expiryTime);
    return remaining.inMinutes < 30 && !isExpired(expiryTime);
  }

  /// Calculate expiry time from hours (now + X hours)
  static DateTime calculateExpiryFromHours(int hours) {
    return DateTime.now().add(Duration(hours: hours));
  }

  /// Calculate expiry time from minutes (now + X minutes)
  static DateTime calculateExpiryFromMinutes(int minutes) {
    return DateTime.now().add(Duration(minutes: minutes));
  }

  /// Get suggested expiry times (quick pick options)
  static List<ExpiryOption> getSuggestedExpiryTimes() {
    final now = DateTime.now();
    return [
      ExpiryOption(label: '30 minutes', expiryTime: now.add(const Duration(minutes: 30))),
      ExpiryOption(label: '1 hour', expiryTime: now.add(const Duration(hours: 1))),
      ExpiryOption(label: '2 hours', expiryTime: now.add(const Duration(hours: 2))),
      ExpiryOption(label: '4 hours', expiryTime: now.add(const Duration(hours: 4))),
      ExpiryOption(label: '8 hours', expiryTime: now.add(const Duration(hours: 8))),
      ExpiryOption(label: '12 hours', expiryTime: now.add(const Duration(hours: 12))),
      ExpiryOption(label: '1 day', expiryTime: now.add(const Duration(days: 1))),
    ];
  }
}

/// Expiry status information
class ExpiryStatus {
  final String label;
  final int color;  // As 0xRRGGBB integer
  final bool isExpired;
  final int minutesRemaining;

  ExpiryStatus({
    required this.label,
    required this.color,
    required this.isExpired,
    required this.minutesRemaining,
  });
}

/// Quick expiry option for donor form
class ExpiryOption {
  final String label;
  final DateTime expiryTime;

  ExpiryOption({
    required this.label,
    required this.expiryTime,
  });
}
