import 'package:flutter/material.dart';

import 'ColorCodes.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget titleWidget;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorCodes.white.withOpacity(0.25),
            offset: Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
          backgroundColor: MaterialStateProperty.all(ColorCodes.darkPurple),
        ),
        onPressed: onPressed,
        child: titleWidget,
        /*child: Text(
          titleWidget,
          style: TextStyles.buttonNameStyle,
        ),*/
      ),
    );
  }
}
