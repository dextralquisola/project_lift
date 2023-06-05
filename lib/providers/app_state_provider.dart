import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  int _currentHomePageIndex = 0;
  dynamic _notif;

  int get currentHomePageIndex => _currentHomePageIndex;
  dynamic get getNotif => _notif;

  void setCurrentHomePageIndex(int index, [bool isNotify = true]) {
    _currentHomePageIndex = index;
    isNotify ? notifyListeners() : () {};
  }

  void setNotif(dynamic notif, [bool isNotify = true]) {
    _notif = notif;
    isNotify ? notifyListeners() : () {};
  }

  void dismissNotif([bool isNotify = true]) {
    _notif = null;
    isNotify ? notifyListeners() : () {};
  }
}
