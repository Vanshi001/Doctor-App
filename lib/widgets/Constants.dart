import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Constants {
   static void showError(String message) {
    Get.snackbar(
      "Validation Error",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      "Successful!",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}