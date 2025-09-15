import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCustomNotesScreen extends StatefulWidget {
  const AddCustomNotesScreen({super.key});

  @override
  State<AddCustomNotesScreen> createState() => _AddCustomNotesScreenState();
}

class _AddCustomNotesScreenState extends State<AddCustomNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorCodes.white,
          appBar: AppBar(
            title: Text("Notes", style: TextStyles.textStyle2_1),
            backgroundColor: ColorCodes.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
