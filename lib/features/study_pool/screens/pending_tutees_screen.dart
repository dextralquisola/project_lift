import 'package:flutter/material.dart';
import 'package:project_lift/providers/current_room_provider.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:provider/provider.dart';

import '../../../constants/styles.dart';

class PendingTuteesScreen extends StatefulWidget {
  const PendingTuteesScreen({super.key});

  @override
  State<PendingTuteesScreen> createState() => _PendingTuteesScreenState();
}

class _PendingTuteesScreenState extends State<PendingTuteesScreen> {
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
                              onPressed: () {},
                              icon: const Icon(Icons.check),
                            ),
                            IconButton(
                              onPressed: () {},
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
