import 'dart:html' as html;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/models/order_item.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:order_online/screens/cart_screen/cart_item.dart';
import '../../providers/order_details.dart';
import 'order_summary_box.dart';
import 'order_details_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:order_online/providers/cart.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantInfo;

  CartScreen({
    required this.restaurantInfo,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _auth = FirebaseAuth.instance;

  double getTotal(List<OrderItem> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += item.activePrice;
      for (var side in item.selectedSides) {
        total += side.activePrice;
      }
      for (var variation in item.selectedVariations) {
        total += variation.price;
      }
    }
    return total;
  }

  Future<void> trySubmitPayment(
    String phoneNumber,
    String name,
    String address,
    String promoCode,
    bool sendTexts,
  ) async {
    final orderDetailsProv = Provider.of<OrderDetails>(context, listen: false);
    final cartProv = Provider.of<Cart>(context, listen: false);
    await orderDetailsProv.locationQDS?.reference.collection('orders').add({
      'createdById': _auth.currentUser?.uid,
      'createdByPhone': phoneNumber,
      'createdDate': DateTime.now(),
      'orderAccepted': false,
      'orderFinished': false,
      'nameForOrder': name,
      'totalCharged': getTotal(cartProv.orderItems) * 1.05,
      'orderType': orderDetailsProv.orderType.name.toTitleCase(),
      'deliveryAddress': address,
      'promoCode': promoCode,
      'sendTextUpdates': sendTexts,
      'sessionId': null,
      'paymentIntent': null,
      'orderItems': cartProv.orderItems
          .map((item) => {
                'name': item.name,
                'activePrice': item.activePrice,
                'maxSides': item.maxSides,
                'notes': item.notes,
                'selectedSides': item.selectedSides
                    .map((side) => {
                          'name': side.name,
                          'activePrice': side.activePrice,
                        })
                    .toList(),
                'selectedVariations': item.selectedVariations
                    .map((variation) => {
                          'description': variation.description,
                          'price': variation.price,
                        })
                    .toList(),
              })
          .toList(),
    }).then((DocumentReference value) async {
      if (_auth.currentUser?.uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'allOrders': FieldValue.arrayUnion([value]),
          'deliveryAddress': address != '' ? address : null,
          'name': name,
          'phoneNumber': phoneNumber,
        });
      }
      final String orderDocRefEnc = encryptString(value.path);
      final session = await FirebaseFunctions.instance
          .httpsCallable('stripeCheckout')
          .call(<String, dynamic>{
        'total': getTotal(cartProv.orderItems) * 1.05,
        'restaurant': widget.restaurantInfo['name'].toTitleCase(),
        'currentUrl': Uri.base
            .toString()
            .replaceFirst('cart', '')
            .replaceFirst('/${widget.restaurantInfo['name']}', ''),
        'email': _auth.currentUser?.email,
        'orderDocRefEnc': orderDocRefEnc,
        'imageLinkList': [
          'https://firebasestorage.googleapis.com/v0/b/online-ordering-b486d.appspot.com/o/blt.jpeg?alt=media&token=695530e1-1303-41c4-83bf-d7ec7c2fbac8',
        ],
      });
      value.update({
        'sessionId': session.data['id'],
        'paymentIntent': session.data['payment_intent'],
      });
      final sessionUrl = session.data['url'];
      html.window.open(sessionUrl, "_self");
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ResponsiveWidget.isLargeScreen(context))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: OrderDetailsBox(
                          restaurantInfo: widget.restaurantInfo),
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: Consumer<Cart>(
                    builder: (ctx, cart, child) => cart.orderItems.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveWidget.isSmallScreen(context)
                                      ? 80
                                      : 120,
                              vertical: 20,
                            ),
                            child: Image.asset('images/nofoodhere.png'),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[200] ?? Colors.grey,
                                  Colors.white
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[200] ?? Colors.white,
                                  spreadRadius: 0.0,
                                  blurRadius: 12.0,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: ListView(
                              shrinkWrap: true,
                              children: cart.orderItems
                                  .map((cartItem) => CartItem(
                                        cartItem: cartItem,
                                        deleteCartItem: () {
                                          Provider.of<Cart>(context,
                                                  listen: false)
                                              .deleteOrderItem(cartItem);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                  ),
                ),
                if (!ResponsiveWidget.isSmallScreen(context))
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Consumer2<Cart, OrderDetails>(
                            builder: (_, cart, orderDetails, _2) =>
                                OrderSummaryBox(
                              total: getTotal(cart.orderItems),
                              orderType: orderDetails.orderType,
                              trySubmitPayment: trySubmitPayment,
                            ),
                          ),
                        ),
                        if (!ResponsiveWidget.isLargeScreen(context))
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: OrderDetailsBox(
                                restaurantInfo: widget.restaurantInfo),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            if (ResponsiveWidget.isSmallScreen(context))
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                child: Consumer2<Cart, OrderDetails>(
                  builder: (_, cart, orderDetails, _2) => OrderSummaryBox(
                    total: getTotal(cart.orderItems),
                    orderType: orderDetails.orderType,
                    trySubmitPayment: trySubmitPayment,
                  ),
                ),
              ),
            if (ResponsiveWidget.isSmallScreen(context))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OrderDetailsBox(restaurantInfo: widget.restaurantInfo),
              ),
          ],
        ),
      ),
    );
  }
}
