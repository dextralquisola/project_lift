import 'package:flutter/material.dart';

class BackgroundCover extends StatelessWidget {
  final bool isBottomBg;
  const BackgroundCover({
    Key? key,
    this.isBottomBg = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          child: isBottomBg
              ? Image.asset('assets/images/bottom_bg.png', fit: BoxFit.cover)
              : Image.asset('assets/images/bg_image.png', fit: BoxFit.cover),
        ),
        SizedBox(
          child:
              Image.asset('assets/images/gradient.png', fit: BoxFit.fitWidth),
        ),
        SizedBox(
          child:
              Image.asset('assets/images/gradient.png', fit: BoxFit.fitWidth),
        ),
        SizedBox(
          child:
              Image.asset('assets/images/gradient.png', fit: BoxFit.fitWidth),
        ),
      ],
    );
  }
}
