import 'package:flutter/material.dart';
import 'package:order_online/models/order_item.dart';
import 'package:order_online/models/variation.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';

class CartItem extends StatelessWidget {
  final OrderItem cartItem;
  final void Function() deleteCartItem;

  const CartItem({
    Key? key,
    required this.cartItem,
    required this.deleteCartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cartItem.name,
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      cartItem.activePrice.toStringAsFixed(2),
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: deleteCartItem,
                      icon: Icon(Icons.delete_forever),
                      iconSize:
                          ResponsiveWidget.isSmallScreen(context) ? 23 : 25,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...cartItem.selectedVariations
              .map(
                (variation) => Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 2, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        variation.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Text(
                            variation.price.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          ...cartItem.selectedSides
              .map(
                (side) => Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 2, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        side.name,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Text(
                            side.activePrice.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          if (cartItem.notes != null && cartItem.notes != '')
            Padding(
              padding:
                  const EdgeInsets.only(left: 20, bottom: 2, right: 40, top: 5),
              child: Text(
                'Notes: ${cartItem.notes!}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          Divider(),
        ],
      ),
    );
  }
}
