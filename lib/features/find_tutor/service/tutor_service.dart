import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/tutors_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/http_error_handler.dart';

import '../../../utils/http_utils.dart' as service;

class TutorService {
  Future<void> fetchTutors(BuildContext context, [String token = ""]) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/home/tutors?page=${tutorProvider.currentPage}&limit=10',
        method: 'GET',
        headers: {
          "Authorization": token != "" ? token : userProvider.user.token,
        },
      );

      if (!context.mounted) return;

      httpErrorHandler(
        response: res,
        context: context,
        onSuccess: () {
          final decoded = json.decode(res.body);
          tutorProvider.setTutorsFromJson(decoded);
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
