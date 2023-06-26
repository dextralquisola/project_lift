import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/constants.dart';
import '../../../utils/socket_client.dart';
import '../../../utils/utils.dart';

import '../../../models/study_room.dart';
import '../../../models/subject.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/user_requests_provider.dart';
import '../../../utils/http_utils.dart' as service;
import '../../../utils/storage_utils.dart' as storage;

class StudyPoolService {
  Future<void> createStudyPool({
    required String studyPoolName,
    required BuildContext context,
    required StudyRoomStatus status,
    required Subject subject,
    required List<SubTopic> subTopics,
    required String location,
    required String schedule,
  }) async {
    // function here
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);
      final currentStudyRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );

      var res = await service.requestApi(
        path: '/api/studyroom/create',
        userAuthHeader: userProvider,
        body: {
          'name': studyPoolName,
          'status': status == StudyRoomStatus.public ? 'public' : 'private',
          'subjectCode': subject.subjectCode,
          'description': subject.description,
          'subtopics': subTopicListToMap(subTopics),
          'location': location,
          'schedule': schedule,
        },
        method: 'POST',
      );

      if (res.statusCode == 200) {
        // success
        studyRoomProvider.addSingleStudyRoom(json.decode(res.body));
        currentStudyRoomProvider.setStudyRoomFromJson(json.decode(res.body));
        currentStudyRoomProvider.addParticipant({
          'userId': userProvider.user.userId,
          'firstName': userProvider.user.firstName,
          'lastName': userProvider.user.lastName,
          'status': 'owner',
        });
      } else {
        // error
      }
    } catch (e) {
      printLog(e.toString(), "createStudyPool error");
    }
  }

  Future<void> getUserRoom(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      var chatRoomRes = await service.requestApi(
        path: '/api/studyroom/user-room',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      printHttpLog(chatRoomRes, "/api/studyroom/user-room");

      if (chatRoomRes.statusCode == 200 && chatRoomRes.statusCode != 404) {
        //fetch the chatroom data
        var decoded = json.decode(chatRoomRes.body);
        currentRoomProvider.setStudyRoomFromJson(decoded);
        currentRoomProvider.studyRoom.printRoom();

        var resMessages = await service.requestApi(
          path:
              '/api/studyroom/messages/${currentRoomProvider.studyRoom.roomId}?page=${currentRoomProvider.currentMessagePage}',
          method: 'GET',
          userAuthHeader: userProvider,
        );

        printHttpLog(resMessages, "/api/studyroom/messages");

        if (resMessages.statusCode == 200) {
          var messages = json.decode(resMessages.body)['messages'];
          currentRoomProvider.setMessagesFromJson(messages);
        }
      }
    } catch (e) {
      printLog(e.toString(), "getUserRoom error");
    }
  }

  Future<void> fetchMessages(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      var currentRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );
      var resMessages = await service.requestApi(
        path:
            '/api/studyroom/messages/${currentRoomProvider.studyRoom.roomId}?page=${currentRoomProvider.currentMessagePage}',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (resMessages.statusCode == 200) {
        var messages = json.decode(resMessages.body)['messages'];
        currentRoomProvider.setMessagesFromJson(messages);
      }
    } catch (e) {
      printLog(e.toString(), "fetchMessages error");
    }
  }

  Future<void> fetchStudyRooms(BuildContext context,
      [bool isRefresh = false]) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);

      if (isRefresh) studyRoomProvider.clearStudyRooms(false);

      var res = await service.requestApi(
        path: '/api/studyroom/public?page=${studyRoomProvider.currentPage}',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        studyRoomProvider.addStudyRoomFromJson(json.decode(res.body), false);
      } else {
        printHttpLog(res, "/api/studyroom/public error");
      }
    } catch (e) {
      printLog(e.toString(), "fetchStudyRooms error");
    }
  }

  Future<void> sendMessage({
    required String roomId,
    required String message,
    PlatformFile? file,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      var fileUrl = "";
      if (file != null) {
        fileUrl = await storage.StorageMethods().uploadFile(
          filePath: file.path!,
          fileName: "files/${DateTime.now().toIso8601String()}_${file.name}",
        );
      }

      printLog(fileUrl, "fileUrl");

      var res = await service.requestApi(
        path: '/api/studyroom/messages',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          'roomId': roomId,
          'message': message,
          'fileUrl': fileUrl,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

      printHttpLog(res, "/api/studyroom/messages");

      if (res.statusCode == 200) {
        currentStudyRoomProvider.addMessage(json.decode(res.body));
      } else {
        printHttpLog(res, "sendMessage error");
      }
    } catch (e) {
      printLog(e.toString(), "sendMessage error");
    }
  }

  Future<void> joinRoom({
    required String roomId,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);

      var joinResRoom = await service.requestApi(
        path: '/api/studyroom/join/$roomId',
        method: 'POST',
        userAuthHeader: userProvider,
      );

      if (!context.mounted) return;

      if (joinResRoom.statusCode == 202) {
        studyRoomProvider.addPendingRoom(roomId);
        showSnackBar(context, "Room joined!, waiting for tutor to accept");
      } else {
        printHttpLog(joinResRoom, "joinRoom error");
      }
    } catch (e) {
      printLog(e.toString(), "joinRoom error");
    }
  }

  Future<void> respondToStudyRoomTuteeRequest({
    required String roomId,
    required String userId,
    required String status,
    required BuildContext context,
  }) async {
    try {
      final currentStudyRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/studyroom/accept-participant/$roomId/$userId/$status',
        method: 'PATCH',
        userAuthHeader: userProvider,
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        // success

        printHttpLog(res, "/api/studyroom/accept-participant");

        if (res.body == "User accepted successfully.") {
          currentStudyRoomProvider.acceptParticipant(userId);
          showSnackBar(context, "Tutee accepted!");
        } else if (res.body == "User rejected successfully.") {
          currentStudyRoomProvider.removeParticipantById(userId);
          showSnackBar(context, "Tutee rejected!");
        }
      } else {
        printHttpLog(res, "respondToStudyRoomTuteeRequest error");
      }
    } catch (e) {
      printLog(e.toString(), "respondToStudyRoomTuteeRequest error");
    }
  }

  Future<void> leaveStudyRoom(BuildContext context) async {
    try {
      final currentRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sharedPref = await SharedPreferences.getInstance();

      var socket = SocketClient.instance.socket!;
      var res = await service.requestApi(
        path: '/api/studyroom/leave/${currentRoomProvider.studyRoom.roomId}',
        method: 'POST',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        // success
        sharedPref.remove('toRateParticipants');
        socket.emit("leave-room", {
          "roomId": currentRoomProvider.studyRoom.roomId,
        });

        if (userProvider.user.userId ==
            currentRoomProvider.studyRoom.roomOwner) {
          studyRoomProvider
              .removeStudyRoomById(currentRoomProvider.studyRoom.roomId);
        }
        currentRoomProvider.clearRoom();
      } else {
        printHttpLog(res, "leaveStudyRoom error");
      }
    } catch (e) {
      printLog(e.toString(), "leaveStudyRoom error");
    }
  }

  Future<List<StudyRoom>> searchStudyRoom({
    required BuildContext context,
    String search = '',
  }) async {
    try {
      if (search == '') {
        return [];
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/studyroom/public?search=$search',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        List<StudyRoom> searchedStudyRooms = [];

        var studyRooms = json.decode(res.body)['rooms'];
        for (var room in studyRooms) {
          var newStudyRoom = StudyRoom.fromMap(room, false, false);
          searchedStudyRooms.add(newStudyRoom);
        }
        return searchedStudyRooms;
      } else {
        printHttpLog(res, "searchStudyRoom error");
      }
    } catch (e) {
      printLog(e.toString(), "searchStudyRoom error");
    }

    return [];
  }

  Future<void> getPendingChatRoomIds(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/studyroom/pending',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        for (var room in decoded) {
          studyRoomProvider.addPendingRoom(room['_id']);
        }
      }
    } catch (e) {
      printLog(e.toString(), "getPendingChatRoomIds error");
    }
  }

  Future<void> endStudySession({
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentSudyRoom =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);
      final sharedPref = await SharedPreferences.getInstance();

      var res = await service.requestApi(
        path: '/api/studyroom/end-session/${currentSudyRoom.studyRoom.roomId}',
        method: 'PATCH',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        await sharedPref.setString('toRateParticipants', res.body);
      }
    } catch (e) {
      printLog(e.toString(), "endStudySession error");
    }
  }

  Future<bool> rateTutor({
    required BuildContext context,
    required int rating,
    required String feedback,
    required Subject subject,
  }) async {
    try {
      final studyRoomService = StudyPoolService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentSudyRoom =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      String path = '';
      Map<String, dynamic> body = {};

      if (userProvider.user.userId == currentSudyRoom.studyRoom.roomOwner) {
        path = '/api/rate-participants';
        var participantsMapped = currentSudyRoom.studyRoom.participants
            .map((e) {
              if (e['status'] == 'accepted') {
                return {
                  "_id": e['userId'],
                };
              }
              return {};
            })
            .toList()
            .where((element) => element.isNotEmpty)
            .toList();

        body = {
          "rating": rating,
          "feedback": feedback,
          "participants": participantsMapped,
        };
      } else {
        path = '/api/rate-tutor';
        body = {
          "subject": subject.toMap(),
          "rating": rating,
          "feedback": feedback,
          "tutorId": currentSudyRoom.studyRoom.roomOwner,
        };
      }

      var res = await service.requestApi(
        path: path,
        method: 'POST',
        userAuthHeader: userProvider,
        body: body,
      );

      if (res.statusCode == 200 && context.mounted) {
        studyRoomService.fetchStudyRooms(context, true);
        return true;
      } else {
        printHttpLog(res, "rateTutor error");
      }
    } catch (e) {
      printLog(e.toString(), "rateTutor error");
    }
    return false;
  }

  Future<bool> rateTutees({
    required BuildContext context,
    required List<dynamic> participants,
    required List<TextEditingController> feedbackControllers,
    required List<int> ratings,
  }) async {
    try {
      final studyRoomService = StudyPoolService();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      var participantsMapped = [];
      for (var i = 0; i < participants.length; i++) {
        participantsMapped.add({
          "_id": participants[i]['userId'],
          "rating": ratings[i],
          "feedback": feedbackControllers[i].text,
        });
      }

      var res = await service.requestApi(
        path: '/api/rate-participants',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          "participants": participantsMapped,
        },
      );

      if (res.statusCode == 200 && context.mounted) {
        studyRoomService.fetchStudyRooms(context, true);
        return true;
      } else {
        printHttpLog(res, "rateTutees error");
      }
    } catch (e) {
      printLog(e.toString(), "rateTutees error");
    }
    return false;
  }

  Future<void> getTuteeRequests(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);
      if (!userProvider.isTutor) return;

      var res = await service.requestApi(
        path: '/api/ask-help/get-request',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      printHttpLog(res, "getTuteeRequests");

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.addTuteeRequestsFromMap(decoded);
      } else {
        printHttpLog(res, "getTuteeRequests error");
      }
    } catch (e) {
      printLog(e.toString(), "getTuteeRequests error");
    }
  }

  Future<void> getMyRequests(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/ask-help/my-requests',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      printHttpLog(res, "getMyRequests");

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.addMyRequestFromMap(
          decoded,
          isMyRequest: true,
        );
      } else {
        printHttpLog(res, "getMyRequests error");
      }
    } catch (e) {
      printLog(e.toString(), "getMyRequests error");
    }
  }

  Future<void> respondTuteeRequest({
    required BuildContext context,
    required String requestId,
    required String requestStatus,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);
      final currentStudyRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );
      var res = await service.requestApi(
        path: '/api/ask-help/accept-request/$requestId/$requestStatus',
        method: 'POST',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);

        printHttpLog(res, "respondTuteeRequest");

        if (decoded['reqStatus'] != null) {
          userRequestsProvider.removeTuteeRequestById(requestId);
          printLog("success, accepted", "respondTuteeRequest");
          return;
        } else if (decoded['request']['reqStatus'] != null) {
          currentStudyRoomProvider.setStudyRoomFromJson(decoded['chatroom']);
          userRequestsProvider.removeTuteeRequestById(requestId);
          printLog("success, accepted", "respondTuteeRequest");
          return;
        }
      } else {
        printHttpLog(res, "respondTuteeRequest error");
      }
    } catch (e) {
      printLog(e.toString(), "respondTuteeRequest error");
    }
  }

  Future<void> getTodo({
    required BuildContext context,
    required String roomId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/todo/$roomId',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      printHttpLog(res, "getTodo");

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        currentStudyRoomProvider.setTodoFromJson(decoded);
      } else {
        printHttpLog(res, "getTodo error");
      }
    } catch (e) {
      printLog(e.toString(), "getTodo error");
    }
  }

  Future<void> addTodo({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/todo/create',
        method: 'POST',
        body: {
          "roomId": currentStudyRoomProvider.studyRoom.roomId,
          "title": title,
          "description": description,
        },
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 201) {
        var decoded = json.decode(res.body);
        printHttpLog(res, "addTodo");
        currentStudyRoomProvider.addTodoFromJson(decoded);
      } else {
        printHttpLog(res, "addTodo error");
      }
    } catch (e) {
      printLog(e.toString(), "addTodo error");
    }
  }

  Future<void> updateTodo({
    required BuildContext context,
    required String roomId,
    required ToDo todo,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/todo/update',
        method: 'PATCH',
        body: {
          "roomId": roomId,
          "todoId": todo.id,
          "title": todo.title,
          "description": todo.description,
          "isDone": todo.isDone,
        },
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        currentStudyRoomProvider.updateTodoItem(todo);
      } else {
        printHttpLog(res, "updateTodo error");
      }
    } catch (e) {
      printLog(e.toString(), "updateTodo error");
    }
  }

  Future<void> deleteTodo({
    required BuildContext context,
    required String roomId,
    required String todoId,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/todo/delete',
        method: 'DELETE',
        body: {
          "roomId": roomId,
          "todoId": todoId,
        },
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        currentStudyRoomProvider.removeTodoItem(todoId);
      } else {
        printHttpLog(res, "deleteTodo error");
      }
    } catch (e) {
      printLog(e.toString(), "deleteTodo error");
    }
  }
}
