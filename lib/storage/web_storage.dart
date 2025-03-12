import 'package:web/web.dart';

late Storage storage;

void rememberMe(String email) {
  storage = window.sessionStorage;
  storage.setItem('email', email);
}
