import 'dart:async';
import 'dart:convert';

import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/DoctorProfileResponse.dart';
import '../model/appointment_model.dart';
import '../model/schedule_item.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';
import 'auth/AuthController.dart';

enum TabType { all, today, tomorrow, custom }

class UpcomingSchedulesController extends GetxController {
  var selectedTab = TabType.today.obs;

  Rxn<AppointmentResponse> allUpcomingAppointmentResponse = Rxn<AppointmentResponse>();
  Rxn<AppointmentResponse> todayUpcomingAppointmentResponse = Rxn<AppointmentResponse>();
  Rxn<AppointmentResponse> tomorrowUpcomingAppointmentResponse = Rxn<AppointmentResponse>();
  Rxn<AppointmentResponse> customUpcomingAppointmentResponse = Rxn<AppointmentResponse>();

  RxBool isLoading = false.obs;
  RxList<Appointment> allList = <Appointment>[].obs;
  RxList<Appointment> todayList = <Appointment>[].obs;
  RxList<Appointment> tomorrowList = <Appointment>[].obs;
  RxList<Appointment> customList = <Appointment>[].obs;

  /*final List<ScheduleItem> allList = [
    ScheduleItem(
      id: "1",
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'All 1 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      id: "2",
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'All 2 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> todayList = [
    ScheduleItem(
      id: "1",
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'T 1 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      id: "2",
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      id: "3",
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> tomorrowList = [
    ScheduleItem(
      id: "1",
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'TR 1 - Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      id: "2",
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      id: "3",
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      id: "4",
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
  ];
*/

  RxList<Appointment> get currentList {
    switch (selectedTab.value) {
      case TabType.today:
        return todayList;
      case TabType.tomorrow:
        return tomorrowList;
      case TabType.custom:
        return customList;
      case TabType.all:
        return allList;
    }
  }

  String getInitials(String firstName) {
    if (firstName.isEmpty) return '';

    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';

    return firstInitial.toUpperCase();
  }

  String get emptyMessage {
    switch (selectedTab.value) {
      case TabType.today:
        return 'No schedules for today';
      case TabType.tomorrow:
        return 'No schedules for tomorrow';
      case TabType.custom:
        return 'No schedules for selected date';
      case TabType.all:
        return 'No schedules found';
    }
  }

