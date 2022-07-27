import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';
import 'package:order_online/responsive/responsive_widget.dart';

class LocationBox extends StatelessWidget {
  final String locationText;
  final String selectedLocation;
  final void Function(String) select;
  LocationBox(this.locationText, this.selectedLocation, this.select);

  String trimLocation(String location) {
    var nums = location.replaceAll(RegExp(r'[^0-9]'), '');
    return location.replaceAll(nums, '').trimLeft();
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = deleteNumbersFromString(selectedLocation) ==
        deleteNumbersFromString(locationText);
    return InkWell(
      onTap: () {
        select(deleteNumbersFromString(locationText));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.transparent,
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          deleteNumbersFromString(locationText),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: ResponsiveWidget.isSmallScreen(context) ? 12 : 14,
          ),
        ),
      ),
    );
  }
}
