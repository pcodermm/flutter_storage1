import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

void rememberMe(String email) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('email', email);
}
