import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../model/appointment_item.dart';
import '../widgets/ColorCodes.dart';
import '../widgets/TextStyles.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final String title;
  final String image;
  final String date;
  final String time;
  final String concern;
  final List<String> medicineNames;
  // final AppointmentItem item;

  const AppointmentDetailsDialog({
    super.key,
    required this.title,
    required this.image,
    required this.date,
    required this.time,
    required this.concern,
    required this.medicineNames,
  });

  String getInitials(String firstName) {
    if (firstName.isEmpty) return '';
    String firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    return firstInitial.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // final List<String> medicines = ['Paracetamol', 'Ibuprofen', 'Atorvastatin', 'Omeprazole', 'Amlodipine'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header with image and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ClipRRect(borderRadius: BorderRadius.circular(40), child: Image.asset(image, height: 50, width: 50, fit: BoxFit.cover)),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorCodes.colorBlack2, // Background color for the circle
                    border: Border.all(color: ColorCodes.colorBlue1, width: 3),
                  ),
                  child: Center(child: Text(getInitials(title.toString()), style: TextStyles.textStyle4)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyles.textStyle3),
                      Text(concern, style: TextStyles.textStyle5, overflow: TextOverflow.ellipsis, maxLines: 2),
                    ],
                  ),
                ),
                GestureDetector(onTap: () => Navigator.pop(context), child: Image.asset('assets/ic_close.png', height: 24, width: 24)),
              ],
            ),

            const SizedBox(height: 12),

            /// Date and time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(color: ColorCodes.colorGrey4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/ic_calendar.png', width: 16),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyles.textStyle4),
                  const SizedBox(width: 20),
                  Image.asset('assets/ic_vertical_line.png', width: 1, height: 30),
                  const SizedBox(width: 20),
                  Image.asset('assets/ic_clock.png', width: 16),
                  const SizedBox(width: 4),
                  Text(time, style: TextStyles.textStyle4),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Medicines section
            DottedBorder(
              options: RoundedRectDottedBorderOptions(radius: Radius.circular(20), dashPattern: [5, 4], color: ColorCodes.colorGrey4, strokeWidth: 1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Medicines", style: TextStyles.textStyle3),
                    const SizedBox(height: 8),
                    ...medicineNames.map(
                      (medicine) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [const Text("• ", style: TextStyles.textStyle6_2), Expanded(child: Text(medicine, style: TextStyles.textStyle5))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
