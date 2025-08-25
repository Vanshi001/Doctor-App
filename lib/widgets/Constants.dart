import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit/zego_uikit.dart';

class Constants {
  // static String baseUrl = "https://dermatics-backend.onrender.com/api/";
  // static String baseUrl = "http://192.168.1.7:5000/api/";
  static String baseUrl = "http://ec2-13-126-77-72.ap-south-1.compute.amazonaws.com/api/";

  static void showError(String message) {
    Get.snackbar("Validation Error", message, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  static void showCallHistoryError(String message) {
    Get.snackbar("Error", message, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  static void showSuccess(String message) {
    Get.snackbar("Successful!", message, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  static String formatTimeToAmPm(String? timeString) {
    // final timeParts = timeString?.split(':');
    // final hour = int.parse(timeParts![0]);
    // final minute = int.parse(timeParts[1]);
    //
    // final dt = DateTime(0, 1, 1, hour, minute);
    // return DateFormat('h:mm a').format(dt);

    if (timeString == null || timeString.isEmpty) {
      return '--:--';
    }

    try {
      // Handle different time formats
      if (timeString.contains(':')) {
        // Parse time string like "09:00:00" or "09:00"
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;

          // Create a DateTime object with today's date and the parsed time
          final now = DateTime.now();
          final time = DateTime(now.year, now.month, now.day, hour, minute);

          return DateFormat('hh:mm a').format(time);
        }
      }

      return '--:--';
    } catch (e) {
      print('Error formatting time: $timeString, error: $e');
      return '--:--';
    }
  }

  static DateTime parseTimeString(String timeStr) {
    final now = DateTime.now();
    final timeParts = timeStr.split(':');
    if (timeParts.length < 2) return now;

    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static ZegoUIKitUser currentUser = ZegoUIKitUser(id: '', name: '');

  static int zegoAppId = 260617754;
  static String zegoAppSign = "0b18f31ba87471a155cfea2833abf4c8168690730f6d565f985115620ca14e28";

}
