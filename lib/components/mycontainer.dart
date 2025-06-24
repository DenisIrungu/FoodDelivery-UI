import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  final String text;
  final String? subtitle;
  final Color? color;
  final Icon? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const MyContainer({
    required this.text,
    this.subtitle,
    this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFF0F2A12) : Colors.grey!,
            width: isSelected ? 2 : 1,
          ),
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (icon != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F2A12).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon!.icon,
                    color: Color(0xFF0F2A12),
                    size: 24,
                  ),
                ),

              if (icon != null) SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF0F2A12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
