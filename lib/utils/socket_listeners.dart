import 'package:flutter/material.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:provider/provider.dart';

import '../providers/current_room_provider.dart';
import '../providers/user_provider.dart';

class SocketListeners {
  final _socket = SocketClient.instance.socket!;

  void activateEventListeners(BuildContext context) {
    _onMessageEvent(context);
    _onParticipantJoinEvent(context);
  }

  void _onMessageEvent(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on('message-sent', (data) {
      if (userProvider.user.userId != data['userId']) {
        currentRoomProvider.addMessage(data['message']);
      }
    });
  }

  void _onParticipantJoinEvent(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("new-pending-participant", (data) {
      print("event fired new-pending-participant");
      print(data);
      currentRoomProvider.addParticipant(data);
    });
  }
}
