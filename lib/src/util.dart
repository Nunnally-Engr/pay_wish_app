import 'package:intl/intl.dart';

abstract class BaseUtil {

  String getNowDateAndTime();
}

class Util implements BaseUtil {

  String getNowDateAndTime() {

    // 現在の日付取得
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    String formatted = formatter.format(now);

    return formatted;
  }

}