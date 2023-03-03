import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../../constants/styles.dart';
import '../../../providers/user_provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: 'Login CvSU Account',
                  textColor: primaryColor,
                  fontWeight: FontWeight.w600,
                  textSize: 24,
                ),
                const SizedBox(height: 100),
                AppTextField(controller: emailController, hintText: 'Email'),
                const SizedBox(height: 20),
                AppTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 5),
                AppText(
                  text: "Forgot Password?",
                  alignment: Alignment.centerRight,
                ),
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () {},
                  height: 50,
                  text: "Login",
                  wrapRow: true,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                        child: Divider(color: Colors.black87, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppText(
                        text: "Or",
                        textColor: Colors.black54,
                        textSize: 16,
                      ),
                    ),
                    const Expanded(
                        child: Divider(color: Colors.black87, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 10),
                AppButton(
                  onPressed: () async {
                    await provider.googleLogin();
                  },
                  text: "Login with Google",
                  icon: FontAwesomeIcons.google,
                  textColor: Colors.black54,
                  iconColor: primaryColor,
                  iconSize: 20,
                  bgColor: Colors.white,
                  height: 50,
                  wrapRow: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
