import 'dart:async';
import 'dart:convert';

import 'package:Doctor/model/appointment_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/DoctorProfileResponse.dart';
import '../../model/PendingAppointmentsWithoutDescriptionResponse.dart';
import '../../screens/AuthScreen.dart';
import '../../widgets/Constants.dart';
import '../AppointmentsController.dart';
import '../auth/AuthController.dart';

class MainController extends GetxController {
  final RxList<Map<String, String>> appointmentList = <Map<String, String>>[].obs;

  RxBool isLoading = false.obs;

  var currentIndex = 0.obs;

  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;

  Rxn<AppointmentResponse> appointmentResponse = Rxn<AppointmentResponse>();

  Rxn<AppointmentResponse> todayAppointmentResponse = Rxn<AppointmentResponse>();
  RxList<Appointment> allList = <Appointment>[].obs;

  // Rxn<DoctorProfileResponse> doctorDetail = Rxn<DoctorProfileResponse>();

  String getInitials(String firstName /*, String lastName*/) {
    if (firstName.isEmpty /*&& lastName.isEmpty*/ ) return '';

    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    // String lastInitial = lastName.isNotEmpty ? lastName[0] : '';

    return firstInitial.toUpperCase(); /*${lastInitial.toUpperCase()}*/
  }

  Future<void> fetchAppointmentsApi() async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called. -mainController fetchAppointmentsApi- ${AuthController.isLoggedIn.value}");
    //   return;
    // } else {
    //   print("User logged out. API not called. else -mainController fetchAppointmentsApi- ${AuthController.isLoggedIn.value}");
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    // print('doctorId -- $doctorId');

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

        // print('Appointments: $responseData');

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

  // final authController = Get.put(AuthController());

  RxBool isLoadingDoctorDetails = false.obs;
  RxBool isFirstLoad = true.obs; // Show loader only for first fetch
  Timer? _refreshDoctorTimer;

  Future<void> fetchDoctorDetailsApi() async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called. - mainController fetchDoctorDetailsApi- ${AuthController.isLoggedIn.value}");
    //   return;
    // } else {
    //   print("User logged out. API not called. else -mainController fetchDoctorDetailsApi- ${AuthController.isLoggedIn.value}");
    // }

