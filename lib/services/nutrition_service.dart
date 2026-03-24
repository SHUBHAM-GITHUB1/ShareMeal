import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharemeal/models/nutrient_data.dart';

class NutritionService {
  static const _ninjaKey = '4OpMPEqxMXFUpzzDAW61MohatdTYuLCw5kbjVsTv';
  static const _ninjaUrl = 'https://api.api-ninjas.com/v1/nutrition';
  static const _offUrl   = 'https://world.openfoodfacts.org/cgi/search.pl';

  Future<NutrientInfo> getNutrients(String foodItem) async {
    final cleanItem = foodItem.trim();
    if (cleanItem.isEmpty) {
      return _getMinimumNutrients();
    }

    // 1️⃣ Try API Ninjas (Calorie Ninja)
    final ninja = await _fromNinjas(cleanItem);
    if (ninja != null && ninja.calories > 0) {
      return ninja;
    }

    // 2️⃣ Try Open Food Facts
    final off = await _fromOpenFoodFacts(cleanItem);
    if (off != null && off.calories > 0) {
      return off;
    }

    // 3️⃣ Local DB with minimum value enforcement
    final localData = NutrientData.getNutrients(cleanItem);
    if (localData != null) {
      return NutrientInfo(
        calories: _ensureMinimum(localData.calories, 50),
        protein: _ensureMinimum(localData.protein, 1.0),
        carbs: _ensureMinimum(localData.carbs, 5.0),
        fat: _ensureMinimum(localData.fat, 0.5),
        fiber: _ensureMinimum(localData.fiber, 0.5),
        sugar: _ensureMinimum(localData.sugar, 1.0),
        sodium: _ensureMinimum(localData.sodium, 5.0),
        cholesterol: localData.cholesterol,
        servingSize: 100, // Always per 100g
        source: 'local',
      );
    }

    // 4️⃣ Generic default with guaranteed minimums
    return _getMinimumNutrients();
  }

