import 'package:Doctor/widgets/ColorCodes.dart';
import 'package:Doctor/widgets/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../controllers/CustomNotesController.dart';
import 'AddCustomNotesScreen.dart';
import 'EditCustomNotesScreen.dart';

class AllCustomNotesScreen extends StatefulWidget {
  const AllCustomNotesScreen({super.key});

  @override
  State<AllCustomNotesScreen> createState() => _AllCustomNotesScreenState();
}

class _AllCustomNotesScreenState extends State<AllCustomNotesScreen> {
  final CustomNotesController controller = Get.put(CustomNotesController());

  @override
  void initState() {
    controller.fetchNotesApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.white, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (controller.isDeleteMode.value || controller.isEditMode.value) {
              controller.isDeleteMode.value = false;
              controller.isEditMode.value = false; // 👈 reset both
              return false; // prevent default back action
            }
            return true; // allow screen pop
          },
          child: Scaffold(
            backgroundColor: ColorCodes.white,
            appBar: AppBar(
              title: Text("My Notes", style: TextStyles.textStyle2_1),
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
                  if (controller.isDeleteMode.value || controller.isEditMode.value) {
                    controller.isDeleteMode.value = false;
                    controller.isEditMode.value = false;
                  } else {
                    Navigator.pop(context); // normal back
                  }
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search Bar
                  TextField(
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyles.textStyle1,
                      prefixIcon: Icon(Icons.search, color: ColorCodes.colorBlack1),
                      // suffixIcon: Icon(Icons.mic, color: Colors.grey),
                      filled: true,
                      fillColor: ColorCodes.colorGrey3,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text("All Notes", style: TextStyles.textStyle2_1),

                  const SizedBox(height: 20),

                  // 👇 Notes List
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingNotes.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.notesList.isEmpty) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/ic_no_notes.png', height: 100, width: 100),
                              SizedBox(height: 20),
                              Text("No Notes Available", style: TextStyles.textStyle2),
                              SizedBox(height: 5),
                              Text(
                                "Add notes with relevant context or instructions. \nVisible under the prescribed medicine.",
                                style: TextStyles.textStyle5_1,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await controller.fetchNotesApi(); // 👈 call API again
                        },
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          itemCount: controller.notesList.length,
                          itemBuilder: (context, index) {
                            //return Obx(() {
                            final note = controller.notesList[index];

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Obx(
                                  () => Stack(
                                    children: [
                                      // Card takes full width of grid cell
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth),
                                        child: Card(
                                          elevation: 0.4,
                                          color: ColorCodes.white,
                                          shadowColor: ColorCodes.colorGrey1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(note.text, style: TextStyles.textStyle4_5, softWrap: true),
                                          ),
                                        ),
                                      ),

                                      // Delete button overlays card corner
                                      if (controller.isDeleteMode.value || controller.isEditMode.value)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () async {
                                              // controller.deleteNoteAt(index)
                                              if (controller.isDeleteMode.value) {
                                                showDeleteDialog(note.id, index);
                                              } else if (controller.isEditMode.value) {
                                                // controller.editNoteAt(index); // implement this in controller
                                                var result = await Get.to(() => EditCustomNotesScreen(existingNote: note.text, noteId: note.id));
                                                if (result == true) {
                                                  controller.fetchNotesApi();
                                                }
                                              }
                                              print('ITEM INDEX -- $index');
                                            },
                                            behavior: HitTestBehavior.translucent, // ✅ allows tapping on padded area
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 8, bottom: 8), // ✅ increases tap area
                                              decoration: BoxDecoration(shape: BoxShape.circle),
                                              child: CircleAvatar(
                                                radius: 10,
                                                backgroundColor: controller.isDeleteMode.value ? ColorCodes.colorRed2 : ColorCodes.colorGreen2,
                                                child: Icon(controller.isDeleteMode.value ? Icons.remove : Icons.edit, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                            //});
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Obx(() {
              final isOpen = controller.isOpen.value;

              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.bottomRight, // 👈 align to bottom-left
                  clipBehavior: Clip.none,
                  children: [
                    if (isOpen) ...[
                      Transform.translate(
                        offset: Offset(0, -70), // 👈 move left-up
                        child: FloatingActionButton(
                          shape: CircleBorder(),
                          heroTag: "add",
                          mini: true,
                          backgroundColor: ColorCodes.colorOrange1,
                          child: Image.asset('assets/ic_add_note.png', height: 22, width: 22),
                          onPressed: () async {
                            print("Add tapped");
                            controller.closeFab();
                            final result = await Get.to(() => AddCustomNotesScreen(), transition: Transition.rightToLeftWithFade);
                            if (result == true) {
                              controller.fetchNotesApi(); // 👈 refresh list
                            }
                            /*final newNote = await Get.to<String>(() => AddCustomNotesScreen(), transition: Transition.rightToLeftWithFade);

                            if (newNote != null && newNote.isNotEmpty) {
                              controller.addNote(newNote); // ✅ this triggers Obx rebuild
                            }*/
                          },
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-50, -50), // 👈 move more up-left
                        child: FloatingActionButton(
                          heroTag: "delete",
                          shape: CircleBorder(),
                          mini: true,
                          backgroundColor: ColorCodes.colorRed2,
                          child: Image.asset('assets/ic_trash_white.png', height: 22, width: 22),
                          onPressed: () {
                            print("Delete tapped");
                            controller.closeFab();
                            controller.toggleDeleteMode();
                          },
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-70, 0),
                        child: FloatingActionButton(
                          heroTag: "edit",
                          shape: CircleBorder(),
                          mini: true,
                          backgroundColor: ColorCodes.colorGreen2,
                          child: Image.asset('assets/ic_edit_white.png', height: 22, width: 22),
                          onPressed: () {
                            print("Edit tapped");
                            controller.closeFab();
                            controller.toggleEditMode();
                          },
                        ),
                      ),
                    ],
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        heroTag: "main",
                        shape: CircleBorder(),
                        backgroundColor: ColorCodes.colorBlue1,
                        child: Icon(controller.isOpen.value ? Icons.close_rounded : Icons.add, color: ColorCodes.white),
                        onPressed: controller.toggleFab,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(String noteId, int index) {
    final controller = Get.find<CustomNotesController>();

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ColorCodes.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/ic_delete_note.png', height: 160, width: 140),
              const SizedBox(height: 5),
              Text("Delete Note?", style: TextStyles.textStyle2_2.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Your note will be permanently deleted and cannot be recovered.", style: TextStyles.textStyle5_1, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: ColorCodes.colorRed2, width: 1)),
                    ),
                    onPressed: () {
                      // Get.back(); // just close dialog
                      Navigator.pop(context);
                    },
                    child: Text("Cancel", style: TextStyles.textStyle4_4.copyWith(color: ColorCodes.colorRed2)),
                  ),
                  // Delete Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.colorRed2,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // controller.deleteNoteAt(index); // delete note
                      controller.deleteNoteApi(noteId, context);
                      // Get.back(); // close dialog
                    },
                    child: Text("Delete", style: TextStyles.textStyle4_4.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
