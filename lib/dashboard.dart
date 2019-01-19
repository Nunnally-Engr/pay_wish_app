import 'package:flutter/material.dart';
import 'package:src/auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:src/table/users.dart';

class Dashboard extends StatelessWidget {
  
  Dashboard({this.auth, this.onSignOut, this.currentPageClaimSet});

  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback currentPageClaimSet;

  final BaseUsers _users = new Users();

  @override
  Widget build(BuildContext context) {

    // ======================
    // 表示名取得
    // ======================
    Future<String> _getCurrentUserId() async {

      String uid = await auth.currentUser();
      Map user = await _users.select(uid);
      return user['displayName'];
    }

    // ======================
    // サインアウト
    // ======================
    void _signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }
    }

    // ======================
    // 登録ボタン
    // ======================
    void onPressdClaimCreate() async {
      // ページセット
      currentPageClaimSet();
    }

    // ======================
    // 取得ボタン
    // ======================
    void onPressdClaimSelect() async {
      print('>>> Click：onCallClaimsSelect');
      final dynamic resp = await CloudFunctions.instance.call(
                              functionName: 'onCallClaimsSelect'
                            );
      print(resp);
    }

    // ======================
    // 定義
    // ======================
    // テキストスタイル：表示名
    var descTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      fontFamily: 'Roboto',
      letterSpacing: 0.5,
      fontSize: 25.0,
    );    

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('ダッシュボード'),
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: new Text('サインアウト', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          )
        ],
      ),
      body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: Colors.yellow,
                    backgroundImage: NetworkImage('https://pbs.twimg.com/profile_images/1068308607953858560/u2m2ti3P_400x400.jpg'),
                    radius: 50
                  ),
                onTap: () => ''
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: 
                FutureBuilder(
                future: _getCurrentUserId(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString(), style: descTextStyle);
                  } else {
                    return Text("");
                  }
                }
              )
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onPressdClaimCreate,
        label: Text("請求する"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}