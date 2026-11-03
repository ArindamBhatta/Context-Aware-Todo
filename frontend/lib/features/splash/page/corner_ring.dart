// Corner ring widget
import 'package:flutter/material.dart';

class CornerRing extends StatelessWidget {
  const CornerRing({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(
            0xFF60A5FA,
          ).withValues(alpha: 0.6), // Light blue border
          width: 1.5,
        ),
      ),
    );
  }
}
