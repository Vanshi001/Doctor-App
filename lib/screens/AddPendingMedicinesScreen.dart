import 'package:Doctor/model/PendingAppointmentsWithoutDescriptionResponse.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/IndividualUpcomingScheduleController.dart';
import '../controllers/main/MainController.dart';
import '../model/PrescriptionRequestModel.dart';
import '../model/ProductModel.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';

class AddPendingMedicinesScreen extends StatefulWidget {
  final WithoutDescriptionAppointment appointmentData;

  const AddPendingMedicinesScreen({super.key, required this.appointmentData});

  @override
  State<AddPendingMedicinesScreen> createState() => _AddPendingMedicinesScreenState();
}

class _AddPendingMedicinesScreenState extends State<AddPendingMedicinesScreen> {
  final controller = Get.put(IndividualUpcomingScheduleController());

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    final parsedDate = DateTime.parse(widget.appointmentData.appointmentDate.toString());
    final formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Add Prescription", style: TextStyles.textStyle2_1),
          backgroundColor: ColorCodes.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorCodes.colorBlack1),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorCodes.colorGrey4, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network('https://randomuser.me/api/portraits/women/1.jpg', height: 50, width: 50, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.appointmentData.patientFullName.toString(), style: TextStyles.textStyle3),
                                SizedBox(height: 2),
                                SizedBox(width: width / 3, child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1)),
                                SizedBox(height: 2),
                                Text(
                                  widget.appointmentData.concerns?.join(", ") ?? '',
                                  style: TextStyles.textStyle5,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        border: Border.all(color: ColorCodes.colorGrey4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/ic_calendar.png', width: 16, height: 16),
                          SizedBox(width: 5),
                          Text(formattedDate, style: TextStyles.textStyle4),
                          SizedBox(width: 20),
                          Image.asset('assets/ic_vertical_line.png', height: 30, width: 1),
                          SizedBox(width: 20),
                          Image.asset('assets/ic_clock.png', width: 16, height: 16),
                          SizedBox(width: 5),
                          Text(
                            '${Constants.formatTimeToAmPm(widget.appointmentData.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(widget.appointmentData.timeSlot?.endTime ?? '')}',
                            style: TextStyles.textStyle4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorCodes.colorGrey4, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Medicine', style: TextStyles.textStyle3),
                        GestureDetector(
                          onTap: () {
                            _showAddMedicineSheet(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: Border.all(color: ColorCodes.colorBlue1, width: 1),
                              color: ColorCodes.white,
                            ),
                            alignment: Alignment.center,
                            height: 40,
                            padding: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
                            child: Obx(() => Text(controller.medicines.isEmpty ? 'Add Medicine' : 'Add', style: TextStyles.textStyle4_2)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Obx(
                          () => ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.medicines.length,
                        itemBuilder: (context, index) {
                          final item = controller.medicines[index];

                          if (controller.itemKeys.length <= index) {
                            controller.itemKeys.add(GlobalKey());
                          }

                          return Row(
                            children: [
                              Flexible(
                                child: Container(
                                  key: controller.itemKeys[index],
                                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorCodes.colorGrey4),
                                    borderRadius: BorderRadius.circular(12),
                                    color: ColorCodes.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 2),
                                            Text(item["medicineName"] ?? '', style: TextStyles.textStyle4_3),
                                            Text(item["notes"] ?? '', overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyles.textStyle5_1),
                                            const SizedBox(height: 2),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 25),
                                      GestureDetector(
                                        onTap: () {
                                          // controller.editMedicine(index);
                                          print("Clicked item $index");
                                          showEditMedicinePopup(context, index, controller);
                                        },
                                        child: Image.asset('assets/ic_edit.png', width: 24, height: 24),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.removeMedicine(index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorCodes.colorGrey4),
                                    borderRadius: BorderRadius.circular(12),
                                    color: ColorCodes.white,
                                  ),
                                  child: Image.asset('assets/ic_trash.png', width: 24, height: 24),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.medicines.isNotEmpty) {
                  return GestureDetector(
                    onTap: () {
                      final prescriptions =
                      controller.medicines
                          .map((medicine) {
                        final name = medicine['medicineName']?.trim();
                        final notes = medicine['notes']?.trim();
                        final variantId = medicine['variantId']?.trim() /*.split('/').last*/;
                        final productId = medicine['productId']?.trim() /*.split('/').last*/;
                        final price = medicine['price']?.trim() /*.split('/').last*/;
                        final compareAtPrice = medicine['compareAtPrice']?.trim() /*.split('/').last*/;
                        final image = medicine['image']?.trim() /*.split('/').last*/;
                        print(
                          "\n prescriptions name ---- $name, "
                              "\n notes - $notes, "
                              "\n variantId - $variantId, "
                              "\n productId - $productId, "
                              "\n price - $price "
                              "\n compareAtPrice - $compareAtPrice, "
                              "\n image - $image",
                        );

                        return PrescriptionItem(
                          medicineName: name ?? '',
                          notes: notes ?? '',
                          variantId: variantId ?? '',
                          productId: productId ?? '',
                          compareAtPrice: compareAtPrice ?? '',
                          image: image ?? '',
                          price: price ?? '',
                        );
                      })
                          .where((item) => item.medicineName.isNotEmpty && item.notes.isNotEmpty)
                          .toList();

                      controller.selectedCustomerId.value = '8466775113981'; /* Vanshi user -> vanshi1@yopmail.com */
                      controller.addMedicineApi(id: widget.appointmentData.id.toString(), prescriptions: prescriptions);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6)), color: ColorCodes.colorBlue1),
                      child: Center(
                        child:
                        controller.isLoading.value
                            ? SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: ColorCodes.darkPurple1,
                            valueColor: AlwaysStoppedAnimation<Color>(ColorCodes.white),
                          ),
                        )
                            : Text('Save', style: TextStyles.textStyle6_1),
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMedicineSheet(BuildContext context) {
    controller.loadProducts();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Still needed for proper keyboard behavior
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add Medicine", style: TextStyles.textStyle2_2),
                  GestureDetector(onTap: () => Get.back(), child: Image.asset('assets/ic_close.png', height: 24, width: 24)),
                ],
              ),
              SizedBox(height: 16),

              // Scrollable Content (excluding the button)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
                  ),
                  child: Column(
                    children: [
                      // Autocomplete Search
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
                                borderRadius: BorderRadius.circular(10),
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
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      SizedBox(height: 16),

                      // Description Field
                      Container(
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
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Button (won't move with keyboard)
              Padding(
                padding: EdgeInsets.only(bottom: 16), // Extra padding at bottom
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.medicineNameController.text.isEmpty) {
                      Constants.showError('Select Medicine');
                    } else if (controller.descriptionController.text.isEmpty) {
                      Constants.showError('Enter description');
                    } else {
                      controller.addMedicine();
                      Get.back();
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
        );
      },
    );
  }

  void showEditMedicinePopup(BuildContext context, int index, IndividualUpcomingScheduleController controller) {
    final nameController = TextEditingController(text: controller.medicines[index]["medicineName"]);
    final descriptionController = TextEditingController(text: controller.medicines[index]["notes"]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ColorCodes.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(nameController.text, style: TextStyles.textStyle2_2, overflow: TextOverflow.ellipsis, maxLines: 2)),
                      SizedBox(width: 2),
                      GestureDetector(onTap: () => Get.back(), child: Image.asset('assets/ic_close.png', width: 24, height: 24)),
                    ],
                  ),
                ),
                Divider(height: 2, thickness: 1, color: ColorCodes.colorGrey4),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorCodes.colorGrey4)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 80, maxHeight: 150),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: descriptionController,
                          maxLines: null,
                          cursorColor: ColorCodes.colorBlack1,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: "Describes Your Medicine ......",
                            hintStyle: TextStyles.textStyle5_1,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.medicines[index]["notes"] = descriptionController.text;
                      controller.medicines.refresh();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCodes.colorBlue1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Done", style: TextStyles.textStyle6_1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
