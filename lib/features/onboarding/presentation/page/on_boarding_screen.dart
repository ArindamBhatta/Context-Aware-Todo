import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/onboarding/presentation/logic/on_boarding_cubit.dart';
import 'package:todo/features/onboarding/presentation/page/widgets/scrollable_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  List<Map<String, String>> list = [
    {
      'caption': 'Plan your day clarity',
      'subCaption':
          'Create tasks in seconds and keep your day organized from morning to night.',
      'imageUrl': 'assets/images/onboarding/plan_your_day.png',
    },
    {
      'caption': 'Prioritize what matters',
      'subCaption':
          'Focus on urgent and important tasks so your energy goes to the right work.',
      'imageUrl': 'assets/images/onboarding/prioritize_what_matters.png',
    },
    {
      'caption': 'Track progress daily',
      'subCaption':
          'See completed tasks grow and build momentum every single day.',
      'imageUrl': 'assets/images/onboarding/track_progress_daily.png',
    },
    {
      'caption': 'Never miss a deadline',
      'subCaption':
          'Use reminders and smart scheduling to stay on top of every commitment.',
      'imageUrl': 'assets/images/onboarding/never_miss_deadline.png',
    },
  ];

  late PageController _pageController;
  late Timer _timer;
  int currentPage = 0; //* Update the dot indicator
  int nextPage = 0; //* Update the page Image
  late int _actualListLength;

  @override
  void initState() {
    super.initState();
    _actualListLength = list.length;
    _pageController = PageController();

    //Listening Event of  scrolling
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.toInt(); //* Update the current page
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      nextPage = currentPage + 1;

      //* Check if we reached the last page
      if (nextPage == list.length) {
        setState(() {
          list.add(list[0]); //* Temporarily add the first item at the end
        }); //* Update the UI with the new list

        //* Animate to the temporary page smoothly
        await _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );

        //* Reset to the actual first page without animation
        _pageController.jumpToPage(0);

        //* reset the page controller animation page
        nextPage = 0;

        //* Remove the temporary item
        list.removeLast();
      } else {
        //* Continue with normal page transition
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int get dotsLength => _actualListLength;
  int get currentDot => _actualListLength == currentPage ? 0 : currentPage;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: height * 0.75,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  children:
                      list.map((iterateItem) {
                        return ScrollableScreen(
                          caption: iterateItem['caption'] ?? '',
                          subCaption: iterateItem['subCaption'] ?? '',
                          imageUrl: iterateItem['imageUrl'] ?? '',
                        );
                      }).toList(),
                ),
                Positioned(
                  bottom: height * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DotsIndicator(
                      dotsCount: dotsLength,
                      position: (currentDot).toDouble(),
                      //* Limit to original items
                      decorator: DotsDecorator(
                        shape: CircleBorder(
                          side: BorderSide(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            width: 0.8,
                          ),
                        ),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        spacing: const EdgeInsets.all(8.0),
                        activeColor: Theme.of(context).colorScheme.primary,
                        size: const Size(8.0, 8.0), // Size of inactive dots
                        activeSize: const Size(
                          40.0,
                          12.0,
                        ), // Size of active dot
                        activeShape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  //1.Store the data in shear preferences saves onboarding_completed = true
                  await context.read<OnBoardingCubit>().completeOnboarding();

                  //2. Navigate to the login screen
                  if (!mounted) return;
                  context.go(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary, // Indigo 600
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
