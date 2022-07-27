import 'dart:html';

import 'package:flutter/material.dart';
import 'package:order_online/models/food_item.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/responsive/responsive_widget.dart';
import 'package:order_online/screens/menu_screen/side_checkbox.dart';
import 'package:order_online/models/order_item.dart';
import 'package:order_online/models/variation.dart';

class MenuGroup extends StatefulWidget {
  const MenuGroup({
    Key? key,
    required this.categories,
    required this.categoriesMap,
    required this.allFoodItems,
    required this.index,
    required this.selectedItem,
    required this.changeSelectedItem,
    required this.editSelectedOrderItem,
    required this.addToCart,
  }) : super(key: key);

  final List<String> categories;
  final Map categoriesMap;
  final List<FoodItem> allFoodItems;
  final int index;
  final OrderItem selectedItem;
  final void Function(FoodItem?) changeSelectedItem;
  final void Function(FoodItem?, Variation?) editSelectedOrderItem;
  final void Function(String?) addToCart;

  @override
  State<MenuGroup> createState() => _MenuGroupState();
}

class _MenuGroupState extends State<MenuGroup> {
  final TextEditingController _controller = TextEditingController();
  bool showNote = false;
  bool aboveMaxSides = false;

  @override
  Widget build(BuildContext context) {
    aboveMaxSides = widget.selectedItem.selectedSides.length >=
        widget.selectedItem.maxSides;
    if (widget.selectedItem.name == '') {
      showNote = false;
      _controller.clear();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.categories[widget.index].toUpperCase(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            widget.categoriesMap[widget.categories[widget.index]],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        ...widget.allFoodItems
            .where((element) =>
                element.category == widget.categories[widget.index])
            .indexedMap((item, index) {
          bool isSelected = item.name == widget.selectedItem.name;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (isSelected) {
                    widget.changeSelectedItem(null);
                  } else {
                    widget.changeSelectedItem(item);
                  }
                },
                hoverColor: themeColor.withOpacity(.08),
                splashColor: themeColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: widget.selectedItem.name == item.name
                            ? Colors.transparent
                            : Colors.grey,
                      ),
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 350,
                    maxWidth: 750,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                item.name.toUpperCase(),
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                item.description,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveWidget.isSmallScreen(context)
                                          ? 12
                                          : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 20),
                          ),
                          Container(
                            width: ResponsiveWidget.isSmallScreen(context)
                                ? 120
                                : 150,
                            height: ResponsiveWidget.isSmallScreen(context)
                                ? 80
                                : 100,
                            child: Material(
                              borderRadius: BorderRadius.circular(8),
                              elevation: 8,
                              child: ClipRRect(
                                child: Image.network(
                                  item.pictureUrl,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 350,
                    maxWidth: 750,
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  )),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      if (item.possibleSides != null)
                        Text(
                          'SIDES',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (item.possibleSides != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Comes With ${item.maxSides} Side(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      if (item.possibleSides != null)
                        ...item.possibleSides!.map((side) {
                          List<OrderItem> alreadySelectedSideList = widget
                              .selectedItem.selectedSides
                              .where((selectedSide) =>
                                  selectedSide.name == side.name)
                              .toList();
                          double alreadySelectedSidePrice() {
                            if (alreadySelectedSideList.isNotEmpty) {
                              return alreadySelectedSideList.first.activePrice;
                            }
                            return 0;
                          }

                          bool isAlreadySelected =
                              alreadySelectedSideList.isNotEmpty;
                          return SideCheckbox(
                            label: side.name,
                            price: isAlreadySelected
                                ? alreadySelectedSidePrice()
                                : aboveMaxSides
                                    ? side.price ?? 0
                                    : side.sidePriceBeforeExceededMax ?? 0,
                            isSide: true,
                            side: side,
                            selectedItem: widget.selectedItem,
                            editSelectedOrderItem: widget.editSelectedOrderItem,
                          );
                        }).toList(),
                      if (item.possibleSides != null) SizedBox(height: 10),
                      if (item.possibleVariations != null)
                        Text(
                          'VARIATIONS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (item.possibleVariations != null)
                        ...item.possibleVariations!
                            .map(
                              (variation) => SideCheckbox(
                                label: variation.description,
                                price: variation.price ?? 0.0,
                                isSide: false,
                                variation: variation,
                                selectedItem: widget.selectedItem,
                                editSelectedOrderItem:
                                    widget.editSelectedOrderItem,
                              ),
                            )
                            .toList(),
                      SizedBox(height: 10),
                      Container(),
                      showNote
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 90),
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showNote = true;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 5),
                                  Text('Add a Note'),
                                ],
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey),
                              ),
                            ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          widget.addToCart(_controller.text);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart),
                            SizedBox(width: 5),
                            Text('Add To Cart'),
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(themeColor),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 80),
      ],
    );
  }
}
