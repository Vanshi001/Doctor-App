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
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

      // print("doctorDetail statusCode: ${response.statusCode}");
      // print("doctorDetail body: ${response.body}");

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
        } else if (errorMessage == "Session expired. Please log in again." || errorMessage == "Invalid token") {
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
      // print('fetchAllAppointments');
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
  String formattedDate = '';

  Set<String> notifiedAppointments = {};

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
    // print('doctorId -~- fetchTodayAppointmentsApi -~- MainController -~- $doctorId');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=today&date=$currentDate&doctorId=$doctorId');
    // print('fetchTodayAppointmentsApi url -- $url');

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

        /*for (var appt in appointments) {
          if (appt.appointmentDate != null && appt.appointmentDate!.isNotEmpty) {
            DateTime parsedDate = DateTime.parse(appt.appointmentDate!);
            print("Parsed Appointment Date: $parsedDate");
            formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate);
            print('formattedDate ------> $formattedDate');
            sendAppointmentNotification(formattedDate, appt.timeSlot!.startTime);
          }
        }*/

        // print("Today's ALL Appointments: $appointments");
        allList.assignAll(appointments);

        for (var appt in appointments) {
          if (appt.appointmentDate != null && appt.appointmentDate!.isNotEmpty) {

            // IDENTIFY UNIQUE APPOINTMENT
            String apptKey = "${appt.id}-${appt.timeSlot?.startTime}";

            // SKIP IF ALREADY NOTIFIED
            if (notifiedAppointments.contains(apptKey)) {
              continue;
            }

            // ADD TO TRACKING
            notifiedAppointments.add(apptKey);

            DateTime parsedDate = DateTime.parse(appt.appointmentDate!);

            formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate);

            sendAppointmentNotification(formattedDate, appt.timeSlot!.startTime);
          }
        }

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

  void sendAppointmentNotification(String formattedDate, String timeStr) async {
    final DateTime appointmentTime = buildAppointment(formattedDate, timeStr);
    print('FOR NOTIFICATION ----> formattedDate -- $formattedDate -- time -- $timeStr');
    print('Appointment DateTime: $appointmentTime');

    // final deviceState = await OneSignal.shared.getDeviceState();
    final id = OneSignal.User.pushSubscription.id;
    final playerId = id;
    print('playerId: $playerId');
    print(OneSignal.User.pushSubscription.optedIn);

    if (playerId != null) {
      await scheduleAppointmentNotification(appointmentTime: appointmentTime, playerId: playerId);
    } else {
      print("Player ID not found. Make sure OneSignal is initialized and the user is subscribed.");
    }
  }

  DateTime buildAppointment(String formattedDate, String timeStr) {
    // parse the date string
    final date = DateFormat('EEEE, MMMM d, yyyy').parse(formattedDate.trim());

    // parse time; try "HH:mm" then fallback to "h:mm a"
    DateTime t;
    try {
      t = DateFormat('HH:mm').parseStrict(timeStr.trim()); // "10:00", "17:30"
    } catch (_) {
      t = DateFormat('h:mm a').parseStrict(timeStr.trim()); // "10:00 AM"
    }

    // compose local DateTime
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  Future<void> scheduleAppointmentNotification({
    required DateTime appointmentTime,
    String deliveryOption = 'timezone', // 'timezone', 'last-active', or null
    int? throttlePerMinute,
    bool enableFrequencyCap = false,
    required String playerId,
  }) async {
    // 5 minutes before appointment
    final DateTime sendAt = appointmentTime.subtract(Duration(minutes: 5));
    print("sendAt ----------------> $sendAt");
    // final sendAfterStr = DateFormat("yyyy-MM-dd HH:mm:ss 'GMT'").format(sendAt.toUtc());
    final sendAfterStr = formatSendAfter(sendAt);
    print("sendAfterStr ----------------> $sendAfterStr");

    final url = Uri.parse('https://api.onesignal.com/notifications?c=push');
    final data = {
      "app_id": "b0d7db1b-8cfa-4edf-9ce9-bf638f1530d9",
      "target_channel": "push",
      "headings": {"en": "Upcoming Appointment"},
      "name": "Appointment Notification",
      "contents": {"en": "Your appointment is at ${fmtTime(appointmentTime)}"},
      // "included_segments": ["All"],
      "include_player_ids": ["$playerId"],
      "small_icon": "app_icon",
      // "included_segments": [
      //   "Subscribed Users"
      // ],
      "send_after": sendAfterStr, //sendAt.toUtc().toIso8601String(), // must be UTC
      // Optional advanced delivery options
      // if (deliveryOption.isNotEmpty) "delayed_option": deliveryOption, // 'timezone' or 'last-active'
      // Optional throttling
      // if (throttlePerMinute != null) "throttle_rate_per_minute": throttlePerMinute,

      // Optional frequency capping
      // "enable_frequency_cap": enableFrequencyCap,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Key os_v2_app_wdl5wg4m7jhn7hhjx5ry6fjq3hjifvrxqxyea2mqdkbcwwpwhfc62p4mor5smajqrlxr2z3bcj2vrh6y53qygk3lix4pgsds4b4s5ma',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("Notification scheduled: $res");
      } else {
        print("Error scheduling notification: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  String fmtTime(DateTime dt) => DateFormat('h:mm a').format(dt); // e.g., 10:55 AM

  String formatSendAfter(DateTime dt) {
    // local time with offset
    final offset = dt.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';

    final formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);
    return "$formatted$sign$hours:$minutes";
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

        // print("Pending Appointment Without Description List's: ${appointments.length}");
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
