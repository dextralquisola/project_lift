import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_lift/models/study_room.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../models/request.dart';
import '../../../providers/user_provider.dart';
import '../service/study_pool_service.dart';

class TuteeRequestScreen extends StatefulWidget {
  const TuteeRequestScreen({super.key});

  @override
  State<TuteeRequestScreen> createState() => _TuteeRequestScreenState();
}

class _TuteeRequestScreenState extends State<TuteeRequestScreen> {
  final studyRoomService = StudyPoolService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final requests = userProvider.requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutee Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            return Card(
              child: ListTile(
                title: AppText(
                    text:
                        "${index + 1}. ${request.tuteeFirstName} ${request.tuteeLastName}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showDialog(context: context, request: request);
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined),
                    ),
                    IconButton(
                      onPressed: () async {
                        await respondTutee(request.requestId, 'accepted');
                      },
                      icon: const Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () async {
                        await respondTutee(request.requestId, 'rejected');
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> respondTutee(String requestId, String requestStatus) async {
    await studyRoomService.respondTuteeRequest(
      context: context,
      requestId: requestId,
      requestStatus: requestStatus,
    );
  }

  void _showDialog({
    required BuildContext context,
    required Request request,
  }) {
    var subject = request.subject;
    var subTopics = subject.subTopics;

    final requestedSchedule =
        StudyRoomSchedule(scheduleString: request.schedule);
    final date = requestedSchedule.scheduleDate;
    final fromTime = requestedSchedule.fromTime;
    final toTime = requestedSchedule.toTime;
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
              text: "${request.tuteeFirstName} ${request.tuteeLastName}",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: "Subject: ${subject.subjectCode}"),
                ...subTopics
                    .map(
                      (subTopic) => AppText(
                          text: "${subTopic.topic} ${subTopic.description}"),
                    )
                    .toList(),
                AppText(
                  text: "Date: ${DateFormat('MMMM dd, yyyy').format(date)}",
                ),
                AppText(
                  text:
                      "Time: ${fromTime.format(context)} - ${toTime.format(context)}",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
