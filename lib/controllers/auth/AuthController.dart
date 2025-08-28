import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static RxBool isLoggedIn = false.obs;

  void login() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    isLoggedIn.value = true;
    pref.setBool('IS_LOGIN', isLoggedIn.value);
  }

  void logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    isLoggedIn.value = false;
    pref.setBool('IS_LOGIN', isLoggedIn.value);
  }
}
