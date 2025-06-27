import 'package:Doctor/screens/DoctorDetailsScreen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main/MainController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Slider.dart';
import '../widgets/TextStyles.dart';
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
      RenderBox box =
      _pointerKey.currentContext!.findRenderObject() as RenderBox;

      //get offset
      Offset boxOffset = box.localToGlobal(Offset.zero);

      // check if your pointerdown event is inside the widget (you could do the same for the width, in this case I just used the height)
      if (position.dy > boxOffset.dy &&
          position.dy < boxOffset.dy + box.size.height) {
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
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    List<Color> valuesDataColors = [
      Colors.purple,
      Colors.yellow,
      Colors.green,
      Colors.red,
      Colors.grey,
      Colors.blue,
    ];

    List<Widget> valuesWidget = [];
    for (int i = 0; i < valuesDataColors.length; i++) {
      valuesWidget.add(Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: valuesDataColors[i],
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              i.toString(),
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
          )));
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        extendBodyBehindAppBar: false,
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Doctor's App", style: TextStyles.buttonNameStyle),
          backgroundColor: ColorCodes.darkPurple,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_open, color: ColorCodes.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Open drawer
            },
          ),
        ),
        drawer: Drawer(
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
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Image.asset("assets/ic_profile.png", height: 45, width: 45),
                  SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello', style: TextStyles.textStyle1),
                        Text('Dr. Dermatics', style: TextStyles.textStyle2, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                key: _pointerKey,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CardSlider(
                  cards: valuesWidget,
                  bottomOffset: 0.005,
                  cardHeight: 0.5,
                  containerHeight: 220, // or MediaQuery.of(context).size.height * 0.3
                  itemDotOffset: 0.45,
                ),
              ),
            ),
            /*CardSlider(
              cards: valuesWidget,
              bottomOffset: .0003,
              cardHeight: 0.75,
            ),*/
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
                                // Image.asset('assets/ic_profile.png', height: 65, width: 65),
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
                                        Container(
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
    );
  }
}
