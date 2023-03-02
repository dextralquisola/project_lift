import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<void> googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("########### Access Token ###########");
    print("Access Token ${credential.accessToken}");
    print("####################################");
    print("");
    print("########### Id Token ###########");
    print("Id Token ${credential.idToken}");
    print("#################################");
    print("");

    await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();
  }
}
