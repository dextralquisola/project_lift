import 'package:flutter/material.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/auth/screens/login_screen.dart';
import 'package:project_lift/features/home/screens/home_screen.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';

import '../service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  controller: nameController,
                  hintText: "Full Name",
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
                    await authService.signup(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      context: context,
                    );
        
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
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
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
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
}
