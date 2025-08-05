import 'dart:convert';

import 'package:Doctor/model/appointment_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/DoctorProfileResponse.dart';
import '../../model/PendingAppointmentsWithoutDescriptionResponse.dart';
import '../../widgets/Constants.dart';
import '../AppointmentsController.dart';

class MainController extends GetxController {
  final RxList<Map<String, String>> appointmentList = <Map<String, String>>[].obs;

  RxBool isLoading = false.obs;

  var currentIndex = 0.obs;

  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;

  Rxn<AppointmentResponse> appointmentResponse = Rxn<AppointmentResponse>();

  Rxn<AppointmentResponse> todayAppointmentResponse = Rxn<AppointmentResponse>();
  RxList<Appointment> allList = <Appointment>[].obs;
  // Rxn<DoctorProfileResponse> doctorDetail = Rxn<DoctorProfileResponse>();

  Future<void> fetchAppointmentsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments');
    final url = Uri.parse('${Constants.baseUrl}appointments?doctorId=$doctorId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
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
        print('fetchAppointmentsApi errorMessage ---- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoading.value = false;
    }
  }

  String? doctorId;
  final doctorName = RxString(''); // Make it observable
  final doctorDetail = Rxn<DoctorProfileResponse>();

  final AppointmentsController appointmentsController = Get.put(AppointmentsController());

  Future<void> fetchDoctorDetailsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId');
    print('fetchDoctorDetailsApi url -- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("doctorDetail: $responseData");

        doctorDetail.value = DoctorProfileResponse.fromJson(responseData);
        print("doctor id:==== ${doctorDetail.value?.data?.id}");
        doctorName.value = doctorDetail.value?.data?.name ?? 'Dr. Dermatics';
        print("doctor name:==== ${doctorDetail.value?.data?.name}");

        fetchTodayAppointmentsApi(currentDate.value, doctorDetail.value?.data?.id);
        fetchPendingAppointmentsWithoutPrescriptionApi(doctorDetail.value?.data?.id);
        appointmentsController.fetchAllAppointmentsApi(doctorDetail.value?.data?.id);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed to get doctor profile";
        print('errorMessage fetchDoctorDetailsApi -- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error:- $e');
      Constants.showError("Error -- $e");
    }
  }

  Future<void> fetchTodayAppointmentsApi(String currentDate, String? doctorId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -~- $doctorId');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=today&date=$currentDate&doctorId=$doctorId');
    print('fetchTodayAppointmentsApi url -- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("Today's Appointments: $responseData");

        todayAppointmentResponse.value = AppointmentResponse.fromJson(responseData);
        final appointments = todayAppointmentResponse.value!.data;

        print("Today's ALL Appointments: $appointments");
        allList.assignAll(appointments);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error:~~ $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoading.value = false;
    }
  }

  RxBool isLoadingAppointmentWithoutDescription = false.obs;
  RxList<WithoutDescriptionAppointment> pendingAppointmentWithoutDescriptionList = <WithoutDescriptionAppointment>[].obs;
  Rxn<PendingAppointmentsWithoutDescriptionResponse> withoutDescriptionAppointmentResponse = Rxn<PendingAppointmentsWithoutDescriptionResponse>();

  Future<void> fetchPendingAppointmentsWithoutPrescriptionApi(String? doctorId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isLoadingAppointmentWithoutDescription.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -~~- $doctorId');
    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/appointments/no-prescription');
    print('fetchPendingAppointmentsWithoutPrescriptionApi url -- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("Pending's Appointments: $responseData");

        withoutDescriptionAppointmentResponse.value = PendingAppointmentsWithoutDescriptionResponse.fromJson(responseData);
        final appointments = withoutDescriptionAppointmentResponse.value!.data;

        print("Pending Appointment Without Description List's: ${appointments.length}");
        pendingAppointmentWithoutDescriptionList.assignAll(appointments);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error:~~ $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoadingAppointmentWithoutDescription.value = false;
    }
  }
}
