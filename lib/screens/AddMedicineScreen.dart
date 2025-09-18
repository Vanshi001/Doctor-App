import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/AddPendingMedicineController.dart';
import '../model/NoteResponseModel.dart';
import '../model/ProductModel.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';
import 'package:get/get.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final controller = Get.put(AddPendingMedicineController());

  @override
  void initState() {
    controller.selectedNotes.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ColorCodes.colorBlue1, statusBarIconBrightness: Brightness.light),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ColorCodes.white,
          appBar: AppBar(
            title: Text("Add Medicine", style: TextStyles.textStyle2_1),
            backgroundColor: ColorCodes.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return Expanded(child: Center(child: CircularProgressIndicator(color: ColorCodes.colorBlue1, backgroundColor: ColorCodes.white)));
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
                      ),
                      child: Column(
                        children: [
                          // Autocomplete Search
                          Align(alignment: Alignment.centerLeft, child: Text('Select Medicine', style: TextStyles.textStyle2_1)),
                          SizedBox(height: 5),
                          Obx(() {
                            final _ = controller.searchQuery.value;
                            final __ = controller.shopifyProducts.length;
                            return Autocomplete<ProductModel>(
                              optionsBuilder: (textEditingValue) {
                                controller.searchQuery.value = textEditingValue.text;
                                if (controller.searchQuery.isEmpty) {
                                  return const Iterable<ProductModel>.empty();
                                }
                                return controller.shopifyProducts.where(
                                  (product) => product.title.toLowerCase().contains(controller.searchQuery.value.toLowerCase()),
                                );
                              },
                              displayStringForOption: (option) => option.title,
                              onSelected: controller.selectProduct,
                              optionsViewBuilder: (context, onSelected, options) {
                                return Container(
                                  height: 400,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: ColorCodes.colorGrey1,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(width: 1, color: ColorCodes.colorBlack2),
                                  ),
                                  child:
                                      controller.isLoading.value
                                          ? Container(
                                            color: ColorCodes.white,
                                            height: 20,
                                            width: 20,
                                            child: Center(
                                              child: CircularProgressIndicator(color: ColorCodes.colorBlue1, backgroundColor: ColorCodes.white),
                                            ),
                                          )
                                          : ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options.elementAt(index);
                                              return Container(
                                                color: ColorCodes.white,
                                                child: ListTile(
                                                  leading: option.image != null ? Image.network(option.image!, width: 40) : Icon(Icons.image),
                                                  title: Text(option.title, style: TextStyles.textStyle1),
                                                  subtitle: Text('\Rs.${option.price.toStringAsFixed(2)}'),
                                                  onTap: () => onSelected(option),
                                                ),
                                              );
                                            },
                                          ),
                                );
                              },
                              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  style: TextStyles.textStyle1,
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyles.textStyle1,
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          SizedBox(height: 20),
                          Align(alignment: Alignment.centerLeft, child: Text('Select Note', style: TextStyles.textStyle2_1)),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorCodes.colorGrey4),
                            ),
                            child: Obx(() {
                              /*final searchText = controller.searchNote.value.toLowerCase();
                              final filteredNotes =
                                  searchText.isEmpty
                                      ? <NoteData>[]
                                      : controller.notesList.where((note) => note.text.toLowerCase().contains(searchText)).toList();*/

                              final searchText = controller.searchNote.value.toLowerCase();
                              final filteredNotes =
                                  searchText.isEmpty
                                      ? controller.notesList
                                      : controller.notesList.where((note) => note.text.toLowerCase().contains(searchText)).toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔍 Search TextField
                                  TextField(
                                    onChanged: (value) {
                                      controller.searchNote.value = value;
                                    },
                                    style: TextStyles.textStyle1,
                                    decoration: InputDecoration(
                                      hintText: 'Search notes...',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // 📋 Suggestions inside the same container
                                  if (controller.isLoading.value)
                                    Center(child: CircularProgressIndicator(color: ColorCodes.colorBlue1, backgroundColor: ColorCodes.white))
                                  else
                                    Container(
                                      height: 300,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: ColorCodes.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(width: 1, color: ColorCodes.colorBlack2),
                                      ),
                                      child:
                                          filteredNotes.isEmpty
                                              ? Center(child: Text("No notes found", style: TextStyles.textStyle2))
                                              : ListView.builder(
                                                shrinkWrap: true,
                                                physics: AlwaysScrollableScrollPhysics(),
                                                itemCount: filteredNotes.length,
                                                itemBuilder: (context, index) {
                                                  final note = filteredNotes[index];
                                                  return Obx(() {
                                                    final isChecked = controller.selectedNotes.contains(note.text);

                                                    return CheckboxListTile(
                                                      value: isChecked,
                                                      onChanged: (checked) {
                                                        if (checked == true) {
                                                          controller.selectedNotes.add(note.text);
                                                        } else {
                                                          controller.selectedNotes.remove(note.text);
                                                        }
                                                      },
                                                      title: Text(note.text, style: TextStyles.textStyle1),
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                    );
                                                  });
                                                },
                                              ),
                                    ),

                                  const SizedBox(height: 12),
                                  // ✅ Show selected values below
                                  Obx(() => Text("Selected Notes: ${controller.selectedNotes.join(', ')}", style: TextStyles.textStyle1)),
                                ],
                              );
                            }),
                          ),

                          // Description Field
                          /*Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ColorCodes.colorGrey4),
                            ),
                            child: TextField(
                              controller: controller.descriptionController,
                              maxLines: null,
                              minLines: 5, // Set a minimum height
                              decoration: InputDecoration(
                                hintText: "Describes Your Medicine .........",
                                hintStyle: TextStyles.textStyle5,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),*/
                        ],
                      ),
                    ),
                  );
                }),

                // Fixed Bottom Button (won't move with keyboard)
                Padding(
                  padding: EdgeInsets.only(bottom: 16), // Extra padding at bottom
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.medicineNameController.text.isEmpty) {
                        // Constants.showError('Select Medicine');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select Medicine", style: TextStyles.textStyle1_1,), backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)));
                      } else if (controller.selectedNotes.isEmpty) {
                        // Constants.showError('Select description');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select description", style: TextStyles.textStyle1_1,), backgroundColor: Colors.redAccent, duration: Duration(seconds: 2)));
                        print('Select description');
                      } else {
                        controller.addMedicine();
                        // Get.back();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.colorBlue1,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('ADD Medicine', style: TextStyles.textStyle6_1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
