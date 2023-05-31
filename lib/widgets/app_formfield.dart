import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_lift/widgets/app_text.dart';

import '../constants/styles.dart';

/// regex
/// patterns
/// validators
///

class CustomFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onEditingComplete;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomFormField({
    super.key,
    this.labelText,
    this.controller,
    this.inputFormatters,
    this.onEditingComplete,
    this.hintText,
    this.isPassword = false,
    required this.validator,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          AppText(
            text: widget.labelText!,
            textSize: 17,
          ),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onEditingComplete: widget.onEditingComplete,
          obscureText: widget.isPassword && isObscure,
          decoration: InputDecoration(
            counterText: "",
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.all(10),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB), width: 2.0),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            errorMaxLines: 3,
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 17),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => isObscure = !isObscure),
                    icon: isObscure
                        ? Icon(Icons.remove_red_eye_outlined,
                            color: primaryColor)
                        : Icon(Icons.remove_red_eye_rounded,
                            color: primaryColor))
                : null,
          ),
        ),
      ],
    );
  }
}
