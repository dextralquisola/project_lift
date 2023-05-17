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
    _onParticipantJoined(context);
    _onAcceptedAsTutor(context);
    _onRejectedAsTutor(context);
    _onParticipantRejected(context);
    _onParticipantCancelled(context);
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

  void _onParticipantJoined(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("participant-joined", (data) {
      currentRoomProvider.updateParticipantById(data['userId']);
    });
  }

  void _onParticipantRejected(BuildContext context) {
    final studyRoomProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    _socket.on("participant-rejected", (data) {
      print("Onparticipant rejected");
      print(data);
      studyRoomProvider.removePendingRoomById(data['chatRoom']['_id']);
    });
  }

  void _onParticipantCancelled(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("participant-cancelled", (data) {
      print("Onparticipant cancelled");
      print(data);
      currentRoomProvider.removeParticipantById(data['userId']);
    });
  }

  void _onUserLeftRoom(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("user-left", (data) {
      if (currentRoomProvider.studyRoom.roomOwner != data['user']['userId']) {
        currentRoomProvider.removeParticipantById(
          data['user']['userId'],
          !data['sessionEnded'],
        );
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

  void _onAcceptedAsTutor(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _socket.on(
      "tutor-application-approved",
      (data) {
        userProvider.setUserFromModel(userProvider.user.copyFrom(
          role: "tutor",
        ));
        userRequestsProvider.clearRequests();
      },
    );
  }

  void _onRejectedAsTutor(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("tutor-application-rejected", (data) {
      userRequestsProvider.clearTutorApplication();
    });
  }
}
