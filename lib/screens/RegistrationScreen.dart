import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/FormController.dart';
import '../widgets/TextStyles.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final controller = Get.put(FormController());

  final List<String> checkboxLabels = [
    'Online consults',
    'Product distribution at clinic/ hospital pharmacy',
    'Social media marketing',
    'Product-related',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            title: Text("Doctor Partner", style: TextStyles.buttonNameStyle),
            backgroundColor: ColorCodes.darkPurple1,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.close, color: ColorCodes.white, size: 20),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Text(
                'Join our community top Doctors.',
                style: TextStyles.textStyle,
                textAlign: TextAlign.center,
              ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorCodes.darkPurple,
                                ),
                              ),
                              child: TextFormField(
                                controller: controller.nameController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: 'Name*',
                                  labelStyle: TextStyles.smallTextStyle,
                                  border: InputBorder.none,
                                ),
                                style: TextStyles.descriptionTextStyle,
                                onChanged: (_) => controller.validateName(),
                              ),
                            ),
                            if (controller.nameError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                  bottom: 8,
                                ),
                                child: Text(
                                  controller.nameError.value,
                                  style: TextStyles.errorTextStyle,
                                ),
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
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorCodes.darkPurple,
                                ),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: TextFormField(
                                  controller: controller.brandNamesController,
                                  maxLines: null,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyles.descriptionTextStyle,
                                  decoration: InputDecoration(
                                    labelText: 'Brand Names*',
                                    labelStyle: TextStyles.smallTextStyle,
                                    border: InputBorder.none,
                                  ),
                                  onChanged:
                                      (_) => controller.validateBrandName(),
                                ),
                              ),
                            ),
                            if (controller.brandNameError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                  bottom: 8,
                                ),
                                child: Text(
                                  controller.brandNameError.value,
                                  style: TextStyles.errorTextStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorCodes.darkPurple),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "How would you like to partner with us?*",
                              style: TextStyles.smallTextStyle,
                            ),
                            SizedBox(height: 5),
                            Obx(
                              () => Column(
                                children: List.generate(checkboxLabels.length, (
                                  index,
                                ) {
                                  return CheckboxListTile(
                                    title: Text(
                                      checkboxLabels[index],
                                      style: TextStyles.descriptionTextStyle,
                                    ),
                                    value: controller.checkboxes[index].value,
                                    onChanged:
                                        (value) => controller.toggleCheckbox(
                                          index,
                                          value,
                                        ),
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
                                  padding: const EdgeInsets.only(
                                    left: 2,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    'Choose your option(s).',
                                    style: TextStyles.errorTextStyle,
                                  ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorCodes.darkPurple,
                                ),
                              ),
                              child: TextFormField(
                                controller: controller.addressController,
                                keyboardType: TextInputType.text,
                                minLines: 1,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText:
                                      'What is your clinic/pharmacy address?',
                                  labelStyle: TextStyles.smallTextStyle,
                                  border: InputBorder.none,
                                ),
                                style: TextStyles.descriptionTextStyle,
                                onChanged: (_) => controller.validateAddress(),
                              ),
                            ),
                            if (controller.addressError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                  bottom: 8,
                                ),
                                child: Text(
                                  controller.addressError.value,
                                  style: TextStyles.errorTextStyle,
                                ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorCodes.darkPurple,
                                ),
                              ),
                              child: TextFormField(
                                controller: controller.emailController,
                                style: TextStyles.descriptionTextStyle,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Contact Email*',
                                  border: InputBorder.none,
                                  labelStyle: TextStyles.smallTextStyle,
                                ),
                                onChanged: (_) => controller.validateEmail(),
                              ),
                            ),
                            if (controller.emailError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                  bottom: 8,
                                ),
                                child: Text(
                                  controller.emailError.value,
                                  style: TextStyles.errorTextStyle,
                                ),
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ColorCodes.darkPurple,
                                ),
                              ),
                              child: TextFormField(
                                controller: controller.phoneController,
                                style: TextStyles.descriptionTextStyle,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Contact Number*',
                                  border: InputBorder.none,
                                  labelStyle: TextStyles.smallTextStyle,
                                ),
                                onChanged: (_) => controller.validatePhone(),
                              ),
                            ),
                            if (controller.phoneError.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 2,
                                  bottom: 8,
                                ),
                                child: Text(
                                  controller.phoneError.value,
                                  style: TextStyles.errorTextStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCodes.darkPurple,
                            disabledBackgroundColor: ColorCodes.darkPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.submitForm,
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
                                  : Text(
                                    'Submit',
                                    style: TextStyles.buttonNameStyle,
                                  ),
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
