import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';

class EditMorningTimeSlotScreen extends StatefulWidget {
  const EditMorningTimeSlotScreen({super.key});

  @override
  State<EditMorningTimeSlotScreen> createState() => _EditMorningTimeSlotScreenState();
}

class _EditMorningTimeSlotScreenState extends State<EditMorningTimeSlotScreen> {
  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}
