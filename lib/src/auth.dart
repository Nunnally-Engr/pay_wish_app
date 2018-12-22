import 'dart:async';
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:src/table/users.dart';

abstract class BaseAuth {

  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password, String displayName, String photoUrl);
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final BaseUsers _users = new Users();

  Future<String> signIn(String email, String password) async {

    // Firebase Authentication サインイン
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    // Usersテーブル更新
    await _users.update(user.uid);

    return user.uid;
  }

  Future<String> createUser(String email, String password, String displayName, String photoUrl) async {

    // Firebase Authentication 登録 & サインイン
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    // Firebase UserInfo 更新
    UserUpdateInfo info = new UserUpdateInfo();
    info.displayName = displayName; // 表示名前
    info.photoUrl = photoUrl;       // 画像URL
    user.updateProfile(info);

    // Usersテーブル作成
    await _users.create(user.uid);

    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}