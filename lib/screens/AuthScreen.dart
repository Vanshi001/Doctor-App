import 'dart:async';

import 'package:Doctor/widgets/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../controllers/NetworkController.dart';
import '../controllers/auth/LoginController.dart';
import '../controllers/auth/SignUpController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/InputTextFieldWidget.dart';
import '../widgets/SubmitButton.dart';
import '../widgets/TextStyles.dart';
import '../widgets/Texts.dart';
import 'MainScreen.dart';
import 'RegistrationScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  SignUpController registrationController = Get.put(SignUpController());
  final NetworkController networkController = Get.put(NetworkController());
  LoginController loginController = Get.put(LoginController());
  var isLogin = true.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    networkController.checkActiveInternetConnection();

    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        networkController.connectionStatus.value = Constants.connected;
        print('networkController.connectionStatus.value ---- ${networkController.connectionStatus.value}');
      } else {
        networkController.connectionStatus.value = Constants.notConnected;
        print('networkController.connectionStatus.value --==-- ${networkController.connectionStatus.value}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: ColorCodes.colorBlue1, statusBarIconBrightness: Brightness.light));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorCodes.colorBlue1,
      body: Stack(
        children: [
          // ✅ Background image (full screen)
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Image.asset('assets/ic_login_bg.png', fit: BoxFit.contain),
          ),

          // ✅ Foreground scrollable container (bottom sheet)
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.58),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: ColorCodes.colorBlack2, borderRadius: BorderRadius.circular(2)),
                    ),
                    Text('Log in or Sign up', style: TextStyles.textStyle1),
                    Text(Texts.welcome, style: TextStyles.textStyle2_3),
                    SizedBox(height: 10),
                    loginWidget(context),
                    SizedBox(height: 20),
                    /*GestureDetector(
                      onTap: () => Get.to(() => RegistrationScreen()),
                      child: Text(
                        'Want to become a Doctor Partner?',
                        style: TextStyles.textStyle1,
                      ),
                    ),*/
                    GestureDetector(
                      onTap: () => Get.to(() => RegistrationScreen()),
                      child: Text.rich(
                        TextSpan(
                          text: 'Want to become a ',
                          style: TextStyles.textStyle1,
                          children: [
                            TextSpan(text: 'Doctor Partner', style: TextStyles.textStyle4_2),
                            TextSpan(text: ' ?', style: TextStyles.textStyle1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        Text('Join our community top Doctors', style: TextStyles.textStyle),
        SizedBox(height: 20),
        InputTextFieldWidget(registrationController.nameController, 'Name*', inputAction: TextInputAction.next, keyboardType: TextInputType.name),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.lastNameController,
          'Brands name*',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.nameController,
          'What is your clinic/pharmacy address?*',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.emailController,
          'Contact email*',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.phoneController,
          'Contact Number*',
          inputAction: TextInputAction.go,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
        ),
        SizedBox(height: 20),
        SubmitButton(
          onPressed: () {
            if (registrationController.validateFields()) {}
          },
          titleWidget:
              registrationController.isLoading.value
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(Texts.register, style: TextStyles.textStyle6_1),
        ),
      ],
    );
  }

  Widget loginWidget(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: 20),
        InputTextFieldWidget(loginController.emailController, /*"dr.sarah@example.com"*/ 'Email*'),
        SizedBox(height: 10),
        // InputTextFieldWidget(loginController.passwordController, /*"securePassword123" */'Password*'),
        Obx(
          () => InputTextFieldWidget(
            loginController.passwordController,
            'Password',
            obscureText: loginController.isPasswordHidden.value, // 👈 hide/show
            suffixIcon: IconButton(
              icon: Icon(loginController.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, size: 18),
              onPressed: () {
                loginController.isPasswordHidden.toggle();
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Obx(
          () => SizedBox(
            width: width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorCodes.colorBlue1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              // onPressed: controller.isLoading.value ? null : controller.submitForm,
              onPressed: () async {
                FocusScope.of(context).unfocus();

                if (loginController.validateFields()) {
                  if (networkController.connectionStatus.value == Constants.notConnected) {
                    Constants.noInternetError();
                    return;
                  } else {
                    loginController.loginApi();
                  }
                }
              },
              child:
                  loginController.isLoading.value
                      ? SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: ColorCodes.darkPurple1,
                          valueColor: AlwaysStoppedAnimation<Color>(ColorCodes.white),
                        ),
                      )
                      : Text(Texts.login, style: TextStyles.textStyle6_1),
            ),
          ),
        ),
      ],
    );
  }

  /* @override
  void dispose() {
    // Reset to default or app-wide style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
    super.dispose();
  }*/
}
