import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/appointment_model.dart';
import '../model/schedule_item.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import 'auth/AuthController.dart';

enum TabType { all, completed, rejected }

class AppointmentsController extends GetxController {
  var selectedTab = TabType.all.obs;
  RxList<Appointment> allList = <Appointment>[].obs;

  // RxList<Appointment> recentList = <Appointment>[].obs;
  RxList<Appointment> completeList = <Appointment>[].obs;
  RxList<Appointment> rejectedList = <Appointment>[].obs;

  /*final List<ScheduleItem> allList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/1.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> recentList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/women/44.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '22 May 2025',
      time: '12:30 - 13:00 pm',
    ),
  ];

  final List<ScheduleItem> completeList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
  ];

  final List<ScheduleItem> canceledList = [
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
    ScheduleItem(
      image: 'https://randomuser.me/api/portraits/men/15.jpg',
      clinic: 'Dermatics India',
      concern: 'Under Eye, Pigmentation',
      date: '23 May 2025',
      time: '10:30 - 11:00 am',
    ),
  ];*/

  RxList<Appointment> get currentList {
    switch (selectedTab.value) {
      // case TabType.recent:
      //   return recentList;
      case TabType.completed:
        return completeList;
      case TabType.rejected:
        return rejectedList;
      case TabType.all:
        return allList;
    }
  }

  String getInitials(String firstName) {
    if (firstName.isEmpty) return '';
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    return firstInitial.toUpperCase();
  }

  Color? getDotColorForTab(TabType tab) {
    switch (tab) {
      // case TabType.recent:
      //   return ColorCodes.colorYellow1;
      case TabType.completed:
        return ColorCodes.colorGreen1;
      case TabType.rejected:
        return ColorCodes.colorRed1;
      default:
        return null;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return ColorCodes.colorGreen1;
      case 'rejected':
        return ColorCodes.colorRed1;
      default:
        return ColorCodes.colorBlue1;
    }
  }

  void updateTab(TabType tab, String? doctorId) {
    selectedTab.value = tab;
    // if (tab == TabType.all) {
    //   fetchAllAppointmentsApi(doctorId);
    // }
  }

  var isLoading = false.obs;
  Rxn<AppointmentResponse> allAppointmentResponse = Rxn<AppointmentResponse>();
  RxBool isFirstLoadAllAppointment = true.obs; // Show loader only for first fetch
  Timer? _refreshAllAppointmentTimer;

  Future<void> fetchAllAppointmentsApi(String? doctorId, {String? searchQuery}) async {
    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    if (isFirstLoadAllAppointment.value) {
      isLoading.value = true; // only first time loader
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('token =====~~~~~~~~~~~~~~~~~~ $token');

    // isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments');

    String statusParam;
    switch (selectedTab.value) {
      case TabType.completed:
        statusParam = 'completed';
        break;
      case TabType.rejected:
        statusParam = 'rejected';
        break;
      case TabType.all:
        statusParam = 'all';
    }

    // final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/appointment?status=all');

    final url = Uri.parse(
      searchQuery != null && searchQuery.isNotEmpty
          ? '${Constants.baseUrl}doctors/$doctorId/appointment?status=all?search=$searchQuery'
          : '${Constants.baseUrl}doctors/$doctorId/appointment?status=all',
    );
    print('url ---- $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      // print('response.statusCode -- ${response.statusCode}');
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print('Appointments: $responseData');

        allAppointmentResponse.value = AppointmentResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        final appointments = allAppointmentResponse.value?.data ?? [];

        /*final List<Appointment> mappedList = appointments.map((appointment) {
          final id = appointment.id;
          final patientName = appointment.patientFullName;
          final concerns = appointment.concerns.join(", ");
          final date = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate));
          final startTime = appointment.timeSlot.startTime;
          final endTime = appointment.timeSlot.endTime;

          return Appointment(
            id: id,
            image: 'https://randomuser.me/api/portraits/women/1.jpg',
            clinic: patientName,
            concern: concerns,
            date: date,
            time: '$startTime - $endTime',
          );
        }).toList();*/
        allList.assignAll(appointments);
        completeList.assignAll(allList.where((a) => a.status == 'completed').toList());
        rejectedList.assignAll(allList.where((a) => a.status == 'rejected').toList());
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Login failed";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('fetchAllAppointmentsApi errorMessage ---- $errorMessage');
          Constants.showError(errorMessage);
        }
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      // isLoading.value = false;
      /*if (isFirstLoadAllAppointment.value) {
        isLoading.value = false; // hide loader after first load
      }*/
      if (isFirstLoadAllAppointment.value) {
        isLoading.value = false;
        isFirstLoadAllAppointment.value = false;
      }

      // Schedule next refresh
      _refreshAllAppointmentTimer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        _refreshAllAppointmentTimer = Timer(const Duration(seconds: 10), () async {
          print('_refreshAllAppointmentTimer');
          // final SharedPreferences prefs = await SharedPreferences.getInstance();
          // var token = prefs.getString('access_token');
          print('token ............................... $token');
          if (token != null && token.isNotEmpty) fetchAllAppointmentsApi(doctorId);
        });
      } else {
        print("Skipping auto-refresh: token is null/empty");
      }
    }
  }
}
