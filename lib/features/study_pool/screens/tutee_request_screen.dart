import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/widgets/tutor_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/study_room.dart';
import '../../../widgets/app_text.dart';
import '../../../models/request.dart';
import '../../../providers/user_requests_provider.dart';
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
    final userRequestsProvider = Provider.of<UserRequestsProvider>(context);
    final requests = userRequestsProvider.requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutee Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: requests.isEmpty
            ? const Center(
                child: AppText(text: 'No tutee requests'),
              )
            : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final formattedName =
                      '${request.tuteeFirstName.capitalize()} ${request.tuteeLastName.capitalize()}';
                  return Card(
                    child: ListTile(
                      title: AppText(text: "${index + 1}. $formattedName"),
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
                            icon: const Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await respondTutee(request.requestId, 'rejected');
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
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

    if (requestStatus == 'accepted') {
      Navigator.of(context).pop();
    }
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

    final rating = request.parsedRating();
    final ratings = request.getRatingsAsTutee;

    final formattedName =
        '${request.tuteeFirstName.capitalize()} ${request.tuteeLastName.capitalize()}';

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
              text: formattedName,
              fontWeight: FontWeight.w600,
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
                AppText(text: "Location: ${request.location}"),
                AppText(
                  text: "Date: ${DateFormat('MMMM dd, yyyy').format(date)}",
                ),
                AppText(
                  text:
                      "Time: ${fromTime.format(context)} - ${toTime.format(context)}",
                ),
                const SizedBox(height: 10),
                AppText(
                  text: "Rating: $rating ⭐️ (${ratings.length})",
                ),
                const SizedBox(height: 10),
                const AppText(
                  text: "Comments: ",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
