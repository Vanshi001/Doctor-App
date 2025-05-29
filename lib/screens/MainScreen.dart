import 'package:Doctor/screens/DoctorDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';
import 'EditProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
                  color: ColorCodes.darkPurple,
                ),
                child: Text(
                  'Welcome, Doctor',
                  style: TextStyles.buttonNameStyle.copyWith(color: Colors.white),
                ),
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
        body: Center(
          child: Text("Main Screen Body"),
        ),
      ),
    );
  }
}
