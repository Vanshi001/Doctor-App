import 'package:get/get.dart';

class MainController extends GetxController {
  final RxList<Map<String, String>> appointmentList =
      <Map<String, String>>[].obs;

  RxBool isLoading = false.obs;

  var currentIndex = 0.obs;

}