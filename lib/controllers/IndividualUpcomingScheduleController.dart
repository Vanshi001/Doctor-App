import 'dart:convert';

import 'package:Doctor/model/PrescriptionRequestModel.dart';
import 'package:Doctor/model/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class IndividualUpcomingScheduleController extends GetxController {
  final medicineNameController = TextEditingController();
  final descriptionController = TextEditingController();

  var medicines = <Map<String, String>>[].obs;

  final List<GlobalKey> itemKeys = [];

  void addMedicine() {
    final name = medicineNameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isNotEmpty) {
      medicines.add({"medicineName": name, "notes": description});
      medicineNameController.clear();
      descriptionController.clear();
      itemKeys.add(GlobalKey());
    }
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
    itemKeys.removeAt(index);
  }

  var isLoading = false.obs;

  Future<void> addMedicineApi({required String id, required dynamic prescriptions}) async {
    isLoading.value = true;
    final url = Uri.parse('http://192.168.1.21:5000/api/appointments/$id/prescription');
    print("add medicine url == $url");

    try {
      final prescriptionList = prescriptions is PrescriptionItem ? [prescriptions] : prescriptions as List<PrescriptionItem>;

      final prescriptionRequest = PrescriptionRequestModel(prescriptions: prescriptionList);

      final body = jsonEncode(prescriptionRequest.toJson());

      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json'}, body: body);
      print('response.body -- ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Add Medicine responseData: $responseData');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'];
        print('errorMessage --$errorMessage');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
