import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';

import '../../../widgets/app_text.dart';

void showBannedDialog({
  required BuildContext context,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const AppText(
          text: 'Notice',
          fontWeight: FontWeight.w600,
          textSize: 18,
          textColor: Colors.amber,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(text: "Your account has been banned!"),
            const SizedBox(height: 10),
            const AppText(text: "Please contact admin for more information."),
            const SizedBox(height: 10),
            const AppText(text: "Email: liftappteam@gmail.com"),
            const SizedBox(height: 10),
            AppButton(
              height: 50,
              wrapRow: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: "Okay",
            )
          ],
        ),
      );
    },
  );
}
