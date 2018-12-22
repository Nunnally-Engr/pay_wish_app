import 'package:flutter/material.dart';
import 'package:login/primary_button.dart';
import 'package:src/auth.dart';


class SignIn extends StatefulWidget {
  SignIn({Key key, this.title, this.auth, this.onSignIn, this.onSignUp}) : super(key: key);
  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  _SignInState createState() => new _SignInState();
}

class _SignInState extends State<SignIn> {
  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _authHint = '';

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  void validateAndSubmit() async {

    setState(() {
      _authHint = '';
    });

    if (validateAndSave()) {
      // Formエラーがない場合
      try {

        String userId = await widget.auth.signIn(_email, _password);
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

  void signUpSubmit() async {
    setState(() {
      _authHint = '';
    });
    widget.onSignUp();
  }

  // 入力フォーム
  List<Widget> usernameAndPassword() {
    return [
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
        key: new Key('login'),
        text: 'サインイン',
        height: 44.0,
        onPressed: validateAndSubmit
      ),
      new FlatButton(
        key: new Key('need-account'),
        textColor: Colors.green,
        child: new Text("初めて利用する方：サインアップ"),
        onPressed: signUpSubmit
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

