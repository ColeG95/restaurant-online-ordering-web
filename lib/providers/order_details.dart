import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:order_online/constants.dart';

class OrderDetails with ChangeNotifier {
  bool sendTextUpdates;
  String? phoneNumber;
  String? deliveryAddress;
  DocumentReference? orderDoc;
  String? nameForOrder;
  String? location;
  OrderType orderType;
  QueryDocumentSnapshot? locationQDS;

  OrderDetails({
    this.sendTextUpdates = true,
    this.phoneNumber,
    this.deliveryAddress,
    this.orderDoc,
    this.nameForOrder,
    this.location,
    this.orderType = OrderType.pickup,
    this.locationQDS,
  });

  void toggleSendTextUpdates() {
    sendTextUpdates = !sendTextUpdates;
    notifyListeners();
  }

  void orderTypePickup() {
    orderType = OrderType.pickup;
    notifyListeners();
  }

  void orderTypeDelivery() {
    orderType = OrderType.delivery;
    notifyListeners();
  }

  void doNotifyListeners() {
    notifyListeners();
  }
}
