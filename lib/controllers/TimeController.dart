import 'dart:async';
import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/AddNoteResponseModel.dart';
import '../model/AvailabilityResponse.dart';
import '../model/DoctorProfileResponse.dart';
import '../model/NoteResponseModel.dart';
import '../model/SlotUpdateResponse.dart';
import '../screens/AuthScreen.dart';
import '../screens/EditCustomNotesScreen.dart';
import '../widgets/Constants.dart';

class TimeController extends GetxController with GetSingleTickerProviderStateMixin {
  var isOpen = false.obs;

  void toggleFab() => isOpen.value = !isOpen.value;

  void closeFab() => isOpen.value = false;

  final textController = TextEditingController(); // 👈 add this
  var noteText = "".obs; // 👈 add this
  final int maxChars = 100;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  // var notesList = <String>[].obs;
  var notesList = <NoteData>[].obs;

  void addNote(String note) {
    /*if (noteText.value.trim().isNotEmpty) {
      notesList.add(noteText.value.trim());
      textController.clear();
      noteText.value = "";
    }*/
    // notesList.add(note);
    textController.clear();
    noteText.value = "";
  }

  void clearText() {
    textController.clear();
    noteText.value = "";
  }

  RxBool isDeleteMode = false.obs;

  // Delete a note by index
  void deleteNoteAt(int index) {
    if (index >= 0 && index < notesList.length) {
      notesList.removeAt(index);
    }
  }

  // Enable/disable delete mode
  void toggleDeleteMode() {
    isDeleteMode.value = !isDeleteMode.value;
    if (isDeleteMode.value) isEditMode.value = false; // prevent conflict
  }

  // Edit note
  void editNoteAt(int index) {
    /*final note = notesList[index];
    // Open AddCustomNotesScreen with existing note for editing
    Get.to<String>(() => EditCustomNotesScreen(existingNote: note, noteIndex: index))?.then((updatedNote) {
      if (updatedNote != null && updatedNote.isNotEmpty) {
        notesList[index] = updatedNote;
        notesList.refresh();
      }
    });*/
  }

