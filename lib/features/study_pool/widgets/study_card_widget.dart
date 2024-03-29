import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_lift/constants/styles.dart';

import '../service/study_pool_service.dart';
import '../../../models/study_room.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class StudyPoolCard extends StatelessWidget {
  final StudyRoom studyRoom;
  final bool isStudyRoomPending;
  StudyPoolCard({
    super.key,
    required this.studyRoom,
    required this.isStudyRoomPending,
  });

  final studyRoomService = StudyPoolService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showDialog(context: context, studyRoom: studyRoom),
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
                  subtitle: AppText(
                      text: studyRoom.roomOwner
                          .split(' ')
                          .map((e) => e.capitalize())
                          .join(' ')),
                  trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog({
    required BuildContext context,
    required StudyRoom studyRoom,
  }) {
    final roomSchedule = StudyRoomSchedule(scheduleString: studyRoom.schedule);
    final date = roomSchedule.scheduleDate;
    final fromTime = roomSchedule.fromTime;
    final toTime = roomSchedule.toTime;

    final participantCount = studyRoom.participants.where((participant) {
      return participant['status'] == 'accepted';
    }).length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: AppText(
              text: studyRoom.roomName,
              textSize: 20,
              fontWeight: FontWeight.w600,
              textColor: primaryColor,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: "Location: ${studyRoom.location}"),
                AppText(
                    text: "Date: ${DateFormat('MMMM dd, yyyy').format(date)}"),
                AppText(
                    text:
                        "Time: ${fromTime.format(context)} - ${toTime.format(context)}"),
                AppText(text: "Tutor: ${studyRoom.roomOwner}"),
                AppText(text: "Tutees: $participantCount"),
                const SizedBox(height: 20),
                AppButton(
                  onPressed: () async {
                    await studyRoomService.joinRoom(
                      roomId: studyRoom.roomId,
                      context: context,
                    );
                    Navigator.of(context).pop();
                  },
                  isEnabled: !isStudyRoomPending,
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
