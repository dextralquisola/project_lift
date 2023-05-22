import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/user.dart';

Future<http.Response> requestApi({
  required String path,
  Map<String, dynamic>? body,
  Map<String, String>? headers,
  User? userAuthHeader,
  String method = "post",
}) async {
  Map<String, String> h = {'Content-Type': 'application/json; charset=UTF-8'};
  if (headers != null) {
    h.addAll(headers);
  }
  if(userAuthHeader != null){
    h.addAll({
      "Authorization": userAuthHeader.token,
      "fcmToken": userAuthHeader.firebaseToken,
      "deviceToken": userAuthHeader.deviceToken,
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
