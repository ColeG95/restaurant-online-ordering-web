import 'package:flutter/material.dart';
import 'package:order_online/constants.dart';

class ThemeElevatedButton extends StatelessWidget {
  final String? label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color1;
  final Color? color2;

  const ThemeElevatedButton({
    Key? key,
    this.label,
    required this.onPressed,
    this.icon,
    this.color1,
    this.color2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: color1 == null && color2 == null
              ? LinearGradient(
                  colors: [
                    themeColor,
                    themeColor.withAlpha(190),
                  ],
                )
              : color1 != null && color2 != null
                  ? LinearGradient(
                      colors: [
                        color1!,
                        color2!,
                      ],
                    )
                  : LinearGradient(
                      colors: [color1!],
                    ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                ),
              if (icon != null) const SizedBox(width: 5),
              Text('$label'),
            ],
          ),
        ),
      ),
    );
  }
}
