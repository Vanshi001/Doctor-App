import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkController extends GetxController {
  var connectionStatus = "Checking...".obs;

  Future<void> checkActiveInternetConnection() async {
    bool hasConnection = await InternetConnectionChecker.instance.hasConnection;
    connectionStatus.value = hasConnection ? "Connected to Internet" : "Not Connected";
  }
}
