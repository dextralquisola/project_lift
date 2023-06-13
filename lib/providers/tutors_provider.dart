import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';

class TutorProvider with ChangeNotifier {
  List<User> _tutors = [];

  int _currentPage = 1;

  List<User> get tutors => _tutors
      .where((tutor) =>
          tutor.subjects.isNotEmpty && tutor.dateTimeAvailability.isNotEmpty)
      .toList();
  int get currentPage => _currentPage;

  void setTutorsFromJson(dynamic data, String userId) {
    List<dynamic> tutors = data['tutors'];

    if (tutors.length == 10) _currentPage++;

    //var newTutors = tutors.map((e) => User.fromMap(e)).toList();
    List<User> newTutors = [];
    for (var tutor in tutors) {
      var newTutor = User.fromMap(tutor);
      if (newTutor.userId != userId) {
        newTutors.add(newTutor);
      }
    }

    var uniqueTutors = newTutors;

    if (tutors.length < 10) uniqueTutors = removeDuplicates(newTutors);

    _tutors = [..._tutors, ...uniqueTutors];

    notifyListeners();
  }

  void clearTutors([bool notify = true]) {
    _tutors = [];
    _currentPage = 1;
    notify ? notifyListeners() : () {};
  }

  List<User> removeDuplicates(List<User> list) {
    List<User> newList = [];
    for (User user in list) {
      if (_tutors.indexWhere((e) => e.userId == user.userId) == -1) {
        newList.add(user);
      }
    }
    return newList;
  }
}
