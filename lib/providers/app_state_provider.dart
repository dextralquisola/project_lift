import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  int _currentHomePageIndex = 0;
  dynamic _notif;
  dynamic _notifLogout;

  int get currentHomePageIndex => _currentHomePageIndex;
  dynamic get getNotif => _notif;
  dynamic get getNotifLogout => _notifLogout;

  void setCurrentHomePageIndex(int index, [bool isNotify = true]) {
    _currentHomePageIndex = index;
    isNotify ? notifyListeners() : () {};
  }

  void setNotif(dynamic notif, [bool isNotify = true]) {
    _notif = notif;
    isNotify ? notifyListeners() : () {};
  }

  void setNotifLogout(dynamic notif, [bool isNotify = true]) {
    _notifLogout = notif;
    isNotify ? notifyListeners() : () {};
  }

  void dismissNotifLogout([bool isNotify = true]) {
    _notifLogout = null;
    isNotify ? notifyListeners() : () {};
  }

  void dismissNotif([bool isNotify = true]) {
    _notif = null;
    isNotify ? notifyListeners() : () {};
  }
}
