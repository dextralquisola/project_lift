import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';
import 'package:project_lift/utils/http_error_handler.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;

import 'package:http/http.dart' as http;

class AuthService {
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // function here
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var res = await service.requestApi(
      path: '/users/login',
      body: {
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
          userProvider: userProvider,
          res: res,
        );
      },
    );
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/users',
        body: {
          "name": name,
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
            userProvider: userProvider,
            res: res,
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchUser() async {
    // function here
    var res = await service.requestApi(
      path: '/users/me',
      method: 'GET',
    );
  }

  Future<void> _loginMethod({
    required BuildContext context,
    required UserProvider userProvider,
    required http.Response res,
  }) async {
    var decoded = json.decode(res.body);

    userProvider.setUserFromMap(decoded);

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('token', decoded['token']);

    print("Token: ${decoded['token']}");

    showSnackBar(context, "Account created successfully");
  }
}
