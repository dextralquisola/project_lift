import 'package:flutter/material.dart';
import 'package:project_lift/models/request.dart';

class UserRequestsProvider with ChangeNotifier {
  List<Request> _myRequests = [];
  List<Request> _tuteeRequests = [];

  List<Request> get requests => _tuteeRequests;
  List<Request> get myRequests => _myRequests;

  bool isHasRequest(String id) {
    return _myRequests.indexWhere((req) => req.tutorId == id) == -1;
  }

  void removeMyRequestById(String id) {
    _myRequests.removeWhere((element) => element.requestId == id);
    notifyListeners();
  }

  void addMyRequestFromMap(List<dynamic> requests,
      [bool notifyListener = false]) {
    _myRequests = requests.map((e) => Request.fromMap(e)).toList();

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
    notifyListeners();
  }
}
