import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({required this.child, required this.shake, super.key});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    if (widget.shake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake != oldWidget.shake) {
      if (widget.shake) {
        _controller.forward(from: 0.0);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curveAnimation,
      builder: (context, child) {
        if (!widget.shake || !_controller.isAnimating) return child!;
        final double pulse = math.sin(_curveAnimation.value * math.pi);
        final double scale = 1.0 + (pulse * 0.035);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: pulse > 0.01
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEF4444)
                            .withValues(alpha: 0.35 * pulse),
                        blurRadius: 16 * pulse,
                        spreadRadius: 2 * pulse,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
