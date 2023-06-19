import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import './pending_tutees_screen.dart';
import './study_room_details_screen.dart';
import '../../../constants/styles.dart';
import '../../../models/study_room.dart';
import '../../../models/user.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/socket_client.dart';
import '../../../widgets/app_text.dart';
import '../../../utils/utils.dart' show capitalize;
import '../service/study_pool_service.dart';

class CurrentRoomScreen extends StatefulWidget {
  const CurrentRoomScreen({super.key});

  @override
  State<CurrentRoomScreen> createState() => _CurrentRoomScreenState();
}

class _CurrentRoomScreenState extends State<CurrentRoomScreen> {
  final _messageInputController = TextEditingController();
  var _scrollControllerMessage = ScrollController();
  var isSendingMsg = false;
  var isLoading = false;

  final _socket = SocketClient.instance.socket!;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      _socket.emit('join-room', {
        'roomId': currentStudyRoomProvider.studyRoom.roomId,
      });
    });

    _scrollControllerMessage = ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListenerMessage);
  }

  @override
  void dispose() {
    super.dispose();
    _messageInputController.dispose();
    _scrollControllerMessage.dispose();
  }

  final studyRoomService = StudyPoolService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);
    final chats = currentStudyRoomProvider.messages;
    final user = userProvider.user;

    final roomSchedule = StudyRoomSchedule(
        scheduleString: currentStudyRoomProvider.studyRoom.schedule);
    final date = roomSchedule.scheduleDate;

    final isEndSessionEnabled = DateTime.now().isAfter(date) &&
        currentStudyRoomProvider.studyRoom.participants
            .where((participant) => participant['status'] == 'accepted')
            .isNotEmpty;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: AppText(
            text: currentStudyRoomProvider.studyRoom.roomName,
            textColor: Colors.white,
          ),
          backgroundColor: primaryColor,
          actions: [
            if (user.userId == currentStudyRoomProvider.studyRoom.roomOwner)
              currentStudyRoomProvider.pendingParticipants.isNotEmpty
                  ? badges.Badge(
                      badgeContent: AppText(
                        text:
                            "${currentStudyRoomProvider.pendingParticipants.length}",
                        textColor: Colors.white,
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Colors.redAccent,
                        shape: badges.BadgeShape.circle,
                        elevation: 1,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PendingTuteesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.pending_actions),
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PendingTuteesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.pending_actions),
                    ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info, color: Colors.amber),
                        SizedBox(width: 5),
                        AppText(text: "Studyroom Details"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.exit_to_app, color: Colors.redAccent),
                        SizedBox(width: 5),
                        AppText(text: "Leave Room"),
                      ],
                    ),
                  ),
                  if (userProvider.user.userId ==
                      currentStudyRoomProvider.studyRoom.roomOwner)
                    PopupMenuItem(
                      value: 2,
                      enabled: isEndSessionEnabled,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.exit_to_app, color: Colors.red),
                          const SizedBox(width: 5),
                          AppText(
                            text: "End session",
                            textColor: isEndSessionEnabled
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                ];
              },
              onSelected: (value) async {
                if (value == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudyRoomDetailsScreen(),
                    ),
                  );
                } else if (value == 1) {
                  await _showAlertDialog(
                    context: context,
                    studyRoom: currentStudyRoomProvider.studyRoom,
                    user: userProvider.user,
                  );
                } else if (value == 2) {
                  await _showEndSessionDialog(
                    context: context,
                    studyRoom: currentStudyRoomProvider.studyRoom,
                    user: userProvider.user,
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            chats.isEmpty
                ? const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: AppText(
                        text: "Send hello to get started! 😊",
                        textSize: 20,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      reverse: true,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      controller: _scrollControllerMessage,
                      itemBuilder: (context, index) {
                        final message = chats[index];
                        final formattedName =
                            "${capitalize(message.firstName)} ${capitalize(message.lastName)}";
                        return Wrap(
                          alignment: message.userId == user.userId
                              ? WrapAlignment.end
                              : WrapAlignment.start,
                          children: [
                            Card(
                              color: message.userId == user.userId
                                  ? const Color(0xff2A813E)
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      message.userId == user.userId
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    if (message.userId != user.userId)
                                      AppText(
                                        textColor: primaryColor,
                                        fontWeight: FontWeight.w600,
                                        text: formattedName,
                                      ),
                                    AppText(
                                      textSize: 14,
                                      textColor: message.userId == user.userId
                                          ? Colors.white
                                          : Colors.black,
                                      text: message.message,
                                    ),
                                    AppText(
                                      textSize: 11,
                                      textColor: message.userId == user.userId
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w300,
                                      text: DateFormat('hh:mm a').format(
                                        DateTime.parse(message.createdAt)
                                            .toLocal(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                      separatorBuilder: (_, index) => const SizedBox(
                        height: 5,
                      ),
                      itemCount: chats.length,
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageInputController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isSendingMsg
                          ? () {}
                          : () async {
                              if (_messageInputController.text
                                  .trim()
                                  .isNotEmpty) {
                                setState(() {
                                  isSendingMsg = true;
                                });
                                await studyRoomService.sendMessage(
                                  roomId:
                                      currentStudyRoomProvider.studyRoom.roomId,
                                  context: context,
                                  message: _messageInputController.text,
                                );
                                FocusManager.instance.primaryFocus?.unfocus();
                                _messageInputController.clear();

                                setState(() {
                                  isSendingMsg = false;
                                });
                              }
                            },
                      icon: const Icon(Icons.send),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showAlertDialog({
    required BuildContext context,
    required User user,
    required StudyRoom studyRoom,
  }) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const AppText(
        text: "Cancel",
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const AppText(text: "Leave", textColor: Colors.red),
      onPressed: () async {
        setState(() {
          isLoading = true;
        });
        await studyRoomService.leaveStudyRoom(context);
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const AppText(
        text: "Warning!",
        textColor: Colors.red,
        textSize: 20,
        fontWeight: FontWeight.w600,
      ),
      content: AppText(
        text: user.userId == studyRoom.roomOwner
            ? "Are you sure you want to leave this study room? The room will be deleted and the tutees will be notified and kicked to the room. "
            : "Are you sure you want to leave this study room?",
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showEndSessionDialog({
    required BuildContext context,
    required User user,
    required StudyRoom studyRoom,
  }) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const AppText(
        text: "Cancel",
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const AppText(text: "End session", textColor: Colors.red),
      onPressed: () async {
        Navigator.of(context).pop();
        await studyRoomService.endStudySession(context: context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const AppText(
        text: "Warning!",
        textColor: Colors.red,
        textSize: 20,
        fontWeight: FontWeight.w600,
      ),
      content: const AppText(
          text: "Are you sure you want to end this study session?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _scrollListenerMessage() async {
    if (_scrollControllerMessage.offset >=
            _scrollControllerMessage.position.maxScrollExtent &&
        !_scrollControllerMessage.position.outOfRange) {
      await StudyPoolService().fetchMessages(context);
    }
  }
}
