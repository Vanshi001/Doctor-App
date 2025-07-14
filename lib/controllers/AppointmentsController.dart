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

enum TabType { all, recent, complete, canceled }

class AppointmentsController extends GetxController {
  var selectedTab = TabType.all.obs;
  RxList<Appointment> allList = <Appointment>[].obs;
  RxList<Appointment> recentList = <Appointment>[].obs;
  RxList<Appointment> completeList = <Appointment>[].obs;
  RxList<Appointment> canceledList = <Appointment>[].obs;

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
      case TabType.recent:
        return recentList;
      case TabType.complete:
        return completeList;
      case TabType.canceled:
        return canceledList;
      case TabType.all:
      return allList;
    }
  }

  Color? getDotColorForTab(TabType tab) {
    switch (tab) {
      case TabType.recent:
        return ColorCodes.colorYellow1;
      case TabType.complete:
        return ColorCodes.colorGreen1;
      case TabType.canceled:
        return ColorCodes.colorRed1;
      default:
        return null;
    }
  }

  void updateTab(TabType tab) {
    selectedTab.value = tab;
  }

  var isLoading = false.obs;
  Rxn<AppointmentResponse> allAppointmentResponse = Rxn<AppointmentResponse>();

  Future<void> fetchAllAppointmentsApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments');
    final url = Uri.parse('${Constants.baseUrl}appointments');

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
