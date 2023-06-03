import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/user_provider.dart';

class TutorialScreen extends StatefulWidget {
  final bool isViewOnly;
  const TutorialScreen({
    super.key,
    this.isViewOnly = false,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  var dontShowAgain = false;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _customTextBuilder("1. Open your CvSU Portal account."),
              _customTextBuilder("2. Navigate to 'Grades'"),
              _customTextBuilder(
                  "3. Make a snippet of your grades one semester at a time."),
              _customTextBuilder(
                  "3.1 It's for initial data entry. You can add more later."),
              _customTextBuilder("4. It must be in this format:"),
              _customTextBuilder(
                  "4.1 Make sure to add this on the snippet (Table headers)"),
              _imageBuilder("assets/images/grade_makesure.JPG"),
              _customTextBuilder("4.2 Correct Format:"),
              _imageBuilder("assets/images/grade_allow1.JPG"),
              _customTextBuilder("4.3 Correct Format:"),
              _imageBuilder("assets/images/grade_allow2.JPG"),
              _customTextBuilder("4.4 Denied Format:"),
              _imageBuilder("assets/images/grade_deny1.JPG"),
              const SizedBox(height: 20),
              widget.isViewOnly
                  ? const SizedBox()
                  : CheckboxListTile(
                      title: const Text("Don't show this again"),
                      value: dontShowAgain,
                      onChanged: (value) {
                        setState(() {
                          dontShowAgain = value!;
                        });
                      },
                    ),
              AppButton(
                wrapRow: true,
                height: 50,
                onPressed: widget.isViewOnly
                    ? () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        prefs.setBool('isTutorialDoNotShow', dontShowAgain);
                        userProvider.setIsTutorialDoNotShow(dontShowAgain);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                text: "Continue",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customTextBuilder(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppText(
        text: text,
        textSize: 16,
      ),
    );
  }

  Widget _imageBuilder(String path) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        child: Image.asset(
          path,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
