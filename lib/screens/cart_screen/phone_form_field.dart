import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'phone_number_box.dart';

class PhoneFormField extends StatelessWidget {
  const PhoneFormField({
    Key? key,
    required this.phoneController,
    required this.setParentState,
    required this.isPhoneFilledOut,
  }) : super(key: key);

  final TextEditingController phoneController;
  final VoidCallback setParentState;
  final bool isPhoneFilledOut;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 1,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 2,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 3,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Text('-'),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 4,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 5,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 6,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Text('-'),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 7,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 8,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 9,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
              Expanded(
                child: PhoneNumberBox(
                  controllerText: phoneController.text,
                  number: 10,
                  isPhoneFilledOut: isPhoneFilledOut,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: TextField(
            showCursor: false,
            onChanged: (value) {
              setParentState();
              if (value.length == 10) {
                FocusScope.of(context).unfocus();
              }
            },
            controller: phoneController,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.transparent,
            ),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
