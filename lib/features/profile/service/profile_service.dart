import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/subject.dart';
import '../../../models/tutor_application.dart';

import '../../../providers/top_subjects_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/user_requests_provider.dart';

import '../../../utils/utils.dart';
import '../../../utils/storage_utils.dart';
import '../../../utils/http_utils.dart' as service;

class ProfileService {
  Future<void> addSubject({
    required Subject subject,
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/tutor/add-subject',
        userAuthHeader: userProvider,
        body: {
          "subjectCode": subject.subjectCode,
          "description": subject.description,
          "subtopics": subject.subTopicsToListMap(),
        },
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        userProvider.addSubject(subject, false);
      } else {
        printHttpLog(res, "addSubject error");
      }
    } catch (e) {
      printLog(e.toString(), "addSubject error");
    }
  }

  Future<void> fetchUser(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        decoded.addAll({'token': userProvider.user.token});
        userProvider.setUserFromMap(decoded, false);
      }
    } catch (e) {
      printLog(e.toString(), "fetchUser error");
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
        userAuthHeader: userProvider,
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
      printLog(e.toString(), "uploadAvatar error");
    }
  }

  Future<void> submitTutorApplication({
    required BuildContext context,
    required String gradePath,
    required String briefIntro,
    required String teachingExperience,
  }) async {
    try {
      final storageMethods = StorageMethods();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);

      var gradeUrl = await storageMethods.uploadImage(
        filePath: gradePath,
        fileName: "grades_${userProvider.user.userId}",
      );

      var res = await service.requestApi(
        path: '/api/tutor-application/create',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          "image": gradeUrl,
          "briefIntro": briefIntro,
          "teachingExperience": teachingExperience,
        },
      );

      if(!context.mounted) return;

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.setTutorApplicationFromMap(decoded);
      } else {
        showSnackBar(context,
            "Failed to submit application, make sure the the image is clear and readable");
        printHttpLog(res, "submitTutorApplication error");
      }
    } catch (e) {
      printLog(e.toString(), "submitTutorApplication error");
    }
  }

  Future<void> updateTutorApplication({
    required BuildContext context,
    required String gradePath,
    required String briefIntro,
    required String teachingExperience,
  }) async {
    try {
      final storageMethods = StorageMethods();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);

      var gradeUrl = gradePath.contains(
              'https://firebasestorage.googleapis.com/v0/b/project-lift-f75f9.appspot.com')
          ? gradePath
          : await storageMethods.uploadImage(
              filePath: gradePath,
              fileName: "grades_${userProvider.user.userId}",
            );

      var res = await service.requestApi(
        path: '/api/tutor-application/update',
        method: 'PATCH',
        userAuthHeader: userProvider,
        body: {
          "image": gradeUrl,
          "briefIntro": briefIntro,
          "teachingExperience": teachingExperience,
        },
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.setTutorApplicationFromMap(decoded);
      } else {
        printHttpLog(res, "updateTutorApplication error");
      }
    } catch (e) {
      printLog(e.toString(), "updateTutorApplication error");
    }
  }

  Future<void> getUserApplication(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.user.role == 'tutor') return;

      final userRequestsProvider =
          Provider.of<UserRequestsProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/tutor-application/me',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        userRequestsProvider.setTutorApplicationFromMap(decoded);
        printHttpLog(res, "getUserApplication");
      } else if (res.statusCode == 404) {
        userRequestsProvider
            .setTutorApplicationFromModel(TutorApplication.empty());
      }
    } catch (e) {
      printLog(e.toString(), "getUserApplication error");
    }
  }

  Future<void> updateUser({
    required BuildContext context,
    String firstName = "",
    String lastName = "",
    String password = "",
    String dateTimeAvailability = "",
    bool? isAvailable,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      var res = await service.requestApi(
        path: '/api/users/me',
        method: 'PATCH',
        userAuthHeader: userProvider,
        body: dateTimeAvailability.isNotEmpty
            ? {
                "timeAndDateAvailability": dateTimeAvailability,
                "isAvailable": isAvailable!,
              }
            : password.isEmpty
                ? {
                    "firstName": firstName,
                    "lastName": lastName,
                  }
                : {
                    "firstName": firstName,
                    "lastName": lastName,
                    "password": password,
                  },
      );

      if (context.mounted) {
        if (res.statusCode == 200) {
          dateTimeAvailability.isNotEmpty
              ? userProvider.setUserFromModel(
                  userProvider.user.copyFrom(
                    dateTimeAvailability: dateTimeAvailability,
                    isAvailable: isAvailable!,
                  ),
                  false,
                )
              : userProvider.setUserFromModel(
                  userProvider.user.copyFrom(
                    firstName: firstName,
                    lastName: lastName,
                  ),
                  false,
                );
        } else if (res.statusCode == 400) {
          showSnackBar(context, "Invalid Input");
        } else {
          showSnackBar(context, "Something went wrong");
        }
      }
    } catch (e) {
      printLog(e.toString(), "updateUser error");
    }
  }

  Future<void> updateSubject({
    required BuildContext context,
    required Subject subject,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/tutor/update-subject/${subject.subjectCode}',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          "description": subject.description,
          "subtopics": subject.subTopicsToListMap(),
        },
      );

      if (res.statusCode == 200) {
        userProvider.updateSubject(subject, false);
      } else {
        printHttpLog(res, "updateSubject error");
      }
    } catch (e) {
      printLog(e.toString(), "updateSubject error");
    }
  }

  Future<void> deleteSubject({
    required BuildContext context,
    required Subject subject,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/tutor/delete-subject/${subject.subjectCode}',
        method: 'DELETE',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        userProvider.deleteSubject(subject, false);
      } else {
        printHttpLog(res, "deleteSubject error");
      }
    } catch (e) {
      printLog(e.toString(), "deleteSubject error");
    }
  }

  Future<void> getMostSearchedTutorAndSubject({
    required BuildContext context,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final topSubjectsProvider =
          Provider.of<TopSubjectProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/analytics/most-searched-tutor-subject',
        method: 'GET',
        userAuthHeader: userProvider,
      );

      if (res.statusCode == 200) {
        var decoded = json.decode(res.body);
        topSubjectsProvider.setTopSubjectsFromMap(decoded['topSubject']);
      } else {
        printHttpLog(res, "getMostSearchedTutorAndSubject error");
      }
    } catch (e) {
      printLog(e.toString(), "getMostSearchedTutorAndSubject error");
    }
  }

  Future<void> addSubjectV2({
    required BuildContext context,
    required XFile image,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final storageMethods = StorageMethods();

      var gradeUrl = await storageMethods.uploadImage(
          filePath: image.path,
          fileName: "${userProvider.user.userId}.grades}");

      printLog(gradeUrl, "gradeUrl");

      var res = await service.requestApi(
        path: '/api/tutor/add-subject',
        method: 'POST',
        userAuthHeader: userProvider,
        body: {
          "image": gradeUrl,
        },
      );

      if (!context.mounted) return;

      if (res.statusCode == 200) {
        showSnackBar(context, "Subject Added");
      } else {
        showSnackBar(context, res.body);
        printHttpLog(res, "addSubjectV2 error");
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      printLog(e.toString(), "addSubjectV2 error");
    }
  }
}
