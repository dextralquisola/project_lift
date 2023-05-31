import 'package:flutter/material.dart';
import 'package:project_lift/models/subject.dart';

class TopSubjectProvider with ChangeNotifier {
  List<TopSearchSubject> _topSubjects = [];

  List<TopSearchSubject> get topSubjects => _topSubjects;

  List<TopSearchSubject> getTopThreeSubjects() {
    print('getTopThreeSubjects');
    print(_topSubjects[0].subjectCode);
    print(_topSubjects[1].subjectCode);
    print(_topSubjects[2].subjectCode);
    return _topSubjects.sublist(0, 3);
  }

  void setTopSubjects(List<TopSearchSubject> topSubjects) {
    _topSubjects = topSubjects;
    notifyListeners();
  }

  void setTopSubjectsFromMap(dynamic topSubjects) {
    _topSubjects = [];
    topSubjects.forEach((element) {
      _topSubjects.add(TopSearchSubject.fromMap(element));
    });
    notifyListeners();
  }
}
