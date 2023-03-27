import 'package:flutter/material.dart';

class BackgroundCover extends StatelessWidget {
  const BackgroundCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          child: Image.asset('assets/images/bg_image.png', fit: BoxFit.cover),
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
