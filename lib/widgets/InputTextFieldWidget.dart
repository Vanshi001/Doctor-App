import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ColorCodes.dart';
import 'TextStyles.dart';

class InputTextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final TextInputAction inputAction;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;

  const InputTextFieldWidget(
    this.textEditingController,
    this.hintText, {
    super.key,
    this.inputAction = TextInputAction.next,
    this.inputFormatters,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorCodes.darkPurple),
      ),
      child: TextField(
        controller: textEditingController,
        textInputAction: inputAction,
        style: TextStyles.descriptionTextStyle,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          border: InputBorder.none,
          labelText: hintText,
          labelStyle: TextStyles.smallTextStyle,
        ),
        inputFormatters: inputFormatters ?? [],
      ),
    );
  }
}
