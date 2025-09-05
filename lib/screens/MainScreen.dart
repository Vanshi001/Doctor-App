import 'dart:convert';

import 'package:Doctor/controllers/auth/LoginController.dart';
import 'package:Doctor/main.dart';
import 'package:Doctor/model/DoctorProfileResponse.dart';
import 'package:Doctor/screens/AddPendingMedicinesScreen.dart';
import 'package:Doctor/screens/AllPendingMedicineUserListScreen.dart';
import 'package:Doctor/screens/AuthScreen.dart';
import 'package:Doctor/screens/DoctorDetailsScreen.dart';
import 'package:Doctor/screens/UpcomingSchedulesScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../controllers/AppointmentsController.dart';
import '../controllers/NetworkController.dart';
import '../controllers/PermissionController.dart';
import '../controllers/UpdateController.dart';
import '../controllers/auth/AuthController.dart';
import '../controllers/main/MainController.dart';
import '../model/appointment_item.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/Slider.dart';
import '../widgets/TextStyles.dart';
import 'AppointmentsScreen.dart';
import 'EditProfileScreen.dart';
import 'IndividualUpcomingScheduleScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MainController mainController = Get.put(MainController());
  final AppointmentsController appointmentsController = Get.put(AppointmentsController());

  final List<String> images = ['assets/ic_arrow_right.png', 'assets/ic_calendar.png', 'assets/ic_document.png', 'assets/ic_profile.png'];

  final List<Map<String, String>> items = [
    {
      'image': 'assets/ic_profile.png',
      'title': 'Dermatics India',
      'subtitle': 'Under Eye, Pigmentation',
      'date': '22 May 2025',
      'time': '12:30 - 13:00 pm',
    },
  ];

  final GlobalKey _pointerKey = GlobalKey();
  bool _dragOverMap = false;

  _checkDrag(Offset position, bool up) {
    if (!up) {
      // find your widget
      RenderBox box = _pointerKey.currentContext!.findRenderObject() as RenderBox;

      //get offset
      Offset boxOffset = box.localToGlobal(Offset.zero);

      // check if your pointerdown event is inside the widget (you could do the same for the width, in this case I just used the height)
      if (position.dy > boxOffset.dy && position.dy < boxOffset.dy + box.size.height) {
        setState(() {
          _dragOverMap = true;
        });
      }
    } else {
      setState(() {
        _dragOverMap = false;
      });
    }
  }

  final PermissionController permissionController = Get.put(PermissionController());

  final NetworkController networkController = Get.put(NetworkController());
  final UpdateController updateController = Get.put(UpdateController());

  @override
  void initState() {
    super.initState();

    // getDoctorDetails();
    // mainController.fetchAppointmentsApi();
    // permissionController.requestAllPermissions();
    networkController.checkActiveInternetConnection();

    if (networkController.hasConnection) {
      mainController.fetchDoctorDetailsApi();
      getDoctorDetails();
    } else {
      Constants.noInternetError();
    }

    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        networkController.connectionStatus.value = Constants.connected;
        print('networkController.connectionStatus.value ---- ${networkController.connectionStatus.value}');
        mainController.fetchDoctorDetailsApi();
        getDoctorDetails();
      } else {
        networkController.connectionStatus.value = Constants.notConnected;
        print('networkController.connectionStatus.value --==-- ${networkController.connectionStatus.value}');
        Constants.noInternetError();
      }
    });

    updateController.checkAppUpdate().then((_) {
      if (updateController.isUpdateAvailable.value) {
        _showUpdateDialog(updateController);
      }
    });
    // mainController.startAutoFetch();
    // checkAppVersion(context);
  }

  void _showUpdateDialog(UpdateController controller) {
    Get.defaultDialog(
      title: "Update Available",
      titleStyle: TextStyles.textStyle4_3,
      titlePadding: const EdgeInsets.only(top: 20),
      middleText: controller.releaseNotes.value,
      middleTextStyle: TextStyles.textStyle1,
      backgroundColor: ColorCodes.white,
      barrierDismissible: false,
      onWillPop: () async => false,
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorCodes.colorBlue1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        onPressed: () => controller.launchUpdate(),
        child: Text("Update Now", style: TextStyles.textStyle6_1),
      ),
      actions: [
        Padding(padding: EdgeInsets.only(bottom: 10)),
      ]
      /* cancel: controller.forceUpdate.value
          ? null
          : ElevatedButton(
        onPressed: () => Get.back(),
        child: Text("Later"),
      ),*/
    );
  }

  Future<void> checkAppVersion(BuildContext context) async {
    final newVersion = NewVersionPlus(
      androidId: "com.dermatics.doctor_app", // your package name
      iOSId: "com.dermatics.doctor_app", // your app id on App Store
    );

    // Check version on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final status = await newVersion.getVersionStatus();
        if (status != null && status.canUpdate) {
          newVersion.showUpdateDialog(
            context: context,
            versionStatus: status,
            dialogTitle: "Update Available",
            dismissButtonText: "Later",
            updateButtonText: "Update",
            dialogText:
                "A new version ${status.storeVersion} is available. "
                "You are using ${status.localVersion}. Please update for the best experience.",
          );
        }
      } catch (e) {
        print("Version check failed: $e"); // prevent crash if 404
      }
    });
  }

  void getDoctorDetails() async {
    print('getDoctorDetails -- called');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var doctorId = prefs.getString('doctor_id');
    print('doctorId -- ${doctorId}');
    print('currentDate -- ${mainController.currentDate.value}');
    var token = prefs.getString("access_token");
    if (token != null && token.isNotEmpty) {
      mainController.fetchTodayAppointmentsApi(mainController.currentDate.value, doctorId);
      mainController.fetchPendingAppointmentsWithoutPrescriptionApi(doctorId);
      mainController.fetchAllAppointments(doctorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    List<Color> valuesDataColors = [Colors.purple, Colors.yellow, Colors.green, Colors.red, Colors.grey, Colors.blue];

    List<Widget> valuesWidget = [];
    for (int i = 0; i < valuesDataColors.length; i++) {
      valuesWidget.add(
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: valuesDataColors[i]),
          child: Align(alignment: Alignment.center, child: Text(i.toString(), style: const TextStyle(fontSize: 28))),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: ColorCodes.white,
          body: Obx(() {
            // 1) No internet
            if (networkController.connectionStatus.value == Constants.notConnected) {
              return _noInternetUI();
            }

            /*// 2) Any API loading? (add more flags if you have them)
            final bool isFetching =
                (appointmentsController.isLoading.value) ||
                (mainController.isLoading.value) ||
                (mainController.isLoadingAppointmentWithoutDescription.value);

            if (isFetching) {
              return const Center(child: CircularProgressIndicator());
            }

            // 3) After loading, check data
            final curr = appointmentsController.currentList; // RxList
            final all = mainController.allList; // RxList
            final pending = mainController.withoutDescriptionAppointmentResponse.value?.data ?? <dynamic>[];

            final bool isAllEmpty = curr.isEmpty && all.isEmpty && pending.isEmpty;

            if (isAllEmpty) {
              return emptyDashboardUI();
            }*/

            // 4) Otherwise show dashboard
            return dashboardUI(width, height);
          }),
        ),
      ),
    );
  }

  Widget _noInternetUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(15.0), child: Image.asset("assets/ic_no_internet.png", width: 205, height: 186)),
          const SizedBox(height: 20),
          Text("No Internet Connection", style: TextStyles.textStyle3),
          const SizedBox(height: 10),
          Text("Please check your connection and try again.", style: TextStyles.textStyle5_1),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: ColorCodes.colorBlue1,
          //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          //   onPressed: () async {
          //     final connected =
          //     await InternetConnectionChecker.instance.hasConnection;
          //     if (connected) {
          //       networkController.connectionStatus.value = Constants.connected;
          //       mainController.fetchDoctorDetailsApi();
          //       getDoctorDetails();
          //     } else {
          //       Constants.noInternetError();
          //     }
          //   },
          //   child: const Text("Retry", style: TextStyle(color: Colors.white)),
          // ),
        ],
      ),
    );
  }

  Widget dashboardUI(double width, double height) {
    return Obx(() {
      // Collect data sources used to decide empty vs available
      final currCompleted = appointmentsController.currentList; // completed
      final todayAll = mainController.allList; // today's schedule
      final pendingList = mainController.withoutDescriptionAppointmentResponse.value?.data ?? <dynamic>[];

      final bool isAllEmpty = currCompleted.isEmpty && todayAll.isEmpty && pendingList.isEmpty;

      // If empty -> empty UI (inside dashboard)
      /*if (isAllEmpty) {
        print('isAllEmpty ---- $isAllEmpty');
        return emptyDashboardUI();
      }*/

      // Else -> show available data UI wrapped with refresh behavior
      return RefreshIndicator(
        onRefresh: () async {
          try {
            mainController.isLoading.value = true;
            if (networkController.connectionStatus.value == Constants.connected)
              mainController.fetchDoctorDetailsApi();
            else
              Constants.noInternetError();
            // await mainController.fetchTodayAppointmentsApi(mainController.currentDate.value, mainController.doctorId);
          } finally {
            mainController.isLoading.value = false;
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 10),
                child: Row(
                  children: [
                    // Image.asset("assets/ic_profile.png", height: 45, width: 45),
                    Obx(
                      () => Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorCodes.colorBlue1, // Background color for the circle
                          border: Border.all(color: ColorCodes.white, width: 3),
                        ),
                        child: Center(child: Text(mainController.getInitials(mainController.doctorName.value), style: TextStyles.textStyle6_1)),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello', style: TextStyles.textStyle1),
                            Text(
                              mainController.doctorName.value.isNotEmpty ? mainController.doctorName.value : 'Dr. Dermatics',
                              style: TextStyles.textStyle2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: ColorCodes.white,
                                title: Column(
                                  children: [
                                    Align(alignment: Alignment.topLeft, child: Text('Logout', style: TextStyles.textStyle2)),
                                    SizedBox(height: 10),
                                    Divider(height: 2, thickness: 1, color: ColorCodes.colorGrey4),
                                  ],
                                ),
                                content: Text('Are you sure you want to logout?', style: TextStyles.textStyle1),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context), // dismiss dialog
                                    child: Text(
                                      'C                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ancel',
                                      style: TextStyles.textStyle4_3,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      logout();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Logout', style: TextStyles.textStyle4_3),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Image.asset('assets/ic_arrow_right.png', height: 24, width: 24),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
              isAllEmpty ? SizedBox(height: height, child: emptyDashboardUI()) : availableDataUI(height, width),
            ],
          ),
        ),
      );
    });
  }

  Widget availableDataUI(double height, double width) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text("Today's Schedule (${mainController.allList.length})", style: TextStyles.textStyle3)),
              GestureDetector(
                child: Row(
                  children: [
                    Text('See all', style: TextStyles.textStyle4),
                    SizedBox(width: 4),
                    Image.asset("assets/ic_arrow_right.png", height: 12, width: 12),
                  ],
                ),
                onTap: () {
                  print("See all");
                  Get.to(() => UpcomingSchedulesScreen());
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          height: height / 5,
          child: Obx(() {
            final todayAppointments = mainController.allList;
            /*    mainController.todayAppointmentResponse.value?.data.where((appointment) {
                            final appointmentDate = DateTime.parse(appointment.appointmentDate.toString());
                            final now = DateTime.now();
                            return appointmentDate.year == now.year && appointmentDate.month == now.month && appointmentDate.day == now.day;
                          }).toList() ??
                          [];*/

            if (todayAppointments.isEmpty) {
              return Center(child: Text('No appointments for today', style: TextStyles.textStyle3));
            }

            final isMultiple = todayAppointments.length > 1;

            return CarouselSlider(
              items:
                  todayAppointments.map((appointment) {
                    final patientName = appointment.patientFullName ?? 'N/A';
                    final concerns = appointment.concerns?.join(", ");
                    final date = DateFormat('dd MMM yyyy').format(DateTime.parse(appointment.appointmentDate.toString()));
                    final startTime = appointment.timeSlot?.startTime;
                    final endTime = appointment.timeSlot?.endTime;

                    return GestureDetector(
                      onTap: () {
                        final id = appointment.id;
                        print('Tapped appointment ID: $id');
                        Get.to(() => IndividualUpcomingScheduleScreen(item: appointment, name: mainController.doctorName.value));
                      },
                      child: Container(
                        height: height / 5,
                        decoration: BoxDecoration(color: ColorCodes.colorBlue1, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 10, right: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: Image.network(
                                                'https://randomuser.me/api/portraits/women/1.jpg',
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                              // Image.asset(url, height: 50, width: 50, fit: BoxFit.cover),
                                            ),*/
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorCodes.colorBlack2, // Background color for the circle
                                      border: Border.all(color: ColorCodes.white, width: 3),
                                    ),
                                    child: Center(child: Text(mainController.getInitials(patientName), style: TextStyles.textStyle6_1)),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(patientName, style: TextStyles.textStyle6_1),
                                        SizedBox(height: 2),
                                        SizedBox(
                                          width: width / 3,
                                          child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey4),
                                        ),
                                        SizedBox(height: 2),
                                        Text(concerns.toString(), style: TextStyles.textStyle5_2, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 10),
                                    child: Image.asset('assets/ic_video_call2.png', height: 40, width: 40),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/ic_calendar.png', width: 12, height: 12),
                                  SizedBox(width: 2),
                                  Text(date, style: TextStyles.textStyle4),
                                  Image.asset('assets/ic_vertical_line.png', height: 20, width: 10),
                                  Image.asset('assets/ic_clock.png', width: 12, height: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    '${Constants.formatTimeToAmPm(startTime.toString())} - ${Constants.formatTimeToAmPm(endTime.toString())}',
                                    style: TextStyles.textStyle4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              options: CarouselOptions(
                autoPlay: isMultiple,
                aspectRatio: 2.8,
                height: 150,
                enableInfiniteScroll: isMultiple,
                enlargeCenterPage: isMultiple,
                viewportFraction: isMultiple ? 0.80 : 0.90,
              ),
            );
          }),
        ),
        Obx(() {
          final appointments = mainController.withoutDescriptionAppointmentResponse.value?.data;

          if (mainController.isLoadingAppointmentWithoutDescription.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appointments == null || appointments.isEmpty) {
            return const SizedBox(); // return empty widget (hides section)
          }

          // ✅ Show only when data is available
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pending Prescriptions", style: TextStyles.textStyle3),
                    GestureDetector(
                      child: Row(
                        children: [
                          Text('See all', style: TextStyles.textStyle4),
                          SizedBox(width: 4),
                          Image.asset("assets/ic_arrow_right.png", height: 12, width: 12),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => AllPendingMedicineUserListScreen());
                      },
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length > 2 ? 2 : appointments.length,
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
                              // profile circle with initials
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorCodes.colorBlack2,
                                      border: Border.all(color: ColorCodes.colorBlue1, width: 3),
                                    ),
                                    child: Center(child: Text(mainController.getInitials(patientName), style: TextStyles.textStyle4)),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 4,
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        color: ColorCodes.colorYellow1,
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
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(patientName, style: TextStyles.textStyle3),
                                      SizedBox(height: 2),
                                      SizedBox(
                                        width: width / 3,
                                        child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1),
                                      ),
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Appointments", style: TextStyles.textStyle3),
              GestureDetector(
                child: Row(
                  children: [
                    Text('See all', style: TextStyles.textStyle4),
                    SizedBox(width: 4),
                    Image.asset("assets/ic_arrow_right.png", height: 12, width: 12),
                  ],
                ),
                onTap: () {
                  print("See all");
                  Get.to(() => AppointmentsScreen(doctorId: mainController.doctorId));
                },
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
          child: Obx(() {
            final appointments = appointmentsController.currentList;

            // print("All appointments ----------- ==== $appointments");
            if (appointmentsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (appointments == null || appointments.isEmpty) {
              return const Center(child: Text("No completed appointments found", style: TextStyles.textStyle3));
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
                final status = appointment.status.toString();

                return Card(
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
                              child: Center(child: Text(mainController.getInitials(patientName), style: TextStyles.textStyle4)),
                            ),
                            Positioned(
                              top: 0,
                              right: 4,
                              child: Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  color: appointmentsController.getStatusColor(status),
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
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget emptyDashboardUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(padding: const EdgeInsets.only(left: 15, right: 15), child: Image.asset("assets/ic_no_data.png", width: 205, height: 186)),
        const SizedBox(height: 20),
        Text("No Appointments Yet", style: TextStyles.textStyle3),
        Container(
          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: Text(
            "You're all caught up. New appointments will show up here once patients book them.",
            style: TextStyles.textStyle5_1,
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  void logout() async {
    // final authController = Get.find<AuthController>();
    // authController.logout();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    print('while logout -> $token');
    prefs.setString("access_token", '');
    print('after logout -> ${prefs.getString('access_token')}');
    Constants.showSuccess('Logout Successfully!');
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    Get.offAll(() => AuthScreen());
  }

  Widget buildAppointmentCard(AppointmentItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorCodes.colorBlue1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(0, 6), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.network(item.image, height: 50, width: 50, fit: BoxFit.cover)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dermatics India", style: TextStyles.textStyle3.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text("Under Eye, Pigmentation...", style: TextStyles.textStyle5.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 36,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Image.asset('assets/ic_video_call.png', color: ColorCodes.colorBlue1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/ic_calendar.png', width: 16),
                const SizedBox(width: 4),
                Text(item.date, style: TextStyles.textStyle4),
                const SizedBox(width: 20),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 20),
                Image.asset('assets/ic_clock.png', width: 16),
                const SizedBox(width: 4),
                Text(item.time, style: TextStyles.textStyle4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
