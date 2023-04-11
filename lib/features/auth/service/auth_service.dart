import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/service/tutor_service.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/utils/http_error_handler.dart';
import 'package:project_lift/utils/socket_listeners.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;

import 'package:http/http.dart' as http;

import '../../../utils/socket_client.dart';

class AuthService {
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    // function here
    try {
      var res = await service.requestApi(
        path: '/api/users/login',
        body: {
          "email": email,
          "password": password,
        },
      );

      if (!context.mounted) return;

      if (json.decode(res.body).isEmpty) {
        showSnackBar(context, "Please check your credentials");
        return;
      }

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () async {
          await _loginMethod(
            isFromLogin: true,
            context: context,
            res: res,
          );
          onSuccess();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      var res = await service.requestApi(
        path: '/api/users/signup',
        body: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
        },
      );

      if (!context.mounted) return;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () async {
          await _loginMethod(
            context: context,
            res: res,
            isSignup: true,
          );

          onSuccess();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchUser(BuildContext context) async {
    // function here
    try {
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      if (token == null) return;

      print("token: $token");
      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        headers: {
          "Authorization": token,
        },
      );

      if (!context.mounted) return;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () async {
          await _loginMethod(
            context: context,
            res: res,
            isFromAutoLogin: true,
            token: token,
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loginMethod({
    required BuildContext context,
    required http.Response res,
    bool isSignup = false,
    bool isFromLogin = false,
    bool isFromAutoLogin = false,
    String token = "",
  }) async {
    /*
      if else hell

      improvement: make an enum and move the functions to seperate methods
    */

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentRoomProvider =
          Provider.of<CurrentStudyRoomProvider>(context, listen: false);
      var userData = json.decode(res.body);

      if (isFromAutoLogin) {
        userData.addAll({'token': token});
      } else {
        userData = {
          "_id": userData['user']['_id'],
          "firstName": userData['user']['firstName'],
          "lastName": userData['user']['lastName'],
          "email": userData['user']['email'],
          "role": userData['user']['role'],
          "token": userData['token'],
        };
      }

      if (isFromLogin) {
        await TutorService().fetchTutors(context, userData['token']);
      }

      userProvider.setUserFromMap(userData);
      userProvider.user.printUser();

      var socket = SocketClient(userProvider.user.token).socket!.connect();
      SocketListeners().activateEventListeners(context);

      var chatRoomRes = await service.requestApi(
        path: '/api/studyroom/user-room',
        method: 'GET',
        headers: {
          "Authorization": userProvider.user.token,
        },
      );

      if (chatRoomRes.statusCode != 404 && chatRoomRes.statusCode == 200) {
        //fetch the chatroom data
        print(chatRoomRes.body);

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
          print("messages");
          print(resMessages.body);

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

      if (!isFromLogin) {
        await TutorService().fetchTutors(context);
      }

      await StudyPoolService().fetchStudyRooms(context);

      if (isSignup) showSnackBar(context, "Account created successfully");

      if (!isFromAutoLogin) {
        var prefs = await SharedPreferences.getInstance();
        prefs.setString('token', userData['token']);
      }
    } catch (e) {
      print(e);
    }
  }
}
