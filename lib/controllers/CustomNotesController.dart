import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/AddNoteResponseModel.dart';
import '../model/NoteResponseModel.dart';
import '../screens/AuthScreen.dart';
import '../screens/EditCustomNotesScreen.dart';
import '../widgets/Constants.dart';

class CustomNotesController extends GetxController with GetSingleTickerProviderStateMixin {
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
  RxBool isLoadingNotes = false.obs;

  Future<void> fetchNotesApi() async {
    try {
      isLoadingNotes.value = true;
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
      isLoadingNotes.value = false; // hide loader after first load
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
        fetchNotesApi();
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
        fetchNotesApi();
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
}
