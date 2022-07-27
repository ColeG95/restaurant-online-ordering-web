import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_online/models/docRefPath.dart';

class OrderSubmittedScreen extends StatefulWidget {
  final String orderDocRefEnc;

  OrderSubmittedScreen({
    Key? key,
    required this.orderDocRefEnc,
  }) : super(key: key);

  @override
  State<OrderSubmittedScreen> createState() => _OrderSubmittedScreenState();
}

class _OrderSubmittedScreenState extends State<OrderSubmittedScreen> {
  final _auth = FirebaseAuth.instance;
  late DocumentReference orderDocRef;
  late String phone;
  late String name;
  String? deliveryAddress;
  bool sendTexts = false;
  bool hasAccount = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isObscured = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _getOrderData() async {
    setState(() {
      _isLoading = true;
    });
    final orderDoc = await orderDocRef.get();
    final Map orderData = orderDoc.data() as Map;
    phone = orderData['createdByPhone'];
    name = orderData['nameForOrder'];
    deliveryAddress = orderData['deliveryAddress'];
    setState(() {
      sendTexts = orderData['sendTextUpdates'];
      hasAccount = orderData['createdById'] != null;
      _isLoading = false;
    });
  }

  void _tryCreateAccount() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    UserCredential userCredential;
    try {
      if (isValid) {
        _formKey.currentState!.save();
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'phoneNumber': phone,
          'allOrders': [orderDocRef],
          'deliveryAddress': deliveryAddress,
          'name': name,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account Created',
              textAlign: TextAlign.center,
            ),
            backgroundColor: themeColor,
          ),
        );
        await orderDocRef.update({
          'createdById': userCredential.user!.uid,
        });
      }
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred';
      if (e.message != null) {
        message = e.message!;
      }
      print(e);
      if (message.contains(
          'There is no user record corresponding to this identifier')) {
        message = 'User not found';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.toString(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor.withOpacity(.9),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor.withOpacity(.9),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _getOrderDoc() {
    DocRefPath path = getDocRefFromPath(decryptString(widget.orderDocRefEnc));
    orderDocRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(path.documentIds[0])
        .collection('locations')
        .doc(path.documentIds[1])
        .collection('orders')
        .doc(path.documentIds[2]);
  }

  @override
  void initState() {
    super.initState();
    _getOrderDoc();
    _getOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'ORDER SUBMITTED! THANKS ${name.toUpperCase()}!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sendTexts)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Stay tuned for text updates from the kitchen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your card won\'t be charged until your order is accepted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  if (!hasAccount)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Create an account so we\'ll remember you for next time?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 250,
                              minWidth: 150,
                            ),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(14),
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return 'Enter a valid email address';
                                } else if (value.contains(' ')) {
                                  return 'Email cannot contain spaces';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 250,
                              minWidth: 150,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              obscureText: isObscured,
                              controller: _passwordController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(14),
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.length < 7) {
                                  return 'Password must be at least 7 characters long';
                                } else if (value.contains(' ')) {
                                  return 'Password cannot contain spaces';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isObscured
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.remove_red_eye,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(isObscured
                                      ? 'Show Password'
                                      : 'Hide Password'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _tryCreateAccount,
                                  child: Text('Create Account'),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(themeColor),
                                  ),
                                ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
