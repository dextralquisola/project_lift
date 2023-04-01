import 'package:flutter/material.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

class StudyPoolCard extends StatelessWidget {
  const StudyPoolCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showDialog(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Card(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    'https://picsum.photos/250?image=9',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                ListTile(
                  title: AppText(text: 'Computer Programming 1'),
                  subtitle: AppText(text: 'Dexter Jay Alquisola'),
                  trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: AppText(text: 'Computer Programming 1'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: "Location: Room 101"),
                AppText(text: "Time: 2:00 PM - 3:00 PM"),
                AppText(text: "Tutor: Dexter Jay Alquisola"),
                AppText(text: "Tutees: 5/10"),
                const SizedBox(height: 10),
                AppButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  height: 50,
                  wrapRow: true,
                  text: "Join now!",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
