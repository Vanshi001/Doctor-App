import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/Constants.dart';

class FormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final brandNamesController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final checkboxes = List.generate(4, (_) => false.obs).obs;
  final isLoading = false.obs;

  var nameError = ''.obs;
  var brandNameError = ''.obs;
  final checkboxError = false.obs;
  var addressError = ''.obs;
  var emailError = ''.obs;
  var phoneError = ''.obs;

  final List<String> checkboxLabels = [
    'Online consults',
    'Product distribution at clinic/ hospital pharmacy',
    'Social media marketing',
    'Product-related',
  ];

  bool validateName() {
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Enter a value for this field.';
      return false;
    }
    nameError.value = '';
    return true;
  }

  bool validateBrandName() {
    if (brandNamesController.text.trim().isEmpty) {
      brandNameError.value = 'Enter a value for this field.';
      return false;
    }
    brandNameError.value = '';
    return true;
  }

  bool validateEmail() {
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Enter a value for this field.';
      return false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = "Enter a valid email";
      return false;
    }
    emailError.value = '';
    return true;
  }

  bool validatePhone() {
    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Enter a value for this field.';
      return false;
    } else if (phoneController.text.trim().length < 10) {
      phoneError.value = 'Enter a 10 digits for this field.';
      return false;
    }
    phoneError.value = '';
    return true;
  }

  bool validateAddress() {
    if (addressController.text.trim().isEmpty) {
      addressError.value = 'Enter a value for this field.';
      return false;
    }
    addressError.value = '';
    return true;
  }

  void toggleCheckbox(int index, bool? value) {
    checkboxes[index].value = value ?? false;

    // Hide error if any checkbox is selected
    if (checkboxes.any((cb) => cb.value)) {
      checkboxError.value = false;
    }
  }

  bool validateCheckboxSelection() {
    final anySelected = checkboxes.any((cb) => cb.value);
    checkboxError.value = !anySelected;
    return anySelected;
  }

  List<String> get selectedConcerns {
    final selected = <String>[];
    for (int i = 0; i < checkboxes.length; i++) {
      if (checkboxes[i].value) {
        selected.add(checkboxLabels[i]);
      }
    }
    return selected;
  }

  void submitForm() {
    final isNameValid = validateName();
    final isBrandNameValid = validateBrandName();
    final isEmailValid = validateEmail();
    final isPhoneValid = validatePhone();
    final isAddressValid = validateAddress();
    final isFormValid = formKey.currentState?.validate() ?? false;
    final isCheckboxValid = validateCheckboxSelection();

    if (isNameValid && isBrandNameValid && isEmailValid && isPhoneValid && isAddressValid && isCheckboxValid && isFormValid) {
      isLoading.value = true;

      Future.delayed(Duration(seconds: 2), () {
        isLoading.value = false;
        doctorRequestApi();
      });
    }
  }

  Future<void> doctorRequestApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoading.value = true;
    final url = Uri.parse('http://192.168.1.10:5000/api/doctors/request');

    final data = {
      "name": nameController.text.trim().toString(),
      "email": emailController.text.trim().toString(),
      "contactNumber": phoneController.text.trim().toString(),
      "address": addressController.text.trim().toString(),
      "brandNames": brandNamesController.text.trim().toString(),
      "partnerPreferences": selectedConcerns,
    };

    print(data);

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json'}, body: jsonEncode(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final message = responseData['message'] ?? 'Success';
        Constants.showSuccess(message);
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        addressController.clear();
        brandNamesController.clear();
        clearAllCheckboxes();
        // Get.snackbar("Submitted", "Form submitted successfully!");
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

  void clearAllCheckboxes() {
    for (var cb in checkboxes) {
      cb.value = false;
    }
    checkboxError.value = false; // if you have error flag, reset that too
  }

  @override
  void onClose() {
    nameController.dispose();
    brandNamesController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
