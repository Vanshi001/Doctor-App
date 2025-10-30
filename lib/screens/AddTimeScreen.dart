import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/TimeController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';
import 'AddEveningTimeScreen.dart';
import 'AddMorningTimeScreen.dart';

class AddTimeScreen extends StatefulWidget {
  const AddTimeScreen({super.key});

  @override
  State<AddTimeScreen> createState() => _AddTimeScreenState();
}

class _AddTimeScreenState extends State<AddTimeScreen> {
  final TimeController controller = Get.find<TimeController>();
  List<DateTime?> rangeDatePickerValue = [];

  late List<String> onlySelectedDates;

  @override
  void initState() {
    super.initState();
    controller.selectedMorningStartTime.value = "";
    controller.selectedMorningEndTime.value = "";
    controller.selectedEveningStartTime.value = "";
    controller.selectedEveningEndTime.value = "";
    // rangeDatePickerValue = [DateTime.now(), DateTime.now().add(const Duration(days: 6))];
    rangeDatePickerValue = [
      DateTime.now().add(const Duration(days: 1)), // start from tomorrow
      DateTime.now().add(const Duration(days: 7)),
    ]; // end 6 days after tomorrow
    onlySelectedDates = controller.getSelectedAllDates(rangeDatePickerValue);
    print("onlySelectedDates ------>>>>> $onlySelectedDates");
    controller.fetchDoctorDetailsApi();
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
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  buildRangeDatePickerWithValue(width),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Morning Times", style: TextStyles.textStyle2_1),
                        Obx(() {
                          final hasMorningTime =
                              controller.selectedMorningStartTime.value.isNotEmpty && controller.selectedMorningEndTime.value.isNotEmpty;

                          // hide '+' icon when morning time is set
                          return hasMorningTime
                              ? const SizedBox(width: 30) // empty space for alignment
                              : GestureDetector(
                                onTap: () async {
                                  await Get.to(() => const AddMorningTimeScreen());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Image.asset("assets/ic_add_time.png", height: 30, width: 30),
                                ),
                              );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(() {
                    final startTime = controller.selectedMorningStartTime.value;
                    final endTime = controller.selectedMorningEndTime.value;

                    if (startTime.isNotEmpty && endTime.isNotEmpty) {
                      return Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: ColorCodes.colorGrey4),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/ic_clock.png', height: 16, width: 16),
                                SizedBox(width: 8),
                                Text("$startTime - $endTime", style: TextStyles.textStyle4_3),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.clearMorningTime();
                              },
                              child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset('assets/ic_delete.png', height: 22, width: 22)),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  Padding(
                    padding: EdgeInsets.only(left: 15, top: 30, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Afternoon / Evening Times", style: TextStyles.textStyle2_1),
                        Obx(() {
                          final hasEveningTime =
                              controller.selectedEveningStartTime.value.isNotEmpty && controller.selectedEveningEndTime.value.isNotEmpty;

                          return hasEveningTime
                              ? const SizedBox(width: 30)
                              : GestureDetector(
                                onTap: () async {
                                  await Get.to(() => const AddEveningTimeScreen());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Image.asset("assets/ic_add_time.png", height: 30, width: 30),
                                ),
                              );
                        }),
                      ],
                    ),
                  ),
                  Obx(() {
                    final startTime = controller.selectedEveningStartTime.value;
                    final endTime = controller.selectedEveningEndTime.value;

                    if (startTime.isNotEmpty && endTime.isNotEmpty) {
                      return Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: ColorCodes.colorGrey4),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/ic_clock.png', height: 16, width: 16),
                                SizedBox(width: 8),
                                Text("$startTime - $endTime", style: TextStyles.textStyle4_3),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.clearEveningTime();
                              },
                              child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset('assets/ic_delete.png', height: 22, width: 22)),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  /* Container(
                    width: width,
                    height: 40,
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () async {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCodes.colorBlue1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      child: Text('Save', style: TextStyles.textStyle6_1.copyWith(color: Colors.white)),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: () async {
                    final mrngStartTime = controller.selectedMorningStartTime.value;
                    final mrngEndTime = controller.selectedMorningEndTime.value;

                    final eveStartTime = controller.selectedEveningStartTime.value;
                    final eveEndTime = controller.selectedEveningEndTime.value;
                    if (mrngStartTime.isNotEmpty && mrngEndTime.isNotEmpty && eveStartTime.isNotEmpty && eveEndTime.isNotEmpty) {
                      print('timing! ---> ${controller.doctorId}');
                      controller.addCustomDatesApi(controller.doctorId, onlySelectedDates);
                    } else {
                      print('Select timing!');
                      Constants.showError('Select timing!');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCodes.colorBlue1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child:
                      controller.isLoading.value
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: ColorCodes.white))
                          : Text('Save', style: TextStyles.textStyle6_1.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRangeDatePickerWithValue(double width) {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastAllowed = today.add(const Duration(days: 6)); // 7 days total

    final config = CalendarDatePicker2Config(
      firstDate: DateTime.now().add(const Duration(days: 1)),
      centerAlignModePicker: true,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: ColorCodes.colorBlue1,
      weekdayLabelTextStyle: TextStyles.textStyle4_3,
      controlsTextStyle: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
      dynamicCalendarRows: true,
      /*modePickerBuilder: ({
        required viewMode,
        required monthDate,
        isMonthPicker,
      }) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            */
      /*decoration: BoxDecoration(
              color: isMonthPicker == true ? Colors.red : Colors.teal[800],
              borderRadius: BorderRadius.circular(5),
            ),*/
      /*
            child: Text(
              isMonthPicker == true
                  ? getLocaleShortMonthFormat(const Locale('en'))
                  .format(monthDate)
                  : monthDate.year.toString(),
              style: TextStyles.textStyle4_3,
            ),
          ),
        );
      },
      weekdayLabelBuilder: ({required weekday, isScrollViewTopHeader}) {
        if (weekday == DateTime.wednesday) {
          return const Center(
            child: Text(
              'W',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return null;
      },
      disabledDayTextStyle:
      const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
      selectableDayPredicate: (day) {
        if (rangeDatePickerValue.isEmpty ||
            rangeDatePickerValue.length == 2) {
          // exclude Wednesday
          return day.weekday != DateTime.wednesday;
        } else {
          // Make sure range does not contain any Wednesday
          final firstDate = rangeDatePickerValue.first;
          final range = [firstDate!, day]..sort();
          for (var date = range.first;
          date.compareTo(range.last) <= 0;
          date = date.add(const Duration(days: 1))) {
            if (date.weekday == DateTime.wednesday) {
              return false;
            }
          }
        }
        return true;
      },*/
      selectableDayPredicate: (day) {
        final d = DateUtils.dateOnly(day);
        return (d.isAtSameMomentAs(today) || d.isAfter(today)) && (d.isAtSameMomentAs(lastAllowed) || d.isBefore(lastAllowed));
      },
      hideLastMonthIcon: true,
      hideNextMonthIcon: true,
    );
    return SizedBox(
      width: width,
      child: /*Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => CalendarDatePicker2(
            config: config,
            value: controller.selectedDates,
            onValueChanged: (dates) => controller.onDateChanged(dates),
          )),
          const SizedBox(height: 10),
          Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selected days: ', style: TextStyles.textStyle1),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  controller.getValueText(config.calendarType),
                  style: TextStyles.textStyle1,
                ),
              ),
            ],
          )),
          const SizedBox(height: 25),
        ],
      ),*/ Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarDatePicker2(
            config: config,
            value: rangeDatePickerValue,
            onValueChanged: (dates) {
              setState(() {
                rangeDatePickerValue = dates;
                onlySelectedDates = controller.getSelectedAllDates(rangeDatePickerValue);
                print("updated selectedDates ------>>>>> $onlySelectedDates");
              });
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selected days: ', style: TextStyles.textStyle1),
              const SizedBox(width: 2),
              Text(getValueText(config.calendarType, rangeDatePickerValue), style: TextStyles.textStyle1),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  String getValueText(CalendarDatePicker2Type datePickerType, List<DateTime?> values) {
    values = values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null).toString().replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty ? values.map((v) => v.toString().replaceAll('00:00:00.000', '')).join(', ') : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1 ? values[1].toString().replaceAll('00:00:00.000', '') : 'null';
        valueText = '$startDate to $endDate';
      } else {
        return 'null';
      }
    }

    return valueText;
  }
}
