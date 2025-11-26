import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/SlotUpdateResponse.dart';
import '../widgets/Constants.dart';

class SlotEditController extends GetxController {
  // your lists
  final morningStartTimes = ["09:00AM", "10:00AM", "11:00AM", "12:00PM", "01:00PM"].obs;
  final morningEndTimes = ["09:00AM", "10:00AM", "11:00AM", "12:00PM", "01:00PM"].obs;
  final eveningStartTimes = ["02:00PM", "03:00PM", "04:00PM", "05:00PM", "06:00PM", "07:00PM", "08:00PM", "09:00PM"].obs;
  final eveningEndTimes = ["02:00PM", "03:00PM", "04:00PM", "05:00PM", "06:00PM", "07:00PM", "08:00PM", "09:00PM"].obs;

  // selected values (reactive)
  final selectedStart = RxnString();
  final selectedEnd = RxnString();

  // call this when you open the edit screen
  void initForEdit({
    required bool isMorning,
    required String? start, // editSlot?.start
    required String? end, // editSlot?.end
  }) {
    final starts = isMorning ? morningStartTimes : eveningStartTimes;
    final ends = isMorning ? morningEndTimes : eveningEndTimes;

    // If the current start/end exists in the list, select it; otherwise pick first
    selectedStart.value = starts.contains(start) ? start : (starts.isNotEmpty ? starts.first : null);
    selectedEnd.value = ends.contains(end) ? end : (ends.isNotEmpty ? ends.first : null);

    // Optional: ensure end is not before start (by index)
    final si = starts.indexOf(selectedStart.value ?? '');
    final ei = ends.indexOf(selectedEnd.value ?? '');
    if (si >= 0 && ei >= 0 && ei < si) {
      // push end to at least start index if same arrays, or choose nearest valid
      selectedEnd.value = ends[(si < ends.length) ? si : ends.length - 1];
    }
  }

  List<String> get startsListForUI => isMorning ? morningStartTimes : eveningStartTimes;

  List<String> get endsListForUI => isMorning ? morningEndTimes : eveningEndTimes;

  // provide isMorning from the screen (or keep it here as RxBool)
  bool isMorning = true;

  var isLoading = false.obs;

  Future<bool> editCustomDatesApi({
    required String? doctorId,
    required String? dateKey,
    required String? slotId,
    required String startTime,
    required String endTime,
  }) async {
    isLoading.value = true; // only first time loader

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // print('token =====~~~~~~~~~~~~~~~~~~ $token');

    final url = Uri.parse('${Constants.baseUrl}doctors/date-availability/$dateKey/slots/$slotId');
    print('url ---- $url');

    final Map<String, dynamic> requestBody = {"start": startTime, "end": endTime};

    print('📤 Request Body: $requestBody');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(requestBody),
      );

      print('response.statusCode -- ${response.statusCode}');
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Appointments: $responseData');

        final data = SlotUpdateResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        // final dates = availabilityResponse.value?.data ?? [];
        // print('dates -------->>>>>> $dates');
        // Constants.showSuccess(data.message);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select Medicine", style: TextStyles.textStyle1_1,), backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)));

        // print('✅ Extracted Dates: ${data}');
        print('✅ Message: ${data.message}');
        return true;
        // allList.assignAll(dates);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('addCustomDatesApi errorMessage ---- $errorMessage');
          Constants.showError(errorMessage);
        }
        return false;
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
      return false;
    } finally {
      isLoading.value = false;

      // Schedule next refresh
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // if (token != null && token.isNotEmpty) {
      // print('_refreshAllAppointmentTimer');
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // var token = prefs.getString('access_token');
      // print('token ............................... $token');
      // if (token != null && token.isNotEmpty) addCustomDatesApi(doctorId);
      // } else {
      //   print("Skipping auto-refresh: token is null/empty");
      // }
    }
  }
}
