import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import './pending_tutees_screen.dart';
import './study_room_details_screen.dart';
import '../../../constants/styles.dart';
import '../../../models/study_room.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/socket_client.dart';
import '../../../widgets/app_text.dart';
import '../../../utils/utils.dart' show printLog;
import '../widgets/study_room_widgets.dart';
import '../service/study_pool_service.dart';

import '../widgets/empty_room_widget.dart';
import '../widgets/message_widget.dart';

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
  PlatformFile? pickedFile;

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

    Future selectFile() async {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      setState(() {
        pickedFile = result.files.first;
        printLog(pickedFile!.name.toString(), "file");
      });
    }

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
                  const PopupMenuItem(
                    value: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info, color: Colors.amber),
                        SizedBox(width: 5),
                        AppText(text: "Studyroom Details"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                  showAlertDialog(
                    context: context,
                    user: user,
                    studyRoom: currentStudyRoomProvider.studyRoom,
                    onLeave: _onLeave,
                  );
                } else if (value == 2) {
                  showEndSessionDialog(
                    context: context,
                    user: user,
                    studyRoom: currentStudyRoomProvider.studyRoom,
                    onEndSession: _endSession,
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            chats.isEmpty
                ? const EmptyMsgWidget()
                : Expanded(
                    child: ListView.separated(
                      reverse: true,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      controller: _scrollControllerMessage,
                      itemBuilder: (context, index) {
                        return MessageWidget(message: chats[index], user: user);
                      },
                      separatorBuilder: (_, index) => const SizedBox(
                        height: 5,
                      ),
                      itemCount: chats.length,
                    ),
                  ),
            if (pickedFile != null)
              Container(
                height: 50,
                color: Colors.greenAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: SizedBox(
                        child: AppText(
                          textColor: Colors.black,
                          text: _cropFileLongFileName(pickedFile!.name),
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          pickedFile = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
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
                    IconButton(
                      onPressed: selectFile,
                      icon: const FaIcon(
                        FontAwesomeIcons.paperclip,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 5),
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
                          : () async => await _sendMsg(
                                studyRoom: currentStudyRoomProvider.studyRoom,
                              ),
                      icon: isSendingMsg
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.send),
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

  String _cropFileLongFileName(String filename) {
    if (filename.length > 20) {
      return "${filename.substring(0, 5)}...${filename.substring(filename.length - 10, filename.length)}";
    }
    return filename;
  }

  Future<void> _sendMsg({
    required StudyRoom studyRoom,
  }) async {
    if (_messageInputController.text.trim().isNotEmpty || pickedFile != null) {
      setState(() {
        isSendingMsg = true;
      });
      await studyRoomService.sendMessage(
        context: context,
        roomId: studyRoom.roomId,
        message: _messageInputController.text,
        file: pickedFile,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      _messageInputController.clear();

      setState(() {
        pickedFile = null;
        isSendingMsg = false;
      });
    }
  }

  _onLeave() async {
    setState(() {
      isLoading = true;
    });

    await studyRoomService.leaveStudyRoom(context);

    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  _endSession() async {
    Navigator.of(context).pop();
    await studyRoomService.endStudySession(context: context);
  }

  _scrollListenerMessage() async {
    if (_scrollControllerMessage.offset >=
            _scrollControllerMessage.position.maxScrollExtent &&
        !_scrollControllerMessage.position.outOfRange) {
      await StudyPoolService().fetchMessages(context);
    }
  }
}
