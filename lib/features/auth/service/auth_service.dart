import 'dart:io';
import 'dart:convert';

import 'package:project_lift/features/auth/widgets/auth_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

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
          isFromGoogleLogin: false,
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

  Future<void> signInWithGoogle({
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

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        await _loginMethod(
          isFromLogin: true,
          context: context,
          res: res,
          fcmToken: fcmToken!,
          deviceToken: deviceToken!,
          isFromGoogleLogin: true,
        );
        sharedPrefs.setBool('isGoogleLogin', true);
      } else if (res.statusCode == 409) {
        showSnackBar(
            context, "Email already registered through traditional login.");
      } else if (res.statusCode == 403) {
        showBannedDialog(context: context);
        return;
      } else if (res.statusCode == 400) {
        showSnackBar(context, "Invalid email address. use CvSU email address.");
      }
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

      if (!context.mounted) return;

      if (res.statusCode == 201) {
        showSnackBar(context,
            "Account created successfully, please verify your email and then login.");
        onSuccess();
      } else {
        showSnackBar(context, "Something went wrong, please try again later.");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> autoLogin(BuildContext context) async {
    // function here
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      var fcmToken = await _getFCMToken();
      var deviceToken = await _getDeviceId();

      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      if (token == null) return;
      print("token: $token");

      var isGoogleLogin = false;
      if (sharedPrefs.containsKey('isGoogleLogin')) {
        isGoogleLogin = sharedPrefs.getBool('isGoogleLogin')!;
      }

      print("isGoogleLogin: $isGoogleLogin");

      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        headers: {
          "Authorization": isGoogleLogin ? "Google $token" : "Bearer $token",
          "fcmToken": fcmToken!,
          "deviceToken": deviceToken!,
        },
      );

      print(res.body);

      if (!context.mounted) return;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () async {
          await _loginMethod(
            context: context,
            res: res,
            isFromAutoLogin: true,
            isFromGoogleLogin: isGoogleLogin,
            token: token,
            fcmToken: fcmToken,
            deviceToken: deviceToken,
          );
        },
      );
    } catch (e) {
      print("asdfasfasdfasdf");
      print(e);
    }
  }

  Future<void> _loginMethod({
    required BuildContext context,
    required http.Response res,
    required String fcmToken,
    required String deviceToken,
    required bool isFromGoogleLogin,
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

      print(res.body);

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

      print("login");
      print(userData);

      userProvider.setUserFromMap(userData);
      userProvider.setTokens(fcmToken: fcmToken, deviceToken: deviceToken);

      if (!userProvider.user.isEmailVerified) {
        showSnackBar(context, "Please verify your email");
        userProvider.clearUserData();
        return;
      }

      SocketClient(userProvider.user.token, isFromGoogleLogin)
          .socket!
          .connect();
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
      print(e);
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
      print(e);
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
      print('device id: ${androidDeviceInfo.id}');
      return androidDeviceInfo.id; // unique ID on Android
    }

    return null;
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
