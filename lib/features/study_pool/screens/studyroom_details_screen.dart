import 'package:flutter/material.dart';
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
    print('room partocopants: $participants');
    return Scaffold(
      appBar: AppBar(
        title: AppText(text: 'Study Room Details', textColor: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
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
                          text:
                              'Room subject: ${roomSubject.subjectCode}, ${roomSubject.description}',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text: 'Room sub topics:',
                          textColor: Colors.black,
                          textSize: 20,
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: roomSubTopics.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: AppText(
                                    text: 'Topic: ${roomSubTopics[index].topic}',
                                  ),
                                  subtitle: AppText(
                                    text: 'Description: ${roomSubTopics[index].description}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(thickness: 2),
                        const SizedBox(height: 10),
                        AppText(
                          text: 'Room members:',
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
            ),
          ],
        ),
      ),
    );
  }
}
