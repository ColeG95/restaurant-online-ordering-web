import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/providers/cart.dart';
import 'package:order_online/models/variation.dart';
import 'package:order_online/providers/order_details.dart';
import 'package:order_online/screens/cart_screen/cart_screen.dart';
import 'package:order_online/screens/order_submitted_screen/order_submitted_screen.dart';
import 'package:order_online/screens/sign_in_screen/sign_in_screen.dart';
// import 'package:url_strategy/url_strategy.dart';
import 'screens/menu_screen/menu_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// TODO change firebase security rules

void main() async {
  // setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final restaurantQuery =
      await FirebaseFirestore.instance.collection('restaurants').get();
  List<Map<String, dynamic>> restaurantsInfo = [];
  for (var doc in restaurantQuery.docs) {
    restaurantsInfo.add({
      'name': doc.data()['name'].toString().toLowerCase(),
      'docRef': doc.reference,
    });
  }
  runApp(MyApp(restaurantsInfo));
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> restaurantsInfo;
  MyApp(this.restaurantsInfo);

  Map<String, Widget Function(BuildContext)> _getRoutes() {
    Map<String, Widget Function(BuildContext)> routeMap = {};
    for (var restaurant in restaurantsInfo) {
      String name = restaurant['name'];
      DocumentReference docRef = restaurant['docRef'];
      routeMap['/${name}/menu'] = (_) => MenuScreen(restaurantInfo: restaurant);
      routeMap['/${name}/cart'] = (_) => CartScreen(restaurantInfo: restaurant);
    }
    routeMap['/signin'] = (_) => SignInScreen();
    return routeMap;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderDetails(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Online Ordering',
        onGenerateRoute: (settings) {
          var startParamIndex = settings.name?.indexOf('=');
          var fragmentEndIndex = settings.name?.indexOf('?');
          if (settings.name != null &&
              startParamIndex != -1 &&
              startParamIndex != null &&
              settings.name?.substring(0, fragmentEndIndex) == '/submitted') {
            var name = settings.name!;
            var queryParameter =
                name.substring(startParamIndex).replaceFirst('=', '');
            return MaterialPageRoute(
              builder: (_) =>
                  OrderSubmittedScreen(orderDocRefEnc: queryParameter),
            );
          } else {
            return MaterialPageRoute(builder: (_) => SignInScreen());
          }
        },
        initialRoute: '/benny\'s/menu',
        routes: _getRoutes(),
      ),
    );
  }
}
