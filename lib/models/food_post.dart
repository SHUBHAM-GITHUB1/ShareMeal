import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharemeal/models/nutrient_data.dart';

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
    final d    = doc.data() as Map<String, dynamic>;
    final item = d['item'] as String? ?? '';
    NutrientInfo? nutrients;
    if (d['nutrients'] is Map) {
      final stored = NutrientInfo.fromMap(
          Map<String, dynamic>.from(d['nutrients'] as Map));
      // If stored carbs is 0 but calories > 0, the record was saved with a
      // bad API response — patch carbs from local DB if available.
      if (stored.carbs == 0 && stored.calories > 0) {
        final local = NutrientData.getNutrients(item);
        nutrients = local != null
            ? NutrientInfo(
                calories:    stored.calories,
                protein:     stored.protein,
                carbs:       local.carbs,
                fat:         stored.fat,
                fiber:       local.fiber > 0 ? local.fiber : stored.fiber,
                sugar:       local.sugar > 0 ? local.sugar : stored.sugar,
                sodium:      stored.sodium > 0 ? stored.sodium : local.sodium,
                cholesterol: stored.cholesterol,
                servingSize: stored.servingSize,
                source:      stored.source,
              )
            : stored;
      } else {
        nutrients = stored;
      }
    } else {
      nutrients = NutrientData.getNutrients(item);
    }
    return FoodPost(
      id:        doc.id,
      item:      item,
      qty:       d['qty']       as String? ?? '',
      img:       d['img']       as String? ?? '',
      donor:     d['donorName'] as String? ?? '',
      isVeg:     d['isVeg']     as bool?   ?? true,
      status:    d['status']    as String? ?? 'available',
      time:      (d['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nutrients: nutrients,
    );
  }
}