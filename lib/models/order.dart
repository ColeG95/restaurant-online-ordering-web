import 'package:order_online/models/order_item.dart';

class Order {
  final List<OrderItem> items;
  final double totalCharged;
  final String nameForOrder;
  final String? promoCode;
  final bool isDelivery;
  final String? deliveryAddress;

  Order({
    required this.items,
    required this.totalCharged,
    required this.nameForOrder,
    this.promoCode,
    this.isDelivery = false,
    this.deliveryAddress,
  });
}
