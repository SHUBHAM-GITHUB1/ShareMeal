import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharemeal/models/nutrient_data.dart';

class NutritionService {
  static const _ninjaKey = '4OpMPEqxMXFUpzzDAW61MohatdTYuLCw5kbjVsTv';
  static const _ninjaUrl = 'https://api.api-ninjas.com/v1/nutrition';
  static const _offUrl   = 'https://world.openfoodfacts.org/cgi/search.pl';

  Future<NutrientInfo> getNutrients(String foodItem) async {
    // 1️⃣ Try API Ninjas
    final ninja = await _fromNinjas(foodItem);
    if (ninja != null && _isValid(ninja, foodItem)) return ninja;

    // 2️⃣ Try Open Food Facts
    final off = await _fromOpenFoodFacts(foodItem);
    if (off != null && _isValid(off, foodItem)) return off;

    // 3️⃣ Local DB → generic default
    return NutrientData.getNutrients(foodItem) ??
        const NutrientInfo(
          calories: 150, protein: 5.0, carbs: 20.0, fat: 4.0,
          fiber: 2.0,    sugar: 3.0,   sodium: 100,  cholesterol: 0,
          servingSize: 100, source: 'local',
        );
  }

  // Zero-carb foods that genuinely have no carbs (pure proteins/fats)
  static const _zeroCarbFoods = {
    'chicken', 'mutton', 'beef', 'pork', 'lamb', 'fish', 'salmon',
    'tuna', 'prawn', 'shrimp', 'egg', 'butter', 'ghee', 'oil',
  };

  /// Valid = calories > 0 AND carbs > 0, UNLESS it's a known zero-carb food.
  bool _isValid(NutrientInfo n, String foodItem) {
    if (n.calories == 0) return false;
    if (n.carbs > 0) return true;
    // carbs == 0: only accept if it's a known zero-carb food
    final key = foodItem.toLowerCase();
    return _zeroCarbFoods.any((f) => key.contains(f));
  }

  // ── API Ninjas ────────────────────────────────────────────────────
  Future<NutrientInfo?> _fromNinjas(String foodItem) async {
    try {
      final uri = Uri.parse(
          '$_ninjaUrl?query=${Uri.encodeComponent(foodItem)}');
      final res = await http
          .get(uri, headers: {'X-Api-Key': _ninjaKey})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        if (data.isNotEmpty) return _aggregateNinja(data);
      }
    } catch (_) {}
    return null;
  }

  NutrientInfo _aggregateNinja(List<dynamic> items) {
    double cal = 0, pro = 0, carb = 0, fat = 0;
    double fib = 0, sug = 0, sod = 0, cho = 0, srv = 0;
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      cal  += (m['calories']              as num? ?? 0).toDouble();
      pro  += (m['protein_g']             as num? ?? 0).toDouble();
      carb += (m['carbohydrates_total_g'] as num? ?? 0).toDouble();
      fat  += (m['fat_total_g']           as num? ?? 0).toDouble();
      fib  += (m['fiber_g']               as num? ?? 0).toDouble();
      sug  += (m['sugar_g']               as num? ?? 0).toDouble();
      sod  += (m['sodium_mg']             as num? ?? 0).toDouble();
      cho  += (m['cholesterol_mg']        as num? ?? 0).toDouble();
      srv  += (m['serving_size_g']        as num? ?? 100).toDouble();
    }
    return NutrientInfo(
      calories: cal, protein: pro, carbs: carb, fat: fat,
      fiber: fib, sugar: sug, sodium: sod, cholesterol: cho,
      servingSize: srv, source: 'api',
    );
  }

  // ── Open Food Facts ───────────────────────────────────────────────
  Future<NutrientInfo?> _fromOpenFoodFacts(String foodItem) async {
    try {
      final uri = Uri.parse(_offUrl).replace(queryParameters: {
        'search_terms': foodItem,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '3',
        'fields': 'nutriments,product_name',
      });
      final res = await http
          .get(uri, headers: {'User-Agent': 'ShareMeal/1.0'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final products = body['products'] as List<dynamic>? ?? [];
      if (products.isEmpty) return null;

      // Pick first product that has calorie data
      for (final p in products) {
        final n = (p as Map<String, dynamic>)['nutriments']
            as Map<String, dynamic>?;
        if (n == null) continue;
        final cal = (n['energy-kcal_100g'] as num? ??
                     n['energy-kcal']      as num? ?? 0).toDouble();
        if (cal == 0) continue;

        return NutrientInfo(
          calories:    cal,
          protein:     (n['proteins_100g']      as num? ?? 0).toDouble(),
          carbs:       (n['carbohydrates_100g'] as num? ?? 0).toDouble(),
          fat:         (n['fat_100g']           as num? ?? 0).toDouble(),
          fiber:       (n['fiber_100g']         as num? ?? 0).toDouble(),
          sugar:       (n['sugars_100g']        as num? ?? 0).toDouble(),
          sodium:      ((n['sodium_100g']       as num? ?? 0) * 1000).toDouble(),
          cholesterol: (n['cholesterol_100g']   as num? ?? 0).toDouble(),
          servingSize: 100,
          source:      'api',
        );
      }
    } catch (_) {}
    return null;
  }
}
