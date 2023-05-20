import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/styles.dart';

import '../../../providers/user_requests_provider.dart';
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

import 'package:badges/badges.dart' as badges;

class StudyPoolScreen extends StatefulWidget {
  const StudyPoolScreen({super.key});

  @override
  State<StudyPoolScreen> createState() => _StudyPoolScreenState();
}

class _StudyPoolScreenState extends State<StudyPoolScreen> {
  var _scrollControllerRoom = ScrollController();
  bool _isLoading = false;
  bool _isDisposed = false;

  final studyPoolService = StudyPoolService();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _scrollControllerRoom = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListenerRoom);
  }

  @override
  void deactivate() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      _isDisposed = true;
      _scrollControllerRoom.dispose();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _scrollControllerRoom.dispose();
    }
    super.dispose();
    isDialOpen.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final studyRoomProvider = Provider.of<StudyRoomProvider>(context);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);
    final userRequestsProvider = Provider.of<UserRequestsProvider>(context);
    final tuteeRequests = userRequestsProvider.requests;

    final studyRooms = studyRoomProvider.studyRooms;

    return currentStudyRoomProvider.isEmpty
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Study pool 💻'),
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
                ? tuteeRequests.isNotEmpty
                    ? badges.Badge(
                        badgeContent: AppText(
                          text: "${tuteeRequests.length}",
                          textColor: Colors.white,
                        ),
                        child: SpeedDial(
                          animatedIcon: AnimatedIcons.menu_close,
                          animatedIconTheme: const IconThemeData(size: 22.0),
                          backgroundColor: primaryColor,
                          openCloseDial: isDialOpen,
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
                              child: badges.Badge(
                                badgeContent: Text(
                                  "${tuteeRequests.length}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                child: const Icon(Icons.list),
                              ),
                              label: 'Tutee Requests',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (contxt) =>
                                        const TuteeRequestScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : SpeedDial(
                        animatedIcon: AnimatedIcons.menu_close,
                        animatedIconTheme: const IconThemeData(size: 22.0),
                        backgroundColor: primaryColor,
                        openCloseDial: isDialOpen,
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
                                  builder: (contxt) =>
                                      const TuteeRequestScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                : null,
          )
        : currentStudyRoomProvider.studyRoom.sessionEnded
            ? FutureBuilder(
                future: getResBody(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    return RateScreen(
                      resBody: snapshot.data,
                    );
                  }

                  return const SizedBox();
                },
              )
            : const CurrentRoomScreen();
  }

  Future<String?> getResBody() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('toRateParticipants');
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

      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
