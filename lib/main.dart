// flutter
import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
// Page
import 'package:src/auth.dart';
import 'package:login/sign_in.dart';
import 'package:login/sign_up.dart';
import 'package:login/dashboard.dart';
import 'package:login/claim.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Firebase Login',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

// 状態定義
enum AuthStatus {
  notSignedIn,
  signedIn,
  signedUp
}

// カレントページ
enum CurrentPage {
  dashboard,
  claim,
  other
}

class _RootPageState extends State<RootPage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;
  CurrentPage currentPage = CurrentPage.other;

  initState() {
    final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    super.initState();

    // Firebase 認証
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });

    // Firebase FCM
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _buildDialog(context, "onMessage：請求が届いたようだ(๑•̀ㅁ•́๑)✧");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _buildDialog(context, "onLaunch：請求が届いたようだ(๑•̀ㅁ•́๑)✧");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _buildDialog(context, "onResume：請求が届いたようだ(๑•̀ㅁ•́๑)✧");
      },
    );
    // Push通知の許可
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    // Push通知の許可・設定(iOS)
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  // ダイアログを表示するメソッド
  void _buildDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new Text("Message: $message"),
          actions: <Widget>[
            new FlatButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            new FlatButton(
              child: const Text('SHOW'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      }
    );
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  void _updateCurrentPage(CurrentPage page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 認証状態に応じて表示する画面を分ける
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        print('■ サインイン');
        // サインインページ
        return new SignIn(
          title: 'Flutter Firebase SignIn',
          auth: widget.auth,
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn),
          onSignUp: () => _updateAuthStatus(AuthStatus.signedUp),
        );
      case AuthStatus.signedIn:
        switch (currentPage) {
          case CurrentPage.claim:
            print('■ 請求画面');
            // サインインページ
            return new Claim(
              auth: widget.auth,
              onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn),
              currentPageDashboardSet: () => _updateCurrentPage(CurrentPage.dashboard)
            );
          default:
            print('■ ダッシュボード');
            // ダッシュボードページ
            return new Dashboard(
              auth: widget.auth,
              onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn),
              currentPageClaimSet: () => _updateCurrentPage(CurrentPage.claim)
            );
        }
        break;
      case AuthStatus.signedUp:
        print('■ サインアップ');
        // 新規登録ページ
        return new SignUp(
          title: 'Flutter Firebase SignUp',
          auth: widget.auth,
          onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn),
          onSignIn: () => _updateAuthStatus(AuthStatus.signedIn)
        );
    }
  }
}