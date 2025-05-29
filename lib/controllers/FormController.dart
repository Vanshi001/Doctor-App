import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    }
    emailError.value = '';
    return true;
  }

  bool validatePhone() {
    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Enter a value for this field.';
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
        Get.snackbar("Submitted", "Form submitted successfully!");
      });
    }
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
