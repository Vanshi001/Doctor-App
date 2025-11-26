import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/SlotEditController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';

class EditMorningTimeSlotScreen extends StatefulWidget {
  const EditMorningTimeSlotScreen({super.key});

  @override
  State<EditMorningTimeSlotScreen> createState() => _EditMorningTimeSlotScreenState();
}

class _EditMorningTimeSlotScreenState extends State<EditMorningTimeSlotScreen> {
  dynamic args;
  String? editDate;
  String? doctorId;
  String? slotId;
  dynamic editSlot; // Slot object
  int? index;
  int? dateIndex;
  bool? isMorning;

  final slotEditController = Get.put(SlotEditController());

  @override
  void initState() {
    super.initState();

    // ✅ Receive arguments safely
    args = Get.arguments;

    editDate = args?['editDate'];
    editSlot = args?['editSlot'];
    index = args?['index'];
    dateIndex = args?['dateIndex'];
    isMorning = args?['isMorning'];
    doctorId = args?['doctorId'];
    slotId = args?['slotId'];

    print("🟢 Received arguments:");
    print("editDate: $editDate");
    print("editSlot.start: ${editSlot?.start}");
    print("editSlot.end: ${editSlot?.end}");
    print("index: $index");
    print("dateIndex: $dateIndex");
    print("isMorning: $isMorning");
    print("doctorId: $doctorId");
    print("slotId: $slotId");

    slotEditController.isMorning = (isMorning == true);
    slotEditController.initForEdit(isMorning: slotEditController.isMorning, start: editSlot?.start, end: editSlot?.end);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorCodes.white,
          appBar: AppBar(
            title: Text("Edit Time", style: TextStyles.textStyle2_1),
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 1, thickness: 1, color: ColorCodes.colorGrey2),
              /*Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Editing ${isMorning == true ? 'Morning' : 'Afternoon'} Slot:\n\n"
                  "Date: ${formatDate(editDate.toString())}\n"
                  "Start: ${editSlot?.start}\n"
                  "End: ${editSlot?.end}",
                  style: TextStyles.textStyle4_3,
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Text("${formatDate(editDate.toString())}", style: TextStyles.textStyle2_1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  slotEditController.isMorning ? "Morning Slot: 9:00 AM to 1:00 PM" : "Evening Slot: 2:00 PM to 9:00 PM",
                  style: TextStyles.textStyle7,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                child: Text(
                  "Your timing is ${editSlot?.start} to ${editSlot?.end}",
                  style: TextStyles.textStyle5_1.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(10, 20, 10, 5), child: Text("Start Time*", style: TextStyles.textStyle4_2)),
              // Start time dropdown
              Obx(() {
                final list = slotEditController.isMorning ? slotEditController.morningStartTimes : slotEditController.eveningStartTimes;
                return Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonFormField<String>(
                    value: slotEditController.selectedStart.value,
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
                    items: list.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) {
                      slotEditController.selectedStart.value = v;
                      // keep end valid (ensure not before start if arrays are parallel)
                      final si = list.indexOf(v ?? '');
                      final ends = slotEditController.isMorning ? slotEditController.morningEndTimes : slotEditController.eveningEndTimes;
                      final ei = ends.indexOf(slotEditController.selectedEnd.value ?? '');
                      if (si >= 0 && (ei < 0 || ei < si) && si < ends.length) {
                        slotEditController.selectedEnd.value = ends[si];
                      }
                    },
                    // decoration: const InputDecoration(labelText: 'Start time'),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 5), child: Text("End Time*", style: TextStyles.textStyle4_2)),
              // End time dropdown
              Obx(() {
                final list = slotEditController.isMorning ? slotEditController.morningEndTimes : slotEditController.eveningEndTimes;
                return Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: DropdownButtonFormField<String>(
                    value: slotEditController.selectedEnd.value,
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
                    items: list.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => slotEditController.selectedEnd.value = v,
                    // decoration: const InputDecoration(labelText: 'End time'),
                  ),
                );
              }),
              Spacer(),
              Container(
                width: width,
                height: 40,
                margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigator.pop(context, true);
                    /*if (controller.selectedMorningStartTime.value.isEmpty ||
                        controller.selectedMorningEndTime.value.isEmpty) {
                      Get.snackbar("Error", "Please select start and end times");
                      return;
                    }*/

                    var result = await slotEditController.editCustomDatesApi(
                      doctorId: doctorId,
                      dateKey: editDate.toString(),
                      slotId: slotId.toString(),
                      startTime: slotEditController.selectedStart.value ?? '',
                      endTime: slotEditController.selectedEnd.value ?? '',
                    );

                    if (result) {
                      print("Result -----> $result");
                      Navigator.pop(context, true);
                    }
                    else
                      print("Result null");
                    // Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCodes.colorBlue1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  child: Text('Save', style: TextStyles.textStyle6_1.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String dateKey) {
    try {
      final parsedDate = DateTime.parse(dateKey); // e.g., 2025-11-05
      final formatted = DateFormat('EEE, MMM dd, yyyy').format(parsedDate);
      return formatted; // → Mon, Nov 05, 2025
    } catch (e) {
      print("Date format error: $e");
      return dateKey; // fallback to original string
    }
  }
}
