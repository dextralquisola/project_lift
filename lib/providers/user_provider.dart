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

  Subject get firstSubject => _user.subjects.first;

  double getRating({required bool isTutor}) {
    double totalRating = 0;
    if (isTutor) {
      for (var rating in _user.ratingAsTutor) {
        totalRating += rating.rating;
      }
    } else {
      for (var rating in _user.ratingAsTutee) {
        totalRating += rating.rating;
      }
    }

    return isTutor
        ? totalRating /
            (_user.ratingAsTutor.isEmpty ? 1 : _user.ratingAsTutor.length)
        : totalRating /
            (_user.ratingAsTutee.isEmpty ? 1 : _user.ratingAsTutee.length);
  }

  bool isSubjectAdded(String subjectCode) {
    return subjects.any((subject) => subject.subjectCode == subjectCode);
  }

  Subject getSubject(String subjectCode) {
    return subjects.firstWhere((subject) => subject.subjectCode == subjectCode);
  }

  List<SubTopic> getSubTopics(String subjectCode) {
    return [SubTopic.empty(), ...getSubject(subjectCode).subTopics];
  }

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
