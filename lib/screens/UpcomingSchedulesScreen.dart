import 'package:Doctor/screens/IndividualUpcomingScheduleScreen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/UpcomingSchedulesController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';

class UpcomingSchedulesScreen extends StatefulWidget {
  const UpcomingSchedulesScreen({super.key});

  @override
  State<UpcomingSchedulesScreen> createState() => _UpcomingSchedulesScreenState();
}

class _UpcomingSchedulesScreenState extends State<UpcomingSchedulesScreen> {
  final UpcomingSchedulesController controller = Get.put(UpcomingSchedulesController());

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Upcoming Schedules", style: TextStyles.textStyle2_1),
          backgroundColor: ColorCodes.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            Divider(height: 2, thickness: 2, color: ColorCodes.colorGrey2),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:
                      TabType.values.map((tab) {
                        final isSelected = controller.selectedTab.value == tab;
                        return Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => controller.updateTab(tab),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  side: BorderSide(color: isSelected ? ColorCodes.colorBlue1 : ColorCodes.colorGrey4, width: 1.5),
                                ),
                                backgroundColor: isSelected ? ColorCodes.colorBlue1 : ColorCodes.white,
                                foregroundColor: isSelected ? ColorCodes.white : ColorCodes.black,
                                textStyle: isSelected ? TextStyles.textStyle6_1 : TextStyles.textStyle6,
                                elevation: 0,
                              ),
                              child: Text(tab.name.capitalizeFirst ?? ''),
                            ),
                            const SizedBox(width: 10),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),

            // List Display
            Expanded(
              child: Obx(() {
                final list = controller.currentList;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return GestureDetector(
                      onTap: () {
                        print("Clicked item: $index -- ${item.clinic}");
                        Get.to(() => IndividualUpcomingScheduleScreen(item: item));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorCodes.colorGrey4, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(item.image, height: 50, width: 50, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Dermatics India", style: TextStyles.textStyle3),
                                        SizedBox(height: 2),
                                        SizedBox(
                                          width: width / 3,
                                          child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1),
                                        ),
                                        SizedBox(height: 2),
                                        SizedBox(
                                          width: width / 3,
                                          child: Text("Under Eye, Pigmentation", style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40, height: 40, child: Image.asset('assets/ic_video_call.png')),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                                border: Border.all(color: ColorCodes.colorGrey4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/ic_calendar.png', width: 16, height: 16),
                                  SizedBox(width: 5),
                                  Text('22 May 2025', style: TextStyles.textStyle4),
                                  SizedBox(width: 20),
                                  Image.asset('assets/ic_vertical_line.png', height: 30, width: 1),
                                  SizedBox(width: 20),
                                  Image.asset('assets/ic_clock.png', width: 16, height: 16),
                                  SizedBox(width: 5),
                                  Text('12:30 - 13:00 pm', style: TextStyles.textStyle4),
                                ],
                              ),
                            ),
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
