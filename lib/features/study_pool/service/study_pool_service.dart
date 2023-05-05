import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_lift/constants/constants.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../models/study_room.dart';
import '../../../models/subject.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;

class StudyPoolService {
  Future<void> createStudyPool({
    required String studyPoolName,
    required BuildContext context,
    required StudyRoomStatus status,
    required Subject subject,
    required List<SubTopic> subTopics,
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
        headers: {
          'Authorization': userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
        body: {
          'name': studyPoolName,
          'status': status == StudyRoomStatus.public ? 'public' : 'private',
          'subjectCode': subject.subjectCode,
          'description': subject.description,
          'subtopics': subTopicListToMap(subTopics),
        },
        method: 'POST',
      );

      if (res.statusCode == 200) {
        // success
        studyRoomProvider.addSingleStudyRoom(json.decode(res.body));
        currentStudyRoomProvider.setStudyRoomFromJson(json.decode(res.body));
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
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

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

        print('resmessage');
        print(resMessages.statusCode);
        print(resMessages.body);

        if (resMessages.statusCode == 200) {
          var messages = json.decode(resMessages.body);
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
        var messages = json.decode(resMessages.body);
        currentRoomProvider.setMessagesFromJson(messages);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchStudyRooms(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/studyroom/public?page=${studyRoomProvider.currentPage}',
        method: 'GET',
        headers: {
          'Authorization': userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
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
        headers: {
          'Authorization': userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
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
      var joinResRoom = await service.requestApi(
        path: '/api/studyroom/join/$roomId',
        method: 'POST',
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
        body: {
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

      if (joinResRoom.statusCode == 202) {
        // success
        showSnackBar(context, "Room joined!, waiting for tutor to accept");
      } else {
        print("ERROR: ${joinResRoom.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> acceptTutee({
    required String roomId,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      final currentStudyRoomProvider = Provider.of<CurrentStudyRoomProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
          path: '/api/studyroom/accept-participant/$roomId/$userId',
          method: 'PATCH',
          headers: {
            "Authorization": userProvider.user.token,
            "fcmToken": userProvider.user.firebaseToken,
            "deviceToken": userProvider.user.deviceToken,
          },
          body: {
            "fcmToken": userProvider.user.firebaseToken,
            "deviceToken": userProvider.user.deviceToken,
          });

      if (res.statusCode == 200) {
        // success
        currentStudyRoomProvider.acceptParticipant(userId);
        showSnackBar(context, "Tutee accepted!");
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      var socket = SocketClient.instance.socket!;
      var res = await service.requestApi(
          path: '/api/studyroom/leave/${currentRoomProvider.studyRoom.roomId}',
          method: 'POST',
          headers: {
            "Authorization": userProvider.user.token,
            "fcmToken": userProvider.user.firebaseToken,
            "deviceToken": userProvider.user.deviceToken,
          },
          body: {
            "fcmToken": userProvider.user.firebaseToken,
            "deviceToken": userProvider.user.deviceToken,
          });

      if (res.statusCode == 200) {
        // success
        socket.emit("leave-room", {
          "roomId": currentRoomProvider.studyRoom.roomId,
        });
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
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
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
}
