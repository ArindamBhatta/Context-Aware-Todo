import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/splash/page/corner_ring.dart';

import '../logic/splash_cubit.dart';
import 'floating_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: Stack(
        children: [
          // Background Blobs (Soft gradients)
          Positioned(
            top: -50,
            left: -50,
            child: _GlowBlob(
              size: 260,
              color: const Color(0xFF86EFAC), // Soft light green
            ),
          ),
          Positioned(
            top: 50,
            right: -60,
            child: _GlowBlob(
              size: 280,
              color: const Color(0xFFDDD6FE), // Soft light violet/purple
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: _GlowBlob(
              size: 320,
              color: const Color(0xFFBFDBFE), // Soft light blue
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: _GlowBlob(
              size: 240,
              color: const Color(0xFFFEF08A), // Soft light yellow
            ),
          ),

          // Corner circles (Stylized mockup border design)
          Positioned(top: 36, left: 24, child: CornerRing()),
          Positioned(top: 36, right: 24, child: CornerRing()),
          Positioned(bottom: 36, left: 24, child: CornerRing()),
          Positioned(bottom: 36, right: 24, child: CornerRing()),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 3D Illustration with floating animation
                  Flexible(
                    flex: 8,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.height * 0.45,
                      ),
                      child: const FloatingWidget(
                        child: Center(
                          child: Image(
                            image: AssetImage(
                              'assets/images/splash/splash_illustration.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Title text
                  const Text(
                    'Task Management & \nTo-Do List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A), // Slate 900
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle/Description text
                  const Text(
                    'This productive tool is designed to help\nyou better manage your task\nproject-wise conveniently!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B), // Slate 500
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background soft glow blob widget
class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.35),
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
