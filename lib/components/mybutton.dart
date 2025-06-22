import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  final IconData? icon;
  final Color color;
  final foregroundColor;
  final Widget? leadingIcon;


  const MyButton(
      {required this.text,
      required this.onPress,
      required this.color,
      this.foregroundColor,
      this.icon,
      this.leadingIcon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: leadingIcon ?? const SizedBox.shrink(),
      onPressed: onPress,
      label: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: color,
          foregroundColor: foregroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}
