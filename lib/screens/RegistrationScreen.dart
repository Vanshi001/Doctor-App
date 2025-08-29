import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../controllers/FormController.dart';
import '../controllers/NetworkController.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with WidgetsBindingObserver {
  final controller = Get.put(FormController());

  // final ScrollController brandNameScrollController = ScrollController();
  final NetworkController networkController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setWhiteStatusBar();

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

  void _setWhiteStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorCodes.colorBlue1,
        statusBarIconBrightness: Brightness.light, // dark icons for white bar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: ColorCodes.colorBlack1, size: 20),
                    onPressed: () {
                      // Get.back();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10),
                  Text("Doctor Partner", style: TextStyles.textStyle2),
                ],
              ),
              Text('Join our community top Doctors.', style: TextStyles.textStyle1, textAlign: TextAlign.center),
              SizedBox(height: 10),
              Form(
                key: controller.formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                              child: TextFormField(
                                controller: controller.nameController,
                                keyboardType: TextInputType.name,
                                cursorColor: ColorCodes.colorBlack1,
                                decoration: InputDecoration(labelText: 'Name*', labelStyle: TextStyles.textStyle1, border: InputBorder.none),
                                style: TextStyles.descriptionTextStyle,
                                onChanged: (_) => controller.validateName(),
                              ),
                            ),
                            if (controller.nameError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 8),
                                child: Text(controller.nameError.value, style: TextStyles.errorTextStyle),
                              ),
                          ],
                        ),
                      ),
                      /*Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 100,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: brandNameScrollController,
                                child: TextFormField(
                                  controller: controller.brandNamesController,
                                  scrollController: brandNameScrollController,
                                  cursorColor: ColorCodes.colorBlack1,
                                  maxLines: null,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyles.descriptionTextStyle,
                                  decoration: InputDecoration(labelText: 'Brand Names*', labelStyle: TextStyles.textStyle1, border: InputBorder.none),
                                  onChanged: (_) => controller.validateBrandName(),
                                ),
                              ),
                            ),
                            if (controller.brandNameError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 8),
                                child: Text(controller.brandNameError.value, style: TextStyles.errorTextStyle),
                              ),
                          ],
                        ),
                      ),*/
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text("How would you like to partner with us?*", style: TextStyles.textStyle1),
                            SizedBox(height: 5),
                            Obx(
                              () => Column(
                                children: List.generate(controller.checkboxLabels.length, (index) {
                                  return CheckboxListTile(
                                    title: Text(controller.checkboxLabels[index], style: TextStyles.textStyle1),
                                    value: controller.checkboxes[index].value,
                                    onChanged: (value) => controller.toggleCheckbox(index, value),
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () =>
                            controller.checkboxError.value
                                ? Padding(
                                  padding: const EdgeInsets.only(left: 2, bottom: 8),
                                  child: Text('Choose your option(s).', style: TextStyles.errorTextStyle),
                                )
                                : SizedBox.shrink(),
                      ),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                              child: TextFormField(
                                controller: controller.addressController,
                                keyboardType: TextInputType.text,
                                cursorColor: ColorCodes.colorBlack1,
                                minLines: 1,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'What is your clinic/pharmacy address?',
                                  labelStyle: TextStyles.textStyle1,
                                  border: InputBorder.none,
                                ),
                                style: TextStyles.textStyle1,
                                onChanged: (_) => controller.validateAddress(),
                              ),
                            ),
                            if (controller.addressError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 8),
                                child: Text(controller.addressError.value, style: TextStyles.errorTextStyle),
                              ),
                          ],
                        ),
                      ),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                              child: TextFormField(
                                controller: controller.emailController,
                                cursorColor: ColorCodes.colorBlack1,
                                style: TextStyles.textStyle1,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(labelText: 'Contact Email*', border: InputBorder.none, labelStyle: TextStyles.textStyle1),
                                onChanged: (_) => controller.validateEmail(),
                              ),
                            ),
                            if (controller.emailError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 8),
                                child: Text(controller.emailError.value, style: TextStyles.errorTextStyle),
                              ),
                          ],
                        ),
                      ),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorCodes.colorGrey4)),
                              child: TextFormField(
                                controller: controller.phoneController,
                                style: TextStyles.textStyle1,
                                cursorColor: ColorCodes.colorBlack1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                decoration: InputDecoration(
                                  labelText: 'Contact Number*',
                                  border: InputBorder.none,
                                  labelStyle: TextStyles.textStyle1,
                                ),
                                onChanged: (_) => controller.validatePhone(),
                              ),
                            ),
                            if (controller.phoneError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 8),
                                child: Text(controller.phoneError.value, style: TextStyles.errorTextStyle),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCodes.colorBlue1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () {
                                    if (networkController.connectionStatus.value == Constants.notConnected) {
                                      Constants.noInternetError();
                                      return;
                                    } else
                                      controller.submitForm();
                                  },
                          child:
                              controller.isLoading.value
                                  ? SizedBox(
                                    height: 23,
                                    width: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor: ColorCodes.darkPurple1,
                                      valueColor: AlwaysStoppedAnimation<Color>(ColorCodes.white),
                                    ),
                                  )
                                  : Text('Submit', style: TextStyles.textStyle6_1),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
