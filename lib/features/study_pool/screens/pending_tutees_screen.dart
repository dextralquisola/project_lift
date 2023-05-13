import 'package:flutter/material.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/providers/current_room_provider.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../constants/styles.dart';

class PendingTuteesScreen extends StatefulWidget {
  const PendingTuteesScreen({super.key});

  @override
  State<PendingTuteesScreen> createState() => _PendingTuteesScreenState();
}

class _PendingTuteesScreenState extends State<PendingTuteesScreen> {
  final studyRoomService = StudyPoolService();
  @override
  Widget build(BuildContext context) {
    final currentRoomProvider = Provider.of<CurrentStudyRoomProvider>(context);
    final pendingParticipants = currentRoomProvider.pendingParticipants;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pending Tutee Requests'),
          backgroundColor: primaryColor,
        ),
        body: pendingParticipants.isEmpty
            ? Center(
                child: AppText(
                  text: 'No pending tutee requests',
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: pendingParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = pendingParticipants[index];
                    return Card(
                      child: ListTile(
                        title: AppText(
                            text:
                                "${participant['firstName']} ${participant['lastName']}"),
                        subtitle: AppText(text: participant['status']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await studyRoomService.respondToStudyRoomTuteeRequest(
                                  context: context,
                                  roomId: currentRoomProvider.studyRoom.roomId,
                                  status: "accepted",
                                  userId: participant['userId'],
                                );
                              },
                              icon: const Icon(Icons.check),
                            ),
                            IconButton(
                              onPressed: () async {
                                await studyRoomService.respondToStudyRoomTuteeRequest(
                                  context: context,
                                  roomId: currentRoomProvider.studyRoom.roomId,
                                  status: "rejected",
                                  userId: participant['userId'],
                                );
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ));
  }
}
