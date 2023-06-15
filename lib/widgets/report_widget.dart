import 'package:flutter/material.dart';

import '../models/user.dart';
import './report_user_screen.dart';
import './app_button.dart';
import './app_text.dart';

void showReportDialog({
  required BuildContext context,
  User? user,
  Map<String, dynamic>? userParticipant,
}) {
  showDialog(
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
                text: user != null
                    ? "Report ${user.firstName}?"
                    : "Report ${userParticipant!['firstName']}?"),
            const SizedBox(height: 20),
            AppButton(
              height: 50,
              wrapRow: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return ReportUserScreen(
                      user: user,
                      userParticipant: userParticipant,
                    );
                  }),
                );
              },
              text: "Report",
            )
          ],
        ),
      );
    },
  );
}
