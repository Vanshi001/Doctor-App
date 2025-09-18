import 'package:Doctor/controllers/CustomNotesController.dart';
import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditCustomNotesScreen extends StatefulWidget {
  final String existingNote;
  final String noteId;

  EditCustomNotesScreen({super.key, required this.existingNote, required this.noteId});

  @override
  State<EditCustomNotesScreen> createState() => _EditCustomNotesScreenState();
}

class _EditCustomNotesScreenState extends State<EditCustomNotesScreen> with SingleTickerProviderStateMixin {
  final CustomNotesController controller = Get.put(CustomNotesController());

  @override
  void initState() {
    super.initState();
    controller.textController.text = widget.existingNote;
    controller.noteText.value = widget.existingNote;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            controller.clearText();
            return true;
          },
          child: Scaffold(
            backgroundColor: ColorCodes.white,
            appBar: AppBar(
              title: Text("Edit Note", style: TextStyles.textStyle2_1),
              backgroundColor: ColorCodes.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
                onPressed: () {
                  controller.clearText();
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(12),
              height: height / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(8),
                    color: ColorCodes.white,
                    shadowColor: Colors.black38,
                    child: TextField(
                      controller: controller.textController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: TextStyles.textStyle4_5,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        if (value.length <= controller.maxChars) {
                          controller.noteText.value = value;
                        } else {
                          controller.textController.text = value.substring(0, controller.maxChars);
                          controller.textController.selection = TextSelection.fromPosition(TextPosition(offset: controller.maxChars));
                        }
                      },
                      onSubmitted: (value) {
                        // ✅ hide keyboard when "Done" is pressed
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        hintText: "Write your note here...",
                        filled: true,
                        fillColor: ColorCodes.white,
                        contentPadding: const EdgeInsets.all(10),
                        // 👇 unified white border for all states
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white, width: 1.2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white, width: 1.2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white, width: 1.5),
                        ),
                        counterText: "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${controller.noteText.value.length}/${controller.maxChars}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Figtree',
                          color: controller.noteText.value.length >= controller.maxChars ? ColorCodes.colorRed1 : ColorCodes.colorGrey1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: SizedBox(
                height: 40,
                width: width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCodes.colorBlue1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 3,
                  ),
                  onPressed: () {
                    if (controller.noteText.value.trim().isNotEmpty) {
                      print('controller.noteText.value -- ${controller.noteText.value}');
                      print('widget.existingNote -- ${widget.existingNote}');
                      // controller.updateNoteAt(widget.noteId, controller.noteText.value.trim());
                      controller.updateNoteApi(widget.noteId, controller.noteText.value.trim(), context);
                    } else {
                      Get.snackbar("Error", "Please write something before saving the note");
                    }
                  },
                  child: Text("Save", style: TextStyles.textStyle6_1.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
