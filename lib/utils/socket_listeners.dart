import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_room.dart';
import './socket_client.dart';
import '../models/subject.dart';

import '../providers/app_state_provider.dart';
import '../providers/study_room_providers.dart';
import '../providers/current_room_provider.dart';
import '../providers/tutors_provider.dart';
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
    _onNewReport(context);
    _onReportResult(context);
    _onRequestRemove(context);
    _onLoginOtherDevice(context);
    _onNewTodo(context);
    _onUpdateTodo(context);
    _onDeleteTodoItem(context);
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
      studyRoomProvider.removePendingRoomById(data['chatRoom']['_id']);
      //printLog(data, "participant-rejected");
    });
  }

  void _onParticipantCancelled(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("participant-cancelled", (data) {
      currentRoomProvider.removeParticipantById(data['userId']);
      //printLog(data, "participant-cancelled");
    });
  }

  void _onUserLeftRoom(BuildContext context) {
    final currentRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("user-left", (data) {
      //printLog(data, "user-left");
      if (data['sessionEnded'] != null &&
          currentRoomProvider.studyRoom.roomOwner != data['user']['userId']) {
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
      //printLog(data, "room-deleted");

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

  void _onRequestRemove(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("request-remove", (data) {
      userRequestsProvider.removeTuteeRequestById(data['_id']);
    });
  }

  void _onTuteeRequested(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    _socket.on("new-request", (data) {
      userRequestsProvider.addSingleTuteeRequestFromMap(data, true);
    });
  }

  void _onAcceptedAsTutor(BuildContext context) {
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _socket.on(
      "tutor-application-approved",
      (data) {
        //printLog(data, "tutor-application-approved");
        userProvider.setUserFromModel(userProvider.user.copyFrom(
          role: "tutor",
          subjects: List<Subject>.from(
            data['subject'].map((subject) => Subject.fromMap(subject)),
          ),
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

  void _onNewReport(BuildContext context) {
    final userProvider = Provider.of<AppStateProvider>(context, listen: false);
    _socket.on("new-report", (data) {
      userProvider.setNotif(data);
    });
  }

  void _onReportResult(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tutorsProvider = Provider.of<TutorProvider>(context, listen: false);
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
    final studyPoolProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
    final currentStudyRoomProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);

    _socket.on("report-result", (data) async {
      if (data['status'] == 'resolved') {
        if (data['reportedUser'] == userProvider.user.userId) {
          tutorsProvider.clearTutors();
          userRequestsProvider.clearRequests();
          studyPoolProvider.clearStudyRooms();
          currentStudyRoomProvider.clearRoom();
          await userProvider.logout();
        } else {
          //printLog(data, "report-result");
        }
      }
    });
  }

  void _onLoginOtherDevice(BuildContext context) {
    final appStateProvider =
        Provider.of<AppStateProvider>(context, listen: false);
    _socket.on("logged-in-other-device", (data) async {
      appStateProvider.setNotifLogout(data);
    });
  }

  void _onNewTodo(BuildContext context) {
    final todoProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("create-todo", (data) {
      todoProvider.addTodoItem(ToDo.fromMap(data));
    });
  }

  void _onUpdateTodo(BuildContext context) {
    final todoProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("update-todo", (data) {
      todoProvider.updateTodoItem(ToDo.fromMap(data));
    });
  }

  void _onDeleteTodoItem(BuildContext context) {
    final todoProvider =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    _socket.on("delete-todo", (data) {
      todoProvider.removeTodoItem(data);
    });
  }
}
