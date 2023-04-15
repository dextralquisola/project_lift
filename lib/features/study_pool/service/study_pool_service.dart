import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_lift/constants/constants.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../providers/current_room_provider.dart';
import '../../../providers/study_room_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;

class StudyPoolService {
  Future<void> createStudyPool({
    required String studyPoolName,
    required BuildContext context,
    required StudyRoomStatus status,
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
        },
        body: {
          'name': studyPoolName,
          'status': status == StudyRoomStatus.public ? 'public' : 'private',
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

      var socket = SocketClient.instance.socket!;

      var chatRoomRes = await service.requestApi(
        path: '/api/studyroom/user-room',
        method: 'GET',
        headers: {
          "Authorization": userProvider.user.token,
        },
      );

      if (chatRoomRes.statusCode == 200 && chatRoomRes.statusCode != 404) {
        //fetch the chatroom data

        currentRoomProvider.setStudyRoomFromJson(json.decode(chatRoomRes.body));
        currentRoomProvider.studyRoom.printRoom();

        var joinResRoom = await service.requestApi(
          path: '/api/studyroom/join/${currentRoomProvider.studyRoom.roomId}',
          method: 'POST',
          headers: {
            "Authorization": userProvider.user.token,
          },
        );

        if (joinResRoom.statusCode == 200) {
          var resMessages = await service.requestApi(
            path:
                '/api/studyroom/messages/${currentRoomProvider.studyRoom.roomId}',
            method: 'GET',
            headers: {
              "Authorization": userProvider.user.token,
            },
          );

          if (resMessages.statusCode == 200) {
            var messages = json.decode(resMessages.body);
            currentRoomProvider.setMessagesFromJson(messages);

            socket.emit('join-room', {
              'roomId': currentRoomProvider.studyRoom.roomId,
            });
          }

          print("joined room");
        } else {
          print("failed to join room");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchStudyRooms(BuildContext context) async {
    try {
      print("fetching study rooms called");
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studyRoomProvider =
          Provider.of<StudyRoomProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/studyroom/public?page=${studyRoomProvider.currentPage}',
        method: 'GET',
        headers: {
          'Authorization': userProvider.user.token,
        },
      );

      if (res.statusCode == 200) {
        // success
        print(res.body);
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
        },
        body: {
          'roomId': roomId,
          'message': message,
        },
      );

      print("msg");
      print(res.body);

      if (res.statusCode == 200) {
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
}
