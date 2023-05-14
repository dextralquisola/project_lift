import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

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

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    firstNameController.text = userProvider.user.firstName;
    lastNameController.text = userProvider.user.lastName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
              AppTextField(
                controller: passwordController,
                labelText: 'Password',
                isPassword: true,
              ),
              AppTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                isPassword: true,
              ),
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
    } else if (passwordController.text.isNotEmpty) {
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
