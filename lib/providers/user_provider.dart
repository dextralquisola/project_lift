import 'package:flutter/foundation.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subject.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User.emptyUser();

  User get user => _user;
  List<Subject> get subjects => _user.subjects;
  bool get isTutor => _user.role == 'tutor';
  bool get isAuthenticated => _user.token != '';

  void addSubject(Subject subject) {
    _user = _user.copyFrom(
      subjects: [...subjects, subject],
    );
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserFromMap(Map<String, dynamic> user) {
    _user = User.fromMap(user);
    notifyListeners();
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
