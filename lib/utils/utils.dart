import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/models/subject.dart';
import 'package:http/http.dart' as http;

String capitalize(String text) {
  return text
      .split(' ')
      .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
      .join(' ');
}

List<Map<String, dynamic>> subTopicListToMap(List<SubTopic> subTopics) {
  return subTopics.map((e) => e.toMap()).toList();
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}

void printHttpLog(http.Response res, [String title = '']) {
  if (kDebugMode) {
    print('==================== $title ====================');
    print('statusCode: ${res.statusCode}');
    print('headers: ${res.headers}');
    print('body: ${res.body}');
  }
}

void printLog(String text, [String title = '']) {
  if (kDebugMode) {
    print('==================== $title ====================');
    print(text);
  }
}
