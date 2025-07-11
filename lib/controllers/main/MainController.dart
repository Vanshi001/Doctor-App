import 'dart:convert';

import 'package:Doctor/model/appointment_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/Constants.dart';

class MainController extends GetxController {
  final RxList<Map<String, String>> appointmentList =
      <Map<String, String>>[].obs;

  RxBool isLoading = false.obs;

  var currentIndex = 0.obs;

  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;

  Rxn<AppointmentResponse> appointmentResponse = Rxn<AppointmentResponse>();

  Rxn<AppointmentResponse> todayAppointmentResponse = Rxn<AppointmentResponse>();

  Future<void> fetchAppointmentsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isLoading.value = true;
    final url = Uri.parse('http://192.168.1.10:5000/api/appointments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Appointments: $responseData');

        appointmentResponse.value = AppointmentResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTodayAppointmentsApi(String currentDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isLoading.value = true;
    final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("Today's Appointments: $responseData");

        todayAppointmentResponse.value = AppointmentResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoading.value = false;
    }
  }

}