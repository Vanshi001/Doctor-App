import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit/zego_uikit.dart';

class Constants {
  // static String baseUrl = "https://dermatics-backend.onrender.com/api/";
  static String baseUrl = "http://192.168.1.21:5000/api/";

  static void showError(String message) {
    Get.snackbar("Validation Error", message, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  static void showSuccess(String message) {
    Get.snackbar("Successful!", message, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  static String formatTimeToAmPm(String timeString) {
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final dt = DateTime(0, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }

  static ZegoUIKitUser currentUser = ZegoUIKitUser(id: '', name: '');

}
