import 'dart:async';

// Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Util
import 'package:src/util.dart';

abstract class BaseUsers {

  Future<void> create(String uid, String displayName);
  Future<void> update(String uid);
  Future<Map> select(String uid);
}

class Users implements BaseUsers {

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final BaseUtil _util = new Util();

  Future<void> create(String uid, String displayName) async {

    String _token = await _firebaseMessaging.getToken();

    var db = Firestore.instance;
    await db.collection("users").document(uid).setData({
      "deviceToken": _token,
      "displayName": displayName,
      "createdAt": _util.getNowDateAndTime(),
      "updatedAt": _util.getNowDateAndTime(),
      "deletedAt": ''
    });
  }

  Future<void> update(String uid) async {
    String _token = await _firebaseMessaging.getToken();
    var db = Firestore.instance;

    await db.collection("users").document(uid).updateData({
      "deviceToken": _token,
      "updatedAt": _util.getNowDateAndTime()
    });
  }

  Future<Map> select(String uid) async {

    var db = Firestore.instance;
    DocumentSnapshot user = await db.collection("users").document(uid).get();
    return user.data;
  }
}