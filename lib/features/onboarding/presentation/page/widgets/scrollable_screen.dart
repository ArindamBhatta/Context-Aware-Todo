import 'package:flutter/material.dart';
import 'package:todo/features/onboarding/presentation/page/widgets/gradient_image.dart';

// ignore: must_be_immutable
class ScrollableScreen extends StatelessWidget {
  final String? caption;
  final String? subCaption;
  String? imageUrl;

  ScrollableScreen({
    super.key,
    required this.caption,
    required this.subCaption,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Stack(
        children: [
          GradientImage(imageUrl: imageUrl),
          Positioned(
            bottom: 0,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      caption!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      subCaption!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