  // ── API Ninjas (Calorie Ninja) ───────────────────────────────────
  Future<NutrientInfo?> _fromNinjas(String foodItem) async {
    try {
      final query = foodItem.trim().toLowerCase();
      final uri = Uri.parse('$_ninjaUrl?query=${Uri.encodeComponent(query)}');
      
      final res = await http.get(
        uri, 
        headers: {
          'X-Api-Key': _ninjaKey,
          'Content-Type': 'application/json',
        }
      ).timeout(const Duration(seconds: 8));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        if (data.isNotEmpty) {
          return _aggregateNinja(data);
        }
      } else if (res.statusCode == 400) {
        // Bad request - try with simplified query
        final simplified = query.split(' ').first;
        if (simplified != query && simplified.length > 2) {
          return _fromNinjasSimplified(simplified);
        }
      }
    } catch (_) {
      // Network error - continue to fallback
    }
    return null;
  }

  // ── Retry with simplified query ──────────────────────────────────
  Future<NutrientInfo?> _fromNinjasSimplified(String simpleQuery) async {
    try {
      final uri = Uri.parse('$_ninjaUrl?query=${Uri.encodeComponent(simpleQuery)}');
      final res = await http.get(
        uri,
        headers: {
          'X-Api-Key': _ninjaKey,
          'Content-Type': 'application/json',
        }
      ).timeout(const Duration(seconds: 6));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        if (data.isNotEmpty) return _aggregateNinja(data);
      }
    } catch (_) {}
    return null;
  }

  NutrientInfo _aggregateNinja(List<dynamic> items) {
    double cal = 0, pro = 0, carb = 0, fat = 0;
    double fib = 0, sug = 0, sod = 0, cho = 0;
    int validItems = 0;
    
    for (final raw in items) {
      final m = raw as Map<String, dynamic>;
      final itemCal = (m['calories'] as num? ?? 0).toDouble();
      final servingSize = (m['serving_size_g'] as num? ?? 100).toDouble();
      
      // Skip items with zero calories or invalid serving size
      if (itemCal <= 0 || servingSize <= 0) continue;
      
      // Normalize to per 100g
      final factor = 100.0 / servingSize;
      
      cal  += itemCal * factor;
      pro  += ((m['protein_g']             as num? ?? 0).toDouble()) * factor;
      carb += ((m['carbohydrates_total_g'] as num? ?? 0).toDouble()) * factor;
      fat  += ((m['fat_total_g']           as num? ?? 0).toDouble()) * factor;
      fib  += ((m['fiber_g']               as num? ?? 0).toDouble()) * factor;
      sug  += ((m['sugar_g']               as num? ?? 0).toDouble()) * factor;
      sod  += ((m['sodium_mg']             as num? ?? 0).toDouble()) * factor;
      cho  += ((m['cholesterol_mg']        as num? ?? 0).toDouble()) * factor;
      
      validItems++;
    }
    
    if (validItems == 0) return _getMinimumNutrients();
    
    // Average the normalized values
    cal  = cal / validItems;
    pro  = pro / validItems;
    carb = carb / validItems;
    fat  = fat / validItems;
    fib  = fib / validItems;
    sug  = sug / validItems;
    sod  = sod / validItems;
    cho  = cho / validItems;
    
    return NutrientInfo(
      calories: _ensureMinimum(cal, 20),      // Min 20 kcal per 100g
      protein: _ensureMinimum(pro, 0.5),     // Min 0.5g protein per 100g
      carbs: _ensureMinimum(carb, 1.0),      // Min 1g carbs per 100g
      fat: _ensureMinimum(fat, 0.1),         // Min 0.1g fat per 100g
      fiber: _ensureMinimum(fib, 0.1),       // Min 0.1g fiber per 100g
      sugar: _ensureMinimum(sug, 0.1),       // Min 0.1g sugar per 100g
      sodium: _ensureMinimum(sod, 1.0),      // Min 1mg sodium per 100g
      cholesterol: cho,                       // Cholesterol can be 0
      servingSize: 100,                       // Always per 100g
      source: 'api',
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
        if (cal <= 0) continue;

        return NutrientInfo(
          calories:    _ensureMinimum(cal, 20),
          protein:     _ensureMinimum((n['proteins_100g']      as num? ?? 0).toDouble(), 0.5),
          carbs:       _ensureMinimum((n['carbohydrates_100g'] as num? ?? 0).toDouble(), 1.0),
          fat:         _ensureMinimum((n['fat_100g']           as num? ?? 0).toDouble(), 0.1),
          fiber:       _ensureMinimum((n['fiber_100g']         as num? ?? 0).toDouble(), 0.1),
          sugar:       _ensureMinimum((n['sugars_100g']        as num? ?? 0).toDouble(), 0.1),
          sodium:      _ensureMinimum(((n['sodium_100g']       as num? ?? 0) * 1000).toDouble(), 1.0),
          cholesterol: (n['cholesterol_100g']   as num? ?? 0).toDouble(),
          servingSize: 100,
          source:      'api',
        );
      }
    } catch (_) {}
    return null;
  }

  // ── Helper methods ────────────────────────────────────────────────
  double _ensureMinimum(double value, double minimum) {
    return value > 0 ? value : minimum;
  }

  NutrientInfo _getMinimumNutrients() {
    return const NutrientInfo(
      calories: 50,     // Minimum 50 kcal per 100g
      protein: 1.0,     // Minimum 1g protein per 100g
      carbs: 5.0,       // Minimum 5g carbs per 100g
      fat: 0.5,         // Minimum 0.5g fat per 100g
      fiber: 0.5,       // Minimum 0.5g fiber per 100g
      sugar: 1.0,       // Minimum 1g sugar per 100g
      sodium: 5.0,      // Minimum 5mg sodium per 100g
      cholesterol: 0,   // Cholesterol can be 0
      servingSize: 100,
      source: 'api',
    );
  }
}