    if (isFirstLoad.value) {
      isLoadingDoctorDetails.value = true; // only first time loader
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    doctorId = prefs.getString('doctor_id') ?? '';
    // print('doctorId -- $doctorId');

    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId');
    // print('fetchDoctorDetailsApi url -- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("doctorDetail: $responseData");

        doctorDetail.value = DoctorProfileResponse.fromJson(responseData);
        // print("doctor id:==== ${doctorDetail.value?.data?.id}");
        doctorName.value = doctorDetail.value?.data?.name ?? 'Dr. Dermatics';
        // print("doctor name:==== ${doctorDetail.value?.data?.name}");

        // fetchTodayAppointmentsApi(currentDate.value, doctorDetail.value?.data?.id);
        // fetchPendingAppointmentsWithoutPrescriptionApi(doctorDetail.value?.data?.id);
        // fetchAllAppointments(doctorDetail.value?.data?.id);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed to get doctor profile";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('errorMessage main fetchDoctorDetailsApi -- $errorMessage');
          Constants.showError(errorMessage);
        } else if (errorMessage == "Session expired. Please log in again.") {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          var token = prefs.getString('access_token');
          print('while logout -> $token');
          prefs.setString("access_token", '');
          print('after logout -> ${prefs.getString('access_token')}');
          Constants.showSuccess('Session expired. Please log in again.');
          Get.offAll(() => AuthScreen());
        }
      }
    } catch (e) {
      print('Error:- $e');
      Constants.showError("Error -- $e");
    } finally {
      if (isFirstLoad.value) {
        isLoadingDoctorDetails.value = false; // hide loader after first load
      }
      if (isFirstLoad.value) {
        isLoadingDoctorDetails.value = false;
        isFirstLoad.value = false;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("access_token");

      if (token != null && token.isNotEmpty) {
        _refreshDoctorTimer?.cancel();
        _refreshDoctorTimer = Timer(const Duration(seconds: 10), () async {
          if (token != null && token.isNotEmpty) fetchDoctorDetailsApi();
        });
      }
    }
  }

  RxBool isLoadingAllAppointment = false.obs;
  RxBool isFirstLoadAllAppointment = true.obs; // Show loader only for first fetch
  Timer? _refreshAllAppointmentTimer;

  void fetchAllAppointments(String? doctorId) async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    if (isFirstLoadAllAppointment.value) {
      isLoadingAllAppointment.value = true; // only first time loader
    }
    try {
      print('fetchAllAppointments');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("access_token");
      if (token != null && token.isNotEmpty) appointmentsController.fetchAllAppointmentsApi(doctorId);
    } catch (e) {
      print('Error fetchAllAppointments:- $e');
      Constants.showError("Error fetchAllAppointments -- $e");
    } finally {
      if (isFirstLoadAllAppointment.value) {
        isFirstLoadAllAppointment.value = false; // hide loader after first load
      }
      if (isFirstLoadAllAppointment.value) {
        isFirstLoadAllAppointment.value = false;
        isFirstLoadAllAppointment.value = false;
      }

      // Schedule next refresh
      _refreshAllAppointmentTimer?.cancel();
      _refreshAllAppointmentTimer = Timer(const Duration(seconds: 10), () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var token = prefs.getString("access_token");
        if (token != null && token.isNotEmpty) fetchAllAppointments(doctorId);
      });
    }
  }

  Timer? _timer;

  RxBool isLoadingToday = false.obs;
  RxBool isFirstLoadToday = true.obs; // Show loader only for first fetch
  Timer? _refreshTodayTimer;

  Future<void> fetchTodayAppointmentsApi(String currentDate, String? doctorId) async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    if (isFirstLoadToday.value) {
      isLoadingToday.value = true; // only first time loader
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    // isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -~- fetchTodayAppointmentsApi -~- MainController -~- $doctorId');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=today&date=$currentDate&doctorId=$doctorId');
    // print('fetchTodayAppointmentsApi url -- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("Today's Appointments: $responseData");

        todayAppointmentResponse.value = AppointmentResponse.fromJson(responseData);
        final appointments = todayAppointmentResponse.value!.data;

        // print("Today's ALL Appointments: $appointments");
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
      // isLoading.value = false;
      if (isFirstLoadToday.value) {
        isLoadingToday.value = false; // hide loader after first load
      }
      if (isFirstLoadToday.value) {
        isLoadingToday.value = false;
        isFirstLoadToday.value = false;
      }

      // Schedule next refresh
      _refreshTodayTimer?.cancel();
      _refreshTodayTimer = Timer(const Duration(seconds: 10), () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var token = prefs.getString("access_token");
        if (token != null) fetchTodayAppointmentsApi(currentDate, doctorId);
      });
    }
  }

  void startAutoFetch() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      print('startAutoFetch');
      fetchDoctorDetailsApi(); // fetch every 5 seconds without loader
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _refreshTodayTimer?.cancel();
    _refreshPendingTimer?.cancel();
    _refreshAllAppointmentTimer?.cancel();
    super.onClose();
  }

  RxBool isLoadingAppointmentWithoutDescription = false.obs;
  RxList<WithoutDescriptionAppointment> pendingAppointmentWithoutDescriptionList = <WithoutDescriptionAppointment>[].obs;
  Rxn<PendingAppointmentsWithoutDescriptionResponse> withoutDescriptionAppointmentResponse = Rxn<PendingAppointmentsWithoutDescriptionResponse>();

  RxBool isFirstLoadPending = true.obs; // Show loader only for first fetch
  Timer? _refreshPendingTimer;

  Future<void> fetchPendingAppointmentsWithoutPrescriptionApi(String? doctorId) async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    if (isFirstLoadPending.value) {
      isLoadingAppointmentWithoutDescription.value = true;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    // isLoadingAppointmentWithoutDescription.value = true;

    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final doctorId = prefs.getString('doctor_id') ?? '';
    // print('doctorId -~~- $doctorId');
    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/appointments/no-prescription');
    // print('fetchPendingAppointmentsWithoutPrescriptionApi url -- $url');

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
      // isLoadingAppointmentWithoutDescription.value = false;
      if (isFirstLoadPending.value) {
        isLoadingAppointmentWithoutDescription.value = false; // hide loader after first load
      }
      if (isFirstLoadPending.value) {
        isLoadingAppointmentWithoutDescription.value = false;
        isFirstLoadPending.value = false;
      }

      // Schedule next refresh
      _refreshPendingTimer?.cancel();
      _refreshPendingTimer = Timer(const Duration(seconds: 10), () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var token = prefs.getString("access_token");
        if (token != null) fetchPendingAppointmentsWithoutPrescriptionApi(doctorId);
      });
    }
  }

  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxString searchText = "".obs;
}
