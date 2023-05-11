import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_lift/models/subject.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/http_utils.dart' as service;
import '../../../utils/storage_utils.dart';

class ProfileService {
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

  Future<void> fetchUser(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        decoded.addAll({'token': userProvider.user.token});
        userProvider.setUserFromMap(decoded, false);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadAvatar({
    required BuildContext context,
    required String avatarPath,
  }) async {
    try {
      final storageMethods = StorageMethods();
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      var avatarUrl = await storageMethods.uploadImage(
        filePath: avatarPath,
        fileName: userProvider.user.userId,
      );

      var res = await service.requestApi(
        path: '/api/users/me/avatar',
        method: 'POST',
        headers: {
          "Authorization": userProvider.user.token,
          "fcmToken": userProvider.user.firebaseToken,
          "deviceToken": userProvider.user.deviceToken,
        },
        body: {
          "image": avatarUrl,
        },
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        userProvider.setUserFromModel(
          userProvider.user.copyFrom(avatar: decoded['avatar']),
          false,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
