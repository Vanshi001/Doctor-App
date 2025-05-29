import 'package:Doctor/controllers/EditProfileController.dart';
import 'package:Doctor/widgets/Constants.dart';
import 'package:Doctor/widgets/SubmitButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../model/login_model.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/InputTextFieldWidget.dart';
import '../widgets/TextStyles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileController controller = Get.put(EditProfileController());

  @override
  void initState() {
    super.initState();
    final doctor = controller.doctor.value;
    print("doctor =-=-=-=-=-=-=-=-=-= ${doctor.name}");
    // final doctorDetails = Rxn<Doctor>();
    // print("doctorDetails =-=-=-=-=-=-=-=-=-= $doctorDetails");

    controller.doctorId = doctor.id;
    controller.nameController.text = doctor.name;
    controller.emailController.text = doctor.email;
    controller.contactController.text = doctor.contactNumber;
    controller.addressController.text = doctor.address;
  }

  @override
  Widget build(BuildContext context) {

    bool validateFields() {
      if (controller.nameController.text.trim().isEmpty) {
        Constants.showError("Name is required");
        return false;
      } else if (controller.emailController.text.trim().isEmpty) {
        Constants.showError("Email is required");
        return false;
      }else if (controller.contactController.text.trim().isEmpty) {
        Constants.showError("Contact is required");
        return false;
      }else if (controller.addressController.text.trim().isEmpty) {
        Constants.showError("Address is required");
        return false;
      }
      return true;
    }
    
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            title: Text("Edit Profile", style: TextStyles.buttonNameStyle),
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InputTextFieldWidget(
                  controller.nameController,
                "Name"
              ),
              SizedBox(height: 10),
              InputTextFieldWidget(
                  controller.emailController,
                  "Email"
              ),
              SizedBox(height: 10),
              InputTextFieldWidget(
                controller.contactController,
                  keyboardType: TextInputType.phone,
                  "Contact",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),],
              ),
              SizedBox(height: 10),
              InputTextFieldWidget(
                controller.addressController,
                  "Address",
              ),
              SizedBox(height: 20),
              SubmitButton(
                onPressed: () {
                  if (!validateFields()) return;

                  // print("${controller.doctorId},${controller.nameController.text},${controller.emailController.text},${controller.contactController.text},${controller.addressController.text}");
                  controller.updateDoctor(
                    controller.doctorId,
                    controller.nameController.text,
                    controller.emailController.text,
                    controller.contactController.text,
                    controller.addressController.text,
                  );
                  Get.back(); // Go back to previous screen
                },
                titleWidget: Text("Save", style: TextStyles.buttonNameStyle,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
