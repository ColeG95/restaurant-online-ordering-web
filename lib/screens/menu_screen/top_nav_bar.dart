import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:provider/provider.dart';
import 'package:order_online/constants.dart';

import '../../providers/cart.dart';
import '../sign_in_screen/sign_in_screen.dart';

class TopNavBar extends StatelessWidget {
  final String restaurant;
  final FirebaseAuth auth;
  final VoidCallback signout;

  const TopNavBar({
    Key? key,
    required this.restaurant,
    required this.auth,
    required this.signout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(child: Container()),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 5),
                Container(
                  width: ResponsiveWidget.isSmallScreen(context)
                      ? MediaQuery.of(context).size.width * .5
                      : MediaQuery.of(context).size.width * .25,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      restaurant,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 60),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  'Order Online',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Consumer<Cart>(
              builder: (ctx, cart, child) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cart.orderItems.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/cart');
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(themeColor),
                      ),
                      child: Icon(Icons.shopping_cart,
                          size: ResponsiveWidget.isSmallScreen(context)
                              ? 20
                              : 24),
                    ),
                  if (cart.orderItems.isNotEmpty)
                    SizedBox(
                        width:
                            ResponsiveWidget.isSmallScreen(context) ? 5 : 10),
                  TextButton(
                    onPressed: () {
                      if (auth.currentUser != null) {
                        signout();
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignInScreen()));
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(themeColor),
                      overlayColor: MaterialStateProperty.all(
                          themeColor.withOpacity(.03)),
                    ),
                    child: Text(
                      auth.currentUser != null ? 'Sign Out' : 'Sign In',
                      style: TextStyle(
                          fontSize: ResponsiveWidget.isSmallScreen(context)
                              ? 16
                              : 20),
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveWidget.isSmallScreen(context) ? 10 : 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
