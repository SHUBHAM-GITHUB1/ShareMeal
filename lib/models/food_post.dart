import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrient_data.dart';

class FoodPost {
  final String id;
  final String item;
  final String qty;
  final String img;
  final DateTime time;
  final String donor;
  final bool isVeg;
  final String status;
  final NutrientInfo? nutrients;

  const FoodPost({
    required this.id,
    required this.item,
    required this.qty,
    required this.img,
    required this.time,
    required this.donor,
    this.isVeg    = true,
    this.status   = 'available',
    this.nutrients,
  });

  // Converts a Firestore document into a FoodPost object
  factory FoodPost.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FoodPost(
      id:        doc.id,
      item:      d['item']      ?? '',
      qty:       d['qty']       ?? '',
      img:       d['img']       ?? '',
      donor:     d['donorName'] ?? '',
      isVeg:     d['isVeg']     ?? true,
      status:    d['status']    ?? 'available',
      time:      (d['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nutrients: NutrientData.getNutrients(d['item'] ?? ''),
    );
  }
}