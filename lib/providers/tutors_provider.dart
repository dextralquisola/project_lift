import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';

class TutorProvider with ChangeNotifier {
  List<User> _tutors = [];

  List<User> get tutors => _tutors;

  void setTutorsFromJson(List<dynamic> tutors) {
    _tutors = tutors.map((e) => User.fromMap(e)).toList();
    notifyListeners();
  }
}
