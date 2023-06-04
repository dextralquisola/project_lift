import 'package:flutter/material.dart';
import 'package:project_lift/models/request.dart';
import 'package:project_lift/models/tutor_application.dart';

class UserRequestsProvider with ChangeNotifier {
  TutorApplication _tutorApplication = TutorApplication.empty();
  List<Request> _myRequests = [];
  List<Request> _tuteeRequests = [];

  List<Request> get requests => _tuteeRequests;
  List<Request> get myRequests => _myRequests;
  TutorApplication get tutorApplication => _tutorApplication;

  void clearTutorApplication() {
    _tutorApplication = TutorApplication.empty();
    notifyListeners();
  }

  void setTutorApplicationFromModel(TutorApplication tutorApplication) {
    _tutorApplication = tutorApplication;
    notifyListeners();
  }

  void setTutorApplicationFromMap(dynamic data) {
    _tutorApplication = TutorApplication.fromMap(data);
    notifyListeners();
  }

  bool isHasRequest(String id) {
    return _myRequests.indexWhere((req) => req.tutorId == id) == -1;
  }

  void removeMyRequestById(String id) {
    _myRequests.removeWhere((element) => element.requestId == id);
    notifyListeners();
  }

  void addMyRequestFromMap(
    List<dynamic> requests, {
    bool notifyListener = true,
    bool isMyRequest = false,
  }) {
    _myRequests = [
      ..._myRequests,
      ...requests.map((e) => Request.fromMap(e, isMyRequest)).toList()
    ];

    notifyListener ? notifyListeners() : () {};
  }

  void removeTuteeRequestById(String id) {
    _tuteeRequests.removeWhere((element) => element.requestId == id);
    notifyListeners();
  }

  void addTuteeRequestsFromMap(List<dynamic> requests,
      [bool notifyListener = false]) {
    _tuteeRequests = requests.map((e) => Request.fromMap(e)).toList();
    notifyListener ? notifyListeners() : () {};
  }

  void clearRequests() {
    _myRequests = [];
    _tuteeRequests = [];
    _tutorApplication = TutorApplication.empty();
    notifyListeners();
  }
}
