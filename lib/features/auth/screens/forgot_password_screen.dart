import 'package:flutter/material.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_formfield.dart';
import '../service/auth_service.dart';

extension ExtString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[A-Za-z0-9._%+-]+@cvsu\.edu\.ph$");
    return emailRegExp.hasMatch(this);
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  var emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final authService = AuthService();

  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Enter your email address and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomFormField(
                  controller: emailController,
                  hintText: "Email",
                  validator: (val) {
                    if (emailController.text.isNotEmpty) {
                      if (!val!.isValidEmail) return 'Use CvSU email only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : AppButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          await authService.forgotPassword(
                            email: emailController.text,
                            context: context,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        text: 'Send',
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
