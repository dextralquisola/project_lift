import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_lift/features/auth/service/auth_service.dart';
import 'package:project_lift/utils/socket_client.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subject.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _googleUser;
  GoogleSignInAccount? get googleUser => _googleUser;

  User _user = User.emptyUser();

  bool _isGoogleLogin = false;
  bool _isTutorialDoNotShow = false;

  User get user => _user;
  bool get isTutor => _user.role == 'tutor';
  bool get isAuthenticated => _user.token != '' && user.isEmailVerified;
  bool get isTutorialDoNotShow => _isTutorialDoNotShow;
  bool get isGoogleLogin => _isGoogleLogin;

  void setIsTutorialDoNotShow(bool value) {
    _isTutorialDoNotShow = value;
    notifyListeners();
  }

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

  void deleteSubject(Subject subject, [bool isNotify = true]) {
    var subjects = _user.subjects;
    subjects
        .removeWhere((element) => element.subjectCode == subject.subjectCode);
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

  Future<void> getUserState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isTutorialDoNotShow = prefs.getBool('isTutorialDoNotShow') ?? false;
    if (prefs.containsKey('isGoogleLogin')) {
      _isGoogleLogin = prefs.getBool('isGoogleLogin')!;
    }
  }

  Future<void> logout() async {
    if (_isGoogleLogin) {
      await googleSignIn.disconnect();
    }

    _user = User.emptyUser();

    SocketClient.instance.disconnect();

    var prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  Future<void> googleLogin(BuildContext context) async {
    try {
      final authService = AuthService();

      await _googleUser?.clearAuthCache();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      _googleUser = googleUser;

      final googleAuth = await googleUser.authentication;

      // if (_isTokenExpired(googleAuth.accessToken)) {
      // }

      printLog(googleAuth.accessToken.toString(), "credential.accessToken:");
      printLog(googleAuth.idToken.toString(), "credential.idToken:");

      if (context.mounted) {
        var result = await authService.signInWithGoogle(
          accessToken: googleAuth.accessToken!,
          idToken: googleAuth.idToken!,
          context: context,
        );

        printLog("googleLogin result: $result", "googleLogin result");

        if (!result && await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
          _googleUser = null;
          return;
        }
      }
    } catch (e) {
      printLog(e.toString(), "googleLogin error");
    }
  }

  void clearUserData() async {
    _user = User.emptyUser();
    _googleUser = null;
    notifyListeners();
  }
}