  void updateTab(TabType tab) async {
    // selectedTab.value = tab;

    if (tab == TabType.custom) {
      final DateTime? picked = await showDatePicker(
        context: Get.context!,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        helpText: 'Select Custom Date',
        cancelText: 'Cancel',
        confirmText: 'OK',
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ColorCodes.colorBlue1, // ✅ Header & selection color
                onPrimary: Colors.white, // ✅ Text on header
                onSurface: Colors.black, // ✅ Body text
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: ColorCodes.colorBlue1, // ✅ Button text color
                  textStyle: TextStyles.textStyle4_3,
                ),
              ),
              primaryTextTheme: Theme.of(context).primaryTextTheme.apply(fontFamily: 'Figtree'),
              textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Figtree'),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        print('Picked date: $formattedDate');
        await fetchCustomUpComingAppointmentsApi(formattedDate);
        selectedTab.value = TabType.custom;
      } else {
        // If user cancels, fallback to ALL or RECENT
        selectedTab.value = TabType.all;
      }
    } else {
      // ✅ If it’s not custom, you might refresh data here too if needed.
      selectedTab.value = tab;

      if (tab == TabType.today) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        fetchCustomUpComingAppointmentsApi(today);
      } else if (tab == TabType.tomorrow) {
        final tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
        fetchCustomUpComingAppointmentsApi(tomorrow);
      } else if (tab == TabType.all) {
        fetchAllUpComingAppointmentsApi();
      }
    }
  }

  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;
  final tomorrowDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))).obs;

  Future<void> fetchAllUpComingAppointmentsApi({String? searchQuery}) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final url = Uri.parse('${Constants.baseUrl}appointments?status=all&doctorId=$doctorId');
    final url = Uri.parse(
      searchQuery != null && searchQuery.isNotEmpty
          ? '${Constants.baseUrl}appointments?status=all&doctorId=$doctorId?search=$searchQuery'
          : '${Constants.baseUrl}appointments?status=all&doctorId=$doctorId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("All Upcoming Appointments: $responseData");

        allUpcomingAppointmentResponse.value = AppointmentResponse.fromJson(responseData);

        final appointments = allUpcomingAppointmentResponse.value?.data ?? [];

        allList.assignAll(appointments);
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

  String? doctorId;
  final doctorName = RxString(''); // Make it observable
  final doctorDetail = Rxn<DoctorProfileResponse>();
  var isFirstLoad = false.obs; // Show loader only for first fetch

  Future<void> fetchDoctorDetailsApi() async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isFirstLoad.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

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
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed to get doctor profile";
        print('errorMessage upcoming fetchDoctorDetailsApi -- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error:- $e');
      Constants.showError("Error -- $e");
    } finally {
      isFirstLoad.value = false;
    }
  }

  Future<void> fetchTodayUpComingAppointmentsApi(String date) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=today&date=$date&doctorId=$doctorId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("Today's Appointments: $responseData");

        todayUpcomingAppointmentResponse.value = AppointmentResponse.fromJson(responseData);

        final appointments = todayUpcomingAppointmentResponse.value?.data ?? [];

        /*final List<ScheduleItem> mappedList =
            appointments.map((appointment) {
              final id = appointment.id;
              final patientName = appointment.patientFullName;
              final concerns = appointment.concerns.join(", ");
              final date = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate));
              final startTime = appointment.timeSlot.startTime;
              final endTime = appointment.timeSlot.endTime;

              return ScheduleItem(
                id: id,
                image: 'https://randomuser.me/api/portraits/women/1.jpg',
                clinic: patientName,
                concern: concerns,
                date: date,
                time: '$startTime - $endTime',
              );
            }).toList();*/

        todayList.assignAll(appointments);
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

  Future<void> fetchTomorrowUpComingAppointmentsApi(String date) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=tomorrow&date=$date&doctorId=$doctorId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("Tomorrow's Appointments: $responseData");

        tomorrowUpcomingAppointmentResponse.value = AppointmentResponse.fromJson(responseData);

        final appointments = tomorrowUpcomingAppointmentResponse.value?.data ?? [];

        /*final List<ScheduleItem> mappedList =
            appointments.map((appointment) {
              final id = appointment.id;
              final patientName = appointment.patientFullName;
              final concerns = appointment.concerns.join(", ");
              final date = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate));
              final startTime = appointment.timeSlot.startTime;
              final endTime = appointment.timeSlot.endTime;

              return ScheduleItem(
                id: id,
                image: 'https://randomuser.me/api/portraits/women/1.jpg',
                clinic: patientName,
                concern: concerns,
                date: date,
                time: '$startTime - $endTime',
              );
            }).toList();*/

        tomorrowList.assignAll(appointments);
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

  Future<void> fetchCustomUpComingAppointmentsApi(String date) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getString('doctor_id') ?? '';
    print('doctorId -- $doctorId');

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    final url = Uri.parse('${Constants.baseUrl}appointments?status=custom&date=$date&doctorId=$doctorId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("Custom Date's Appointments: $responseData");

        customUpcomingAppointmentResponse.value = AppointmentResponse.fromJson(responseData);

        final appointments = customUpcomingAppointmentResponse.value?.data ?? [];

        /*final List<ScheduleItem> mappedList =
            appointments.map((appointment) {
              final id = appointment.id;
              final patientName = appointment.patientFullName;
              final concerns = appointment.concerns.join(", ");
              final date = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate));
              final startTime = appointment.timeSlot.startTime;
              final endTime = appointment.timeSlot.endTime;

              return ScheduleItem(
                id: id,
                image: 'https://randomuser.me/api/portraits/women/1.jpg',
                clinic: patientName,
                concern: concerns,
                date: date,
                time: '$startTime - $endTime',
              );
            }).toList();*/

        customList.assignAll(appointments);
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
