import 'dart:convert';

import 'package:Doctor/widgets/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/DoctorProfileResponse.dart';
import '../../model/login_model.dart';
import '../../screens/MainScreen.dart';
import '../EditProfileController.dart';
import 'AuthController.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var isPasswordHidden = true.obs;

  var isLoading = false.obs;

  Rxn<LoginResponse> loginResponse = Rxn<LoginResponse>();
  final EditProfileController editProfileController = Get.put(EditProfileController());

  Future<void> loginApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoading.value = true;
    // final url = Uri.parse('http://192.168.1.10:5000/api/doctors/login');
    final url = Uri.parse('${Constants.baseUrl}doctors/login');

    final data = {"email": emailController.text.trim().toString(), "password": passwordController.text.trim().toString()};

    print(data);

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json', 'accept': 'application/json'}, body: jsonEncode(data));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        loginResponse.value = LoginResponse.fromJson(responseData);

        final message = responseData['message'] ?? 'Success';
        Constants.showSuccess(message);

        // Debug print:
        print('Logged in doctor name: ${loginResponse.value?.doctor.name}');
        print('Token: ${loginResponse.value?.token}');
        prefs.setString('access_token', loginResponse.value!.token.toString());
        prefs.setString('doctor_name', loginResponse.value!.doctor.name);
        prefs.setString('doctor_id', loginResponse.value!.doctor.id);

        // authController.login();

        Doctor model = Doctor.fromJson(responseData['data']);
        editProfileController.setDoctor(model);
        fetchDoctorDetailsApi(loginResponse.value!.doctor.id);
        Get.offAll(() => MainScreen());
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

  Rxn<DoctorProfileResponse> doctorDetail = Rxn<DoctorProfileResponse>();

  Future<void> fetchDoctorDetailsApi(String doctorId) async {

    // ✅ Don't call API if user is logged out
    // if (AuthController.isLoggedIn.value) {
    //   print("User logged out. API not called. -login fetchDoctorDetailsApi- ${AuthController.isLoggedIn.value}");
    //   return;
    // } else {
    //   print("User logged out. API not called. else -login fetchDoctorDetailsApi- ${AuthController.isLoggedIn.value}");
    // }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    // final url = Uri.parse('http://192.168.1.10:5000/api/appointments?date=$currentDate');
    // final doctorId = prefs.getString('doctor_id') ?? '';
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
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed to get doctor profile";
        print('errorMessage login fetchDoctorDetailsApi -- $errorMessage');
        Constants.showError(errorMessage);
      }
    } catch (e) {
      print('Error:- $e');
      Constants.showError("Error -- $e");
    }
  }

  bool validateFields() {
    if (emailController.text.trim().isEmpty) {
      Constants.showError("Email is required");
      return false;
    } else if (passwordController.text.trim().isEmpty) {
      Constants.showError("Password is required");
      return false;
    }
    return true;
  }

  /*Future loginWithEmail() async {
    var headers = {'Content-Type': 'application/json'};
    try {
      var url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.loginEmail,
      );
      Map body = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };
      http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 0) {
          var token = json['data']['Token'];
          final SharedPreferences _prefs = await SharedPreferences.getInstance();
          // final SharedPreferences? prefs = _prefs;
          await _prefs?.setString('token', token);
          emailController.clear();
          passwordController.clear();
          Get.offAll(HomeScreen());
        } else if (json['code'] == 1) {
          throw jsonDecode(response.body)['message'];
        }
      } else {
        throw jsonDecode(response.body)["Message"] ?? "Unknown Error Occurred";
      }
    } catch (error) {
      Get.back();
      showDialog(
        context: Get.context!,
        builder: (context) {
          return SimpleDialog(
            title: Text('Error'),
            contentPadding: EdgeInsets.all(20),
            children: [Text(error.toString())],
          );
        },
      );
    }
  }*/

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
