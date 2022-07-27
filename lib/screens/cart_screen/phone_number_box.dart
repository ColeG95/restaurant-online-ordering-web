import 'package:flutter/material.dart';

class PhoneNumberBox extends StatelessWidget {
  const PhoneNumberBox({
    Key? key,
    required this.controllerText,
    required this.number,
    required this.isPhoneFilledOut,
  }) : super(key: key);

  final String controllerText;
  final int number;
  final bool isPhoneFilledOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPhoneFilledOut ? Colors.grey : Theme.of(context).errorColor,
        ),
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          (controllerText.length >= number)
              ? controllerText.substring(number - 1, number)
              : '',
        ),
      ),
    );
  }
}
