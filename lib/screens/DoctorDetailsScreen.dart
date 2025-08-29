import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth/LoginController.dart';
import '../model/login_model.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({super.key});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {

  final loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final doctor = loginController.loginResponse.value?.doctor;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            title: Text("Doctor's Detail", style: TextStyles.buttonNameStyle),
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
                // Get.back();
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: doctor == null
            ? Center(child: Text("No doctor data available"))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${doctor.name}", style: TextStyles.textStyle),
              SizedBox(height: 10),
              Text("Email: ${doctor.email}", style: TextStyles.textStyle),
              SizedBox(height: 10),
              Text("Contact: ${doctor.contactNumber}", style: TextStyles.textStyle),
              SizedBox(height: 10),
              Text("Address: ${doctor.address}", style: TextStyles.textStyle),
              SizedBox(height: 10),
              /*Text("Verified: ${doctor.isVerified ? 'Yes' : 'No'}", style: TextStyles.textStyle),
              SizedBox(height: 20),
              Text("Education:", style: TextStyles.smallTextStyle),
              ...doctor.education.map((e) => Text("• $e", style: TextStyles.textStyle)),
              SizedBox(height: 20),
              Text("Experience:", style: TextStyles.smallTextStyle),
              ...doctor.experience.map((e) => Text("• $e", style: TextStyles.textStyle)),*/
            ],
          ),
        ),
      ),
    );
  }
}
