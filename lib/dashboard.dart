import 'package:flutter/material.dart';
import 'package:src/auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Dashboard extends StatelessWidget {
  Dashboard({this.auth, this.onSignOut, this.currentPageClaimSet});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback currentPageClaimSet;

  @override
  Widget build(BuildContext context) {

    void _signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }

    }

    // 登録ボタン
    void onPressdClaimCreate() async {
      // ページセット
      currentPageClaimSet();
    }

    // 取得ボタン
    void onPressdClaimSelect() async {
      print('>>> Click：onCallClaimsSelect');
      final dynamic resp = await CloudFunctions.instance.call(
                              functionName: 'onCallClaimsSelect'
                            );
      print(resp);
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('ダッシュボード(*´ω`*)'),
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
          child: RaisedButton(
            child: const Text('取得'),
            color: Theme.of(context).accentColor,
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            onPressed: onPressdClaimSelect,
          ),
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