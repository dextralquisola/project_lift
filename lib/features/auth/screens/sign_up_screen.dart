import 'package:flutter/material.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_formfield.dart';

import '../../../constants/styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

import '../service/auth_service.dart';

extension ExtString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[A-Za-z0-9._%+-]+@cvsu\.edu\.ph$");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName {
    final nameRegExp =
        RegExp(r'^[a-zA-Z0-9 _.+-]*(?:[a-zA-Z][a-zA-Z0-9 _.+-]*){2,}$');
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp = RegExp(
        r'^(?!.*?password|.*?PASSWORD|.*?Password)(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegExp.hasMatch(this);
  }
}

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

  var _isAgreed = false;

  final authService = AuthService();

  var formKey = GlobalKey<FormState>();

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
            child: Form(
              key: formKey,
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
                  CustomFormField(
                    validator: (p0) => p0!.isValidName
                        ? null
                        : "First name is required and must be valid",
                    controller: firstNameController,
                    hintText: "First name",
                  ),
                  const SizedBox(height: 10),
                  CustomFormField(
                    validator: (p0) => p0!.isValidName
                        ? null
                        : "Last name is required and must be valid",
                    controller: lastNameController,
                    hintText: "Last name",
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  CustomFormField(
                    isPassword: true,
                    controller: passwordController,
                    hintText: "Password",
                    validator: (val) {
                      if (passwordController.text.isNotEmpty) {
                        if ((!val!.isValidPassword &&
                                val.toLowerCase().contains("password")) ||
                            !val.isValidPassword) {
                          return 'Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, one special character and must not contain the word "password"';
                        }
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value!;
                          });
                        },
                      ),
                      AppText(
                        text: "I agree to the ",
                        textColor: Colors.black,
                        textSize: 14,
                      ),
                      TextButton(
                        onPressed: () {
                          showTermsAndCondition(context);
                        },
                        child: AppText(
                          text: "Terms and conditions",
                          textColor: primaryColor,
                          textSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    onPressed: () async {
                      if (!verifyFields()) {
                        showSnackBar(context, "Please fill up all fields");
                        return;
                      }
                      if (!_isAgreed) {
                        showSnackBar(context,
                            "Please agree to the terms and conditions");
                        return;
                      }

                      if (!formKey.currentState!.validate()) {
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

    return true;
  }

  void showTermsAndCondition(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AppText(text: 'Terms and Conditions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                  textAlign: TextAlign.justify,
                  text:
                      "I grant my consent for using my personal university information and grades by the LFT Team for scholarly purposes. I understand that this data will be used for educational research and academic analysis while ensuring strict confidentiality and compliance with data protection regulations by Republic Act No. 10173, otherwise known as the Data Privacy Act. This consent is valid until revoked in writing. May God guide us in our pursuit of knowledge."),
            ],
          ),
        );
      },
    );
  }
}
