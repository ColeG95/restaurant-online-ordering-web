import 'package:flutter/foundation.dart';
import 'package:order_online/models/order_item.dart';

class Cart with ChangeNotifier {
  List<OrderItem> _orderItems = [];

  List<OrderItem> get orderItems {
    return [..._orderItems];
  }

  OrderItem findById(String id) {
    return _orderItems.firstWhere((item) => item.id == id);
  }

  void addOrderItem(OrderItem orderItem) {
    _orderItems.add(orderItem);
    notifyListeners();
  }

  void deleteOrderItem(OrderItem orderItem) {
    _orderItems.remove(orderItem);
    notifyListeners();
  }

  void clearEntireCart() {
    _orderItems.clear();
    notifyListeners();
  }

  void doNotifyListeners() {
    notifyListeners();
  }
}
