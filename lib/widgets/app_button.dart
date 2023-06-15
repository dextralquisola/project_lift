import 'package:flutter/material.dart';
import 'app_text.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double textSize;
  final Color? bgColor;
  final Color? textColor;
  final double? height;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final double radius;
  final bool isEnabled;
  final bool wrapRow;
  const AppButton({
    required this.onPressed,
    required this.text,
    this.radius = 11,
    this.height,
    this.textSize = 20,
    this.isEnabled = true,
    this.textColor = Colors.white,
    this.bgColor = Colors.green,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.wrapRow = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget btnBuilder() {
      return Expanded(
        child: SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon != null
                    ? Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                      )
                    : const SizedBox(),
                icon != null ? const SizedBox(width: 10) : const SizedBox(),
                AppText(
                  text: text,
                  textColor: textColor,
                  textSize: textSize,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return wrapRow ? Row(children: [btnBuilder()]) : btnBuilder();
  }
}
