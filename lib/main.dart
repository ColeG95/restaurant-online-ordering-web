import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'models/docRefPath.dart';

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
      'logoUrl': doc.data()['logoUrl'],
    });
  }
  await dotenv.load(fileName: ".env");
  runApp(MyApp(restaurantsInfo));
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> restaurantsInfo;
  MyApp(this.restaurantsInfo);

  Map<String, Widget Function(BuildContext)> _getRoutes() {
    Map<String, Widget Function(BuildContext)> routeMap = {};
    for (var restaurantInfo in restaurantsInfo) {
      String name = restaurantInfo['name'];
      routeMap['/${name}/menu'] =
          (_) => MenuScreen(restaurantInfo: restaurantInfo);
      routeMap['/${name}/cart'] =
          (_) => CartScreen(restaurantInfo: restaurantInfo);
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
          var name = settings.name;
          var queryParameter =
              name == null || startParamIndex == -1 || startParamIndex == null
                  ? null
                  : name.substring(startParamIndex!).replaceFirst('=', '');
          var chosenRestaurantId = queryParameter != null
              ? getDocRefFromPath(decryptString(queryParameter)).documentIds[0]
              : null;
          var chosenRestaurantInfo = chosenRestaurantId == null
              ? null
              : restaurantsInfo.firstWhere((restaurant) {
                  DocumentReference restaurantDocRef = restaurant['docRef'];
                  return restaurantDocRef.id == chosenRestaurantId;
                });
          if (settings.name != null &&
              startParamIndex != -1 &&
              startParamIndex != null &&
              queryParameter != null &&
              settings.name?.substring(0, fragmentEndIndex) == '/submitted') {
            return MaterialPageRoute(
              builder: (_) =>
                  OrderSubmittedScreen(orderDocRefEnc: queryParameter),
            );
          } else if (settings.name != null &&
              startParamIndex != -1 &&
              startParamIndex != null &&
              queryParameter != null &&
              settings.name?.substring(0, fragmentEndIndex) ==
                  '/${chosenRestaurantInfo?['name']}/menu') {
            return MaterialPageRoute(
              builder: (_) => MenuScreen(
                restaurantInfo: chosenRestaurantInfo!,
                orderDocRefEnc: queryParameter,
              ),
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
