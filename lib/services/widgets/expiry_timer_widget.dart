import 'package:flutter/material.dart';
import 'package:sharemeal/services/expiry_service.dart';

/// Displays a compact expiry time indicator with status color
/// Shows: "Fresh ✓" | "Expires in 2h 30min ⏳" | "Expires Soon ⚠️" | "Expired ⏰"
class ExpiryBadge extends StatefulWidget {
  final DateTime? expiryTime;
  final bool showIcon;
  final TextStyle? textStyle;
  final EdgeInsets padding;

  const ExpiryBadge({
    Key? key,
    this.expiryTime,
    this.showIcon = true,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) : super(key: key);

  @override
  State<ExpiryBadge> createState() => _ExpiryBadgeState();
}

class _ExpiryBadgeState extends State<ExpiryBadge> {
  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    // Refresh every minute to update countdown
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _startRefreshTimer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expiryTime == null) {
      return Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (widget.showIcon) const SizedBox(width: 4),
          Text(
            'No expiry set',
            style: widget.textStyle ?? const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ]),
      );
    }

    final status = ExpiryService.getExpiryStatus(widget.expiryTime!);
    final bgColor = Color(status.color).withOpacity(0.15);
    final textColor = Color(status.color);

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (widget.showIcon) const SizedBox(width: 4),
        Text(
          status.label,
          style: (widget.textStyle ?? const TextStyle(fontSize: 12)).copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.showIcon) const SizedBox(width: 4),
      ]),
    );
  }
}

/// Displays an expiry timer with countdown and icon
/// Used in food cards to show remaining time prominently
class ExpiryTimer extends StatefulWidget {
  final DateTime? expiryTime;
  final double? width;
  final double? height;
  final bool showCountdown;

  const ExpiryTimer({
    Key? key,
    this.expiryTime,
    this.width,
    this.height = 60,
    this.showCountdown = true,
  }) : super(key: key);

  @override
  State<ExpiryTimer> createState() => _ExpiryTimerState();
}

class _ExpiryTimerState extends State<ExpiryTimer> {
  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    // Refresh every 30 seconds for smooth countdown
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _startRefreshTimer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expiryTime == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No timer', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ),
      );
    }

    final status = ExpiryService.getExpiryStatus(widget.expiryTime!);
    final bgColor = Color(status.color);
    final isExpired = status.isExpired;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.15),
          border: Border.all(color: bgColor.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showCountdown)
              Text(
                isExpired
                    ? 'Expired'
                    : ExpiryService.formatRemainingTime(widget.expiryTime!),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bgColor,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              isExpired ? '⏰' : '⏳',
              style: const TextStyle(fontSize: 14),
            ),
            if (widget.showCountdown && !isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'until expiry',
                  style: TextStyle(
                    fontSize: 9,
                    color: bgColor.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Inline expiry indicator with timestamp
/// Shows "Expires: Today 2:30 PM" with color-coded status
class ExpiryTimestamp extends StatelessWidget {
  final DateTime? expiryTime;
  final TextStyle? labelStyle;
  final TextStyle? timeStyle;
  final bool showStatus;

  const ExpiryTimestamp({
    Key? key,
    this.expiryTime,
    this.labelStyle,
    this.timeStyle,
    this.showStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expiryTime == null) {
      return Text(
        'No expiry set',
        style: labelStyle ?? TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    final status = ExpiryService.getExpiryStatus(expiryTime!);
    final timeStr = ExpiryService.formatExpiryDateTime(expiryTime!);
    final statusColor = Color(status.color);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(
        'Expires: ',
        style: labelStyle ?? TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      Text(
        timeStr,
        style: (timeStyle ?? const TextStyle(fontSize: 12)).copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (showStatus) ...[
        const SizedBox(width: 4),
        if (status.isExpired)
          const Text('⏰', style: TextStyle(fontSize: 12))
        else if (status.minutesRemaining < 30)
          const Text('⚠️', style: TextStyle(fontSize: 12))
        else if (status.minutesRemaining < 180)
          const Text('⏳', style: TextStyle(fontSize: 12))
        else
          const Text('✓', style: TextStyle(fontSize: 12, color: Color(0xFF6B9080)))
      ],
    ]);
  }
}

/// Warning banner for expired or expiring-soon food
/// Shows prominent warning when food is expired or expires in < 30 mins
class ExpiryWarningBanner extends StatelessWidget {
  final DateTime? expiryTime;
  final VoidCallback? onDismiss;

  const ExpiryWarningBanner({
    Key? key,
    this.expiryTime,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expiryTime == null) return const SizedBox.shrink();

    final status = ExpiryService.getExpiryStatus(expiryTime!);

    if (!status.isExpired && status.minutesRemaining >= 30) {
      return const SizedBox.shrink();
    }

    final bgColor = Color(status.color);
    final message = status.isExpired
        ? '⏰ This food has expired. Please remove it from the listing.'
        : '⚠️ This food expires very soon! Only ${status.minutesRemaining} minutes left.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        border: Border(
          left: BorderSide(color: bgColor, width: 4),
          top: BorderSide(color: bgColor.withOpacity(0.3)),
          bottom: BorderSide(color: bgColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: bgColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: bgColor, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick expiry selector for donor form
/// Shows preset options like "30 minutes", "1 hour", "2 hours", etc.
class ExpirySelector extends StatefulWidget {
  final DateTime? selectedExpiry;
  final ValueChanged<DateTime?> onExpirySelected;
  final bool showClearButton;

  const ExpirySelector({
    Key? key,
    this.selectedExpiry,
    required this.onExpirySelected,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  State<ExpirySelector> createState() => _ExpirySelectorState();
}

class _ExpirySelectorState extends State<ExpirySelector> {
  late DateTime? _selectedExpiry;

  @override
  void initState() {
    super.initState();
    _selectedExpiry = widget.selectedExpiry;
  }

  void _showTimePicker() async {
    final now = DateTime.now();
    final picked = await showDateTimePicker(
      context: context,
      initialDateTime: _selectedExpiry ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _selectedExpiry = picked);
      widget.onExpirySelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = ExpiryService.getSuggestedExpiryTimes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Food Expiry Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...options.map((opt) {
                final isSelected = _selectedExpiry != null &&
                    _selectedExpiry!.difference(opt.expiryTime).inMinutes.abs() < 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedExpiry = opt.expiryTime);
                      widget.onExpirySelected(opt.expiryTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF6B9080) : Colors.grey.shade200,
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      elevation: isSelected ? 2 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(opt.label, style: const TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ElevatedButton.icon(
                  onPressed: _showTimePicker,
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Custom', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedExpiry != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Set to: ${ExpiryService.formatExpiryDateTime(_selectedExpiry!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              if (widget.showClearButton)
                TextButton(
                  onPressed: () {
                    setState(() => _selectedExpiry = null);
                    widget.onExpirySelected(null);
                  },
                  child: const Text('Clear', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Helper function for DateTime picker (using showDateTimePicker dialog)
Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  // ignore: use_build_context_synchronously
  final selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDateTime),
  );

  if (selectedTime == null) return null;

  return DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
}
