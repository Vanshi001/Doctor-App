import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/TimeController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';
import 'package:get/get.dart';

class AddEveningTimeScreen extends StatefulWidget {
  const AddEveningTimeScreen({super.key});

  @override
  State<AddEveningTimeScreen> createState() => _AddEveningTimeScreenState();
}

class _AddEveningTimeScreenState extends State<AddEveningTimeScreen> {
  final TimeController controller = Get.find<TimeController>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorCodes.white,
          appBar: AppBar(
            title: Text("Add Time", style: TextStyles.textStyle2_1),
            backgroundColor: ColorCodes.white,
            elevation: 0,
            // removes shadow tint
            surfaceTintColor: Colors.transparent,
            // ✅ prevent purple overlay on scroll
            scrolledUnderElevation: 0,
            // ✅ Flutter 3.7+ prevents color change on scroll
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
              onPressed: () {
                // Get.back();
                Navigator.pop(context); // normal back
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Afternoon Times", style: TextStyles.textStyle2_1),
                Text("Afternoon slot: 2:00 PM to 9:00 PM", style: TextStyles.textStyle7),
                SizedBox(height: 20),
                Text("Start Time*", style: TextStyles.textStyle4_2),
                Obx(() {
                  /*final times = isMorning
                      ? controller.morningStartTimes
                      : controller.eveningStartTimes;

                  final selected = isMorning
                      ? controller.selectedMorningStartTime.value
                      : controller.selectedEveningStartTime.value;*/

                  final startTimes = controller.eveningStartTimes.toSet().toList(); // remove duplicates
                  final selectedStart = controller.selectedEveningStartTime.value.isEmpty ? null : controller.selectedEveningStartTime.value;

                  return SizedBox(
                    width: width,
                    child: DropdownButtonFormField<String>(
                      value: selectedStart,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: ColorCodes.colorGrey2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      dropdownColor: ColorCodes.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorCodes.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorCodes.colorGrey2, width: 1)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorCodes.colorGrey2, width: 1.5)),
                      ),
                      style: TextStyles.textStyle4_3,
                      items: startTimes.map((time) => DropdownMenuItem<String>(value: time, child: Text(time))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setEveningStartTime(value);
                        }
                      },
                    ),
                  );
                }),
                SizedBox(height: 20),
                Text("End Time*", style: TextStyles.textStyle4_2),
                Obx(() {
                  final endTimes = controller.eveningEndTimes.toSet().toList();
                  final selectedEnd = controller.selectedEveningEndTime.value.isEmpty ? null : controller.selectedEveningEndTime.value;

                  return SizedBox(
                    width: width,
                    child: DropdownButtonFormField<String>(
                      value: selectedEnd,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: ColorCodes.colorGrey2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      dropdownColor: ColorCodes.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorCodes.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorCodes.colorGrey2, width: 1)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorCodes.colorGrey2, width: 1.5)),
                      ),
                      style: TextStyles.textStyle4_3,
                      items: endTimes.map((time) => DropdownMenuItem<String>(value: time, child: Text(time))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setEveningEndTime(value);
                        }
                      },
                    ),
                  );
                }),
                Spacer(),
                Container(
                  width: width,
                  height: 40,
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      print("Evening start time --> ${controller.selectedEveningStartTime.value}");
                      print("Evening end time --> ${controller.selectedEveningEndTime.value}");
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.colorBlue1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                    child: Text('ADD Time', style: TextStyles.textStyle6_1.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
