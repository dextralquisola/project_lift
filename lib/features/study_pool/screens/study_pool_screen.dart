import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/study_pool/screens/create_room_screen.dart';
import 'package:project_lift/features/study_pool/widgets/study_card_widget.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';
import '../service/study_pool_service.dart';

class StudyPoolScreen extends StatelessWidget {
  const StudyPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final studyRoomProvider = Provider.of<StudyRoomProvider>(context);
    final studyRooms = studyRoomProvider.studyRooms;
    final studyPoolService = StudyPoolService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Pool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        backgroundColor: primaryColor,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) =>
            StudyPoolCard(studyRoom: studyRooms[index]),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: studyRooms.length,
      ),
      floatingActionButton: userProvider.isTutor
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: const IconThemeData(size: 22.0),
              backgroundColor: primaryColor,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'Create Study Room',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateStudyRoomScreen(),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.list),
                  label: 'Tutee Requests',
                  onTap: () {},
                ),
              ],
            )
          : null,
    );
  }
}
