import 'dart:convert';

import 'package:flutter/material.dart';
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      if (token == null) return;

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
          var decoded = json.decode(res.body);

          var userData = {
            "_id": decoded['_id'],
            "firstName": decoded['firstName'],
            "lastName": decoded['lastName'],
            "email": decoded['email'],
            "token": token,
          };

          userProvider.setUserFromMap(userData);
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
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var decoded = json.decode(res.body);

      var userData = {
        "_id": decoded['user']['_id'],
        "firstName": decoded['user']['firstName'],
        "lastName": decoded['user']['lastName'],
        "email": decoded['user']['email'],
        "token": decoded['token'],
      };

      userProvider.setUserFromMap(userData);

      var prefs = await SharedPreferences.getInstance();
      prefs.setString('token', decoded['token']);

      if (isSignup) showSnackBar(context, "Account created successfully");
    } catch (e) {
      print(e);
    }
  }
}
