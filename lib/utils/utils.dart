import 'package:flutter/material.dart';
import 'package:project_lift/models/subject.dart';

List<Map<String, dynamic>> subTopicListToMap(List<SubTopic> subTopics) {
  return subTopics.map((e) => e.toMap()).toList();
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}
