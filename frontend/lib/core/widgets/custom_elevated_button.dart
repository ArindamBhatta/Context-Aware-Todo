import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double width;
  final double borderRadius;
  final double shadowBlurRadius;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = const Color(
      0xFF5E42EB,
    ), // Matches the vibrant violet from your design
    this.textColor = Colors.white,
    this.height = 56.0,
    this.width = double.infinity,
    this.borderRadius = 20.0,
    this.shadowBlurRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.25),
            blurRadius: shadowBlurRadius,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation:
              0, // Handled by the Container's box shadow for a softer glow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
