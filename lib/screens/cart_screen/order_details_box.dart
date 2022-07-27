import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:order_online/providers/order_details.dart';
import 'package:order_online/constants.dart';

class OrderDetailsBox extends StatelessWidget {
  final Map<String, dynamic> restaurantInfo;

  const OrderDetailsBox({
    Key? key,
    required this.restaurantInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderDetails = Provider.of<OrderDetails>(context);
    final location = orderDetails.location;
    final orderTypeString = orderDetails.orderType?.name.toTitleCase();
    return Container(
      height: 250,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'Order Details',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Chip(
              label: Text(
                restaurantInfo['name'].toString().toTitleCase(),
              ),
              side: BorderSide(
                color: Colors.grey[600] ?? Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Chip(
              label: Text(
                location ?? 'Not Chosen',
              ),
              side: BorderSide(
                color: Colors.grey[600] ?? Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Chip(
              label: Text(
                orderTypeString ?? 'Not Chosen',
              ),
              side: BorderSide(
                color: Colors.grey[600] ?? Colors.grey,
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
