import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './sign_up_screen.dart';
import '../../../utils/utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/app_textfield.dart';

import '../../../constants/styles.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1),
                AppText(
                  text: 'Login CvSU Account',
                  textColor: primaryColor,
                  fontWeight: FontWeight.w600,
                  textSize: 24,
                ),
                const SizedBox(height: 100),
                AppTextField(
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  hintText: 'Email',
                ),
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        onPressed: () => _login(context),
                        height: 50,
                        text: "Login",
                        wrapRow: true,
                      ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () async {
                    //await provider.googleLogin();
                    showSnackBar(context, "Feature coming soon!");
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppText(text: "Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        emailController.clear();
                        passwordController.clear();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: AppText(
                        text: "Sign Up",
                        textColor: primaryColor,
                        fontWeight: FontWeight.w600,
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

  Future<void> _login(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!verifyFields()) return;
    setState(() => _isLoading = true);
    await authService.login(
      email: emailController.text,
      password: passwordController.text,
      context: context,
      onSuccess: () {},
    );
  }

  bool verifyFields() {
    if (emailController.text.isEmpty) {
      return false;
    }
    if (passwordController.text.isEmpty) {
      return false;
    }
    return true;
  }
}
