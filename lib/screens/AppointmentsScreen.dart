import 'package:Doctor/controllers/AppointmentsController.dart';
import 'package:Doctor/widgets/Constants.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';
import 'AppointmentDetailsDialog.dart';

class AppointmentsScreen extends StatefulWidget {
  final String? doctorId;

  const AppointmentsScreen({super.key, required this.doctorId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AppointmentsController controller = Get.put(AppointmentsController());
  List<String> medicineNames = [];

  @override
  void initState() {
    super.initState();
    controller.fetchAllAppointmentsApi(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Appointments", style: TextStyles.textStyle2_1),
          backgroundColor: ColorCodes.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 2, thickness: 2, color: ColorCodes.colorGrey2),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                        TabType.values.map((tab) {
                          final isSelected = controller.selectedTab.value == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: () => controller.updateTab(tab, widget.doctorId),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  side: BorderSide(color: isSelected ? ColorCodes.colorBlue1 : ColorCodes.colorGrey4, width: 1.5),
                                ),
                                backgroundColor: isSelected ? ColorCodes.colorBlue1 : ColorCodes.white,
                                foregroundColor: isSelected ? ColorCodes.white : ColorCodes.black,
                                textStyle: isSelected ? TextStyles.textStyle6_1 : TextStyles.textStyle6,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isSelected && controller.getDotColorForTab(tab) != null)
                                    Container(
                                      height: 8,
                                      width: 8,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(color: controller.getDotColorForTab(tab), shape: BoxShape.circle),
                                    ),
                                  Text(tab.name.capitalizeFirst ?? ''),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

            // List Display
            Expanded(
              child: Obx(() {
                final list = controller.currentList;
                medicineNames.clear();

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No ${controller.selectedTab.value.name.capitalizeFirst} appointments available', style: TextStyles.textStyle2),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    for (var medicine in item.prescription!) {
                      medicineNames.add(medicine.medicineName);
                    }
                    // print("item.id ---------------------------- ${item.id}");
                    // print("item.clinic ---------------------------- ${item.patientFullName}");
                    // print("item.concern ---------------------------- ${item.concerns}");
                    // print("item.date ---------------------------- ${item.appointmentDate}");
                    // print("item.time ---------------------------- ${item.timeSlot}");
                    // print("=======================");

                    final parsedDate = DateTime.parse(item.appointmentDate.toString());
                    final formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

                    print('selected tab -- ${controller.selectedTab.value}');
                    print('item.status -- ${item.status}');

                    return GestureDetector(
                      onTap: () {
                        print("Clicked on individual appointment : ${item.id} -- $index");
                        if (item.status == "completed") {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) =>
                                AppointmentDetailsDialog(
                                  title: item.patientFullName.toString(),
                                  image: 'assets/ic_user.png',
                                  //'https://randomuser.me/api/portraits/women/1.jpg',
                                  date: formattedDate,
                                  time:
                                  '${Constants.formatTimeToAmPm(item.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(
                                      item.timeSlot?.endTime ?? '')}',
                                  concern: item.concerns?.join(", ") ?? '',
                                  medicineNames: medicineNames,
                                ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorCodes.colorGrey4, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            // Image.asset('assets/ic_profile.png', height: 65, width: 65),
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
                                  child: Center(child: Text(controller.getInitials(item.patientFullName.toString()), style: TextStyles.textStyle4)),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 4,
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                      color: controller.getStatusColor(item.status.toString()), // dot color
                                      shape: BoxShape.circle,
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
                                    Text(item.patientFullName.toString(), style: TextStyles.textStyle3),
                                    SizedBox(height: 2),
                                    SizedBox(width: width / 3, child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1)),
                                    SizedBox(height: 2),
                                    Text(item.concerns?.join(", ") ?? '', style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Image.asset('assets/ic_calendar.png', width: 12, height: 12),
                                        SizedBox(width: 3),
                                        Text(formattedDate, style: TextStyles.textStyle4_1),
                                        SizedBox(width: 8),
                                        Image.asset('assets/ic_clock.png', width: 12, height: 12),
                                        SizedBox(width: 3),
                                        Text(
                                          '${Constants.formatTimeToAmPm(item.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(item.timeSlot?.endTime ?? '')}',
                                          style: TextStyles.textStyle4_1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (item.status == "completed") SizedBox(width: 40, height: 40, child: Image.asset('assets/ic_document.png')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
