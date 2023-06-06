import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/service/tutor_service.dart';

import '../../../widgets/app_text.dart';

class NoTutorWidget extends StatelessWidget {
  NoTutorWidget({super.key});
  final tutorService = TutorService();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(text: "There is no tutor available.", textSize: 20),
          TextButton(
            onPressed: () async =>
                await tutorService.fetchTutors(context, true),
            child: const Text("Tap to refresh"),
          )
        ],
      ),
    );
  }
}
