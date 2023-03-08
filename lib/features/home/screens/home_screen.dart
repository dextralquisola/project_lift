import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(text: user.name),
              const SizedBox(height: 10),
              AppText(text: user.email),
              const SizedBox(height: 20),
              AppButton(
                wrapRow: true,
                height: 50,
                onPressed: () async  {
                  await userProvider.logout();
                },
                text: "Logout",
              )
            ],
          ),
        ),
      ),
    );
  }
}
