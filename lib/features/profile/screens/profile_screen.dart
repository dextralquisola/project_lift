import 'package:flutter/material.dart';
import 'package:project_lift/main.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/background_cover.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(
                  child: BackgroundCover(hasBgImage: false),
                ),
                Positioned(
                  bottom: -75,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(105),
                        child: Container(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          await userProvider.logout();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.exit_to_app, color: Colors.white),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                    text: "${user.firstName} ${user.lastName}",
                    textSize: 24,
                    fontWeight: FontWeight.bold),
                const SizedBox(height: 50),
                Column(
                  children: [
                    AppButton(
                      height: 50,
                      onPressed: () {},
                      wrapRow: true,
                      text: "Account Settings",
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      onPressed: () => _showDialog(context),
                      wrapRow: true,
                      text: "Be a tutor!",
                      height: 50,
                    ),
                  ],
                ),
              ],
            ),
          )
          // profile body
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AppText(text: 'Be a tutor!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                  text:
                      "Beware this cannot be undo, being a tutor can still be a tutee. Being a tutor can have the ff:"),
              const SizedBox(height: 10),
              AppText(text: "1. Badge"),
              AppText(text: "2. Rated by tutee"),
              AppText(text: "3. Setup schedule"),
              AppText(text: "4. Create tutor session"),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                height: 50,
                wrapRow: true,
                text: "Be a tutor!",
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: AppText(
                  text: "Maybe next time...",
                  textColor: Colors.grey,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
