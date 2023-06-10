import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

Future<http.Response> requestApi({
  required String path,
  Map<String, dynamic>? body,
  Map<String, String>? headers,
  UserProvider? userAuthHeader,
  String method = "post",
}) async {
  Map<String, String> h = {'Content-Type': 'application/json; charset=UTF-8'};
  if (headers != null) {
    h.addAll(headers);
  }
  if (userAuthHeader != null) {
    final isGoogleLogin = userAuthHeader.isGoogleLogin;
    h.addAll({
      "Authorization": isGoogleLogin
          ? "Google ${userAuthHeader.user.token}"
          : "Bearer ${userAuthHeader.user.token}",
      "fcmToken": userAuthHeader.user.firebaseToken,
      "deviceToken": userAuthHeader.user.deviceToken,
    });
  }
  if (method.toLowerCase() == "get") {
    return await http.get(
      Uri.parse('$baseServerAddress$path'),
      headers: h,
    );
  } else if (method.toLowerCase() == "put") {
    return await http.put(
      Uri.parse('$baseServerAddress$path'),
      body: body != null ? json.encode(body) : null,
      headers: h,
    );
  } else if (method.toLowerCase() == "patch") {
    return await http.patch(
      Uri.parse('$baseServerAddress$path'),
      body: body != null ? json.encode(body) : null,
      headers: h,
    );
  } else if (method.toLowerCase() == "delete") {
    return await http.delete(
      Uri.parse('$baseServerAddress$path'),
      body: body != null ? json.encode(body) : null,
      headers: h,
    );
  }
  return await http.post(
    Uri.parse('$baseServerAddress$path'),
    body: body != null ? json.encode(body) : null,
    headers: h,
  );
}
