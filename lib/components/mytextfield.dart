import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String hintText;
  final Color background;
  final bool obscureText;
  final Color hintTextColor;
  final Color labelTextColor;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? errorMsg;
  final String? Function(String?)? onChanged;
  final int? maxlength;

  String? errorText;

  MyTextField(
      {required this.controller,
      this.labelText,
      required this.hintText,
      required this.obscureText,
      this.background = const Color(0xFFDFDEE8),
      this.hintTextColor = const Color(0xFF000000),
      this.labelTextColor = const Color(0xFF303F9F),
      this.keyboardType,
      this.suffixIcon,
      this.onTap,
      this.prefixIcon,
      this.validator,
      this.focusNode,
      this.errorMsg,
      this.onChanged,
      this.maxlength,
      super.key});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        maxLength: widget.maxlength,
        validator: widget.validator,
        obscureText: widget.obscureText,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          fillColor: widget.background,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: widget.hintTextColor),
          labelText: widget.labelText,
          suffix: widget.suffixIcon,
          prefix: widget.prefixIcon,
          errorText: widget.errorMsg,
          labelStyle: TextStyle(color: widget.labelTextColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0F2A12)),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black)),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: TextStyle(color: Color(0xFF0F2A12), fontSize: 20),
      ),
    );
  }
}
