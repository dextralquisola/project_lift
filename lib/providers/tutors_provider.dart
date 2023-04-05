import 'package:flutter/material.dart';
import 'package:project_lift/models/user.dart';

class TutorProvider with ChangeNotifier {
  List<User> _tutors = [];

  int _currentPage = 1;
  int _totalPages = 1;

  List<User> get tutors => _tutors;
  int get currentPage => _currentPage;

  void setTutorsFromJson(dynamic data) {
    if (_currentPage > _totalPages) {
      return;
    }

    print('total pages: $_totalPages');
    print('current page: $_currentPage');

    _totalPages = data['totalPages'];

    List<dynamic> tutors = data['tutors'];

    var newTutors = tutors.map((e) => User.fromMap(e)).toList();
    // _currentPage = data['currentPage'];
    _currentPage++;
    _tutors = [..._tutors, ...newTutors];

    print('total tutors: ${_tutors.length}');
    notifyListeners();
  }
}
