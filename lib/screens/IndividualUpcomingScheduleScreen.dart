import 'package:Doctor/model/appointment_model.dart';
import 'package:Doctor/model/schedule_item.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../controllers/IndividualUpcomingScheduleController.dart';
import '../model/PrescriptionRequestModel.dart';
import '../model/ProductModel.dart';
import '../model/ShopifyService.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/Constants.dart';
import '../widgets/TextStyles.dart';

class IndividualUpcomingScheduleScreen extends StatefulWidget {
  final Appointment item;

  const IndividualUpcomingScheduleScreen({super.key, required this.item});

  @override
  State<IndividualUpcomingScheduleScreen> createState() => _IndividualUpcomingScheduleScreenState();
}

class _IndividualUpcomingScheduleScreenState extends State<IndividualUpcomingScheduleScreen> {
  final controller = Get.put(IndividualUpcomingScheduleController());
  // final ShopifyService _shopifyService = Get.find<ShopifyService>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    final parsedDate = DateTime.parse(widget.item.appointmentDate.toString());
    final formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);

    Constants.currentUser = ZegoUIKitUser(id: widget.item.bookingId.toString(), name: widget.item.patientFullName.toString());
    print('widget.item.id.toString() ---- ${widget.item.id.toString()}');

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCodes.white,
        appBar: AppBar(
          title: Text("Upcoming Schedule", style: TextStyles.textStyle2_1),
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
                                Text(widget.item.patientFullName.toString(), style: TextStyles.textStyle3),
                                SizedBox(height: 2),
                                SizedBox(width: width / 3, child: DottedLine(dashLength: 3, dashGapLength: 2, dashColor: ColorCodes.colorGrey1)),
                                SizedBox(height: 2),
                                Text(
                                  widget.item.concerns?.join(", ") ?? '',
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
                            '${Constants.formatTimeToAmPm(widget.item.timeSlot?.startTime ?? '')} - ${Constants.formatTimeToAmPm(widget.item.timeSlot?.endTime ?? '')}',
                            style: TextStyles.textStyle4,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      height: 40,
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          print('widget.item.userId.toString() ---- ${widget.item.userId.toString()}');
                          /*           sendCallButton(
                            isVideoCall: true,
                            inviteeUsersIDTextCtrl: widget.item.userId.toString(),
                            onCallFinished: onSendCallInvitationFinished,
                          );*/
                          Get.to(() => CallPage(callId: widget.item.userId.toString()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorCodes.colorBlue1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        ),
                        child: Text('Call', style: TextStyles.textStyle6_1),
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
                                final variantId = medicine['variantId']?.trim()/*.split('/').last*/;
                                print("prescriptions name ---- $name, notes - $notes, variantId - $variantId");

                                return PrescriptionItem(medicineName: name ?? '', notes: notes ?? '', variantId: variantId ?? '');
                              })
                              .where((item) => item.medicineName.isNotEmpty && item.notes.isNotEmpty)
                              .toList();

                      controller.selectedCustomerId.value = '8466775113981'; /* Vanshi user -> vanshi1@yopmail.com */
                      controller.addMedicineApi(id: widget.item.id.toString(), prescriptions: prescriptions);
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
              if (controller.selectedItems.isNotEmpty) ...[
                SizedBox(height: 20),
                Text('Selected Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...controller.selectedItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Text('item -- $item');
                  /*final product = controller.products.firstWhere(
                        (p) => (p['variants'] as List).any(
                          (v) => v['id'].toString() == item['variant_id'],
                    ),
                    orElse: () => {'title': 'Unknown', 'variants': []},
                  );

                  final variant = (product['variants'] as List).firstWhere(
                        (v) => v['id'].toString() == item['variant_id'],
                    orElse: () => {'title': 'Unknown', 'price': '0'},
                  );

                  return ListTile(
                    title: Text('${product['title']} - ${variant['title']}'),
                    subtitle: Text('Qty: ${item['quantity']} × \$${variant['price']}'),
                  );*/
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String extractCustomerId(String gidOrId) {
    if (gidOrId.startsWith('gid://shopify/Customer/')) {
      return gidOrId.split('/').last;
    }
    return gidOrId;
  }

  final ScrollController _sheetScrollController = ScrollController();

  void _showAddMedicineSheet(BuildContext context) {
    controller.loadProducts();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: Navigator.of(context), // Requires TickerProvider
      ),
      builder: (context) {
        return ConstrainedBox /*AnimatedPadding*/ (
          // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // duration: Duration(milliseconds: 300),
          // curve: Curves.easeOut,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: SingleChildScrollView(
            controller: _sheetScrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            // padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add Medicine", style: TextStyles.textStyle2_2),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Image.asset('assets/ic_close.png', height: 24, width: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // TextField(
                //   controller: controller.medicineNameController,
                //   cursorColor: ColorCodes.colorBlack1,
                //   decoration: InputDecoration(
                //     hintText: 'Enter medicine name',
                //     hintStyle: TextStyles.textStyle5_1,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(16),
                //       borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(16),
                //       borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(16),
                //       borderSide: BorderSide(width: 1, color: ColorCodes.colorGrey4),
                //     ),
                //   ),
                // ),
                Obx(() {
                  final _ = controller.searchQuery.value; // 👈 forces read!
                  final __ = controller.shopifyProducts.length;
                  return Autocomplete<ProductModel>(
                    optionsBuilder: (textEditingValue) {
                      controller.searchQuery.value = textEditingValue.text;
                      if (controller.searchQuery.isEmpty) {
                        return const Iterable<ProductModel>.empty();
                      }
                      // if (textEditingValue.text.isEmpty) {
                      //   return const Iterable<ProductModel>.empty();
                      // }
                      // return controller.shopifyProducts.where((product) => product.title.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      return controller.shopifyProducts.where(
                        (product) => product.title.toLowerCase().contains(controller.searchQuery.value.toLowerCase()),
                      );
                    },
                    displayStringForOption: (option) => option.title,
                    onSelected: controller.selectProduct,
                    optionsViewBuilder: (context, onSelected, options) {
                      return Material(
                        elevation: 4,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: option.image != null ? Image.network(option.image!, width: 40) : Icon(Icons.image),
                              title: Text(option.title, style: TextStyles.textStyle1,),
                              subtitle: Text('\Rs.${option.price.toStringAsFixed(2)}'),
                              onTap: () => onSelected(option),
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
                          // border: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(12),
                            /*contentPadding: EdgeInsets.symmetric(vertical: 12)*/
                          // ),
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
                const SizedBox(height: 16),

                // Selected Product Preview
                /*Obx(() {
                  if (controller.selectedProduct.value == null) {
                    return const SizedBox();
                  }
                  final product = controller.selectedProduct.value!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.image != null) Image.network(product.image!, height: 100),
                          const SizedBox(height: 8),
                          Text(product.title, style: TextStyle(fontWeight: FontWeight.bold)),
                          if (product.sku != null) Text('SKU: ${product.sku}'),
                          Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  );
                }),*/

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorCodes.colorGrey4),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 100, maxHeight: 180),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: controller.descriptionController,
                          maxLines: null,
                          cursorColor: ColorCodes.colorBlack1,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: "Describes Your Medicine .........",
                            hintStyle: TextStyles.textStyle5,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.addMedicine();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCodes.colorBlue1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Center(child: Text('ADD Medicine', style: TextStyles.textStyle6_1)),
                ),
              ],
            ),
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
                      Flexible(child: Text(nameController.text, style: TextStyles.textStyle2_2, overflow: TextOverflow.ellipsis, maxLines: 2,)),
                      SizedBox(width: 2,),
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

  Widget sendCallButton({
    required bool isVideoCall,
    required String inviteeUsersIDTextCtrl,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    /*return ValueListenableBuilder<String>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees = getInvitesFromTextCtrl(inviteeUserID.trim());

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          resourceID: 'zego_data',
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: onCallFinished,
        );
      },
    );*/
    final invitees = getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.trim());

    return ZegoSendCallInvitationButton(
      isVideoCall: isVideoCall,
      invitees: invitees,
      resourceID: 'zego_data',
      iconSize: const Size(40, 40),
      buttonSize: const Size(50, 50),
      onPressed: onCallFinished,
    );
  }

  void onSendCallInvitationFinished(String code, String message, List<String> errorInvitees) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
        print('userIDs: $userIDs');
      }

      var message = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      print('message:$message');
      Constants.showSuccess(message);
    } else if (code.isNotEmpty) {
      Constants.showError('code: $code, message:$message');
      print('code: $code, message:$message');
    }
  }

  List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
    final invitees = <ZegoUIKitUser>[];

    final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
    inviteeIDs.split(',').forEach((inviteeUserID) {
      if (inviteeUserID.isEmpty) {
        print('inviteeUserID: $inviteeUserID');
        return;
      }

      print('inviteeUserID NOT EMPTY: $inviteeUserID');
      invitees.add(ZegoUIKitUser(id: inviteeUserID, name: 'user_$inviteeUserID'));
    });

    return invitees;
  }
}

class CallPage extends StatelessWidget {
  final String callId;

  const CallPage({super.key, required this.callId});

  @override
  Widget build(BuildContext context) {
    print('callId ---- $callId');

    return ZegoUIKitPrebuiltCall(
      appID: 260617754,
      appSign: "0b18f31ba87471a155cfea2833abf4c8168690730f6d565f985115620ca14e28",
      userID: Constants.currentUser.id,
      userName: Constants.currentUser.name,
      callID: callId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
