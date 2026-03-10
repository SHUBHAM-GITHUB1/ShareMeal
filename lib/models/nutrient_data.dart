class NutrientInfo {
  final String protein;
  final String carbs;
  final String fat;
  final String vitamins;

  const NutrientInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.vitamins,
  });
}

class NutrientData {
  static const Map<String, NutrientInfo> _foodNutrients = {
    'rice': NutrientInfo(protein: '2.7g', carbs: '28g', fat: '0.3g', vitamins: 'B1, B3'),
    'dal': NutrientInfo(protein: '9g', carbs: '20g', fat: '0.8g', vitamins: 'B9, B1'),
    'roti': NutrientInfo(protein: '3g', carbs: '15g', fat: '0.4g', vitamins: 'B1, B3'),
    'curry': NutrientInfo(protein: '4g', carbs: '8g', fat: '2g', vitamins: 'A, C'),
    'vegetable': NutrientInfo(protein: '2g', carbs: '5g', fat: '0.2g', vitamins: 'A, C, K'),
    'fruit': NutrientInfo(protein: '1g', carbs: '12g', fat: '0.3g', vitamins: 'C, A'),
    'bread': NutrientInfo(protein: '8g', carbs: '49g', fat: '3g', vitamins: 'B1, B3'),
    'chicken': NutrientInfo(protein: '31g', carbs: '0g', fat: '3.6g', vitamins: 'B6, B12'),
    'fish': NutrientInfo(protein: '22g', carbs: '0g', fat: '12g', vitamins: 'D, B12'),
    'egg': NutrientInfo(protein: '13g', carbs: '1g', fat: '11g', vitamins: 'B12, D'),
  };

  static NutrientInfo? getNutrients(String foodItem) {
    final key = foodItem.toLowerCase();
    for (final entry in _foodNutrients.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return const NutrientInfo(protein: '5g', carbs: '15g', fat: '2g', vitamins: 'Mixed');
  }
}