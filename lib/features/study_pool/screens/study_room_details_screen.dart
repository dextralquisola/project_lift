import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/report_widget.dart';
import 'package:provider/provider.dart';

import '../../../models/study_room.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/app_text.dart';

class StudyRoomDetailsScreen extends StatelessWidget {
  const StudyRoomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);

    if (currentStudyRoomProvider.isEmpty ||
        currentStudyRoomProvider.studyRoom.sessionEnded) {
      Navigator.of(context).pop();
    }

    final studyRoom = currentStudyRoomProvider.studyRoom;
    final roomSubject = studyRoom.subject;
    final roomSubTopics = roomSubject.subTopics;
    final participants = studyRoom.participants;

    final roomSchedule = StudyRoomSchedule(scheduleString: studyRoom.schedule);
    late DateTime date;
    late TimeOfDay fromTime;
    late TimeOfDay toTime;

    if (currentStudyRoomProvider.isEmpty) {
      date = DateTime.now();
      fromTime = TimeOfDay.now();
      toTime = TimeOfDay.now();
    } else {
      date = roomSchedule.scheduleDate;
      fromTime = roomSchedule.fromTime;
      toTime = roomSchedule.toTime;
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const AppText(text: 'Study Room Details', textColor: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text:
                              'Room name: ${currentStudyRoomProvider.studyRoom.roomName}',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text: 'Location: ${studyRoom.location}',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text:
                              'Schedule:\n${DateFormat('MMMM dd, yyyy').format(date)} from ${fromTime.format(context)} - ${toTime.format(context)}',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text:
                              'Room subject: ${roomSubject.subjectCode}, ${roomSubject.description}',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        const SizedBox(height: 10),
                        roomSubject.subTopics.isEmpty
                            ? const SizedBox()
                            : Column(
                                children: [
                                  const AppText(
                                    text: 'Room sub topics:',
                                    textColor: Colors.black,
                                    textSize: 20,
                                  ),
                                  ...roomSubTopics
                                      .map(
                                        (e) => Card(
                                          child: ListTile(
                                            title: AppText(
                                              text: 'Topic: ${e.topic}',
                                            ),
                                            subtitle: AppText(
                                              text:
                                                  'Description: ${e.description}',
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ],
                              ),
                        const SizedBox(height: 10),
                        const AppText(
                          text: 'Room participants:',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: currentStudyRoomProvider
                                .studyRoom.participants.length,
                            itemBuilder: (context, index) {
                              final formattedName = capitalize(
                                  participants[index]['firstName'] +
                                      ' ' +
                                      participants[index]['lastName']);
                              return GestureDetector(
                                onLongPress: participants[index]['userId'] ==
                                        userProvider.user.userId
                                    ? () {}
                                    : () {
                                        showReportDialog(
                                            context: context,
                                            userParticipant:
                                                participants[index]);
                                      },
                                child: ListTile(
                                  leading: AppText(
                                    text: '${index + 1}.',
                                    textColor: Colors.black54,
                                    textSize: 20,
                                  ),
                                  title: AppText(
                                    text: formattedName,
                                  ),
                                  trailing: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      participants[index]['status'] == 'owner'
                                          ? const Icon(Icons.star,
                                              color: Colors.yellow)
                                          : participants[index]['status'] ==
                                                  'pending'
                                              ? const AppText(text: 'Pending')
                                              : const AppText(
                                                  text: 'Participant'),
                                      const SizedBox(width: 10),
                                      participants[index]['userId'] ==
                                              userProvider.user.userId
                                          ? const SizedBox()
                                          : IconButton(
                                              onPressed: () {
                                                showReportDialog(
                                                    context: context,
                                                    userParticipant:
                                                        participants[index]);
                                              },
                                              icon: const Icon(Icons.more_vert),
                                            )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
