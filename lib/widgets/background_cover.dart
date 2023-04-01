import 'package:flutter/material.dart';

class BackgroundCover extends StatelessWidget {
  final bool isBottomBg;
  final bool hasBgImage;
  const BackgroundCover({
    Key? key,
    this.isBottomBg = false,
    this.hasBgImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        hasBgImage
            ? SizedBox(
                child: isBottomBg
                    ? Image.asset('assets/images/bottom_bg.png',
                        fit: BoxFit.cover)
                    : Image.asset('assets/images/bg_image.png',
                        fit: BoxFit.cover),
              )
            : const SizedBox(),
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
