import 'package:Doctor/main.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/main/MainController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';
import 'AddPendingMedicinesScreen.dart';

class AllPendingMedicineUserListScreen extends StatefulWidget {
  const AllPendingMedicineUserListScreen({super.key});

  @override
  State<AllPendingMedicineUserListScreen> createState() => _AllPendingMedicineUserListScreenState();
}

class _AllPendingMedicineUserListScreenState extends State<AllPendingMedicineUserListScreen> {
  final MainController mainController = Get.put(MainController());
  final ScrollController scrollController = ScrollController();

  String getInitials(String firstName) {
    if (firstName.isEmpty) return '';
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    return firstInitial.toUpperCase();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> handleRefresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var doctorId = prefs.getString('doctor_id');
    print('doctorId -- ${doctorId}');
    mainController.fetchPendingAppointmentsWithoutPrescriptionApi(doctorId);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Pending Prescriptions", style: TextStyles.textStyle2_1),
          backgroundColor: ColorCodes.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: handleRefresh,
          backgroundColor: ColorCodes.colorBlue1,
          color: ColorCodes.white,
          elevation: 3,
          child: Obx(() {
            final appointments = mainController.withoutDescriptionAppointmentResponse.value?.data;

            // print("Pending appointments ----------- ==== $appointments");
            if (mainController.isLoadingAppointmentWithoutDescription.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (appointments == null || appointments.isEmpty) {
              return const Center(child: Text("No pending prescriptions found", style: TextStyles.textStyle3));
            }

            return /*mainController.isLoading.value
                            ? Center(child: CircularProgressIndicator(color: ColorCodes.colorBlack1))
                            : */ ListView.builder(
              // padding: EdgeInsets.symmetric(vertical: 10),
              shrinkWrap: true,
              itemCount: appointments.length > 2 ? 2 : appointments.length,
              // itemCount: mainController.appointmentList.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final patientName = appointment.patientFullName ?? '';
                final concerns = appointment.concerns?.join(", ") ?? '';
                final appointmentDate = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate.toString()));
                final startTime = Constants.formatTimeToAmPm(appointment.timeSlot!.startTime);
                final endTime = Constants.formatTimeToAmPm(appointment.timeSlot!.endTime);

                return GestureDetector(
                  onTap: () {
                    Get.to(() => AddPendingMedicinesScreen(appointmentData: appointment), transition: Transition.rightToLeft);
                  },
                  child: Card(
                    color: ColorCodes.white,
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Image.asset('assets/ic_profile.png', height: 65, width: 65),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorCodes.colorBlack2, // Background color for the circle
                                  border: Border.all(color: ColorCodes.colorBlue1, width: 3),
                                ),
                                child: Center(child: Text(getInitials(patientName.toString()), style: TextStyles.textStyle4)),
                              ),
                              Positioned(
                                top: 0,
                                right: 4,
                                child: Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color: ColorCodes.colorYellow1, // dot color
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patientName, style: TextStyles.textStyle3),
                                  SizedBox(height: 2),
                                  SizedBox(width: width / 3, child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1)),
                                  SizedBox(height: 2),
                                  Text(concerns, style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Image.asset('assets/ic_calendar.png', width: 12, height: 12),
                                      SizedBox(width: 3),
                                      Text(appointmentDate, style: TextStyles.textStyle4_1),
                                      SizedBox(width: 8),
                                      Image.asset('assets/ic_clock.png', width: 12, height: 12),
                                      SizedBox(width: 3),
                                      Text('$startTime - $endTime', style: TextStyles.textStyle4_1),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(width: 40, height: 40, child: Image.asset('assets/ic_document.png')),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
