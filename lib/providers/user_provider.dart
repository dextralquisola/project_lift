import 'package:flutter/foundation.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User.initialize();

  User get user => _user;

  bool get isAuthenticated => _user.token != '';

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserFromMap(Map<String, dynamic> user) {
    _user = User.fromMap(user);
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
