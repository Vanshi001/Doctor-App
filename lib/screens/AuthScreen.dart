import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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

class _AuthScreenState extends State {
  SignUpController registrationController = Get.put(SignUpController());
  LoginController loginController = Get.put(LoginController());
  var isLogin = true.obs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: ColorCodes.colorBlue1, statusBarIconBrightness: Brightness.light));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorCodes.colorBlue1,
      body: Stack(
        children: [
          // ✅ Background image (full screen)
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Image.asset(
              'assets/ic_login_bg.png',
              fit: BoxFit.contain,
            ),
          ),

          // ✅ Foreground scrollable container (bottom sheet)
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.58,
                ),
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
                      decoration: BoxDecoration(
                        color: ColorCodes.colorBlack2,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
                            TextSpan(
                              text: 'Doctor Partner',
                              style: TextStyles.textStyle4_2
                            ),
                            TextSpan(
                              text: ' ?',
                              style: TextStyles.textStyle1
                            ),
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

    /*return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorCodes.colorBlue1,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset('assets/ic_login_bg.png', fit: BoxFit.contain),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
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
                    GestureDetector(
                      onTap: () {
                        Get.to(() => RegistrationScreen());
                      },
                      child: Text('Want to become a Doctor Partner?', style: TextStyles.textStyle),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );*/

    /*return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(Texts.welcome, style: TextStyles.welcomeTextStyle),
                SizedBox(height: 60),
                loginWidget(context),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(() => RegistrationScreen());
                  },
                  child: Text('Want to became Doctor Partner?', style: TextStyles.textStyle),
                ),
                */ /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color:
                            !isLogin.value ? ColorCodes.darkPurple : Colors.white,
                        onPressed: () {
                          isLogin.value = false;
                        },
                        child: Text(
                          Texts.register,
                          style:
                              !isLogin.value
                                  ? TextStyles.profileTextStyle
                                  : TextStyles.textStyle,
                        ),
                      ),
                      MaterialButton(
                        color:
                            isLogin.value ? ColorCodes.darkPurple : Colors.white,
                        onPressed: () {
                          isLogin.value = true;
                        },
                        child: Text(
                          Texts.login,
                          style:
                              !isLogin.value
                                  ? TextStyles.textStyle
                                  : TextStyles.profileTextStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  isLogin.value ? loginWidget() : registerWidget(),*/ /*
              ],
            ),
          ),
        ),
      ),
    );*/
  }

  /*Widget registerWidget() {
    return Column(
      children: [
        InputTextFieldWidget(
          registrationController.firstNameController,
          'first name',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.lastNameController,
          'last name',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.emailController,
          'email address',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.passwordController,
          'password',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.visiblePassword,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          registrationController.phoneController,
          'phone',
          inputAction: TextInputAction.go,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        SizedBox(height: 20),
        Obx(
          () => SubmitButton(
            onPressed: () {
              if (registrationController.validateFields()) {
                registrationController.createCustomer();
              }
            },
            titleWidget:
                registrationController.isLoading.value
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(Texts.register, style: TextStyles.buttonNameStyle),
          ),
        ),
      ],
    );
  }*/

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
        InputTextFieldWidget(loginController.emailController, "dr.sarah@example.com" /*'Email*'*/),
        SizedBox(height: 10),
        InputTextFieldWidget(loginController.passwordController, "securePassword123" /*'Password*'*/),
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
              onPressed: () {
                if (loginController.validateFields()) {
                  loginController.loginApi();
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

  @override
  void dispose() {
    // Reset to default or app-wide style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
    super.dispose();
  }
}
