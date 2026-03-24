import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharemeal/models/nutrient_data.dart';
import 'package:sharemeal/services/image_service.dart';
import 'package:sharemeal/services/nutrition_service.dart';
import 'package:sharemeal/services/expiry_service.dart';

class FoodPost {
  final String id;
  final String item;
  final String qty;
  final String img;
  final bool imgIsBase64;
  final DateTime time;
  final String donor;
  final String donorPhone;
  final bool isVeg;
  final String status;
  final NutrientInfo? nutrients;
  final bool needsNutrientRefetch;
  final double? lat;
  final double? lng;
  final String? locationAddress;
  final DateTime? expiryTime;  // ⏰ NEW: When food expires

  const FoodPost({
    required this.id,
    required this.item,
    required this.qty,
    required this.img,
    required this.time,
    this.imgIsBase64 = false,
    required this.donor,
    this.donorPhone = '',
    this.isVeg    = true,
    this.status   = 'available',
    this.nutrients,
    this.needsNutrientRefetch = false,
    this.lat,
    this.lng,
    this.locationAddress,
    this.expiryTime,
  });

  bool get hasLocation => lat != null && lng != null;
  
  /// Check if food is expired
  bool get isExpired => expiryTime != null && ExpiryService.isExpired(expiryTime!);
  
  /// Check if food is expiring soon (within 30 minutes)
  bool get isExpiringSoon => expiryTime != null && ExpiryService.isExpiringSoon(expiryTime!);
  
  /// Get remaining time as formatted string (e.g., "2h 30min")
  String get remainingTimeFormatted => expiryTime != null 
    ? ExpiryService.formatRemainingTime(expiryTime!) 
    : 'No expiry set';
  
  /// Get expiry status
  ExpiryStatus get expiryStatus => expiryTime != null 
    ? ExpiryService.getExpiryStatus(expiryTime!) 
    : ExpiryStatus(
        label: 'No expiry set',
        color: 0xFF999999,
        isExpired: false,
        minutesRemaining: -1,
      );

  factory FoodPost.fromFirestore(DocumentSnapshot doc) {
    final d    = doc.data() as Map<String, dynamic>;
    final item = d['item'] as String? ?? '';

    NutrientInfo? nutrients;
    bool needsRefetch = false;

    if (d['nutrients'] is Map) {
      nutrients = NutrientInfo.fromMap(
          Map<String, dynamic>.from(d['nutrients'] as Map));
      if (nutrients.source == 'local') needsRefetch = true;
    } else {
      nutrients = NutrientData.getNutrients(item);
      needsRefetch = true;
    }

    final rawImg   = d['img']         as String? ?? '';
    final isBase64 = d['imgIsBase64'] as bool?   ?? false;

    String finalImg = rawImg;
    if (rawImg.isEmpty || (!isBase64 && rawImg.startsWith('https://loremflickr.com'))) {
      finalImg = ImageService.getFallbackImageUrl(item);
    }

    return FoodPost(
      id:          doc.id,
      item:        item,
      qty:         d['qty']            as String? ?? '',
      img:         finalImg,
      imgIsBase64: isBase64,
      donor:       d['donorName']      as String? ?? '',
      donorPhone:  d['donorPhone']     as String? ?? '',
      isVeg:       d['isVeg']          as bool?   ?? true,
      status:      d['status']         as String? ?? 'available',
      time:        (d['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nutrients:   nutrients,
      needsNutrientRefetch: needsRefetch,
      lat:             (d['lat']  as num?)?.toDouble(),
      lng:             (d['lng']  as num?)?.toDouble(),
      locationAddress: d['locationAddress'] as String?,
      expiryTime:      (d['expiryTime'] as Timestamp?)?.toDate(),  // ⏰ NEW
    );
  }

  Future<FoodPost> withFreshNutrients() async {
    final fresh = await NutritionService().getNutrients(item);
    if (fresh.source == 'api') {
      await FirebaseFirestore.instance
          .collection('meals')
          .doc(id)
          .update({'nutrients': fresh.toMap()});
    }
    return FoodPost(
      id: id, item: item, qty: qty, img: img, imgIsBase64: imgIsBase64,
      time: time, donor: donor, donorPhone: donorPhone, isVeg: isVeg, status: status,
      nutrients: fresh, needsNutrientRefetch: false,
      lat: lat, lng: lng, locationAddress: locationAddress,
      expiryTime: expiryTime,  // ⏰ NEW: Preserve expiry time
    );
  }
}