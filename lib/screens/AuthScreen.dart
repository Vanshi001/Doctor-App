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
  @override
  State createState() => _AuthScreenState();
}

class _AuthScreenState extends State {
  SignUpController registrationController = Get.put(SignUpController());
  LoginController loginController = Get.put(LoginController());
  var isLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                loginWidget(),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(() => RegistrationScreen());
                  },
                  child: Text(
                    'Want to became Doctor Partner?',
                    style: TextStyles.textStyle,
                  ),
                ),
                /*Row(
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
                  isLogin.value ? loginWidget() : registerWidget(),*/
              ],
            ),
          ),
        ),
      ),
    );
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
        InputTextFieldWidget(
          registrationController.nameController,
          'Name*',
          inputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
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
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        SizedBox(height: 20),
        SubmitButton(
          onPressed: () {
            if (registrationController.validateFields()) {}
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
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        SizedBox(height: 20),
        InputTextFieldWidget(
          loginController.emailController,
          "dr.sarah@example.com" /*'Email address*'*/,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          loginController.passwordController,
          "securePassword123" /*'Password*'*/,
        ),
        SizedBox(height: 20),
        Obx(
          () => SubmitButton(
            onPressed:
                () => {
                  // Get.offAll(() => MainScreen()),
                  if (loginController.validateFields())
                    {loginController.loginApi()},
                },
            titleWidget:
                loginController.isLoading.value
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(Texts.login, style: TextStyles.buttonNameStyle),
          ),
        ),
      ],
    );
  }
}
