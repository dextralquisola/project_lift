import 'package:flutter/material.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../../../providers/user_provider.dart';
import '../service/profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final profileService = ProfileService();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late UserProvider userProvider;
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      firstNameController.text = userProvider.user.firstName;
      lastNameController.text = userProvider.user.lastName;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    final isGoogleLogin = userProvider.isGoogleLogin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: firstNameController,
                labelText: 'First Name',
              ),
              AppTextField(
                controller: lastNameController,
                labelText: 'Last Name',
              ),
              !isGoogleLogin
                  ? AppTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      isPassword: true,
                    )
                  : const SizedBox(),
              !isGoogleLogin
                  ? AppTextField(
                      controller: confirmPasswordController,
                      labelText: 'Confirm Password',
                      isPassword: true,
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : AppButton(
                      height: 50,
                      wrapRow: true,
                      onPressed: () async => await saveChanges(),
                      text: "Save Changes",
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);
    var password = "";
    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password does not match'),
        ),
      );
      return;
    } else if (passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text) {
      password = passwordController.text;
    }
    
    await profileService.updateUser(
      context: context,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      password: password,
    );

    setState(() => _isLoading = false);

    Navigator.of(context).pop();
  }
}
