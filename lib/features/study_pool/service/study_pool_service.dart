import 'dart:convert';

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
        userAuthHeader: userProvider.user,
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
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      print("Chat room res");
      print(chatRoomRes.body);

      if (chatRoomRes.statusCode == 200 && chatRoomRes.statusCode != 404) {
        //fetch the chatroom data
        var decoded = json.decode(chatRoomRes.body);
        currentRoomProvider.setStudyRoomFromJson(decoded);
        currentRoomProvider.studyRoom.printRoom();

        var resMessages = await service.requestApi(
          path:
              '/api/studyroom/messages/${currentRoomProvider.studyRoom.roomId}?page=${currentRoomProvider.currentMessagePage}',
          method: 'GET',
          headers: {
            "Authorization": userProvider.user.token,
            "fcmToken": userProvider.user.firebaseToken,
            "deviceToken": userProvider.user.deviceToken,
          },
        );

        print("MessageRes");
        print(resMessages.body);

        if (resMessages.statusCode == 200) {
          var messages = json.decode(resMessages.body)['messages'];
          currentRoomProvider.setMessagesFromJson(messages);
        }
      }
    } catch (e) {
      print(e);
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
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

      if (resMessages.statusCode == 200) {
        var messages = json.decode(resMessages.body)['messages'];
        currentRoomProvider.setMessagesFromJson(messages);
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (res.statusCode == 200) {
        studyRoomProvider.addStudyRoomFromJson(json.decode(res.body), false);
      } else {
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage({
    required String roomId,
    required String message,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentStudyRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/studyroom/messages',
        method: 'POST',
        userAuthHeader: userProvider.user,
        body: {
          'roomId': roomId,
          'message': message,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

      print("msg");
      print(res.body);

      if (res.statusCode == 200) {
        print("message sent232323");
        currentStudyRoomProvider.addMessage(json.decode(res.body));
      } else {
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (joinResRoom.statusCode == 202) {
        studyRoomProvider.addPendingRoom(roomId);
        showSnackBar(context, "Room joined!, waiting for tutor to accept");
      } else {
        print("ERROR: ${joinResRoom.statusCode}");
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (res.statusCode == 200) {
        // success
        print("response to study room tutee request success");
        print(res.body);

        if (res.body == "User accepted successfully.") {
          currentStudyRoomProvider.acceptParticipant(userId);
          showSnackBar(context, "Tutee accepted!");
        } else if (res.body == "User rejected successfully.") {
          currentStudyRoomProvider.removeParticipantById(userId);
          showSnackBar(context, "Tutee rejected!");
        }
      } else {
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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

      final studyPoolService = StudyPoolService();

      var socket = SocketClient.instance.socket!;
      var res = await service.requestApi(
        path: '/api/studyroom/leave/${currentRoomProvider.studyRoom.roomId}',
        method: 'POST',
        userAuthHeader: userProvider.user,
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
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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
      final user = userProvider.user;
      var res = await service.requestApi(
        path: '/api/studyroom/public?search=$search',
        method: 'GET',
        userAuthHeader: userProvider.user,
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
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        for (var room in decoded) {
          studyRoomProvider.addPendingRoom(room['_id']);
        }
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (res.statusCode == 200) {
        await sharedPref.setString('toRateParticipants', res.body);
      }
    } catch (e) {
      print(e);
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
        print("rate participants");

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
        userAuthHeader: userProvider.user,
        body: body,
      );

      if (res.statusCode == 200) {
        print("Success");
        studyRoomService.fetchStudyRooms(context, true);
        return true;
      } else {
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
        body: {
          "participants": participantsMapped,
        },
      );

      if (res.statusCode == 200) {
        print("Success");
        studyRoomService.fetchStudyRooms(context, true);
        return true;
      } else {
        print("ERROR: ${res.statusCode}");
      }
    } catch (e) {
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      print("getTuteeRequests");
      print(res.body);

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.addTuteeRequestsFromMap(decoded);
      } else {
        print("ERROR: ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print("getTuteeRequest");
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      print("getMyRequests");
      print(res.body);

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.addMyRequestFromMap(
          decoded,
          isMyRequest: true,
        );
      } else {
        print("ERROR: ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print("getMyRequests");
      print(e);
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
        userAuthHeader: userProvider.user,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);

        print("respond tutee request");
        print(res.body);

        if (decoded['reqStatus'] != null) {
          userRequestsProvider.removeTuteeRequestById(requestId);
          print("success, rejected");
          return;
        } else if (decoded['request']['reqStatus'] != null) {
          currentStudyRoomProvider.setStudyRoomFromJson(decoded['chatroom']);
          userRequestsProvider.removeTuteeRequestById(requestId);
          print('success, accepted');
          return;
        }
      } else {
        print("ERROR: ${res.statusCode}");
        print(res.body);
      }
    } catch (e) {
      print(e);
    }
  }
}
