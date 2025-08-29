import 'package:Doctor/widgets/Constants.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkController extends GetxController {
  var connectionStatus = "Checking...".obs;

  bool hasConnection = false;

  Future<void> checkActiveInternetConnection() async {
    hasConnection = await InternetConnectionChecker.instance.hasConnection;
    print('hasConnection ---- $hasConnection');
    connectionStatus.value = hasConnection ? Constants.connected : Constants.notConnected;
  }
}
