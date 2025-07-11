import 'package:Doctor/screens/AuthScreen.dart';
import 'package:Doctor/screens/DoctorDetailsScreen.dart';
import 'package:Doctor/screens/UpcomingSchedulesScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/main/MainController.dart';
import '../model/appointment_item.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/Slider.dart';
import '../widgets/TextStyles.dart';
import 'AppointmentsScreen.dart';
import 'EditProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MainController mainController = Get.put(MainController());

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

  @override
  void initState() {
    super.initState();
    getDoctorDetails();
    mainController.fetchAppointmentsApi();
    mainController.fetchTodayAppointmentsApi(mainController.currentDate.value);
  }

  String? doctorName;

  void getDoctorDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    doctorName = prefs.getString('doctor_name');
    print('currentDate -- ${mainController.currentDate.value}');
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

    final List<String> imageUrls = ['assets/ic_profile.png', 'assets/ic_profile.png', 'assets/ic_profile.png'];

    final List<Map<String, String>> sliderData = [
      {
        'image': 'https://via.placeholder.com/150',
        'title': 'Dermatics India',
        'subtitle': 'Under Eye, Pigmentation',
        'date': '22 May 2025',
        'time': '12:30 - 13:00 pm',
      },
      {
        'image': 'https://via.placeholder.com/150/0000FF',
        'title': 'Glow Clinic',
        'subtitle': 'Acne Treatment',
        'date': '23 May 2025',
        'time': '14:00 - 14:30 pm',
      },
      {
        'image': 'https://via.placeholder.com/150/FF0000',
        'title': 'SkinCare Hub',
        'subtitle': 'Laser Therapy',
        'date': '25 May 2025',
        'time': '10:00 - 10:30 am',
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: ColorCodes.white,
          /*drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: ColorCodes.darkPurple),
                  child: Text('Welcome, Doctor', style: TextStyles.buttonNameStyle.copyWith(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Doctor's Detail"),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => DoctorDetailsScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit_note),
                  title: Text("Edit Profile"),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => EditProfileScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),*/
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20, 10, 10),
                child: Row(
                  children: [
                    Image.asset("assets/ic_profile.png", height: 45, width: 45),
                    SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello', style: TextStyles.textStyle1),
                          Text(
                            (doctorName != null && doctorName!.isNotEmpty) ? doctorName! : 'Dr. Dermatics',
                            style: TextStyles.textStyle2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                                    child: Text('Cancel', style: TextStyles.textStyle4_3),
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
              GestureDetector(
                onTap:
                    () => {
                      // Get.to(() => ShowShopByCategoryScreen(title: 'Products', data: 'search'))
                    },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: ColorCodes.colorGrey4, width: 1),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/ic_search.png', height: 20, width: 20),
                      SizedBox(width: 10),
                      Expanded(child: Text("Search", style: TextStyles.textStyle5_1)),
                      // Image.asset('assets/ic_vertical_line.png', height: 20, width: 20),
                      // Image.asset('assets/ic_microphone.png', height: 20, width: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Schedule (6)", style: TextStyles.textStyle3),
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
                child: CarouselSlider(
                  items:
                      imageUrls.map((url) {
                        return Container(
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(url, height: 50, width: 50, fit: BoxFit.cover),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Dermatics India", style: TextStyles.textStyle6_1),
                                          SizedBox(height: 2),
                                          SizedBox(
                                            width: width / 3,
                                            child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey4),
                                          ),
                                          SizedBox(height: 2),
                                          Text("Under Eye, Pigmentation", style: TextStyles.textStyle5_2, overflow: TextOverflow.ellipsis),
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
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                                    Text('22 May 2025', style: TextStyles.textStyle4),
                                    Image.asset('assets/ic_vertical_line.png', height: 20, width: 20),
                                    Image.asset('assets/ic_clock.png', width: 12, height: 12),
                                    SizedBox(width: 2),
                                    Text('12:30 - 13:00 pm', style: TextStyles.textStyle4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  options: CarouselOptions(autoPlay: true, aspectRatio: 2.8, height: 150, enlargeCenterPage: true, viewportFraction: 0.75),
                ),
              ),
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
                        Get.to(() => AppointmentsScreen());
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  return mainController.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: ColorCodes.colorBlack1))
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        itemCount: 5,
                        // itemCount: mainController.appointmentList.length,
                        itemBuilder: (context, index) {
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
                                      Image.asset('assets/ic_profile.png', height: 65, width: 65),
                                      Positioned(
                                        top: 0,
                                        right: 4,
                                        child: Container(
                                          height: 12,
                                          width: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.red, // dot color
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
                                          Text("Dermatics India", style: TextStyles.textStyle3),
                                          SizedBox(height: 2),
                                          SizedBox(
                                            width: width / 3,
                                            child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1),
                                          ),
                                          SizedBox(height: 2),
                                          Text("Under Eye, Pigmentation", style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Image.asset('assets/ic_calendar.png', width: 12, height: 12),
                                              SizedBox(width: 3),
                                              Text('22 May 2025', style: TextStyles.textStyle4_1),
                                              SizedBox(width: 8),
                                              Image.asset('assets/ic_clock.png', width: 12, height: 12),
                                              SizedBox(width: 3),
                                              Text('12:30 - 13:00 pm', style: TextStyles.textStyle4_1),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 40, height: 40, child: Image.asset('assets/ic_document.png')),
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
      ),
    );
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access_token", '');
    Constants.showSuccess('Logout Successfully!');
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
