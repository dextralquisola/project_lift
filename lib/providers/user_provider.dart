import 'package:flutter/foundation.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subject.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User.emptyUser();

  User get user => _user;
  bool get isTutor => _user.role == 'tutor';
  bool get isAuthenticated => _user.token != '' && user.isEmailVerified;

  void updateSubject(Subject subject, [bool isNotify = true]) {
    var subjects = _user.subjects;

    var index = subjects
        .indexWhere((element) => element.subjectCode == subject.subjectCode);

    subjects[index] = subject;

    _user = _user.copyFrom(subjects: subjects);
    isNotify ? notifyListeners() : () {};
  }

  void addSubject(Subject subject, [bool isNotify = true]) {
    _user = _user.copyFrom(
      subjects: [..._user.subjects, subject],
    );
    isNotify ? notifyListeners() : () {};
  }

  void deleteSubject(Subject subject, [bool isNotify = true]){
    var subjects = _user.subjects;
    subjects.removeWhere((element) => element.subjectCode == subject.subjectCode);
    _user = _user.copyFrom(subjects: subjects);
    isNotify ? notifyListeners() : () {};
  }

  void setUserFromModel(User user, [bool isNotify = true]) {
    _user = user;
    isNotify ? notifyListeners() : () {};
  }

  void setUserFromMap(Map<String, dynamic> user, [bool notify = true]) {
    _user = User.fromMap(user);
    notify ? notifyListeners() : () {};
  }

  void setTokens({
    required String fcmToken,
    required String deviceToken,
  }) async {
    _user = _user.copyFrom(
      firebaseToken: fcmToken,
      deviceToken: deviceToken,
    );

    notifyListeners();
  }

  Future<void> logout() async {
    _user = User.emptyUser();

    SocketClient.instance.disconnect();

    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void clearUserData() {
    _user = User.emptyUser();
    notifyListeners();
  }
}

// class UserProvider with ChangeNotifier {
//   final googleSignIn = GoogleSignIn();

//   GoogleSignInAccount? _user;
//   GoogleSignInAccount get user => _user!;

//   Future<void> googleLogin() async {
//     final googleUser = await googleSignIn.signIn();
//     if (googleUser == null) return;

//     _user = googleUser;

//     final googleAuth = await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     await FirebaseAuth.instance.signInWithCredential(credential);
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     await googleSignIn.disconnect();
//     FirebaseAuth.instance.signOut();
//   }
// }
