import 'package:flutter/cupertino.dart';

import 'food_item.dart';
import 'variation.dart';

class OrderItem {
  final String id;
  final String name;
  final double activePrice;
  late String? notes;
  final int maxSides;
  final List<OrderItem> selectedSides;
  final List<Variation> selectedVariations;

  OrderItem({
    required this.id,
    required this.name,
    required this.activePrice,
    this.notes,
    this.maxSides = 0,
    this.selectedSides = const [],
    this.selectedVariations = const [],
  });
}
