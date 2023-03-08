import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_lift/constants/styles.dart';

import 'app_text.dart';

class AppTextField extends StatefulWidget {
  final VoidCallback? onEditingComplete;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final MouseCursor? mouseCursor;
  final List<TextInputFormatter>? inputFormatters;
  final String? labelText;
  final String? hintText;
  final bool isPassword;
  final bool isEnabled;
  final int length;
  final int maxLines;
  final OutlineInputBorder? outlineInputBorder;

  const AppTextField({
    required this.controller,
    this.mouseCursor,
    this.onEditingComplete,
    this.labelText,
    this.textInputType,
    this.hintText,
    this.isPassword = false,
    this.isEnabled = true,
    this.length = 12,
    this.inputFormatters,
    this.maxLines = 1,
    this.outlineInputBorder,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
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
        SizedBox(
          child: Material(
            child: TextField(
              maxLength: widget.length,
              enabled: widget.isEnabled,
              controller: widget.controller,
              obscureText: widget.isPassword && isObscure,
              keyboardType: widget.textInputType,
              mouseCursor: widget.mouseCursor,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              onEditingComplete: () {
                if (widget.onEditingComplete != null) {
                  widget.onEditingComplete!();
                }
              },
              decoration: InputDecoration(
                counterText: "",
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: widget.outlineInputBorder ??
                    OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB), width: 2.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                enabledBorder: widget.outlineInputBorder ??
                    OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                hintText: widget.hintText,
                hintStyle: const TextStyle(fontSize: 17),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        onPressed: () => setState(() => isObscure = !isObscure),
                        icon: isObscure
                            ? Icon(
                                Icons.remove_red_eye_outlined,
                                color: primaryColor
                              )
                            : Icon(
                                Icons.remove_red_eye_rounded,
                                color: primaryColor
                              ))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
