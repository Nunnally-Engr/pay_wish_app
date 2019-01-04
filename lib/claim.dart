import 'package:intl/intl.dart';

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

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
            ),
          ],
        ),
      ),
    );
  }
}

// 購入日：日付Picker
class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectDate
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().add(new Duration(days: -365)),
      lastDate: DateTime.now().add(new Duration(days: 365))
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _InputDropdown(
            labelText: labelText,
            valueText: DateFormat("yyyy-MM-dd").format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
      ],
    );
  }
}

class _ClaimState extends State<Claim> {
  static final formKey = new GlobalKey<FormState>();

  String _buyUid = '';
  String _billingUid = '';
  DateTime _buyDate = DateTime.now(); // 購入日
  String _buyItem = '';               // 商品
  String _buyAmount = '';             // 購入金額
  List _payMethods = ["現金", "デビット", "交通系IC", "クレジット", "ポイント", "その他"];
  String _currentPayMethod;

  String _authHint = '';


  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _payMethods) {
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city)
      ));
    }
    return items;
  }

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
  
  // 支払方法変更処理
  void changedDropDownItem(String selectedPayMethod) {
    setState(() {
      _currentPayMethod = selectedPayMethod;
    });
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
        print(_buyDate);
        print(_buyItem);
        print(_buyAmount);
        print(_currentPayMethod);
        // final dynamic resp = await CloudFunctions.instance.call(
        //                         functionName: 'onCallClaimsCreate',
        //                         parameters: <String, String> {
        //                           'buy_uid': _buyUid,
        //                           'buy_date': '2018-12-10',
        //                           'buy_item': _buyItem,
        //                           'buy_amount': '2100',
        //                           'pay_method': 'デビットカード',
        //                           'pay_status': '未',
        //                           'billing_amount': '750',
        //                           'billing_uid': _billingUid,
        //                           'created_at': '2018-12-12',
        //                           'updated_at': '2018-12-12'
        //                         },
        //                       );
        // print(resp);

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
      padded(child: new _DateTimePicker(
        key: new Key('購入日'),
        labelText: '購入日',
        selectedDate: _buyDate,
        selectDate: (DateTime date) {
          setState(() {
            _buyDate = date;
          });
        }
      )),
      padded(child: new TextFormField(
        key: new Key('購入品'),
        decoration: new InputDecoration(labelText: '購入品'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? '購入品を入力してください' : null,
        onSaved: (val) => _buyItem = val,
      )),
      padded(child: new TextFormField(
        key: new Key('購入金額'),
        decoration: new InputDecoration(labelText: '購入金額'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? '購入金額を入力してください' : null,
        onSaved: (val) => _buyAmount = val,
        keyboardType: TextInputType.number
      )),
      padded(child: new DropdownButtonHideUnderline(
        child: new ButtonTheme(
        alignedDropdown: true,
        child: new DropdownButton(
            key: new Key('支払方法'),
            value: _currentPayMethod,
            items: getDropDownMenuItems(),
            onChanged: changedDropDownItem,
          )
        )
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
