import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/CustomNotesController.dart';
import 'AddCustomNotesScreen.dart';

class AllCustomNotesScreen extends StatefulWidget {
  const AllCustomNotesScreen({super.key});

  @override
  State<AllCustomNotesScreen> createState() => _AllCustomNotesScreenState();
}

class _AllCustomNotesScreenState extends State<AllCustomNotesScreen> {
  final CustomNotesController controller = Get.put(CustomNotesController());

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorCodes.white,
          appBar: AppBar(
            title: Text("My Notes", style: TextStyles.textStyle2_1),
            backgroundColor: ColorCodes.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
            ),
          ),
          floatingActionButton: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isOpen.value) ...[
                  FloatingActionButton(
                    heroTag: "add",
                    mini: true,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add, color: ColorCodes.white),
                    onPressed: () {
                      print("Add tapped");
                      controller.closeFab();
                      Get.to(() => AddCustomNotesScreen());
                    },
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "edit",
                    mini: true,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.edit, color: ColorCodes.white),
                    onPressed: () {
                      print("Edit tapped");
                      controller.closeFab();
                    },
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "delete",
                    mini: true,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.delete, color: ColorCodes.white),
                    onPressed: () {
                      print("Delete tapped");
                      controller.closeFab();
                    },
                  ),
                  SizedBox(height: 10),
                ],
                FloatingActionButton(
                  heroTag: "main",
                  backgroundColor: ColorCodes.colorBlue1,
                  child: Icon(controller.isOpen.value ? Icons.close : Icons.add, color: ColorCodes.white),
                  onPressed: controller.toggleFab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
