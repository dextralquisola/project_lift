import 'package:flutter/material.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../screens/tutor_application_screen.dart';

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
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TutotApplicationScreen(),
                  ),
                );
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
