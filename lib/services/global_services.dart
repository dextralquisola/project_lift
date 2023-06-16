import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/http_utils.dart' as service;
import '../utils/utils.dart';

class GlobalService {
  Future<void> reportUser({
    required BuildContext context,
    required String userId,
    required String category,
    required String content,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      var res = await service.requestApi(
        path: '/api/report',
        userAuthHeader: userProvider,
        body: {
          "reportedUser": userId,
          "category": category,
          "content": content,
        },
      );

      if (res.statusCode == 201 && context.mounted) {
        showSnackBar(context, "User reported");
      } else {
        printHttpLog(res, "Failed to report user");
        showSnackBar(context, "Failed to report user");
      }
    } catch (e) {
      showSnackBar(context, "$e");
      printLog(e.toString(), "Failed to report user");
    }
  }
}
