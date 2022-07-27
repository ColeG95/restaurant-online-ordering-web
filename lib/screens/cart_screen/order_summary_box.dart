import 'dart:async';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/providers/order_details.dart';
import 'package:provider/provider.dart';
import 'phone_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderSummaryBox extends StatefulWidget {
  final double total;
  final OrderType orderType;
  final Future<void> Function(String, String, String, String, bool)
      trySubmitPayment;

  OrderSummaryBox({
    Key? key,
    required this.total,
    required this.orderType,
    required this.trySubmitPayment,
  }) : super(key: key);

  @override
  State<OrderSummaryBox> createState() => _OrderSummaryBoxState();
}

class _OrderSummaryBoxState extends State<OrderSummaryBox> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _deliveryController = TextEditingController();
  TextEditingController _promoController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool _isLoadingUserInfo = false;

  bool isNameFilledOut = true;
  bool isPhoneFilledOut = true;
  bool isDeliveryFilledOut = true;
  bool sendTextUpdates = true;

  void tryConfirmOrder() async {
    if (_nameController.text.length < 2) {
      setState(() {
        isNameFilledOut = false;
      });
    } else if (isNameFilledOut == false && _nameController.text.length >= 2) {
      setState(() {
        isNameFilledOut = true;
      });
    }
    if (_phoneController.text.length != 10) {
      setState(() {
        isPhoneFilledOut = false;
      });
    } else if (isPhoneFilledOut == false &&
        _phoneController.text.length == 10) {
      setState(() {
        isPhoneFilledOut = true;
      });
    }
    if (_deliveryController.text.length < 6 &&
        widget.orderType == OrderType.delivery) {
      setState(() {
        isDeliveryFilledOut = false;
      });
    } else if (isDeliveryFilledOut == false &&
        _deliveryController.text.length >= 6) {
      setState(() {
        isDeliveryFilledOut = true;
      });
    }
    if (isNameFilledOut && isPhoneFilledOut && isDeliveryFilledOut) {
      showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        context: context,
      );
      widget.trySubmitPayment(
        _phoneController.text,
        _nameController.text,
        _deliveryController.text,
        _promoController.text,
        sendTextUpdates,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    getUserInfo();
  }

  void getUserInfo() async {
    final id = FirebaseAuth.instance.currentUser?.uid;
    if (id != null) {
      setState(() {
        _isLoadingUserInfo = true;
      });
      final user =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final userData = user.data();
      if (userData != null) {
        setState(() {
          _phoneController.text = userData['phoneNumber'] ?? '';
          _nameController.text = userData['name'] ?? '';
          _deliveryController.text = userData['deliveryAddress'] ?? '';
        });
      }
      setState(() {
        _isLoadingUserInfo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingUserInfo
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                width: 120,
                child: TextField(
                  controller: _promoController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(14),
                    hintText: 'Promo Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(14),
                    hintText: 'Name For Order',
                    hintStyle: TextStyle(
                      color: isNameFilledOut
                          ? Colors.grey[600]
                          : Theme.of(context).errorColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isNameFilledOut
                            ? Colors.grey
                            : Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.orderType == OrderType.delivery)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    controller: _deliveryController,
                    style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(14),
                      hintText: 'Delivery Address',
                      hintStyle: TextStyle(
                        color: isDeliveryFilledOut
                            ? Colors.grey[600]
                            : Theme.of(context).errorColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDeliveryFilledOut
                              ? Colors.grey
                              : Theme.of(context).errorColor,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Cell Phone',
                  style: TextStyle(
                    fontSize: 13,
                    color: isPhoneFilledOut
                        ? Colors.grey[600]
                        : Theme.of(context).errorColor,
                    letterSpacing: .2,
                  ),
                ),
              ),
              PhoneFormField(
                phoneController: _phoneController,
                setParentState: () {
                  setState(() {});
                },
                isPhoneFilledOut: isPhoneFilledOut,
              ),
              Consumer<OrderDetails>(
                builder: (ctx, orderDetailsProv, child) => CheckboxListTile(
                  dense: true,
                  value: orderDetailsProv.sendTextUpdates,
                  activeColor: themeColor,
                  title: Text(
                    'Send me text message updates about my order',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onChanged: (_) {
                    orderDetailsProv.toggleSendTextUpdates();
                    sendTextUpdates = orderDetailsProv.sendTextUpdates;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: widget.total == 0 ? null : tryConfirmOrder,
                  child: Text('Confirm Order'),
                  style: ButtonStyle(
                    backgroundColor: widget.total == 0
                        ? MaterialStateProperty.all(Colors.grey[400])
                        : MaterialStateProperty.all(themeColor),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'By confirming your order you agree to *insert company name* privacy policy, terms of service, and understand the restaurant\'s return policy.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items Total:',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Tax:',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${(widget.total * 0.05).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Total:',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '\$${(widget.total * 1.05).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Divider(),
            ],
          );
  }
}
