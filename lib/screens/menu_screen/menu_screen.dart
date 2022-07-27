import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/models/food_item.dart';
import 'package:order_online/models/order_item.dart';
import 'package:order_online/models/variation.dart';
import 'package:order_online/providers/order_details.dart';
import 'package:order_online/screens/cart_screen/cart_screen.dart';
import 'package:order_online/screens/sign_in_screen/sign_in_screen.dart';
import '../../providers/cart.dart';
import 'menu_group.dart';
import 'location_box.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'top_nav_bar.dart';

class MenuScreen extends StatefulWidget {
  final Map<String, dynamic> restaurantInfo;
  MenuScreen({required this.restaurantInfo});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> locations = [];
  List<String> locationsNoNumbers = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> locationsQDS = [];
  String selectedLocation = '';
  late int selectedLocationIndex;
  bool _isLoadingMainScreen = false;
  bool _isLoadingMenu = false;
  bool _allowDelivery = false;
  OrderType orderType = OrderType.pickup;
  List<String> categories = [];
  Map categoriesMap = {};
  final _auth = FirebaseAuth.instance;

  bool aboveMaxSides = false;

  List<Variation> allVariations = [];
  List<FoodItem> allFoodItems = [];

  OrderItem? selectedOrderItem;

  void selectOrderItem(FoodItem? item) {
    if (item != null) {
      final orderItem = OrderItem(
        id: UniqueKey().toString(),
        name: item.name,
        activePrice: item.price,
        selectedSides: [],
        selectedVariations: [],
        notes: null,
        maxSides: item.maxSides,
      );
      setState(() {
        selectedOrderItem = orderItem;
      });
    } else {
      setState(() {
        selectedOrderItem = null;
      });
    }
    aboveMaxSides =
        selectedOrderItem!.selectedSides.length >= selectedOrderItem!.maxSides;
  }

  void editSelectedOrderItem(FoodItem? side, Variation? variation) {
    if (side != null && selectedOrderItem != null) {
      bool isAlreadySelected = selectedOrderItem!.selectedSides
          .where((selectedSide) => selectedSide.name == side.name)
          .isNotEmpty;
      if (isAlreadySelected) {
        setState(() {
          selectedOrderItem!.selectedSides
              .removeWhere((selectedSide) => selectedSide.name == side.name);
        });
      } else {
        selectedOrderItem!.selectedSides.add(
          OrderItem(
            id: UniqueKey().toString(),
            name: side.name,
            activePrice: aboveMaxSides
                ? side.price ?? 0
                : side.sidePriceBeforeExceededMax ?? 0,
          ),
        );
      }
      setState(() {
        aboveMaxSides = selectedOrderItem!.selectedSides.length >=
            selectedOrderItem!.maxSides;
      });
    }
    if (variation != null && selectedOrderItem != null) {
      bool isAlreadySelected = selectedOrderItem!.selectedVariations
          .where((selectedVariation) =>
              selectedVariation.description == variation.description)
          .isNotEmpty;
      if (isAlreadySelected) {
        setState(() {
          selectedOrderItem!.selectedVariations.removeWhere(
              (selectedVariation) =>
                  selectedVariation.description == variation.description);
        });
      } else {
        setState(() {
          selectedOrderItem!.selectedVariations.add(
            Variation(
              description: variation.description,
              price: variation.price ?? 0,
            ),
          );
        });
      }
    }
  }

  void _signOut() {
    setState(() {
      _auth.signOut();
    });
  }

