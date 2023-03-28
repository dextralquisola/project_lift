import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';

class TutorProvider with ChangeNotifier {
  List<User> _tutors = [];

  int _currentPage = 1;
  int _totalPages = 0;

  List<User> get tutors => _tutors;
  int get currentPage => _currentPage;

  void setTutorsFromJson(dynamic data) {
    _totalPages = data['totalPages'];

    if (_currentPage > _totalPages) {
      _currentPage--;
      return;
    }

    List<dynamic> tutors = data['tutors'];

    var newTutors = tutors.map((e) => User.fromMap(e)).toList();
    // _currentPage = data['currentPage'];
    _currentPage++;
    _tutors = [..._tutors, ...newTutors];

    notifyListeners();
  }
}
