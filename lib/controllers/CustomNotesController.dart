import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class CustomNotesController extends GetxController with GetSingleTickerProviderStateMixin {
  var isOpen = false.obs;

  void toggleFab() => isOpen.value = !isOpen.value;

  void closeFab() => isOpen.value = false;
}
