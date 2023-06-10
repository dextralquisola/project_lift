import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:project_lift/models/user.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../models/subject.dart';
import '../../../providers/tutors_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/user_requests_provider.dart';

import '../../../utils/http_utils.dart' as service;

class TutorService {
  Future<void> fetchTutors(BuildContext context,
      [bool isRefresh = false]) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tutorProvider = Provider.of<TutorProvider>(context, listen: false);

      if (isRefresh) tutorProvider.clearTutors(false); // reset tutors

      var res = await service.requestApi(
        path: '/home/tutors?page=${tutorProvider.currentPage}&limit=10',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        tutorProvider.setTutorsFromJson(decoded, userProvider.user.userId);
      } else {
        print(res.statusCode);
        print(res.body);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<User>> searchTutor({
    String search = "",
    required BuildContext context,
  }) async {
    try {
      if (search == "") return [];
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/home/tutors?search=$search',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      List<User> listOfTutors = [];
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        for (var tutor in decoded['tutors']) {
          var newTutor = User.fromMap(tutor);
          if (newTutor.userId != userProvider.user.userId &&
              newTutor.dateTimeAvailability.isNotEmpty &&
              newTutor.subjects.isNotEmpty) {
            listOfTutors.add(newTutor);
          }
        }
      }

      return listOfTutors;
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<void> askHelp({
    required BuildContext context,
    required String tutorId,
    required String name,
    required String location,
    required String schedule,
    required Subject subject,
    required List<SubTopic> subTopics,
    required String status,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/ask-help/request/$tutorId',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          "name": name,
          "status": status,
          "location": location,
          "schedule": schedule,
          "subjectCode": subject.subjectCode,
          "description": subject.description,
          "subtopics": subTopicListToMap(subTopics),
        },
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider
            .addMyRequestFromMap([decoded], notifyListener: true);
        print("Success");
      } else {
        print(res.statusCode);
        print(res.body);
        print("Failed");
      }
    } catch (e) {
      print(e);
    }
  }
}
