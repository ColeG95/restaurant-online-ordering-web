import 'package:order_online/models/variation.dart';

class FoodItem {
  final String name;
  final String description;
  final String pictureUrl;
  final double price;
  final double? sidePriceBeforeExceededMax;
  final String category;
  final bool isSide;
  final int maxSides;
  final List<FoodItem>? possibleSides;
  final List<Variation>? possibleVariations;

  FoodItem({
    required this.name,
    this.description = '',
    this.pictureUrl = 'https://cdn-icons-png.flaticon.com/512/3304/3304773.png',
    required this.price,
    this.sidePriceBeforeExceededMax = 0,
    required this.category,
    this.isSide = false,
    this.maxSides = 0,
    this.possibleSides,
    this.possibleVariations,
  });
}
