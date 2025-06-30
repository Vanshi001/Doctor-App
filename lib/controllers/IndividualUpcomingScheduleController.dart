import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndividualUpcomingScheduleController extends GetxController {

  final medicineNameController = TextEditingController();
  final descriptionController = TextEditingController();

  var medicines = <Map<String, String>>[].obs;

  final List<GlobalKey> itemKeys = [];

  void addMedicine() {
    final name = medicineNameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isNotEmpty) {
      medicines.add({"name": name, "description": description});
      medicineNameController.clear();
      descriptionController.clear();
      itemKeys.add(GlobalKey());
    }
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
    itemKeys.removeAt(index);
  }
}