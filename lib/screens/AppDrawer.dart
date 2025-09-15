import 'package:Doctor/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../controllers/main/MainController.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';
import 'AddCustomNotesScreen.dart';
import 'AuthScreen.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final MainController mainController = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Drawer(
      child: Container(
        color: ColorCodes.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: ColorCodes.colorBlue1),
              child: SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const CircleAvatar(radius: 30, backgroundColor: Colors.white),
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
                    const SizedBox(width: 10),
                    Obx(() =>
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: width * 0.5,
                          child: Text(
                            mainController.doctorName.value.isNotEmpty ? mainController.doctorName.value : 'Dr. Dermatics',
                            style: TextStyles.textStyle2_4,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: ColorCodes.black,),
              title: Text("Dashboard"),
              onTap: () {
                // Get.back(); // Close drawer
                Navigator.of(context).pop();
                Get.off(() => MainScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.notes, color: ColorCodes.black,),
              title: Text("Notes"),
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => AddCustomNotesScreen());
              },
            ),
            /*ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Get.to(() => YourSettingsScreen());
              },
            ),*/
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: ColorCodes.black),
              title: Text("Logout", style: TextStyles.textStyle4_3),
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
            ),
          ],
        ),
      ),
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
}
