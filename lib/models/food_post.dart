import 'nutrient_data.dart';

class FoodPost {
  final String id;
  final String item;
  final String qty;
  final String img;
  final DateTime time;
  final String donor;
  final bool isVeg;
  final NutrientInfo? nutrients;

  const FoodPost({
    required this.id,
    required this.item,
    required this.qty,
    required this.img,
    required this.time,
    required this.donor,
    this.isVeg = true,
    this.nutrients,
  });
}