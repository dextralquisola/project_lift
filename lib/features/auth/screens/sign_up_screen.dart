import 'package:flutter/material.dart';

import '../../../constants/styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/app_textfield.dart';

import '../service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                AppText(
                  text: "Create an Account",
                  fontWeight: FontWeight.bold,
                  textSize: 28,
                ),
                AppText(
                  text: "Sign up to get started with an account",
                  textColor: Colors.grey,
                  textSize: 14,
                ),
                const SizedBox(height: 50),
                AppTextField(
                  controller: firstNameController,
                  hintText: "First name",
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: lastNameController,
                  hintText: "Last name",
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: emailController,
                  hintText: "Email",
                ),
                const SizedBox(height: 10),
                AppTextField(
                  isPassword: true,
                  controller: passwordController,
                  hintText: "Password",
                ),
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () async {
                    if (!verifyFields()) {
                      return;
                    }
                    await authService.signup(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      context: context,
                      onSuccess: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  text: 'Sign Up',
                  height: 50,
                  wrapRow: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppText(text: "Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: AppText(
                        text: "Login",
                        textColor: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool verifyFields() {
    if (firstNameController.text.isEmpty) {
      return false;
    }

    if (lastNameController.text.isEmpty) {
      return false;
    }

    if (emailController.text.isEmpty) {
      return false;
    }

    if (passwordController.text.isEmpty) {
      return false;
    }

    if (passwordController.text.contains("password")) {
      return false;
    }

    return true;
  }
}
