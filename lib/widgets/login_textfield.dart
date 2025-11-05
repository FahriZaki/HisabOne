import 'package:flutter/material.dart';

final _borderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(8.0),
  borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
);

class LoginTextfield extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction inputAction;
  final bool isObscure;
  final bool hasSuffix;
  final VoidCallback? onSuffixPressed;
  const LoginTextfield({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.isObscure = false,
    this.hasSuffix = false,
    this.onSuffixPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: labelText,
        border: _borderStyle,
        focusedBorder: _borderStyle,
        suffixIcon:
            hasSuffix
                ? IconButton(
                  onPressed: onSuffixPressed,
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                )
                : null,
      ),
      keyboardType: keyboardType,
      textInputAction: inputAction,
      onTapOutside: (event) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      style: const TextStyle(fontSize: 16.0, color: Colors.black),
    );
  }
}
