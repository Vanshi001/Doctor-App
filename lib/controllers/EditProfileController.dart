import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/login_model.dart';
import '../widgets/Constants.dart';
import 'auth/AuthController.dart';

class EditProfileController extends GetxController {

  var isLoading = false.obs;

  var doctorId = "";
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  Rx<Doctor> doctor = Doctor(
    id: '',
    name: '',
    email: '',
    contactNumber: '',
    address: '',
  ).obs;

  Future<void> updateDoctor(String id, String name, String email,
      String contact, String address,) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called.");
    //   return;
    // }

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/doctors/profile/$id');
    final url = Uri.parse('${Constants.baseUrl}doctors/profile/$id');

    final data = {
      "_id": id.trim(),
      "name": name.trim().toString(),
      "email": email.trim().toString(),
      "contactNumber": contact.trim().toString(),
      "address": address.trim().toString()
    };

    print("data ---------------- $data");

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('responseData ------- $responseData');
        Constants.showSuccess("Profile updated successfully.");

        // Update local observable doctor
        doctor.value = Doctor.fromJson(responseData['data']);
        Doctor model = Doctor.fromJson(responseData['data']);
        setDoctor(model);
        // print("doctor.value ----------------------------------------------- ${doctor.value.contactNumber}");
        // print("doctor.model ----------------------------------------------- ${model.contactNumber}");
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Edit Profile failed";
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error: $e');
      Constants.showError("Error -- $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setDoctor(Doctor model) {
    doctor.value = model;

    nameController.text = model.name;
    emailController.text = model.email;
    contactController.text = model.contactNumber;
    addressController.text = model.address;
  }
}
