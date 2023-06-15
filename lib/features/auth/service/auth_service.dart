import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../widgets/auth_widgets.dart';
import '../../../utils/http_error_handler.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/socket_listeners.dart';
import '../../../utils/socket_client.dart';
import '../../../utils/http_utils.dart' as service;
import '../../../utils/utils.dart';

class AuthService {
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    // function here
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
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

      if (res.statusCode == 200) {
        if (res.body.isEmpty) {
          showSnackBar(context, "Please check your credentials");
          return;
        }

        await _loginMethod(
          isFromLogin: true,
          context: context,
          res: res,
          fcmToken: fcmToken!,
          deviceToken: deviceToken!,
        );
        sharedPrefs.setBool('isGoogleLogin', false);
        onSuccess();
      } else {
        if (res.statusCode == 403) {
          showBannedDialog(context: context);
          return;
        }

        showSnackBar(context, "Please check your credentials");
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> signInWithGoogle({
    required BuildContext context,
    required String idToken,
    required String accessToken,
  }) async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      var fcmToken = await _getFCMToken();
      var deviceToken = await _getDeviceId();
      var res = await service.requestApi(
        path: '/google-login',
        body: {
          "id_token": idToken,
          "access_token": accessToken,
          "deviceToken": deviceToken,
          "fcmToken": fcmToken,
        },
      );

      if (!context.mounted) return false;

      if (res.statusCode == 200) {
        await _loginMethod(
          isFromLogin: true,
          context: context,
          res: res,
          fcmToken: fcmToken!,
          deviceToken: deviceToken!,
        );
        sharedPrefs.setBool('isGoogleLogin', true);
        return true;
      } else if (res.statusCode == 409) {
        showSnackBar(
            context, "Email already registered through traditional login.");
      } else if (res.statusCode == 403) {
        showBannedDialog(context: context);
      } else if (res.statusCode == 400) {
        showSnackBar(context, "Invalid email address. use CvSU email address.");
      } else {
        showSnackBar(context, "Something went wrong, please try again later.");
      }
    } catch (e) {
      printLog(e.toString(), 'signInWithGoogle');
    }

    return false;
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
        printLog('fcmToken is null');
        return;
      }
      var deviceToken = await _getDeviceId();

      if (deviceToken == null) {
        printLog('deviceToken is null');
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

      if (!context.mounted) return;

      if (res.statusCode == 201) {
        showSnackBar(context,
            "Account created successfully, please verify your email and then login.");
        onSuccess();
      } else {
        showSnackBar(context, "Something went wrong, please try again later.");
      }
    } catch (e) {
      printLog(e.toString(), 'signup');
    }
  }

  Future<void> autoLogin(BuildContext context) async {
    // function here
    try {
      var fcmToken = await _getFCMToken();
      var deviceToken = await _getDeviceId();

      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      if (token == null) return;
      printLog("token: $token");

      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        headers: {
          "Authorization": token,
          "fcmToken": fcmToken!,
          "deviceToken": deviceToken!,
        },
      );

      printHttpLog(res, '/api/users/me');

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
            fcmToken: fcmToken,
            deviceToken: deviceToken,
          );
        },
      );
    } catch (e) {
      printLog(e.toString(), 'autoLogin');
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

      printLog(res.body, 'loginMethod');

      if (userData['message'] != null) {
        showSnackBar(context, userData['message']);
        return;
      }

      if (isFromAutoLogin) {
        userData.addAll({'token': token});
      } else {
        userData = {
          "_id": userData['user']['_id'],
          "firstName": userData['user']['firstName'],
          "lastName": userData['user']['lastName'],
          "email": userData['user']['email'],
          "avatar": userData['user']['avatar'],
          "role": userData['user']['role'],
          "token": userData['token'],
          "subjects": userData['user']['subjects'],
          "ratingsAsTutor": userData['user']['ratingsAsTutor'],
          "ratingsAsTutee": userData['user']['ratingsAsTutee'],
          "isEmailVerified": userData['user']['isEmailVerified'] ?? false,
          "isAvailable": userData['user']['isAvailable'] ?? false,
          "timeAndDateAvailability":
              userData['user']['timeAndDateAvailability'] ?? "",
        };
      }

      printLog(userData.toString(), 'loginMethod');

      userProvider.setUserFromMap(userData);
      userProvider.setTokens(fcmToken: fcmToken, deviceToken: deviceToken);

      if (!userProvider.user.isEmailVerified) {
        showSnackBar(context, "Please verify your email");
        userProvider.clearUserData();
        return;
      }

      SocketClient(userProvider.user.token).socket!.connect();
      SocketListeners().activateEventListeners(context);

      if (isSignup) showSnackBar(context, "Account created successfully");

      if (!isFromAutoLogin) {
        var prefs = await SharedPreferences.getInstance();
        prefs.setString('token', userData['token']);
      }
    } catch (e) {
      printLog(e.toString(), 'loginMethod');
    }
  }

  Future<void> forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      var res = await service.requestApi(
        path: '/api/forgot-password',
        body: {
          "email": email,
        },
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        showSnackBar(context, "Please check your email");
      } else {
        showSnackBar(
          context,
          json.decode(res.body)['error'] ??
              "Something went wrong, please try again later.",
        );
      }
    } catch (e) {
      printLog(e.toString(), 'forgotPassword error');
    }
  }

  Future<bool> logout(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/users/logout',
        method: 'POST',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      printLog(e.toString(), 'logout error');
    }
    return false;
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      printLog(androidDeviceInfo.id, 'getDeviceId');
      return androidDeviceInfo.id; // unique ID on Android
    }

    return null;
  }

  Future<String?> _getFCMToken() async {
    String? token;
    await FirebaseMessaging.instance.getToken().then((t) {
      token = t!;
      printLog("fcm token: $token", 'getFCMToken');
    });
    return token;
  }
}
