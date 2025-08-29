import 'package:Doctor/screens/IndividualUpcomingScheduleScreen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/UpcomingSchedulesController.dart';
import '../model/DoctorProfileResponse.dart';
import '../model/appointment_model.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';

class UpcomingSchedulesScreen extends StatefulWidget {
  const UpcomingSchedulesScreen({super.key});

  @override
  State<UpcomingSchedulesScreen> createState() => _UpcomingSchedulesScreenState();
}

class _UpcomingSchedulesScreenState extends State<UpcomingSchedulesScreen> {
  final UpcomingSchedulesController controller = Get.put(UpcomingSchedulesController());
  final ScrollController scrollController = ScrollController();
  RxList<Appointment> filteredList = RxList<Appointment>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchDoctorDetailsApi();
    controller.fetchAllUpComingAppointmentsApi();
    controller.fetchTodayUpComingAppointmentsApi(controller.todayDate.value);
    controller.fetchTomorrowUpComingAppointmentsApi(controller.tomorrowDate.value);

    filteredList.addAll(controller.currentList);
    _searchController.addListener(_filterAppointments);
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(controller.currentList);
    } else {
      filteredList.assignAll(controller.currentList.where((appointment) {
        return appointment.patientFullName.toString().toLowerCase().contains(query) ||
            appointment.concerns!.any((concern) => concern.toLowerCase().contains(query));
      }).toList());
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> handleRefresh() async {
    await controller.fetchAllUpComingAppointmentsApi();
    await controller.fetchTodayUpComingAppointmentsApi(controller.todayDate.value);
    await controller.fetchTomorrowUpComingAppointmentsApi(controller.tomorrowDate.value);
  }

  final TextEditingController editingController = TextEditingController();

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
              // Get.back();
              Navigator.pop(context);
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: handleRefresh,
          backgroundColor: ColorCodes.colorBlue1,
          color: ColorCodes.white,
          elevation: 3,
          child: CustomScrollView(
            controller: scrollController, // Assign the controller
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Divider(height: 2, thickness: 2, color: ColorCodes.colorGrey2),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
                      child: TextField(
                        controller: _searchController,
                        cursorColor: ColorCodes.colorBlack1,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyles.textStyle3,
                          prefixIcon: Padding(padding: EdgeInsets.all(12), child: Image.asset('assets/ic_search.png', height: 20, width: 20)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: ColorCodes.colorGrey4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: ColorCodes.colorGrey4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: ColorCodes.colorGrey4, width: 1),
                          ),
                        ),
                      ),
                    ),
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
                                      const SizedBox(width: 5),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: Obx(() {
                  final list = filteredList.reversed.toList(); //controller.currentList.reversed.toList();

                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (list.isEmpty) {
                    return Center(child: Text(controller.emptyMessage, style: TextStyles.textStyle3));
                  }

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // Disable inner ListView scrolling
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final parsedDate = DateTime.parse(item.appointmentDate.toString());
                      final formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => IndividualUpcomingScheduleScreen(item: item, name: controller.doctorDetail.value!.data!.name.toString()));
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
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 5, right: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.patientFullName.toString(), style: TextStyles.textStyle3),
                                          SizedBox(height: 2),
                                          SizedBox(
                                            width: width / 3,
                                            child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1),
                                          ),
                                          SizedBox(height: 2),
                                          SizedBox(
                                            width: width / 3,
                                            child: Text(
                                              item.concerns?.join(", ") ?? '',
                                              style: TextStyles.textStyle5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
                                    Text(formattedDate, style: TextStyles.textStyle4),
                                    SizedBox(width: 20),
                                    Image.asset('assets/ic_vertical_line.png', height: 30, width: 1),
                                    SizedBox(width: 20),
                                    Image.asset('assets/ic_clock.png', width: 16, height: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      '${Constants.formatTimeToAmPm(item.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(item.timeSlot?.endTime ?? '')}',
                                      style: TextStyles.textStyle4,
                                    ),
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
        // body: Column(
        //   children: [
        //     Divider(height: 2, thickness: 2, color: ColorCodes.colorGrey2),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Obx(
        //         () => SingleChildScrollView(
        //           scrollDirection: Axis.horizontal,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.start,
        //             children:
        //                 TabType.values.map((tab) {
        //                   final isSelected = controller.selectedTab.value == tab;
        //                   return Row(
        //                     children: [
        //                       ElevatedButton(
        //                         onPressed: () => controller.updateTab(tab),
        //                         style: ElevatedButton.styleFrom(
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(100),
        //                             side: BorderSide(color: isSelected ? ColorCodes.colorBlue1 : ColorCodes.colorGrey4, width: 1.5),
        //                           ),
        //                           backgroundColor: isSelected ? ColorCodes.colorBlue1 : ColorCodes.white,
        //                           foregroundColor: isSelected ? ColorCodes.white : ColorCodes.black,
        //                           textStyle: isSelected ? TextStyles.textStyle6_1 : TextStyles.textStyle6,
        //                           elevation: 0,
        //                         ),
        //                         child: Text(tab.name.capitalizeFirst ?? ''),
        //                       ),
        //                       const SizedBox(width: 5),
        //                     ],
        //                   );
        //                 }).toList(),
        //           ),
        //         ),
        //       ),
        //     ),
        //
        //     // List Display
        //     Expanded(
        //       child: Obx(() {
        //         final list = controller.currentList;
        //
        //         if (controller.isLoading.value) {
        //           // ✅ Show a loader when fetching
        //           return const Center(
        //             child: CircularProgressIndicator(),
        //           );
        //         }
        //
        //         if (list.isEmpty) {
        //           // ✅ Show empty text if no data AFTER loading
        //           return Center(
        //             child: Text(
        //               controller.emptyMessage,
        //               style: TextStyles.textStyle3,
        //             ),
        //           );
        //         }
        //
        //         return ListView.builder(
        //           itemCount: list.length,
        //           itemBuilder: (context, index) {
        //             final item = list[index];
        //             final parsedDate = DateTime.parse(item.appointmentDate.toString());
        //             final formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
        //
        //             return GestureDetector(
        //               onTap: () {
        //                 print("Clicked item: $index -- ${item.id}");
        //                 Get.to(() => IndividualUpcomingScheduleScreen(item: item, name: controller.doctorDetail.value!.data!.name.toString()));
        //               },
        //               child: Container(
        //                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        //                 padding: const EdgeInsets.all(12),
        //                 decoration: BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: BorderRadius.circular(20),
        //                   border: Border.all(color: ColorCodes.colorGrey4, width: 1.5),
        //                 ),
        //                 child: Column(
        //                   children: [
        //                     Row(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         // Profile Image
        //                         /*ClipRRect(
        //                           borderRadius: BorderRadius.circular(50),
        //                           child: Image.network('https://randomuser.me/api/portraits/women/1.jpg', height: 50, width: 50, fit: BoxFit.cover),
        //                         ),*/
        //                         Container(
        //                           height: 50,
        //                           width: 50,
        //                           decoration: BoxDecoration(
        //                             shape: BoxShape.circle,
        //                             color: ColorCodes.colorBlack2, // Background color for the circle
        //                             border: Border.all(color: ColorCodes.colorBlue1, width: 3),
        //                           ),
        //                           child: Center(child: Text(controller.getInitials(item.patientFullName.toString()), style: TextStyles.textStyle4)),
        //                         ),
        //                         const SizedBox(width: 5),
        //                         Expanded(
        //                           child: Container(
        //                             padding: EdgeInsets.only(left: 5, right: 5),
        //                             child: Column(
        //                               crossAxisAlignment: CrossAxisAlignment.start,
        //                               children: [
        //                                 Text(item.patientFullName.toString(), style: TextStyles.textStyle3),
        //                                 SizedBox(height: 2),
        //                                 SizedBox(
        //                                   width: width / 3,
        //                                   child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1),
        //                                 ),
        //                                 SizedBox(height: 2),
        //                                 SizedBox(
        //                                   width: width / 3,
        //                                   child: Text(item.concerns?.join(", ") ?? '', style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis),
        //                                 ),
        //                                 SizedBox(height: 5),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                         SizedBox(width: 40, height: 40, child: Image.asset('assets/ic_video_call.png')),
        //                       ],
        //                     ),
        //                     SizedBox(height: 10),
        //                     Container(
        //                       padding: EdgeInsets.all(10),
        //                       decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.all(Radius.circular(100)),
        //                         border: Border.all(color: ColorCodes.colorGrey4),
        //                       ),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         children: [
        //                           Image.asset('assets/ic_calendar.png', width: 16, height: 16),
        //                           SizedBox(width: 5),
        //                           Text(formattedDate, style: TextStyles.textStyle4),
        //                           SizedBox(width: 20),
        //                           Image.asset('assets/ic_vertical_line.png', height: 30, width: 1),
        //                           SizedBox(width: 20),
        //                           Image.asset('assets/ic_clock.png', width: 16, height: 16),
        //                           SizedBox(width: 5),
        //                           Text('${Constants.formatTimeToAmPm(item.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(item.timeSlot?.endTime ?? '')}', style: TextStyles.textStyle4),
        //                         ],
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             );
        //           },
        //         );
        //       }),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
