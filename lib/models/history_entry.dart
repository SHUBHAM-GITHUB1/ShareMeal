import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String item;
  final String qty;
  final bool isVeg;
  final String partnerName;
  final DateTime time;
  final DateTime completedAt;

  HistoryEntry({
    required this.id,
    required this.item,
    required this.qty,
    required this.isVeg,
    required this.partnerName,
    required this.time,
    required this.completedAt,
  });

  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final completedAt = (d['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return HistoryEntry(
      id: doc.id,
      item: d['item'] as String? ?? '',
      qty: d['qty'] as String? ?? '',
      isVeg: d['isVeg'] as bool? ?? true,
      partnerName: (d['claimedByName'] as String?) ?? (d['partnerName'] as String?) ?? '',
      time: completedAt,
      completedAt: completedAt,
    );
  }
}
