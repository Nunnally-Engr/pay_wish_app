import 'package:flutter/material.dart';
import 'package:src/auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Claim extends StatefulWidget {

  Claim({Key key, this.auth, this.onSignOut, this.currentPageDashboardSet}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback currentPageDashboardSet;

  @override
  _ClaimState createState() => new _ClaimState();
}

class _ClaimState extends State<Claim> {
  static final formKey = new GlobalKey<FormState>();

  String _buyUid = '';
  String _billingUid = '';
  String _buyItem = '';
  String _authHint = '';

  void _signOut() async {
    try {
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  void _dashboard() async {
    try {
      widget.currentPageDashboardSet();
    } catch (e) {
      print(e);
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  // 登録ボタン
  void onPressdClaimCreate() async {

    setState(() {
      _authHint = '';
    });

    if (validateAndSave()) {
      // Formエラーがない場合
      try {

        print('>>> Click：onPressdClaimCreate');
        final dynamic resp = await CloudFunctions.instance.call(
                                functionName: 'onCallClaimsCreate',
                                parameters: <String, String> {
                                  'buy_uid': _buyUid,
                                  'buy_date': '2018-12-10',
                                  'buy_item': _buyItem,
                                  'buy_amount': '2100',
                                  'pay_method': 'デビットカード',
                                  'pay_status': '未',
                                  'billing_amount': '750',
                                  'billing_uid': _billingUid,
                                  'created_at': '2018-12-12',
                                  'updated_at': '2018-12-12'
                                },
                              );
        print(resp);

      }
      catch (e) {
        setState(() {
          _authHint = 'Sign In Error\n\n${e.toString()}';
        });
        print(e);
      }
    }
  }

  // 入力フォーム
  List<Widget> inputForm() {
    return [
      padded(child: new TextFormField(
        key: new Key('購入者'),
        decoration: new InputDecoration(labelText: '購入者'),
        autocorrect: false,
        initialValue: _buyUid,
        validator: (val) => val.isEmpty ? '購入者を入力してください' : null,
        onSaved: (val) => _buyUid = val,
      )),
      padded(child: new TextFormField(
        key: new Key('購入品'),
        decoration: new InputDecoration(labelText: '購入品'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? '購入品を入力してください' : null,
        onSaved: (val) => _buyItem = val,
      )),
      padded(child: new TextFormField(
        key: new Key('請求先'),
        decoration: new InputDecoration(labelText: '請求先'),
        autocorrect: false,
        initialValue: _billingUid,
        validator: (val) => val.isEmpty ? '請求先を指定してください' : null,
        onSaved: (val) => _billingUid = val,
      )),
    ];
  }


  Widget hintText() {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('請求画面(´・ω・｀)'),
        actions: <Widget>[
          new FlatButton(
              onPressed: _dashboard,
              child: new Text('ダッシュボードへ', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          ),
          new FlatButton(
              onPressed: _signOut,
              child: new Text('サインアウト', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: new SingleChildScrollView(child: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: [
            new Card(
              child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: inputForm(),
                        )
                    )
                ),
              ])
            ),
            hintText()
          ]
        )
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressdClaimCreate,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}

