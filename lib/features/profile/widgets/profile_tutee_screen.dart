import 'package:flutter/material.dart';
import '../../../models/tutor_application.dart';

import '../../../widgets/app_button.dart';
import '../screens/tutor_application_screen.dart';
import './profile_widgets.dart';

class TuteeScreen extends StatelessWidget {
  final TutorApplication tutorApplication;
  const TuteeScreen({
    super.key,
    required this.tutorApplication,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          AppButton(
            onPressed: tutorApplication.id.isNotEmpty
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TutotApplicationScreen(),
                      ),
                    );
                  }
                : () {
                    showApplyTutorDialog(context);
                  },
            height: 50,
            wrapRow: true,
            text: tutorApplication.id.isNotEmpty
                ? "View application"
                : "Be a tutor!",
          ),
        ],
      ),
    );
  }
}
