import 'package:flutter/material.dart';
import 'package:project_lift/providers/study_room_providers.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:provider/provider.dart';

import '../providers/current_room_provider.dart';
import '../providers/user_provider.dart';
import '../providers/user_requests_provider.dart';

class SocketListeners {
  final _socket = SocketClient.instance.socket!;

  void activateEventListeners(BuildContext context) {
    _onMessageEvent(context);
    _onParticipantJoinEvent(context);
    _onParticipantAcceptedEvent(context);
    _onUserLeftRoom(context);
    _onRoomDeleted(context);
    _onSessionEnded(context);
    _onRequestAccepted(context);
    _onRequestRejected(context);
    _onTuteeRequested(context);
  }

  void _onMessageEvent(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);

    _socket.on('message-sent', (data) {
      if (userProvider.user.userId != data['user']['userId']) {
        currentRoomProvider.addMessage(data);
      }
    });
  }

  void _onParticipantJoinEvent(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);

    _socket.on("new-pending-participant", (data) {
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

  void _onParticipantAcceptedEvent(BuildContext context) {
    final studyRoomProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("participant-accepted", (data) {
      currentRoomProvider.setStudyRoomFromJson(data['chatRoom']);
      currentRoomProvider.setMessagesFromJson(data['messages']);
      studyRoomProvider.clearPendingRooms();
    });
  }

  void _onUserLeftRoom(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _socket.on("user-left", (data) {
      if (userProvider.user.userId != data['user']['userId']) {
        final currentRoomProvider =
            Provider.of<CurrentStudyRoomProvider>(context, listen: false);
        if (currentRoomProvider.studyRoom.roomId == data['roomId']) {
          currentRoomProvider.removeParticipantById(data['user']['userId']);
        }
      }
    });
  }

  void _onRoomDeleted(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    final studyRoomProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    
    _socket.on("room-deleted", (data) {

      print("on room deleted");
      print(data);

      _socket.emit("leave-room", {
        "roomId": currentRoomProvider.studyRoom.roomId,
      });

      studyRoomProvider
          .removeStudyRoomById(currentRoomProvider.studyRoom.roomId);
      currentRoomProvider.clearRoom();
    });
  }

  void _onSessionEnded(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("session-ended", (data) {
      currentRoomProvider.setStudyRoomSessionEnded();
    });
  }

  void _onRequestAccepted(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("request-accepted", (data) {
      currentRoomProvider.setStudyRoomFromJson(data['chatroom']);
      userRequestsProvider.removeMyRequestById(data['request']['_id']);
    });
  }

  void _onRequestRejected(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("request-rejected", (data) {
      userRequestsProvider.removeMyRequestById(data['_id']);
    });
  }

  void _onTuteeRequested(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("new-request", (data) {
      userRequestsProvider.addTuteeRequestsFromMap([data], true);
    });
  }
}
