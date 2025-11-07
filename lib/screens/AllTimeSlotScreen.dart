import 'package:Doctor/controllers/TimeController.dart';
import 'package:Doctor/screens/AddTimeScreen.dart';
import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/TextStyles.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/CustomNotesController.dart';
import '../widgets/Constants.dart';
import 'AddCustomNotesScreen.dart';
import 'EditCustomNotesScreen.dart';
import 'EditMorningTimeSlotScreen.dart';

class AllTimeSlotScreen extends StatefulWidget {
  const AllTimeSlotScreen({super.key});

  @override
  State<AllTimeSlotScreen> createState() => _AllTimeSlotScreenState();
}

class _AllTimeSlotScreenState extends State<AllTimeSlotScreen> {
  final TimeController controller = Get.put(TimeController());

  late final ScrollController _controller;

  @override
  void initState() {
    // controller.fetchNotesApi();
    super.initState();
    _controller = ScrollController();
    controller.fetchDoctorDetailsApi();
    controller.getCustomDatesApi();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Obx(() {
      final hasData = controller.allDatesList.isNotEmpty;
      // print("hasData ----> $hasData");

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: hasData ? ColorCodes.colorBlue1 : ColorCodes.white,
          statusBarIconBrightness: hasData ? Brightness.light : Brightness.dark,
        ),
        child: SafeArea(
          child: Obx(() {
            bool hasData = controller.allDatesList.isNotEmpty;
            // print("hasData --> $hasData");

            return Scaffold(
              backgroundColor: hasData ? ColorCodes.colorBlue1 : ColorCodes.white,
              appBar: AppBar(
                title: Text("All Time", style: TextStyles.textStyle2_4),
                backgroundColor: hasData ? ColorCodes.colorBlue1 : ColorCodes.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: hasData ? ColorCodes.white : ColorCodes.colorBlack1),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  GestureDetector(
                    onTap: () async {
                      final refreshNeeded = await Get.to(() => AddTimeScreen());
                      if (refreshNeeded == true || (refreshNeeded is Map && refreshNeeded['refresh'] == true)) {
                        controller.getCustomDatesApi();
                      }
                    },
                    child: Container(
                      width: width / 2.8,
                      color: ColorCodes.colorBlue1,
                      height: 35,
                      padding: EdgeInsets.only(right: 15),
                      child: Stack(
                        children: [
                          // 🔲 Outer Dotted Border
                          Positioned.fill(
                            child: Column(
                              children: [
                                // Top border
                                const DottedLine(dashLength: 4, dashGapLength: 2, lineThickness: 1, dashColor: ColorCodes.white),
                                Expanded(
                                  child: Row(
                                    children: const [
                                      // Left border
                                      RotatedBox(
                                        quarterTurns: 1,
                                        child: DottedLine(dashLength: 4, dashGapLength: 2, lineThickness: 1, dashColor: ColorCodes.white),
                                      ),
                                      Spacer(),
                                      // Right border
                                      RotatedBox(
                                        quarterTurns: 1,
                                        child: DottedLine(dashLength: 4, dashGapLength: 2, lineThickness: 1, dashColor: ColorCodes.white),
                                      ),
                                    ],
                                  ),
                                ),
                                // Bottom border
                                const DottedLine(dashLength: 4, dashGapLength: 2, lineThickness: 1, dashColor: ColorCodes.white),
                              ],
                            ),
                          ),

                          // ➕ Center Content
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, color: ColorCodes.white, size: 20),
                                SizedBox(width: 6),
                                Text("Add Time", style: TextStyles.textStyle6_1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                height: height,
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingTimes.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.allDatesList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/ic_no_calendar.png', height: 100, width: 100),
                                const SizedBox(height: 20),
                                Text("No Availability Set", style: TextStyles.textStyle2),
                                const SizedBox(height: 5),
                                Text(
                                  "You haven't added any active hours yet. Set your \navailable time slots so patients can book appointments.",
                                  style: TextStyles.textStyle5_1,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        // Step 1️⃣ - Find today's date in your data list
                        final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                        final todayData = controller.allDatesList.firstWhereOrNull((item) => item.dateKey?.startsWith(todayDate) ?? false);

                        // Step 2️⃣ - Create a filtered list (excluding today)
                        final filteredList = controller.allDatesList.where((item) => !(item.dateKey?.startsWith(todayDate) ?? false)).toList();

                        return RefreshIndicator(
                          onRefresh: () async {
                            await controller.getCustomDatesApi();
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🌞 Show today's date/time section ABOVE the white container
                              if (todayData != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "You have ${todayData.slots?.length ?? 0} Shifts today",
                                        style: TextStyles.textStyle6_1.copyWith(fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children:
                                            todayData.slots!.asMap().entries.map((entry) {
                                              final slotIndex = entry.key;
                                              final slot = entry.value;
                                              final isMorning = slotIndex == 0;

                                              return Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(right: slotIndex == 0 ? 10 : 0),
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("${slot.start ?? ''} → ${slot.end ?? ''}", style: TextStyles.textStyle1),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        textAlign: TextAlign.start,
                                                        isMorning ? "Morning Timing" : "Afternoon Times",
                                                        style: TextStyles.textStyle5_1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // 🟦 Below container for upcoming days

                              // Expanded(
                              //   child: Obx(() {
                              //     final items = controller.filteredList; // reactive source
                              //
                              //     return ListView.builder(
                              //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              //       itemCount: items.length,
                              //       itemBuilder: (context, index) {
                              //         final data = items[index];
                              //
                              //         return Dismissible(
                              //           key: ValueKey('date::${data.dateKey}'),
                              //           background: _editBg(),
                              //           secondaryBackground: _deleteBg(),
                              //           confirmDismiss: (direction) async {
                              //             if (direction == DismissDirection.startToEnd) {
                              //               Get.to(() => AddTimeScreen(), arguments: {"editData": data});
                              //               return false; // edit only, no removal
                              //             } else {
                              //               return await _confirm(context, 'Delete this date and all its slots?') == true;
                              //             }
                              //           },
                              //           onDismissed: (direction) {
                              //             // ✅ mutate here, AFTER animation starts
                              //             controller.deleteDateByKey(data.dateKey);
                              //           },
                              //           child: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             children: [
                              //               // Date header (guard parse)
                              //               Padding(
                              //                 padding: const EdgeInsets.symmetric(vertical: 10),
                              //                 child: Text(_formatDateSafe(data.dateKey), style: TextStyles.textStyle4_3),
                              //               ),
                              //
                              //               // Slots list for this date
                              //               Column(
                              //                 children:
                              //                     data.slots.asMap().entries.map((entry) {
                              //                       final slotIndex = entry.key;
                              //                       final slot = entry.value;
                              //                       final stableKey = slot.id ?? '${data.dateKey}::${slot.start}-${slot.end}'; // avoid index
                              //                       final isMorning = slotIndex == 0;
                              //
                              //                       return Padding(
                              //                         padding: const EdgeInsets.only(bottom: 10),
                              //                         child: Dismissible(
                              //                           key: ValueKey('slot::$stableKey'),//ValueKey('slot::${data.dateKey}::$slotIndex::${slot.id ?? ''}'),
                              //                           direction: DismissDirection.horizontal,
                              //                           background: _editSlotBg(),
                              //                           secondaryBackground: _deleteSlotBg(),
                              //                           confirmDismiss: (direction) async {
                              //                             if (direction == DismissDirection.startToEnd) {
                              //                               Get.to(
                              //                                     () => EditMorningTimeSlotScreen(),
                              //                                 arguments: {"editDate": data.dateKey, "editSlot": slot, "index": slotIndex},
                              //                               );
                              //                               return false;
                              //                             } else {
                              //                               return await _confirm(context, 'Delete this time slot?') == true;
                              //                             }
                              //                           },
                              //                           onDismissed: (direction) {
                              //                             // ✅ mutate here, AFTER animation starts
                              //                             controller.deleteSpecificSlot(data.dateKey, slotIndex);
                              //                           },
                              //                           child: Card(
                              //                             elevation: 0,
                              //                             color: Colors.white,
                              //                             shape: RoundedRectangleBorder(
                              //                               borderRadius: BorderRadius.circular(40),
                              //                               side: BorderSide(color: Colors.grey.shade300, width: 1),
                              //                             ),
                              //                             child: Padding(
                              //                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              //                               child: Row(
                              //                                 children: [
                              //                                   CircleAvatar(
                              //                                     radius: 28,
                              //                                     backgroundColor: isMorning ? ColorCodes.colorYellow2 : ColorCodes.colorBlue3,
                              //                                     child: Image.asset(
                              //                                       isMorning ? 'assets/ic_sun.png' : 'assets/ic_moon.png',
                              //                                       width: 40,
                              //                                       height: 40,
                              //                                     ),
                              //                                   ),
                              //                                   const SizedBox(width: 15),
                              //                                   Column(
                              //                                     crossAxisAlignment: CrossAxisAlignment.start,
                              //                                     children: [
                              //                                       Text(
                              //                                         isMorning ? "Morning Timing" : "Afternoon Times",
                              //                                         style: TextStyles.textStyle5_1,
                              //                                       ),
                              //                                       const SizedBox(height: 4),
                              //                                       Row(
                              //                                         children: [
                              //                                           Text(slot.start ?? '', style: TextStyles.textStyle4_3),
                              //                                           const SizedBox(width: 8),
                              //                                           const Icon(Icons.arrow_forward, size: 18, color: ColorCodes.colorGrey1),
                              //                                           const SizedBox(width: 8),
                              //                                           Text(slot.end ?? '', style: TextStyles.textStyle4_3),
                              //                                         ],
                              //                                       ),
                              //                                     ],
                              //                                   ),
                              //                                 ],
                              //                               ),
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       );
                              //                     }).toList(),
                              //               ),
                              //             ],
                              //           ),
                              //         );
                              //       },
                              //     );
                              //   }),
                              // ),
                              Expanded(
                                child: Container(
                                  height: height,
                                  decoration: const BoxDecoration(
                                    color: ColorCodes.white,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                                  ),
                                  child:
                                      filteredList.isEmpty
                                          ? Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.asset('assets/ic_no_calendar.png', height: 100, width: 100),
                                                const SizedBox(height: 20),
                                                Text("No Availability Set", style: TextStyles.textStyle2),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "You haven't added any active hours yet. Set your \navailable time slots so patients can book appointments.",
                                                  style: TextStyles.textStyle5_1,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          )
                                          : ListView.builder(
                                            controller: _controller,
                                            shrinkWrap: true,
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            itemCount: filteredList.length,
                                            // In your ListView.builder
                                            itemBuilder: (context, dateIndex) {
                                              final data = filteredList[dateIndex];

                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // ... your date header ...
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                    child: Text(
                                                      "${DateFormat('EEEE d').format(DateTime.parse(data.dateKey ?? ''))}",
                                                      style: TextStyles.textStyle4_3,
                                                    ),
                                                  ),

                                                  // 🔹 Build slots with BOTH indices bound
                                                  Column(
                                                    children:
                                                        data.slots!.asMap().entries.map((entry) {
                                                          final int slotIndex = entry.key; // 0, 1, ...
                                                          final slot = entry.value;
                                                          final bool isMorning = slotIndex == 0;

                                                          // Helpful log: which date row + which slot
                                                          // (e.g., "date=2, slot=0 (Morning) start=09:00 end=12:00")
                                                          // ignore: avoid_print
                                                          print(
                                                            'dateIndex=$dateIndex, slotIndex=$slotIndex '
                                                            '(${isMorning ? "Morning" : "Afternoon"}) '
                                                            'start=${slot.start} end=${slot.end}',
                                                          );

                                                          return Padding(
                                                            padding: const EdgeInsets.only(bottom: 10),
                                                            child: Dismissible(
                                                              key: ValueKey('slot::${data.dateKey}::$slotIndex::${slot.id ?? ''}'),
                                                              direction: DismissDirection.horizontal,
                                                              background: _editSlotBg(),
                                                              secondaryBackground: _deleteSlotBg(),
                                                              confirmDismiss: (direction) async {
                                                                try {
                                                                  final now = DateTime.now();
                                                                  final slotDate = DateTime.parse(data.dateKey ?? '');

                                                                  // Compare only by date (ignore time)
                                                                  final currentDate = DateTime(now.year, now.month, now.day);
                                                                  final targetDate = DateTime(slotDate.year, slotDate.month, slotDate.day);

                                                                  final dayDifference = targetDate.difference(currentDate).inDays;
                                                                  print(
                                                                    "📅 Today: $currentDate | Slot Date: $targetDate | Diff: $dayDifference days",
                                                                  );

                                                                  // ❌ Block if slot date is today or tomorrow (difference < 2)
                                                                  if (dayDifference < 2) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(
                                                                        content: Text(
                                                                          "You can’t edit or delete slots within 1 day of today.",
                                                                          style: TextStyles.textStyle6_1,
                                                                        ),
                                                                        backgroundColor: ColorCodes.colorRed2,
                                                                        duration: const Duration(seconds: 3),
                                                                      ),
                                                                    );
                                                                    print("⛔ Blocked: slot too soon ($dayDifference days difference)");
                                                                    return false;
                                                                  }

                                                                  // ✅ Allowed cases
                                                                  if (direction == DismissDirection.startToEnd) {
                                                                    // 👉 EDIT
                                                                    print(
                                                                      'EDIT → dateIndex=$dateIndex, slotIndex=$slotIndex (${isMorning ? "Morning" : "Afternoon"})',
                                                                    );
                                                                    Get.to(
                                                                      () => EditMorningTimeSlotScreen(),
                                                                      arguments: {
                                                                        "editDate": data.dateKey,
                                                                        "editSlot": slot,
                                                                        "index": slotIndex,
                                                                        "dateIndex": dateIndex,
                                                                        "isMorning": isMorning,
                                                                        "doctorId": controller.doctorId,
                                                                        "slotId": slot.id,
                                                                      },
                                                                    );
                                                                    return false; // keep the tile after editing
                                                                  } else {
                                                                    // 👉 DELETE
                                                                    final ok = await _confirm(context, 'Delete this time slot?');
                                                                    if (ok == true) {
                                                                      print('OK -------------> $ok');
                                                                      controller.deleteCustomDateApi(
                                                                        doctorId: controller.doctorId,
                                                                        dateKey: data.dateKey,
                                                                        slotId: slot.id,
                                                                      );
                                                                      return true; // proceed with delete
                                                                    }
                                                                    return false;
                                                                  }
                                                                } catch (e) {
                                                                  print("❌ Date parse error: $e");
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text("Invalid slot date. Cannot edit/delete."),
                                                                      backgroundColor: ColorCodes.colorRed2,
                                                                      duration: const Duration(seconds: 3),
                                                                    ),
                                                                  );
                                                                  return false;
                                                                }
                                                              },

                                                              // confirmDismiss: (direction) async {
                                                              //   // 🕒 Parse the slot’s full datetime
                                                              //   /*try {
                                                              //     final date = DateTime.parse(data.dateKey ?? '');
                                                              //     final now = DateTime.now();
                                                              //
                                                              //     // If your start time is something like "09:00 AM", combine it with the date
                                                              //     DateTime? slotDateTime;
                                                              //     if (slot.start != null && slot.start!.isNotEmpty) {
                                                              //       // ✅ Normalize time like "10:00AM" → "10:00 AM"
                                                              //       String normalizedTime = slot.start!.replaceAllMapped(
                                                              //         RegExp(r'(\d)(AM|PM)'),
                                                              //         (m) => '${m[1]} ${m[2]}',
                                                              //       );
                                                              //
                                                              //       // ✅ Parse normalized time (example: "10:00 AM")
                                                              //       final timeFormat = DateFormat("hh:mm a");
                                                              //       final parsedTime = timeFormat.parse(normalizedTime);
                                                              //
                                                              //       // ✅ Combine parsed time with the given dateKey
                                                              //       slotDateTime = DateTime(
                                                              //         date.year,
                                                              //         date.month,
                                                              //         date.day,
                                                              //         parsedTime.hour,
                                                              //         parsedTime.minute,
                                                              //       );
                                                              //       print("slotDateTime ----> $slotDateTime");
                                                              //     } else {
                                                              //       slotDateTime = date;
                                                              //     }
                                                              //
                                                              //     // ⛔ Restrict if less than 24 hours remain
                                                              //     final difference = slotDateTime!.difference(now).inHours;
                                                              //     if (difference < 24) {
                                                              //       // Constants.showError("You can’t edit or delete a slot within 24 hours of its time.");
                                                              //       ScaffoldMessenger.of(context).showSnackBar(
                                                              //         SnackBar(
                                                              //           content: Text(
                                                              //             "You can’t edit or delete a slot within 24 hours of its time.",
                                                              //             style: TextStyles.textStyle6_1,
                                                              //           ),
                                                              //           backgroundColor: ColorCodes.colorRed2,
                                                              //           duration: const Duration(seconds: 3),
                                                              //         ),
                                                              //       );
                                                              //       print("You can’t edit or delete a slot within 24 hours of its time.");
                                                              //       return false;
                                                              //     }
                                                              //   } catch (e) {
                                                              //     print("Time parse error: $e");
                                                              //     Constants.showError("Invalid slot time. Cannot edit/delete.");
                                                              //     return false;
                                                              //   }*/
                                                              //   try {
                                                              //     final now = DateTime.now();
                                                              //
                                                              //     // Parse date from dateKey
                                                              //     final date = DateTime.parse(data.dateKey ?? '');
                                                              //
                                                              //     // Combine date with slot time if available, else use default 00:00
                                                              //     DateTime slotDateTime;
                                                              //     if (slot.start != null && slot.start!.isNotEmpty) {
                                                              //       // Normalize "10:00AM" → "10:00 AM"
                                                              //       String normalizedTime = slot.start!.replaceAllMapped(
                                                              //         RegExp(r'(\d)(AM|PM)'),
                                                              //         (m) => '${m[1]} ${m[2]}',
                                                              //       );
                                                              //
                                                              //       // Parse "hh:mm a" time
                                                              //       final timeFormat = DateFormat("hh:mm a");
                                                              //       final parsedTime = timeFormat.parse(normalizedTime);
                                                              //
                                                              //       // Combine with date
                                                              //       slotDateTime = DateTime(
                                                              //         date.year,
                                                              //         date.month,
                                                              //         date.day,
                                                              //         parsedTime.hour,
                                                              //         parsedTime.minute,
                                                              //       );
                                                              //     } else {
                                                              //       slotDateTime = DateTime(date.year, date.month, date.day);
                                                              //     }
                                                              //
                                                              //     print("slotDateTime → $slotDateTime");
                                                              //     print("now → $now");
                                                              //
                                                              //     // ✅ If slot date is same day or next day → block
                                                              //     final dayDifference = slotDateTime.difference(now).inDays;
                                                              //     // if (dayDifference < 2) {
                                                              //     if (slotDateTime.difference(now).inHours < 24) {
                                                              //       ScaffoldMessenger.of(context).showSnackBar(
                                                              //         SnackBar(
                                                              //           content: Text(
                                                              //             "You can’t edit or delete a slot within 24 hours of its date.",
                                                              //             style: TextStyles.textStyle6_1,
                                                              //           ),
                                                              //           backgroundColor: ColorCodes.colorRed2,
                                                              //           duration: const Duration(seconds: 3),
                                                              //         ),
                                                              //       );
                                                              //       print("Blocked: Less than 24 hours remain (dayDifference = $dayDifference)");
                                                              //       return false;
                                                              //     }
                                                              //   } catch (e) {
                                                              //     print("Time parse error: $e");
                                                              //     Constants.showError("Invalid slot time. Cannot edit/delete.");
                                                              //     return false;
                                                              //   }
                                                              //
                                                              //   // 👉 Normal swipe logic
                                                              //   if (direction == DismissDirection.startToEnd) {
                                                              //     // EDIT
                                                              //     print(
                                                              //       'EDIT → dateIndex=$dateIndex, slotIndex=$slotIndex '
                                                              //       '(${isMorning ? "Morning" : "Afternoon"})',
                                                              //     );
                                                              //     Get.to(
                                                              //       () => EditMorningTimeSlotScreen(),
                                                              //       arguments: {
                                                              //         "editDate": data.dateKey,
                                                              //         "editSlot": slot,
                                                              //         "index": slotIndex,
                                                              //         "dateIndex": dateIndex,
                                                              //         "isMorning": isMorning,
                                                              //       },
                                                              //     );
                                                              //     return false; // keep tile
                                                              //   } else {
                                                              //     // DELETE
                                                              //     final ok = await _confirm(context, 'Delete this time slot?');
                                                              //     if (ok == true) {
                                                              //       return true; // allow deletion
                                                              //     }
                                                              //     return false;
                                                              //   }
                                                              // },
                                                              /*confirmDismiss: (direction) async {
                                                      if (direction == DismissDirection.startToEnd) {
                                                        // 👉 EDIT tapped
                                                        print('EDIT → dateIndex=$dateIndex, slotIndex=$slotIndex '
                                                            '(${isMorning ? "Morning" : "Afternoon"})');
                                                        Get.to(
                                                              () => EditMorningTimeSlotScreen(),
                                                          arguments: {
                                                            "editDate": data.dateKey,
                                                            "editSlot": slot,
                                                            "index": slotIndex,         // inner index
                                                            "dateIndex": dateIndex,     // outer index (if you want it)
                                                            "isMorning": isMorning,
                                                          },
                                                        );
                                                        return false; // keep tile
                                                      }
                                                      else {
                                                        // 👉 DELETE tapped
                                                        final ok = await _confirm(context, 'Delete this time slot?');
                                                        if (ok == true) {
                                                          // Do the actual deletion in onDismissed (recommended),
                                                          // or here if you must — but then return true to animate.
                                                          return true;
                                                        }
                                                        return false;
                                                      }
                                                    },*/
                                                              onDismissed: (direction) {
                                                                // Now we know EXACTLY which date + which slot was swiped
                                                                print(
                                                                  'DELETE → dateIndex=$dateIndex, slotIndex=$slotIndex '
                                                                  '(${isMorning ? "Morning" : "Afternoon"})',
                                                                );
                                                                // remove the slot from your model so the builder no longer renders it
                                                                controller.removeSlotAt(data.dateKey!, slot.id);

                                                                // if that date has no slots left, also remove the date group
                                                                controller.removeDateIfEmpty(data.dateKey!);
                                                                Constants.showSuccess('Slot Deleted');
                                                                // controller.deleteSpecificSlot(data.dateKey!, slotIndex);
                                                              },
                                                              child: Card(
                                                                elevation: 0,
                                                                color: Colors.white,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(40),
                                                                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                                  child: Row(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius: 28,
                                                                        backgroundColor: isMorning ? ColorCodes.colorYellow2 : ColorCodes.colorBlue3,
                                                                        child: Image.asset(
                                                                          isMorning ? 'assets/ic_sun.png' : 'assets/ic_moon.png',
                                                                          width: 40,
                                                                          height: 40,
                                                                          fit: BoxFit.contain,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 15),
                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            isMorning ? "Morning Timing" : "Afternoon Times",
                                                                            style: TextStyles.textStyle5_1,
                                                                          ),
                                                                          const SizedBox(height: 4),
                                                                          Row(
                                                                            children: [
                                                                              Text(slot.start ?? '', style: TextStyles.textStyle4_3),
                                                                              const SizedBox(width: 8),
                                                                              const Icon(Icons.arrow_forward, size: 18, color: ColorCodes.colorGrey1),
                                                                              const SizedBox(width: 8),
                                                                              Text(slot.end ?? '', style: TextStyles.textStyle4_3),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                  ),
                                                ],
                                              );
                                            },

                                            /*itemBuilder: (context, index) {
                                      final data = filteredList[index];

                                      return Dismissible(
                                        key: ValueKey(data.dateKey.toString() + index.toString()),
                                        background: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          color: Colors.blue.shade100,
                                          child: const Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.blue, size: 26),
                                              SizedBox(width: 8),
                                              Text("Edit", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          color: Colors.red.shade100,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                              SizedBox(width: 8),
                                              Icon(Icons.delete, color: Colors.red, size: 26),
                                            ],
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          if (direction == DismissDirection.startToEnd) {
                                            // 👉 Swipe Right → Edit
                                            Get.to(() => AddTimeScreen(), arguments: {"editData": data});
                                            return false; // don’t remove from list
                                          } else if (direction == DismissDirection.endToStart) {
                                            // 👉 Swipe Left → Delete
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    title: const Text("Delete Slot?"),
                                                    content: const Text("Are you sure you want to delete this time slot?"),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                                                    ],
                                                  ),
                                            );

                                            if (confirm == true) {
                                              controller.deleteDateSlot(data); // 🧠 call delete logic from your controller
                                              return true; // remove from UI
                                            }
                                            return false;
                                          }
                                          return false;
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // 🗓 Date Header
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "${DateFormat('EEEE d').format(DateTime.parse(data.dateKey ?? ''))}",
                                                style: TextStyles.textStyle4_3,
                                              ),
                                            ),

                                            // ⏰ Time Slot Cards (your same design)
                                            Column(
                                              children:
                                                  data.slots!.asMap().entries.map((entry) {
                                                    final slotIndex = entry.key;
                                                    final slot = entry.value;
                                                    final isMorning = slotIndex == 0;

                                                    return Padding(
                                                      padding: const EdgeInsets.only(bottom: 10),
                                                      child: Dismissible(
                                                        key: ValueKey("${data.dateKey}-${slotIndex}"),
                                                        direction: DismissDirection.horizontal,
                                                        background: Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade100,
                                                            borderRadius: BorderRadius.circular(40),
                                                          ),
                                                          alignment: Alignment.centerLeft,
                                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                                          child: const Row(
                                                            children: [
                                                              Icon(Icons.edit, color: ColorCodes.colorBlue1, size: 24),
                                                              SizedBox(width: 8),
                                                              Text("Edit", style: TextStyles.textStyle4_2),
                                                            ],
                                                          ),
                                                        ),
                                                        secondaryBackground: Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.red.shade100,
                                                            borderRadius: BorderRadius.circular(40),
                                                          ),
                                                          alignment: Alignment.centerRight,
                                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                                          child: const Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text("Delete", style: TextStyles.textStyle4_4),
                                                              SizedBox(width: 8),
                                                              Icon(Icons.delete, color: ColorCodes.colorRed1, size: 24),
                                                            ],
                                                          ),
                                                        ),
                                                        confirmDismiss: (direction) async {
                                                          print('slotIndex ----------------------> $slotIndex');
                                                          if (direction == DismissDirection.startToEnd) {
                                                            // 👉 Swipe right → Edit slot
                                                            Get.to(() => EditMorningTimeSlotScreen(), arguments: {"editDate": data.dateKey, "editSlot": slot});
                                                            return false; // don't auto-remove
                                                          } else if (direction == DismissDirection.endToStart) {
                                                            // 👉 Swipe left → Delete slot
                                                            final confirm = await showDialog<bool>(
                                                              context: context,
                                                              builder:
                                                                  (context) => AlertDialog(
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                    title: const Text("Delete Slot?", style: TextStyles.textStyle3,),
                                                                    content: const Text("Are you sure you want to delete this time slot?", style: TextStyles.textStyle4_5),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(context, false),
                                                                        child: const Text("Cancel", style: TextStyles.textStyle4_3,),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () => Navigator.pop(context, true),
                                                                        child: const Text("Delete", style: TextStyles.textStyle4_4,),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            );

                                                            if (confirm == true) {
                                                              controller.deleteSpecificSlot(data.dateKey!, slotIndex);
                                                              return true; // allow remove animation
                                                            }
                                                            return false;
                                                          }
                                                          return false;
                                                        },
                                                        child: Card(
                                                          elevation: 0,
                                                          color: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(40),
                                                            side: BorderSide(color: Colors.grey.shade300, width: 1),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                            child: Row(
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 28,
                                                                  backgroundColor: isMorning ? ColorCodes.colorYellow2 : ColorCodes.colorBlue3,
                                                                  child: Image.asset(
                                                                    isMorning ? 'assets/ic_sun.png' : 'assets/ic_moon.png',
                                                                    width: 40,
                                                                    height: 40,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 15),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      isMorning ? "Morning Timing" : "Afternoon Times",
                                                                      style: TextStyles.textStyle5_1,
                                                                    ),
                                                                    const SizedBox(height: 4),
                                                                    Row(
                                                                      children: [
                                                                        Text("${slot.start ?? ''}", style: TextStyles.textStyle4_3),
                                                                        const SizedBox(width: 8),
                                                                        const Icon(Icons.arrow_forward, size: 18, color: ColorCodes.colorGrey1),
                                                                        const SizedBox(width: 8),
                                                                        Text("${slot.end ?? ''}", style: TextStyles.textStyle4_3),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),

                                            // Column(
                                            //   children: data.slots!.asMap().entries.map((entry) {
                                            //     final slotIndex = entry.key;
                                            //     final slot = entry.value;
                                            //     final isMorning = slotIndex == 0;
                                            //
                                            //     return Padding(
                                            //       padding: const EdgeInsets.only(bottom: 10),
                                            //       child: Card(
                                            //         elevation: 0,
                                            //         color: Colors.white,
                                            //         shape: RoundedRectangleBorder(
                                            //           borderRadius: BorderRadius.circular(40),
                                            //           side: BorderSide(color: Colors.grey.shade300, width: 1),
                                            //         ),
                                            //         child: Padding(
                                            //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                            //           child: Row(
                                            //             children: [
                                            //               CircleAvatar(
                                            //                 radius: 28,
                                            //                 backgroundColor: isMorning
                                            //                     ? ColorCodes.colorYellow2
                                            //                     : ColorCodes.colorBlue3,
                                            //                 child: Image.asset(
                                            //                   isMorning ? 'assets/ic_sun.png' : 'assets/ic_moon.png',
                                            //                   width: 40,
                                            //                   height: 40,
                                            //                   fit: BoxFit.contain,
                                            //                 ),
                                            //               ),
                                            //               const SizedBox(width: 15),
                                            //               Column(
                                            //                 crossAxisAlignment: CrossAxisAlignment.start,
                                            //                 children: [
                                            //                   Text(
                                            //                     isMorning ? "Morning Timing" : "Afternoon Times",
                                            //                     style: TextStyles.textStyle5_1,
                                            //                   ),
                                            //                   const SizedBox(height: 4),
                                            //                   Row(
                                            //                     children: [
                                            //                       Text("${slot.start ?? ''}", style: TextStyles.textStyle4_3),
                                            //                       const SizedBox(width: 8),
                                            //                       const Icon(Icons.arrow_forward, size: 18, color: ColorCodes.colorGrey1),
                                            //                       const SizedBox(width: 8),
                                            //                       Text("${slot.end ?? ''}", style: TextStyles.textStyle4_3),
                                            //                     ],
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ],
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     );
                                            //   }).toList(),
                                            // ),
                                          ],
                                        ),
                                      );
                                    },*/

                                            /*itemBuilder: (context, index) {
                                      final data = filteredList[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 🗓 Date Header
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                              "${DateFormat('EEEE d').format(DateTime.parse(data.dateKey ?? ''))}",
                                              style: TextStyles.textStyle4_3,
                                            ),
                                          ),
                                          // ⏰ Time Slot Cards
                                          Column(
                                            children: data.slots!.asMap().entries.map((entry) {
                                              final slotIndex = entry.key;
                                              final slot = entry.value;
                                              final isMorning = slotIndex == 0;

                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Card(
                                                  elevation: 0,
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(40),
                                                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 28,
                                                          backgroundColor: isMorning
                                                              ? ColorCodes.colorYellow2
                                                              : ColorCodes.colorBlue3,
                                                          child: Image.asset(
                                                            isMorning ? 'assets/ic_sun.png' : 'assets/ic_moon.png',
                                                            width: 40,
                                                            height: 40,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 15),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              isMorning ? "Morning Timing" : "Afternoon Times",
                                                              style: TextStyles.textStyle5_1,
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Row(
                                                              children: [
                                                                Text("${slot.start ?? ''}", style: TextStyles.textStyle4_3),
                                                                const SizedBox(width: 8),
                                                                const Icon(Icons.arrow_forward, size: 18, color: ColorCodes.colorGrey1),
                                                                const SizedBox(width: 8),
                                                                Text("${slot.end ?? ''}", style: TextStyles.textStyle4_3),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      );
                                    },*/
                                          ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Obx(() {
                return controller.allDatesList.isEmpty
                    ? FloatingActionButton(
                      heroTag: "main",
                      shape: const CircleBorder(),
                      backgroundColor: ColorCodes.colorBlue1,
                      child: const Icon(Icons.add, color: ColorCodes.white),
                      onPressed: () => Get.to(() => AddTimeScreen()),
                    )
                    : const SizedBox.shrink(); // ✅ hide when list has data
              }),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          }),
        ),
      );
    });
  }

  Widget _editBg() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Colors.blue.shade100,
    child: const Row(
      children: [
        Icon(Icons.edit, color: Colors.blue),
        SizedBox(width: 8),
        Text("Edit", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _deleteBg() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Colors.red.shade100,
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
        SizedBox(width: 8),
        Icon(Icons.delete, color: Colors.red),
      ],
    ),
  );

  Widget _editSlotBg() => Container(
    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(40)),
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Row(children: [Icon(Icons.edit, color: ColorCodes.colorBlue1), SizedBox(width: 8), Text("Edit", style: TextStyles.textStyle4_2)]),
  );

  Widget _deleteSlotBg() => Container(
    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(40)),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Text("Delete", style: TextStyles.textStyle4_4), SizedBox(width: 8), Icon(Icons.delete, color: ColorCodes.colorRed1)],
    ),
  );

  Future<bool> _confirm(BuildContext context, String msg) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text("Confirm"),
                content: Text(msg),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                ],
              ),
        ) ??
        false;
  }

  String _formatDateSafe(String? key) {
    final dt = key == null ? null : DateTime.tryParse(key);
    return dt == null ? '' : DateFormat('EEEE d').format(dt);
  }

  void showDeleteDialog(String noteId, int index) {
    final controller = Get.find<CustomNotesController>();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ColorCodes.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/ic_delete_note.png', height: 160, width: 140),
              const SizedBox(height: 5),
              Text("Delete Note?", style: TextStyles.textStyle2_2.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Your note will be permanently deleted and cannot be recovered.", style: TextStyles.textStyle5_1, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: ColorCodes.colorRed2, width: 1)),
                    ),
                    onPressed: () {
                      // Get.back(); // just close dialog
                      Navigator.pop(context);
                    },
                    child: Text("Cancel", style: TextStyles.textStyle4_4.copyWith(color: ColorCodes.colorRed2)),
                  ),
                  // Delete Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.colorRed2,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // controller.deleteNoteAt(index); // delete note
                      controller.deleteNoteApi(noteId, context);
                      // Get.back(); // close dialog
                    },
                    child: Text("Delete", style: TextStyles.textStyle4_4.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ dispose
    super.dispose();
  }
}
