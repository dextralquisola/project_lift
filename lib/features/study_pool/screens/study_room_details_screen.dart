import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_lift/models/study_room.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_room_provider.dart';
import '../../../widgets/app_text.dart';

class StudyRoomDetailsScreen extends StatelessWidget {
  const StudyRoomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);
    final studyRoom = currentStudyRoomProvider.studyRoom;
    final roomSubject = studyRoom.subject;
    final roomSubTopics = roomSubject.subTopics;
    final participants = studyRoom.participants;

    final roomSchedule = StudyRoomSchedule(scheduleString: studyRoom.schedule);
    final date = roomSchedule.scheduleDate;
    final fromTime = roomSchedule.fromTime;
    final toTime = roomSchedule.toTime;

    return Scaffold(
      appBar: AppBar(
        title: AppText(text: 'Study Room Details', textColor: Colors.white),
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
                                  AppText(
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
                        AppText(
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
                              return ListTile(
                                leading: AppText(
                                  text: '${index + 1}.',
                                  textColor: Colors.black54,
                                  textSize: 20,
                                ),
                                title: AppText(
                                  text:
                                      '${participants[index]["firstName"]} ${participants[index]["lastName"]}',
                                ),
                                trailing: participants[index]['status'] ==
                                        'owner'
                                    ? const Icon(Icons.star,
                                        color: Colors.yellow)
                                    : participants[index]['status'] == 'pending'
                                        ? AppText(text: 'Pending')
                                        : AppText(text: 'Participant'),
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
