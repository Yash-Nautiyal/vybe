import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ThemeData theme;
  final Function onchange;
  final TextInputType keyboardType;
  final String? labelText;
  final bool? isPasswordVisible;
  final Function? onClickPasswordVisisble;
  final int? maxLines;
  final int? minLines;
  final bool? close;
  final Function? onClose;
  final String? Function(String?)? validator; // <-- ADD THIS

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.theme,
    required this.onchange,
    required this.hintText,
    this.onClickPasswordVisisble,
    this.labelText,
    this.isPasswordVisible,
    this.maxLines = 1,
    this.minLines = 1,
    this.close = false,
    this.onClose,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      obscureText: isPasswordVisible != null ? !(isPasswordVisible!) : false,
      enableSuggestions: isPasswordVisible != null ? false : true,
      autocorrect: isPasswordVisible != null ? false : true,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onchange(value),
      maxLines: maxLines,
      minLines: minLines,
      style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: labelText?.isNotEmpty == true ? labelText : null,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        floatingLabelBehavior:
            hintText == ""
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.auto,
        suffixIcon:
            isPasswordVisible != null
                ? IconButton(
                  icon: Icon(
                    (isPasswordVisible ?? false)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    if (onClickPasswordVisisble != null) {
                      onClickPasswordVisisble!(); // Invoke the function
                    }
                  },
                )
                : close!
                ? IconButton(
                  icon: Icon(Icons.close, color: theme.disabledColor, size: 18),
                  onPressed: () => onClose!(),
                )
                : null,
      ),
    );
  }
}
