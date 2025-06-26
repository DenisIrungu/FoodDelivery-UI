import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  final String text;
  final String? subtitle;
  final Color? color;
  final Icon? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool useVerticalLayout;
  final Widget? customTrailing;
  final Widget? customContent;
  final Gradient? gradient;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? badge;
  final bool showArrow;
  final Widget? bottomWidget;
  final BorderRadius? borderRadius;

  const MyContainer({
    required this.text,
    this.subtitle,
    this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.useVerticalLayout = false,
    this.customTrailing,
    this.customContent,
    this.gradient,
    this.height,
    this.padding,
    this.badge,
    this.showArrow = false,
    this.bottomWidget,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: gradient == null ? Border.all(
            color: isSelected ? Color(0xFF0F2A12) : Colors.grey,
            width: isSelected ? 2 : 1,
          ) : null,
          color: gradient == null ? Theme.of(context).colorScheme.surface : null,
          gradient: gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          boxShadow: gradient != null ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: customContent ?? _buildDefaultContent(),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    if (useVerticalLayout) {
      return _buildVerticalLayout();
    } else {
      return _buildHorizontalLayout();
    }
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        // Icon section
        if (icon != null) ...[
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
          SizedBox(width: 16),
        ],

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
                  color: gradient != null ? Colors.white : Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 16,
                    color: gradient != null 
                        ? Colors.white.withOpacity(0.9) 
                        : Colors.grey[800],
                  ),
                ),
              ],
              if (badge != null) ...[
                SizedBox(height: 8),
                badge!,
              ],
              if (bottomWidget != null) ...[
                SizedBox(height: 12),
                bottomWidget!,
              ],
            ],
          ),
        ),

        // Trailing section
        _buildTrailing(),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with icon and trailing
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF0F2A12).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon!.icon,
                  color: Color(0xFF0F2A12),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
            ],
            
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: gradient != null ? Colors.white : Colors.black,
                ),
              ),
            ),
            
            _buildTrailing(),
          ],
        ),
        
        // Subtitle
        if (subtitle != null) ...[
          SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: gradient != null 
                  ? Colors.white.withOpacity(0.9) 
                  : Colors.grey[800],
            ),
          ),
        ],
        
        // Badge
        if (badge != null) ...[
          SizedBox(height: 8),
          badge!,
        ],
        
        // Bottom widget
        if (bottomWidget != null) ...[
          SizedBox(height: 12),
          bottomWidget!,
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    if (customTrailing != null) {
      return customTrailing!;
    }
    
    if (showArrow) {
      return Icon(
        Icons.chevron_right,
        color: gradient != null ? Colors.white : Color(0xFF0F2A12),
        size: 24,
      );
    }
    
    if (isSelected) {
      return Container(
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
      );
    }
    
    return SizedBox.shrink();
  }
}