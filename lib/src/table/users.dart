import 'dart:async';
import 'package:intl/intl.dart';
// Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseUsers {

  Future<void> create(String uid);
  Future<void> update(String uid);
}

class Users implements BaseUsers {

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  Future<void> create(String uid) async {
    String _token = await _firebaseMessaging.getToken();
    var db = Firestore.instance;
    await db.collection("users").document(uid).setData({
      "deviceToken": _token,
      "createdAt": DateFormat("y/m/d H:mm", "en_US").format(new DateTime.now()),
      "updatedAt": DateFormat("y/m/d H:mm", "en_US").format(new DateTime.now()),
      "deletedAt": ''
    });
  }

  Future<void> update(String uid) async {
    String _token = await _firebaseMessaging.getToken();
    var db = Firestore.instance;
    await db.collection("users").document(uid).updateData({
      "deviceToken": _token,
      "updatedAt": DateFormat("y/m/d H:mm", "en_US").format(new DateTime.now())
    });
  }


}