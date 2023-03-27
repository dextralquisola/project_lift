import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';

import '../../../models/user.dart';

class TutorCard extends StatelessWidget {
  final User tutor;
  const TutorCard({
    super.key,
    required this.tutor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(
                            "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80",
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textBuilder(
                            "${tutor.firstName} ${tutor.lastName}", true),
                        _textBuilder("BS Computer Science"),
                        _textBuilder("Specialization:"),
                        _textBuilder("Computer Programming 1-2"),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                _textBuilder("Schedule"),
                _textBuilder("Monday - Friday: 8:00 AM - 5:00 PM"),
                const SizedBox(height: 20),
                AppButton(
                  height: 50,
                  onPressed: () {},
                  wrapRow: true,
                  text: "Ask Help",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textBuilder(String text, [isName = false]) {
    return AppText(
      text: text,
      textSize: isName ? 18 : 14,
      fontWeight: isName ? FontWeight.bold : FontWeight.w300,
    );
  }
}
