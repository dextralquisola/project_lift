import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../constants/styles.dart';

import './create_room_screen.dart';
import './rate_screen.dart';
import './study_room_screen.dart';
import './study_room_search_screen.dart';
import './tutee_request_screen.dart';
import '../service/study_pool_service.dart';
import '../widgets/study_card_widget.dart';
import '../../../utils/utils.dart';

import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/app_text.dart';

class StudyPoolScreen extends StatefulWidget {
  const StudyPoolScreen({super.key});

  @override
  State<StudyPoolScreen> createState() => _StudyPoolScreenState();
}

class _StudyPoolScreenState extends State<StudyPoolScreen> {
  var _scrollControllerRoom = ScrollController();
  bool _isLoading = false;

  final studyPoolService = StudyPoolService();

  @override
  void initState() {
    super.initState();

    _scrollControllerRoom = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListenerRoom);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollControllerRoom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building StudyPoolScreen!" );
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StudyRoomSearchScreen(),
                      ),
                    );
                  },
                ),
              ],
              backgroundColor: primaryColor,
            ),
            body: studyRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: "No study rooms...",
                          textSize: 20,
                        ),
                        TextButton(
                          onPressed: () async {
                            await studyPoolService.fetchStudyRooms(context);
                          },
                          child: const Text("Tap to refresh"),
                        )
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        await studyPoolService.fetchStudyRooms(context, true),
                    child: ListView.separated(
                      controller: _scrollControllerRoom,
                      itemBuilder: (context, index) => StudyPoolCard(
                        studyRoom: studyRooms[index],
                        isStudyRoomPending: studyRoomProvider
                            .isRoomPending(studyRooms[index].roomId),
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: studyRooms.length,
                    ),
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
                          if (userProvider.user.subjects.isEmpty) {
                            showSnackBar(
                              context,
                              "Please add subjects to your profile first",
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateStudyRoomScreen(),
                            ),
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.list),
                        label: 'Tutee Requests',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (contxt) => const TuteeRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : null,
          )
        : currentStudyRoomProvider.studyRoom.sessionEnded
            ? const RateScreen()
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
