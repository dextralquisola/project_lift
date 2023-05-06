import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  Color? textColor;
  double? textSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  Alignment? alignment;
  TextOverflow? textOverflow;
  AppText({
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
