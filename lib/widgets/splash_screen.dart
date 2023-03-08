import 'package:flutter/material.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/widgets/app_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppText(
          text: "Looking For Tutor",
          textSize: 28,
          textColor: primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
