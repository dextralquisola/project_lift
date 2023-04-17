import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:project_lift/features/study_pool/screens/pending_tutees_screen.dart';
import 'package:provider/provider.dart';

import '../../../constants/styles.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/socket_client.dart';
import '../service/study_pool_service.dart';

class CurrentRoomScreen extends StatefulWidget {
  const CurrentRoomScreen({super.key});

  @override
  State<CurrentRoomScreen> createState() => _CurrentRoomScreenState();
}

class _CurrentRoomScreenState extends State<CurrentRoomScreen> {
  final _messageInputController = TextEditingController();
  var _scrollControllerMessage = ScrollController();
  var _isLoading = false;

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
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context);
    final chats = currentStudyRoomProvider.messages;
    final user = userProvider.user;

    final studyRoomService = StudyPoolService();
    return Scaffold(
      appBar: AppBar(
        title: Text(currentStudyRoomProvider.studyRoom.roomName),
        backgroundColor: primaryColor,
        actions: [
          if (user.userId == currentStudyRoomProvider.studyRoom.roomOwner)
            IconButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PendingTuteesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.pending_actions),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
                reverse: true,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                controller: _scrollControllerMessage,
                itemBuilder: (context, index) {
                  final message = chats[index];
                  return Wrap(
                    alignment: message.userId == user.userId
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.userId == user.userId
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: message.userId == user.userId
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(message.userId == user.userId
                                  ? 'You'
                                  : "${message.firstName} ${message.lastName}"),
                              Text(message.message),
                              Text(
                                DateFormat('hh:mm a').format(
                                  DateTime.parse(message.createdAt).toLocal(),
                                ),
                                style: Theme.of(context).textTheme.caption,
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
                itemCount: chats.length),
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
                    onPressed: () async {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        await studyRoomService.sendMessage(
                          roomId: currentStudyRoomProvider.studyRoom.roomId,
                          context: context,
                          message: _messageInputController.text,
                        );
                        FocusManager.instance.primaryFocus?.unfocus();
                        _messageInputController.clear();
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
    );
  }

  _scrollListenerMessage() async {
    if (_scrollControllerMessage.offset >=
            _scrollControllerMessage.position.maxScrollExtent &&
        !_scrollControllerMessage.position.outOfRange) {
      print('reached top');
      setState(() {
        _isLoading = true;
      });

      if (_isLoading) {
        //call fetch messages
        await StudyPoolService().fetchMessages(context);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}
