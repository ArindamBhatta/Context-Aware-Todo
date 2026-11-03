import 'package:flutter/material.dart';

class GradientImage extends StatelessWidget {
  final String? imageUrl;

  const GradientImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.7, 0.85, 1],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              imageUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFEEF2F6),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF94A3B8),
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Spacer(),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}
