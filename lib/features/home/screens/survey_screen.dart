import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/app_text.dart';

class SurveyScreen extends StatelessWidget {
  SurveyScreen({super.key});

  final Uri _urlTechnical = Uri.parse('https://forms.gle/EyrgHruM2GvLpBUv6');
  final Uri _urlNonTechnical = Uri.parse('https://forms.gle/iBr7TzP9aHaVEUJi9');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text:
                    'We kindly request your participation in a survey for our thesis research, focusing on gathering insights about user experiences with our mobile application. Your valuable feedback will greatly contribute to our study, and we would greatly appreciate your time in completing the survey.',
                textSize: 20,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              AppText(
                text: "For non-tech user (e.g., Students)",
                textSize: 20,
              ),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () async {
                  await _launchUrl(_urlNonTechnical);
                },
                text: "Survey for non-tech user",
                wrapRow: true,
                height: 50,
              ),
              const SizedBox(height: 20),
              AppText(
                text: "For techinical user (e.g., IT professionals)",
                textSize: 20,
              ),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () async {
                  await _launchUrl(_urlTechnical);
                },
                text: "Survey for technical users",
                wrapRow: true,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
