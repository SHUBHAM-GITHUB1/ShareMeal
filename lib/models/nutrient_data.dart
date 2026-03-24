class NutrientInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double cholesterol;
  final double servingSize;
  final String source; // 'api' | 'local'
  final String? imageUrl;

  const NutrientInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.cholesterol,
    required this.servingSize,
    this.source = 'local',
    this.imageUrl,
  });

  // ── Firestore serialization ───────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'calories':    calories,
        'protein':     protein,
        'carbs':       carbs,
        'fat':         fat,
        'fiber':       fiber,
        'sugar':       sugar,
        'sodium':      sodium,
        'cholesterol': cholesterol,
        'servingSize': servingSize,
        'source':      source,
        'imageUrl':    imageUrl,
      };

  factory NutrientInfo.fromMap(Map<String, dynamic> m) => NutrientInfo(
        calories:    (m['calories']    as num? ?? 0).toDouble(),
        protein:     (m['protein']     as num? ?? 0).toDouble(),
        carbs:       (m['carbs']       as num? ?? 0).toDouble(),
        fat:         (m['fat']         as num? ?? 0).toDouble(),
        fiber:       (m['fiber']       as num? ?? 0).toDouble(),
        sugar:       (m['sugar']       as num? ?? 0).toDouble(),
        sodium:      (m['sodium']      as num? ?? 0).toDouble(),
        cholesterol: (m['cholesterol'] as num? ?? 0).toDouble(),
        servingSize: (m['servingSize'] as num? ?? 100).toDouble(),
        source:      m['source']       as String? ?? 'local',
        imageUrl:    m['imageUrl']     as String?,
      );

  // ── Display strings ───────────────────────────────────────────────
  String get caloriesStr    => '${calories.toStringAsFixed(0)} kcal';
  String get proteinStr     => '${protein.toStringAsFixed(1)}g';
  String get carbsStr       => '${carbs.toStringAsFixed(1)}g';
  String get fatStr         => '${fat.toStringAsFixed(1)}g';
  String get fiberStr       => '${fiber.toStringAsFixed(1)}g';
  String get sugarStr       => '${sugar.toStringAsFixed(1)}g';
  String get sodiumStr      => '${sodium.toStringAsFixed(0)}mg';
  String get cholesterolStr => '${cholesterol.toStringAsFixed(0)}mg';
  String get servingSizeStr => '${servingSize.toStringAsFixed(0)}g';
}

