import 'package:flutter/material.dart';
import 'package:project_lift/models/subject.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;

class ProfileServie {
  Future<void> addSubject({
    required Subject subject,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/tutor/add-subject',
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
        body: {
          "subjectCode": subject.subjectCode,
          "description": subject.description,
          "subtopics": subject.subTopicsToListMap(),
        },
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        userProvider.addSubject(subject);
        print("Success");
      } else {
        print("Failed");
      }
    } catch (e) {
      print(e);
    }
  }
}
