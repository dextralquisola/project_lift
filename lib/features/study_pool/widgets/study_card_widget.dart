import 'package:flutter/material.dart';
import 'package:project_lift/models/study_room.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

class StudyPoolCard extends StatelessWidget {
  final StudyRoom studyRoom;
  const StudyPoolCard({
    super.key,
    required this.studyRoom,
  });

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
                  title: AppText(text: studyRoom.roomName),
                  subtitle: AppText(text: studyRoom.roomOwner),
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
                AppText(
                  text: "Description:",
                  fontWeight: FontWeight.bold,
                ),
                AppText(
                    text:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel ultricies lacinia, nunc nisl ultricies nunc, nec ultricies nisl nunc vel nunc. Sed euismod, nunc vel ultricies lacinia, nunc nisl ultricies nunc, nec ultricies nisl nunc vel nunc."),
                const SizedBox(height: 20),
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
