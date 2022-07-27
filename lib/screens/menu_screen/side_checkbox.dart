import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/models/food_item.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:order_online/models/order_item.dart';
import 'package:order_online/models/variation.dart';

class SideCheckbox extends StatelessWidget {
  final String label;
  final double price;
  final FoodItem? side;
  final Variation? variation;
  final bool isSide;
  final OrderItem selectedItem;
  final void Function(FoodItem?, Variation?) editSelectedOrderItem;

  const SideCheckbox({
    Key? key,
    required this.label,
    required this.price,
    this.side,
    this.variation,
    required this.isSide,
    required this.selectedItem,
    required this.editSelectedOrderItem,
  }) : super(key: key);

  bool isAlreadyInList() {
    if (isSide) {
      return selectedItem.selectedSides
          .where((element) => element.name == label)
          .isNotEmpty;
    } else {
      return selectedItem.selectedVariations
          .where((element) => element.description == label)
          .isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: isAlreadyInList(),
            activeColor: themeColor,
            onChanged: (_) {
              if (isSide) {
                editSelectedOrderItem(side, null);
              } else {
                editSelectedOrderItem(null, variation);
              }
            },
          ),
          Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: ResponsiveWidget.isSmallScreen(context) ? 12 : 14,
            ),
          ),
          Spacer(),
          Text(
            '\$${price.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: ResponsiveWidget.isSmallScreen(context) ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
