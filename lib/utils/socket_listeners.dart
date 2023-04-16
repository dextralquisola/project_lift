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
    _onParticipantAcceptedEvent(context);
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
      print(data.toString());
      var participant = data['user']['participants'][0];
      var newParticipant = {
        "userId": participant['userId']['_id'],
        "firstName": participant['userId']['firstName'],
        "lastName": participant['userId']['lastName'],
        "status": participant['status'],
      };
      currentRoomProvider.addParticipant(newParticipant);
    });
  }

  void _onParticipantAcceptedEvent(BuildContext context){
    _socket.on("participant-accepted", (data){
      print("event fired participant-accepted");
      print(data.toString());
      print("event fired participant-accepted");

      final currentRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);
      currentRoomProvider.setStudyRoomFromJson(data['chatRoom']);
      
    });
  }
}
