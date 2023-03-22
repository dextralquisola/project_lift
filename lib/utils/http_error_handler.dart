import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import './utils.dart';

void httpErrorHandler({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    onSuccess();
    return;
  } else if (response.statusCode >= 400 && response.statusCode < 500) {
    showSnackBar(context, jsonDecode(response.body)['msg']);
    return;
  } else if (response.statusCode >= 500 && response.statusCode < 600) {
    showSnackBar(context, jsonDecode(response.body)['error']);
    return;
  } else {
    showSnackBar(context, "Something went wrong");
    return;
  }
}
