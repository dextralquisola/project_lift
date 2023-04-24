import 'dart:io';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/utils/http_error_handler.dart';
import 'package:project_lift/utils/socket_listeners.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      var fcmToken = await _getFCMToken();
      var deviceToken = await _getDeviceId();
      var res = await service.requestApi(
        path: '/api/users/login',
        body: {
          "email": email,
          "password": password,
          "deviceToken": deviceToken,
          "fcmToken": fcmToken,
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
            fcmToken: fcmToken!,
            deviceToken: deviceToken!,
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
      var fcmToken = await _getFCMToken();
      if (fcmToken == null) {
        print('fcmToken is null');
        return;
      }
      var deviceToken = await _getDeviceId();

      if (deviceToken == null) {
        print('deviceToken is null');
        return;
      }
      var res = await service.requestApi(
        path: '/api/users/signup',
        body: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "deviceToken": deviceToken,
          "fcmToken": fcmToken,
        },
      );

      print("here1");
      print('${res.statusCode}');

      if (!context.mounted) return;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () async {
          print("signup success!");
          await _loginMethod(
            context: context,
            res: res,
            isSignup: true,
            fcmToken: fcmToken!,
            deviceToken: deviceToken,
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
      print("this hsit");

      var fcmToken = await _getFCMToken();
      var deviceToken = await _getDeviceId();
      print("fcmToken: $fcmToken");
      print("deviceToken: $deviceToken");

      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      if (token == null) return;
      print("token: $token");

      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        headers: {
          "Authorization": token,
          "fcmToken": fcmToken!,
          "deviceToken": deviceToken!,
        },
        body: {
          "fcmToken": fcmToken!,
          "deviceToken": deviceToken!,
        }
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
            fcmToken: fcmToken!,
            deviceToken: deviceToken!,
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
    required String fcmToken,
    required String deviceToken,
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

      userProvider.setUserFromMap(userData);
      userProvider.setTokens(fcmToken: fcmToken, deviceToken: deviceToken);
      userProvider.user.printUser();

      SocketClient(userProvider.user.token).socket!.connect();
      SocketListeners().activateEventListeners(context);

      if (isSignup) showSnackBar(context, "Account created successfully");

      if (!isFromAutoLogin) {
        var prefs = await SharedPreferences.getInstance();
        prefs.setString('token', userData['token']);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      print('device id: ${androidDeviceInfo.id}');
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  Future<String?> _getFCMToken() async {
    String? token;
    await FirebaseMessaging.instance.getToken().then((t) {
      token = t!;
      print("FCM TOKEN: $token");
    });
    return token;
  }
}
