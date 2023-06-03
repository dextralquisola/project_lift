import 'package:flutter/material.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../screens/tutor_application_screen.dart';
import '../utils/profile_utils.dart' show logout;

Future<bool> showCancelApplyDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: AppText(text: 'Warning!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text:
                  "The application is processing, please wait. Do you want to cancel the application?",
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: AppText(
              text: 'Cancel',
              textColor: Colors.red,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: AppText(
              text: 'Ok',
              textColor: Colors.green,
            ),
          ),
        ],
      );
    },
  );
}

Future<void> logoutDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: AppText(text: 'Are you sure?'),
      content: AppText(text: 'Do you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: AppText(text: 'No'),
        ),
        TextButton(
          onPressed: () async {
            await logout(context);
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: AppText(text: 'Yes'),
        ),
      ],
    ),
  );
}

void showApplyTutorDialog(BuildContext context) {
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
            AppText(text: "3. Create tutor session"),
            const SizedBox(height: 10),
            AppButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TutotApplicationScreen(),
                  ),
                );
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
