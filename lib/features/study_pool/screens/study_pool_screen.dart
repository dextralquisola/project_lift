import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/study_pool/screens/create_room_screen.dart';
import 'package:project_lift/features/study_pool/screens/study_room_screen.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/features/study_pool/widgets/study_card_widget.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';

class StudyPoolScreen extends StatefulWidget {
  const StudyPoolScreen({super.key});

  @override
  State<StudyPoolScreen> createState() => _StudyPoolScreenState();
}

class _StudyPoolScreenState extends State<StudyPoolScreen> {
  var _scrollControllerRoom = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollControllerRoom = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListenerRoom);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final studyRoomProvider = Provider.of<StudyRoomProvider>(context);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);
    final studyRooms = studyRoomProvider.studyRooms;

    return currentStudyRoomProvider.isEmpty
        ? Scaffold(
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
              controller: _scrollControllerRoom,
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
          )
        : const CurrentRoomScreen();
  }

  _scrollListenerRoom() async {
    if (_scrollControllerRoom.offset >=
            _scrollControllerRoom.position.maxScrollExtent &&
        !_scrollControllerRoom.position.outOfRange) {
      setState(() {
        _isLoading = true;
      });

      if (_isLoading) {
        //call fetch tutors
        await StudyPoolService().fetchStudyRooms(context);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
