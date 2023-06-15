import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final Alignment? alignment;
  final TextOverflow? textOverflow;
  const AppText({
    super.key,
    required this.text,
    this.textColor = Colors.black,
    this.textSize,
    this.fontWeight,
    this.textAlign,
    this.alignment,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: textBuilder(),
    );
  }

  Widget textBuilder() {
    return Text(
      text,
      textAlign: textAlign,
      overflow: textOverflow,
      style: TextStyle(
        color: textColor,
        fontSize: textSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