  RxBool isEditMode = false.obs;

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) isDeleteMode.value = false; // prevent conflict
  }

  void updateNoteAt(int index, String newNote) {
    if (index >= 0 && index < notesList.length) {
      // notesList[index] = newNote;
      notesList.refresh(); // ✅ trigger UI update
    }
  }

  String? doctorId;
  final noteDetail = Rxn<NoteResponseModel>();
  RxBool isLoadingTimes = false.obs;

  Future<void> fetchTimeSlotsApi() async {
    try {
      isLoadingTimes.value = true;
      notesList.clear();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      doctorId = prefs.getString('doctor_id') ?? '';

      final url = Uri.parse('${Constants.baseUrl}doctors/notes');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // print("doctorDetail: $responseData");

        final noteResponse = NoteResponseModel.fromJson(responseData);
        // print('noteResponse ----> ${noteResponse.data}');
        notesList.assignAll(noteResponse.data);
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
      isLoadingTimes.value = false; // hide loader after first load
    }
  }

  RxBool isLoadingAddNotes = false.obs;

  Future<void> addNoteApi(String note, BuildContext context) async {
    isLoadingAddNotes.value = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    doctorId = prefs.getString('doctor_id') ?? '';

    final url = Uri.parse('${Constants.baseUrl}doctors/notes');
    print("addNoteApi url == $url");
    print("addNoteApi note == $note");

    try {
      // final prescriptionRequest = AddNoteResponseModel();

      final body = jsonEncode({"text": note.toString()});

      final token = prefs.getString('access_token');
      print('token =====~~~~ $token');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      );
      // print('response.body -- ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('responseData: $responseData');
        clearText();
        Navigator.pop(context, true);
        // Get.back();
      } else {
        // print('token =====~~~~ ELSE ----> $token');
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? "Something went wrong";
        print('errorMessage --> $errorMessage');
        Constants.showCallHistoryError(errorMessage);
        // Get.snackbar("Error", errorMessage, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2),);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoadingAddNotes.value = false;
    }
  }

  RxBool isLoadingDeleteNotes = false.obs;

  Future<void> deleteNoteApi(String noteId, BuildContext context) async {
    try {
      isLoadingDeleteNotes.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      doctorId = prefs.getString('doctor_id') ?? '';

      final url = Uri.parse('${Constants.baseUrl}doctors/notes');
      print("deleteNoteApi url == $url");
      print("deleteNoteApi note == $noteId");

      // final prescriptionRequest = AddNoteResponseModel();

      final body = jsonEncode({"noteId": noteId.toString()});

      final token = prefs.getString('access_token');
      print('token =====~~~~ $token');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      );
      // print('response.body -- ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('responseData: $responseData');
        // Constants.showSuccess(responseData["message"] ?? "Note Deleted");
        clearText();
        Navigator.pop(context);
        // Constants.showSuccess(responseData["message"] ?? "Note Deleted");
        fetchTimeSlotsApi();
        // Get.back();
      } else {
        // print('token =====~~~~ ELSE ----> $token');
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? "Something went wrong";
        print('errorMessage --> $errorMessage');
        Constants.showCallHistoryError(errorMessage);
        // Get.snackbar("Error", errorMessage, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2),);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoadingDeleteNotes.value = false;
    }
  }

  RxBool isLoadingUpdateNotes = false.obs;

  Future<void> updateNoteApi(String noteId, String text, BuildContext context) async {
    try {
      isLoadingUpdateNotes.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      doctorId = prefs.getString('doctor_id') ?? '';

      final url = Uri.parse('${Constants.baseUrl}doctors/notes');
      print("deleteNoteApi url == $url");
      print("deleteNoteApi note == $noteId");

      // final prescriptionRequest = AddNoteResponseModel();

      final body = jsonEncode({"noteId": noteId.toString(), "text": text.toString()});

      final token = prefs.getString('access_token');
      print('token =====~~~~ $token');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      );
      // print('response.body -- ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('responseData: $responseData');
        // Constants.showSuccess(responseData["message"] ?? "Note Deleted");
        clearText();
        Navigator.pop(context);
        // Constants.showSuccess(responseData["message"] ?? "Note Deleted");
        fetchTimeSlotsApi();
        // Get.back();
      } else {
        // print('token =====~~~~ ELSE ----> $token');
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message']?.toString() ?? "Something went wrong";
        print('errorMessage --> $errorMessage');
        Constants.showCallHistoryError(errorMessage);
        // Get.snackbar("Error", errorMessage, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2),);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoadingUpdateNotes.value = false;
    }
  }

  final morningStartTimes = ["09:00AM", "10:00AM", "11:00AM", "12:00PM", "01:00PM"].obs;

  // var selectedMorningStartTime = "09:00 AM".obs;
  RxString selectedMorningStartTime = ''.obs;

  void setMorningStartTime(String value) {
    selectedMorningStartTime.value = value;
  }

  final morningEndTimes = ["09:00AM", "10:00AM", "11:00AM", "12:00PM", "01:00PM"].obs;

  var selectedMorningEndTime = "01:00PM".obs;

  void setMorningEndTime(String value) {
    selectedMorningEndTime.value = value;
  }

  void clearMorningTime() {
    selectedMorningStartTime.value = "";
    selectedMorningEndTime.value = "";
  }

  void clearEveningTime() {
    selectedEveningStartTime.value = "";
    selectedEveningEndTime.value = "";
  }

  final eveningStartTimes = ["02:00PM", "03:00PM", "04:00PM", "05:00PM", "06:00PM", "07:00PM", "08:00PM", "09:00PM"].obs;

  var selectedEveningStartTime = ''.obs;

  void setEveningStartTime(String value) {
    selectedEveningStartTime.value = value;
  }

  final eveningEndTimes = ["02:00PM", "03:00PM", "04:00PM", "05:00PM", "06:00PM", "07:00PM", "08:00PM", "09:00PM"].obs;

  var selectedEveningEndTime = ''.obs;

  void setEveningEndTime(String value) {
    selectedEveningEndTime.value = value;
  }

  RxList<DateTime?> selectedDates = <DateTime?>[].obs;

  void onDateChanged(List<DateTime?> dates) {
    selectedDates.value = dates;
  }

  String getValueText(CalendarDatePicker2Type calendarType) {
    if (selectedDates.isEmpty) return 'No date selected';

    return selectedDates.where((d) => d != null).map((d) => '${d!.day}/${d.month}/${d.year}').join(', ');
  }

  RxList<DateTime?> rangeDates = <DateTime?>[].obs;

  void onRangeChanged(List<DateTime?> dates) {
    selectedDates.value = dates;
  }

  /*List<DateTime> getSelectedAllDates(List<DateTime?> rangeDatePickerValue) {
    if (rangeDatePickerValue.length < 2 || rangeDatePickerValue[0] == null || rangeDatePickerValue[1] == null) {
      return [];
    }

    final start = rangeDatePickerValue[0]!;
    final end = rangeDatePickerValue[1]!;
    final daysCount = end.difference(start).inDays;

    return List.generate(daysCount + 1, (i) => start.add(Duration(days: i)));
  }*/

  List<String> getSelectedAllDates(List<DateTime?> rangeDatePickerValue) {
    if (rangeDatePickerValue.length < 2 || rangeDatePickerValue[0] == null || rangeDatePickerValue[1] == null) {
      return [];
    }

    final start = DateTime(rangeDatePickerValue[0]!.year, rangeDatePickerValue[0]!.month, rangeDatePickerValue[0]!.day);

    final end = DateTime(rangeDatePickerValue[1]!.year, rangeDatePickerValue[1]!.month, rangeDatePickerValue[1]!.day);

    final daysCount = end.difference(start).inDays;

    return List.generate(daysCount + 1, (i) {
      final date = start.add(Duration(days: i));
      // Format as YYYY-MM-DD
      return "${date.year.toString().padLeft(4, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";
    });
  }

  var isLoading = false.obs;

  Rxn<AvailabilityResponse> availabilityResponse = Rxn<AvailabilityResponse>();

  RxBool isLoadingDoctorDetails = false.obs;
  RxBool isFirstLoad = true.obs; // Show loader only for first fetch
  Timer? _refreshDoctorTimer;
  final doctorName = RxString(''); // Make it observable
  final doctorDetail = Rxn<DoctorProfileResponse>();

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
    // print('doctorId ------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $doctorId');

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

  Future<void> addCustomDatesApi(String? doctorId, List<String> onlySelectedDates) async {
    isLoading.value = true; // only first time loader

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // print('token =====~~~~~~~~~~~~~~~~~~ $token');

    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/date-availability');
    print('url ---- $url');

    final Map<String, dynamic> requestBody = {
      "dateKeys": onlySelectedDates,
      "slots": [
        {"start": selectedMorningStartTime.value, "end": selectedMorningEndTime.value},
        {"start": selectedEveningStartTime.value, "end": selectedEveningEndTime.value},
      ],
    };

    print('📤 Request Body: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(requestBody),
      );

      print('response.statusCode -- ${response.statusCode}');
      print('response.body -- ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        print('Appointments: $responseData');

        availabilityResponse.value = AvailabilityResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        // final dates = availabilityResponse.value?.data ?? [];
        // print('dates -------->>>>>> $dates');
        final dates = availabilityResponse.value?.data?.map((e) => e.dateKey).toList() ?? [];
        print('✅ Extracted Dates: $dates');
        // allList.assignAll(dates);
        Constants.showSuccess('Slots saved successfully');

        // ✅ IMPORTANT: pop this screen and send a signal to refresh
        Get.back(result: true); // or: Get.back(result: {'refresh': true});
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "failed";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('addCustomDatesApi errorMessage ---- $errorMessage');
          Constants.showError(errorMessage);
        } else {
          print('addCustomDatesApi errorMessage --~~-- $errorMessage');
          Constants.showError(errorMessage);
        }
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
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

  var isDeleteLoading = false.obs;

  Future<SlotUpdateResponse?> deleteCustomDateApi({required String? doctorId, required String? dateKey, required String? slotId}) async {
    isDeleteLoading.value = true; // only first time loader

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // print('token =====~~~~~~~~~~~~~~~~~~ $token');

    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/date-availability/${dateKey}/slots/$slotId');
    print('url ---- $url');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      print('response.statusCode -- ${response.statusCode}');
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Date delete: $responseData');

        final data = SlotUpdateResponse.fromJson(responseData);

        // print('✅ Extracted Dates: ${data.data}');
        print('✅ responseData[message]: ${responseData['message']}');
        // Constants.showSuccess(responseData['message']);
        getCustomDatesApi();
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "failed";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('deleteCustomDateApi errorMessage ---- $errorMessage');
          Constants.showError(errorMessage);
        } else {
          print('deleteCustomDateApi errorMessage --~~-- $errorMessage');
          Constants.showError(errorMessage);
        }
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isDeleteLoading.value = false;

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
    return null;
  }

  var isLoadingAllDates = false.obs;
  Rxn<AvailabilityResponse> allDatesResponse = Rxn<AvailabilityResponse>();

  // RxBool isFirstLoadAllDates = true.obs; // Show loader only for first fetch
  // Timer? _refreshAllDatesTimer;
  RxList<AvailabilityData> allDatesList = <AvailabilityData>[].obs;

  Future<void> getCustomDatesApi() async {
    allDatesList.clear();

    // if (isFirstLoadAllDates.value) {
    isLoadingAllDates.value = true; // only first time loader
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // print('token =====~~~~~~~~~~~~~~~~~~ $token');

    final url = Uri.parse('${Constants.baseUrl}doctors/$doctorId/availability');
    print('url ---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      print('response.statusCode -- ${response.statusCode}');
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Dates: $responseData');

        allDatesResponse.value = AvailabilityResponse.fromJson(responseData);
        // final message = responseData['message'] ?? 'Success';
        // Constants.showSuccess(message);

        // final dates = availabilityResponse.value?.data ?? [];
        // print('dates -------->>>>>> $dates');
        final dates = allDatesResponse.value?.data?.map((e) => e.dateKey).toList() ?? [];
        print('✅ Get Dates: $dates');

        final allData = allDatesResponse.value?.data ?? [];

        print('✅ Total AvailabilityData fetched: ${allData.length}');

        // ✅ Assign full objects to observable list
        allDatesList.assignAll(allData);
        print('allDatesList ----> ${allDatesList.length}');

        // allList.assignAll(dates);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed";
        if (token != null && token.isNotEmpty && errorMessage == "Unauthorized") {
          print('getCustomDatesApi errorMessage ---- $errorMessage');
          Constants.showError(errorMessage);
        }
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoadingAllDates.value = false;

      // Schedule next refresh
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('access_token');

      // if (isFirstLoadAllDates.value) {
      //   isLoading.value = false;
      // isFirstLoadAllDates.value = false;
      // }

      // Schedule next refresh
      /*_refreshAllDatesTimer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        _refreshAllDatesTimer = Timer(const Duration(seconds: 60), () async {
          // print('_refreshAllDatesTimer');
          // final SharedPreferences prefs = await SharedPreferences.getInstance();
          // var token = prefs.getString('access_token');
          // print('token ............................... $token');
          if (token != null && token.isNotEmpty) getCustomDatesApi();
        });
      } else {
        print("Skipping auto-refresh: token is null/empty");
      }*/
    }
  }

  void deleteDateSlot(dynamic data) {
    // Call your delete API or remove locally
    // allDatesList.removeWhere((e) => e.dateKey == data.dateKey);
    // update();
    print("deleteDateSlot");
  }

  void editDateSlot(dynamic data) {
    // Navigate to edit page or pre-fill AddTimeScreen
    // Get.to(() => AddTimeScreen(), arguments: {"editData": data});
    print("editDateSlot");
  }

  void deleteSpecificSlot_(String dateKey, int slotIndex) {
    final dateItem = allDatesList.firstWhereOrNull((e) => e.dateKey == dateKey);
    if (dateItem != null && dateItem.slots != null) {
      dateItem.slots!.removeAt(slotIndex);
      allDatesList.refresh();
    }
  }

  final slotsByDate = <String, List<String>>{}.obs;

  List<String> slotsFor(String dateKey) => slotsByDate[dateKey] ?? [];

  void deleteAt(String dateKey, int index) {
    final list = slotsFor(dateKey).toList();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    slotsByDate[dateKey] = list; // triggers Obx rebuild
  }

  void updateAt(String dateKey, int index, String newValue) {
    final list = slotsFor(dateKey).toList();
    if (index < 0 || index >= list.length) return;
    list[index] = newValue;
    slotsByDate[dateKey] = list;
  }

  var filteredList = <DateSlots>[].obs;

  void deleteDateByKey(String dateKey) {
    final i = filteredList.indexWhere((e) => e.dateKey == dateKey);
    if (i < 0) return;
    filteredList.removeAt(i); // triggers Obx rebuild
  }

  void deleteSpecificSlot(String dateKey, int slotIndex) {
    final i = filteredList.indexWhere((e) => e.dateKey == dateKey);
    if (i < 0) return;

    final item = filteredList[i];
    if (slotIndex < 0 || slotIndex >= item.slots.length) return;

    final newSlots = item.slots.toList()..removeAt(slotIndex);
    if (newSlots.isEmpty) {
      // remove the whole date row if no slots remain
      filteredList.removeAt(i);
    } else {
      filteredList[i] = item.copyWith(slots: newSlots);
    }
    // filteredList.refresh(); // not needed after []= / removeAt
  }

  void removeSlotAt(String dateKey, String? slotId) {
    final i = filteredList.indexWhere((d) => d.dateKey == dateKey);
    if (i == -1) return;
    final slots = filteredList[i].slots ?? [];
    final si = slots.indexWhere((s) => s.id == slotId);
    if (si == -1) return;
    slots.removeAt(si);
    filteredList.refresh(); // GetX: notify listeners
  }

  void removeDateIfEmpty(String dateKey) {
    final i = filteredList.indexWhere((d) => d.dateKey == dateKey);
    if (i == -1) return;
    if ((filteredList[i].slots ?? []).isEmpty) {
      filteredList.removeAt(i);
    }
  }
}

class DateSlots {
  final String dateKey; // e.g. "2025-11-01"
  final List<SlotModel> slots;

  const DateSlots({required this.dateKey, required this.slots});

  DateSlots copyWith({String? dateKey, List<SlotModel>? slots}) => DateSlots(dateKey: dateKey ?? this.dateKey, slots: slots ?? this.slots);
}

class SlotModel {
  final String? id;
  final String? start;
  final String? end;

  const SlotModel({this.id, this.start, this.end});
}