  void goToSignInPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignInScreen()));
  }

  void addToCart(String? notes) {
    if (selectedOrderItem != null) {
      selectedOrderItem!.notes = notes;
      Provider.of<Cart>(context, listen: false)
          .addOrderItem(selectedOrderItem!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Added To Cart',
            textAlign: TextAlign.center,
          ),
          backgroundColor: themeColor,
        ),
      );
    }
    setState(() {
      selectedOrderItem = null;
    });
  }

  void selectLocationGetData(String location) async {
    Provider.of<Cart>(context, listen: false).clearEntireCart();
    final orderDetailsProv = Provider.of<OrderDetails>(context, listen: false);
    orderDetailsProv.location = location;
    setState(() {
      selectedLocation = location;
      _isLoadingMenu = true;
    });
    selectedLocationIndex = locationsNoNumbers.indexOf(selectedLocation);
    final Map<String, dynamic> locData =
        locationsQDS[selectedLocationIndex].data();
    orderDetailsProv.locationQDS = locationsQDS[selectedLocationIndex];
    _allowDelivery = locData['allowDelivery'];
    List variations = locData['variations'];
    List foodItems = locData['foodItems'];
    Map menuNotes = locData['categoryMenuNotes'];
    List sides =
        foodItems.where((element) => element['isSide'] == true).toList();
    List nonSides =
        foodItems.where((element) => element['isSide'] == false).toList();
    categoriesMap = menuNotes;
    categories = [];
    final List<String> cats = [];
    allFoodItems = [];
    for (var side in sides) {
      cats.add(side['category']);
      allFoodItems.add(
        FoodItem(
          name: side['name'],
          price: side['price'],
          category: side['category'],
          isSide: side['isSide'],
          sidePriceBeforeExceededMax: side['sidePriceBeforeExceededMax'],
          pictureUrl: side['pictureUrl'] != null
              ? side['pictureUrl']
              : 'https://firebasestorage.googleapis.com/v0/b/online-ordering-b486d.appspot.com/o/default_image.png?alt=media&token=a451d174-590e-4de7-a4b0-26a2fb2c5e90',
          description: side['description'],
        ),
      );
    }
    allVariations = [];
    for (var variation in variations) {
      allVariations.add(
        Variation(
          description: variation['description'],
          price: variation['price'],
        ),
      );
    }
    for (var item in nonSides) {
      cats.add(item['category']);
      List possibleSides = item['possibleSides'];
      List<FoodItem> sides = [];
      for (var side in possibleSides) {
        FoodItem? sideItem =
            allFoodItems.firstWhereOrNull((element) => element.name == side);
        if (sideItem != null) {
          sides.add(sideItem);
        }
      }
      List possibleVariations = item['possibleVariations'];
      List<Variation> theseVariations = [];
      for (var variation in possibleVariations) {
        Variation? variationItem = allVariations
            .firstWhereOrNull((element) => element.description == variation);
        if (variationItem != null) {
          theseVariations.add(variationItem);
        }
      }
      allFoodItems.add(
        FoodItem(
          name: item['name'],
          description: item['description'],
          pictureUrl: item['pictureUrl'] != null
              ? item['pictureUrl']
              : 'https://firebasestorage.googleapis.com/v0/b/online-ordering-b486d.appspot.com/o/default_image.png?alt=media&token=a451d174-590e-4de7-a4b0-26a2fb2c5e90',
          price: item['price'],
          category: item['category'],
          maxSides: item['maxSides'],
          isSide: item['isSide'],
          possibleSides: sides,
          possibleVariations: theseVariations,
        ),
      );
    }
    categories = cats.toSet().toList();
    setState(() {
      _isLoadingMenu = false;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoadingMainScreen = true;
    });
    getLocationData();
  }

  Future<void> getLocationData() async {
    final locationsSnapshot =
        await widget.restaurantInfo['docRef'].collection('locations').get();
    for (var loc in locationsSnapshot.docs) {
      var locData = loc.data();
      locationsNoNumbers.add(deleteNumbersFromString(locData['address']));
      locations.add(locData['address']);
      locationsQDS.add(loc);
    }
    if (locations.length == 1) {
      selectLocationGetData(locations.first);
    }
    setState(() {
      _isLoadingMainScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer<Cart>(
        builder: (ctx, cart, child) => cart.orderItems.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      '/${widget.restaurantInfo['name'].toString()}/cart');
                },
                child: Stack(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            '/${widget.restaurantInfo['name'].toString()}/cart');
                      },
                      backgroundColor: themeColor,
                      child: Icon(Icons.shopping_cart),
                    ),
                    Positioned(
                      right: 14,
                      top: 6,
                      child: Text(
                        cart.orderItems.length.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ),
      body: _isLoadingMainScreen
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(),
                  TopNavBar(
                    restaurant:
                        widget.restaurantInfo['name'].toString().toTitleCase(),
                    auth: _auth,
                    signout: _signOut,
                  ),
                  SizedBox(height: 20),
                  if (locations.length > 1)
                    Text(
                      'CHOOSE LOCATION',
                      style: TextStyle(fontSize: 20),
                    ),
                  SizedBox(height: 10),
                  if (locations.length > 1)
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_location_rounded),
                          SizedBox(width: 5),
                          Text('Find Closest Location'),
                        ],
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(themeColor),
                      ),
                    ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      children: locations
                          .map((location) => LocationBox(
                                location,
                                selectedLocation,
                                selectLocationGetData,
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    selectedLocation == ''
                        ? ''
                        : _allowDelivery
                            ? 'ORDER TYPE'
                            : 'FOR PICK-UP ONLY',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  _allowDelivery
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  orderType = OrderType.pickup;
                                });
                              },
                              child: Container(
                                child: Text(
                                  'Pick-up',
                                  style: TextStyle(
                                    color: orderType == OrderType.pickup
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: orderType == OrderType.pickup
                                      ? themeColor
                                      : Colors.transparent,
                                  border: Border.all(color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  orderType = OrderType.delivery;
                                });
                              },
                              child: Container(
                                child: Text(
                                  'Delivery',
                                  style: TextStyle(
                                    color: orderType == OrderType.delivery
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: orderType == OrderType.delivery
                                      ? themeColor
                                      : Colors.transparent,
                                  border: Border.all(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 80),
                  selectedLocation == ''
                      ? SizedBox()
                      : ListView.builder(
                          itemBuilder: (context, i) {
                            return MenuGroup(
                              categories: categories,
                              categoriesMap: categoriesMap,
                              allFoodItems: allFoodItems,
                              index: i,
                              selectedItem: selectedOrderItem ??
                                  OrderItem(
                                    name: '',
                                    activePrice: 0,
                                    id: UniqueKey().toString(),
                                  ),
                              changeSelectedItem: selectOrderItem,
                              editSelectedOrderItem: editSelectedOrderItem,
                              addToCart: addToCart,
                            );
                          },
                          itemCount: categories.length,
                          shrinkWrap: true,
                        ),
                ],
              ),
            ),
    );
  }
}
