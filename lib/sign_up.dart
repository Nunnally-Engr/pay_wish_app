import 'package:flutter/material.dart';
import 'package:src/auth.dart';
import 'package:login/primary_button.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key, this.title, this.auth, this.onSignOut, this.onSignIn}) : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  @override
  _SignUpState createState() => new _SignUpState();
}

enum FormType {
  login,
  register
}

class _SignUpState extends State<SignUp> {
  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _displayName;
  String _photoUrl;
  String _authHint = '';

  bool isValidata() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void onPressSignIn() async {

    setState(() {
      _authHint = '';
    });
    widget.onSignOut();
  }


  void onPressSignUp() async {

    setState(() {
      _authHint = '';
    });

    if (isValidata()) {
      // Formエラーがない場合
      try {
        
        // Firebase: User Create.
        String userId = await widget.auth.createUser(_email, _password, _displayName, _photoUrl);

        setState(() {
          _authHint = 'Signed In\n\nUser id: $userId';
        });
        widget.onSignIn();
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
  List<Widget> usernameAndPassword() {
    return [
      padded(child: new TextFormField(
        key: new Key('displayName'),
        decoration: new InputDecoration(labelText: 'Name'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Name can\'t be empty.' : null,
        onSaved: (val) => _displayName = val,
      )),
      padded(child: new TextFormField(
        key: new Key('email'),
        decoration: new InputDecoration(labelText: 'Email'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
        onSaved: (val) => _email = val,
      )),
      padded(child: new TextFormField(
        key: new Key('password'),
        decoration: new InputDecoration(labelText: 'Password'),
        obscureText: true,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
        onSaved: (val) => _password = val,
      )),
    ];
  }

  // ボタン
  List<Widget> submitWidgets() {
    return [
      new PrimaryButton(
        key: new Key('register'),
        text: 'サインアップ',
        height: 44.0,
        onPressed: onPressSignUp
      ),
      new FlatButton(
        key: new Key('login'),
        textColor: Colors.green,
        child: new Text("既にアカウントをお持ちの方：サインイン"),
        onPressed: onPressSignIn
      ),
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
        title: new Text(widget.title),
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
                          children: usernameAndPassword() + submitWidgets(),
                        )
                    )
                ),
              ])
            ),
            hintText()
          ]
        )
      ))
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}