// ── Local fallback database (USDA / IFCT verified, per 100g) ─────────────────
class NutrientData {
  static const Map<String, NutrientInfo> _db = {
    // ── Staples ──────────────────────────────────────────────────────
    'rice':      NutrientInfo(calories: 130, protein: 2.7,  carbs: 28.2, fat: 0.3,  fiber: 0.4, sugar: 0.1, sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),
    'white rice':NutrientInfo(calories: 130, protein: 2.7,  carbs: 28.2, fat: 0.3,  fiber: 0.4, sugar: 0.1, sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),
    'brown rice':NutrientInfo(calories: 123, protein: 2.6,  carbs: 25.6, fat: 0.9,  fiber: 1.8, sugar: 0.4, sodium: 5,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),
    'roti':      NutrientInfo(calories: 297, protein: 10.9, carbs: 53.4, fat: 3.7,  fiber: 2.7, sugar: 0.4, sodium: 2,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'chapati':   NutrientInfo(calories: 297, protein: 10.9, carbs: 53.4, fat: 3.7,  fiber: 2.7, sugar: 0.4, sodium: 2,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'naan':      NutrientInfo(calories: 317, protein: 8.7,  carbs: 55.0, fat: 7.0,  fiber: 2.1, sugar: 3.0, sodium: 536, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'paratha':   NutrientInfo(calories: 326, protein: 7.5,  carbs: 47.0, fat: 12.5, fiber: 2.5, sugar: 1.0, sodium: 310, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'bread':     NutrientInfo(calories: 265, protein: 9.0,  carbs: 49.0, fat: 3.2,  fiber: 2.7, sugar: 5.0, sodium: 491, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400'),

    // ── Lentils & Legumes ─────────────────────────────────────────────
    'dal':       NutrientInfo(calories: 116, protein: 9.0,  carbs: 20.0, fat: 0.8,  fiber: 7.9, sugar: 1.8, sodium: 6,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400'),
    'lentils':   NutrientInfo(calories: 116, protein: 9.0,  carbs: 20.0, fat: 0.4,  fiber: 7.9, sugar: 1.8, sodium: 2,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400'),
    'chana':     NutrientInfo(calories: 164, protein: 8.9,  carbs: 27.4, fat: 2.6,  fiber: 7.6, sugar: 4.8, sodium: 24,  cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1606692344781-a796b306435c?w=400'),
    'rajma':     NutrientInfo(calories: 127, protein: 8.7,  carbs: 22.8, fat: 0.5,  fiber: 6.4, sugar: 0.3, sodium: 2,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1606692344781-a796b306435c?w=400'),

    // ── Vegetables & Curries ──────────────────────────────────────────
    'sabzi':     NutrientInfo(calories: 80,  protein: 2.5,  carbs: 10.0, fat: 3.5,  fiber: 3.0, sugar: 4.0, sodium: 200, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400'),
    'vegetable': NutrientInfo(calories: 65,  protein: 2.0,  carbs: 13.0, fat: 0.2,  fiber: 3.5, sugar: 5.0, sodium: 50,  cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400'),
    'curry':     NutrientInfo(calories: 120, protein: 4.0,  carbs: 10.5, fat: 7.0,  fiber: 2.0, sugar: 3.0, sodium: 400, cholesterol: 10,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400'),
    'aloo':      NutrientInfo(calories: 77,  protein: 2.0,  carbs: 17.0, fat: 0.1,  fiber: 2.2, sugar: 0.8, sodium: 6,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400'),
    'potato':    NutrientInfo(calories: 77,  protein: 2.0,  carbs: 17.0, fat: 0.1,  fiber: 2.2, sugar: 0.8, sodium: 6,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400'),
    'spinach':   NutrientInfo(calories: 23,  protein: 2.9,  carbs: 3.6,  fat: 0.4,  fiber: 2.2, sugar: 0.4, sodium: 79,  cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589647321047-9739483a91a4?w=400'),
    'palak':     NutrientInfo(calories: 23,  protein: 2.9,  carbs: 3.6,  fat: 0.4,  fiber: 2.2, sugar: 0.4, sodium: 79,  cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589647321047-9739483a91a4?w=400'),

    // ── Dairy & Protein ───────────────────────────────────────────────
    'paneer':    NutrientInfo(calories: 265, protein: 18.3, carbs: 1.2,  fat: 20.8, fiber: 0,   sugar: 1.2, sodium: 28,  cholesterol: 66,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1567188046833-2280f27b0b63?w=400'),
    'milk':      NutrientInfo(calories: 61,  protein: 3.2,  carbs: 4.8,  fat: 3.3,  fiber: 0,   sugar: 4.8, sodium: 43,  cholesterol: 10,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400'),
    'curd':      NutrientInfo(calories: 61,  protein: 3.5,  carbs: 4.7,  fat: 3.3,  fiber: 0,   sugar: 4.7, sodium: 46,  cholesterol: 13,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400'),
    'yogurt':    NutrientInfo(calories: 61,  protein: 3.5,  carbs: 4.7,  fat: 3.3,  fiber: 0,   sugar: 4.7, sodium: 46,  cholesterol: 13,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400'),
    'egg':       NutrientInfo(calories: 155, protein: 13.0, carbs: 1.1,  fat: 11.0, fiber: 0,   sugar: 1.1, sodium: 124, cholesterol: 373, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1518569656558-1f25e69d93d7?w=400'),

    // ── Meat & Fish ───────────────────────────────────────────────────
    'chicken':   NutrientInfo(calories: 165, protein: 31.0, carbs: 0.0,  fat: 3.6,  fiber: 0,   sugar: 0,   sodium: 74,  cholesterol: 85,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400'),
    'mutton':    NutrientInfo(calories: 294, protein: 25.6, carbs: 0.0,  fat: 20.9, fiber: 0,   sugar: 0,   sodium: 72,  cholesterol: 97,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400'),
    'fish':      NutrientInfo(calories: 206, protein: 22.0, carbs: 0.0,  fat: 12.0, fiber: 0,   sugar: 0,   sodium: 61,  cholesterol: 63,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400'),

    // ── Indian Dishes ─────────────────────────────────────────────────
    'biryani':   NutrientInfo(calories: 200, protein: 8.0,  carbs: 28.0, fat: 6.5,  fiber: 1.5, sugar: 2.0, sodium: 350, cholesterol: 30,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400'),
    'samosa':    NutrientInfo(calories: 308, protein: 6.0,  carbs: 32.0, fat: 17.0, fiber: 2.5, sugar: 1.5, sodium: 420, cholesterol: 5,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589307324489-32863a36b283?w=400'),
    'idli':      NutrientInfo(calories: 58,  protein: 2.0,  carbs: 11.4, fat: 0.4,  fiber: 0.5, sugar: 0.5, sodium: 150, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400'),
    'dosa':      NutrientInfo(calories: 168, protein: 3.9,  carbs: 24.0, fat: 6.5,  fiber: 1.0, sugar: 1.0, sodium: 210, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'upma':      NutrientInfo(calories: 145, protein: 3.5,  carbs: 22.0, fat: 5.0,  fiber: 1.5, sugar: 1.0, sodium: 280, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'poha':      NutrientInfo(calories: 130, protein: 2.5,  carbs: 26.0, fat: 2.5,  fiber: 1.2, sugar: 1.5, sodium: 180, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'khichdi':   NutrientInfo(calories: 124, protein: 5.0,  carbs: 22.0, fat: 2.5,  fiber: 2.0, sugar: 0.5, sodium: 220, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'puri':      NutrientInfo(calories: 336, protein: 7.0,  carbs: 44.0, fat: 15.0, fiber: 1.8, sugar: 0.5, sodium: 290, cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),

    // ── International ─────────────────────────────────────────────────
    'pasta':     NutrientInfo(calories: 158, protein: 5.8,  carbs: 30.9, fat: 0.9,  fiber: 1.8, sugar: 0.6, sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=400'),
    'pizza':     NutrientInfo(calories: 266, protein: 11.0, carbs: 33.0, fat: 10.0, fiber: 2.3, sugar: 3.6, sodium: 598, cholesterol: 17,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
    'burger':    NutrientInfo(calories: 295, protein: 17.0, carbs: 24.0, fat: 14.0, fiber: 1.3, sugar: 5.0, sodium: 396, cholesterol: 44,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
    'sandwich':  NutrientInfo(calories: 250, protein: 11.0, carbs: 33.0, fat: 8.0,  fiber: 2.0, sugar: 4.0, sodium: 480, cholesterol: 20,  servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=400'),

    // ── Fruits ────────────────────────────────────────────────────────
    'banana':    NutrientInfo(calories: 89,  protein: 1.1,  carbs: 22.8, fat: 0.3,  fiber: 2.6, sugar: 12.2,sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400'),
    'apple':     NutrientInfo(calories: 52,  protein: 0.3,  carbs: 13.8, fat: 0.2,  fiber: 2.4, sugar: 10.4,sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400'),
    'mango':     NutrientInfo(calories: 60,  protein: 0.8,  carbs: 15.0, fat: 0.4,  fiber: 1.6, sugar: 13.7,sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400'),
    'fruit':     NutrientInfo(calories: 52,  protein: 0.3,  carbs: 13.8, fat: 0.2,  fiber: 2.4, sugar: 10.4,sodium: 1,   cholesterol: 0,   servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400'),
    'gulab jamun': NutrientInfo(calories: 300, protein: 5, carbs: 45, fat: 12, fiber: 1, sugar: 35, sodium: 50, cholesterol: 20, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'jalebi': NutrientInfo(calories: 450, protein: 4, carbs: 80, fat: 15, fiber: 1, sugar: 60, sodium: 20, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'rasmalai': NutrientInfo(calories: 250, protein: 8, carbs: 30, fat: 10, fiber: 1, sugar: 25, sodium: 60, cholesterol: 30, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'gajar ka halwa': NutrientInfo(calories: 350, protein: 6, carbs: 50, fat: 15, fiber: 4, sugar: 40, sodium: 100, cholesterol: 40, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'kheer': NutrientInfo(calories: 200, protein: 5, carbs: 35, fat: 5, fiber: 1, sugar: 25, sodium: 80, cholesterol: 15, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'malpua': NutrientInfo(calories: 350, protein: 5, carbs: 50, fat: 15, fiber: 2, sugar: 40, sodium: 30, cholesterol: 10, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'rabri': NutrientInfo(calories: 250, protein: 8, carbs: 30, fat: 12, fiber: 1, sugar: 25, sodium: 100, cholesterol: 40, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'barfi': NutrientInfo(calories: 400, protein: 8, carbs: 60, fat: 15, fiber: 2, sugar: 50, sodium: 120, cholesterol: 30, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'ladoo': NutrientInfo(calories: 450, protein: 10, carbs: 65, fat: 20, fiber: 5, sugar: 50, sodium: 50, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'kachori': NutrientInfo(calories: 350, protein: 8, carbs: 40, fat: 20, fiber: 4, sugar: 5, sodium: 400, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'pakora': NutrientInfo(calories: 300, protein: 10, carbs: 25, fat: 20, fiber: 5, sugar: 5, sodium: 350, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'cutlet': NutrientInfo(calories: 250, protein: 8, carbs: 30, fat: 12, fiber: 5, sugar: 5, sodium: 300, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'chaat': NutrientInfo(calories: 250, protein: 6, carbs: 40, fat: 8, fiber: 5, sugar: 15, sodium: 500, cholesterol: 5, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'bhel puri': NutrientInfo(calories: 200, protein: 4, carbs: 35, fat: 5, fiber: 4, sugar: 10, sodium: 400, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'pani puri': NutrientInfo(calories: 200, protein: 4, carbs: 30, fat: 8, fiber: 3, sugar: 5, sodium: 300, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'sev puri': NutrientInfo(calories: 250, protein: 6, carbs: 35, fat: 10, fiber: 4, sugar: 10, sodium: 450, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'dahi puri': NutrientInfo(calories: 280, protein: 8, carbs: 40, fat: 10, fiber: 4, sugar: 15, sodium: 400, cholesterol: 10, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'pav bhaji': NutrientInfo(calories: 400, protein: 10, carbs: 50, fat: 20, fiber: 8, sugar: 10, sodium: 800, cholesterol: 20, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'misal pav': NutrientInfo(calories: 350, protein: 12, carbs: 40, fat: 15, fiber: 10, sugar: 8, sodium: 700, cholesterol: 10, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
    'thepla': NutrientInfo(calories: 250, protein: 8, carbs: 30, fat: 12, fiber: 5, sugar: 2, sodium: 300, cholesterol: 0, servingSize: 100, imageUrl: 'https://images.unsplash.com/photo-1626776878426-b3c20c021e3f?w=400'),
  };

  static NutrientInfo? getNutrients(String foodItem) {
    final key = foodItem.toLowerCase().trim();
    if (_db.containsKey(key)) return _db[key];
    // Partial match — longest key that matches wins
    String? bestKey;
    for (final k in _db.keys) {
      if (key.contains(k) || k.contains(key)) {
        if (bestKey == null || k.length > bestKey.length) bestKey = k;
      }
    }
    return bestKey != null ? _db[bestKey] : null;
  }
}
