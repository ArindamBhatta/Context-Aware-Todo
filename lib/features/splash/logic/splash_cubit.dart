import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/onboarding/data/repositories/on_boarding_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final OnBoardingRepository _onBoardingRepository;

  SplashCubit({required OnBoardingRepository onBoardingRepository})
    : _onBoardingRepository = onBoardingRepository,
      super(SplashLoading());

  Future<void> initialize() async {
    await _resolveNavigationState(includeSplashDelay: true);
  }

  Future<void> refreshRoutingState() async {
    await _resolveNavigationState(includeSplashDelay: false);
  }

  Future<void> _resolveNavigationState({
    // include splash delay for the first time
    required bool includeSplashDelay,
  }) async {
    // <-- Task #1 Check onBoarding completed? datatype boolean---->
    final List<Future<bool>> tasks = <Future<bool>>[
      _onBoardingRepository.isOnboardingCompleted(),
    ];

    // <-- Task #2 Splash screen duration for atleast 2.5 seconds datatype Duration ---->
    //now datatype mixmatch is coming
    if (includeSplashDelay) {
      tasks.insert(
        0,
        Future.delayed(const Duration(milliseconds: 2500), () => true),
      );
    }

    // 3. Future.wait runs all tasks in the list AT THE SAME TIME (in parallel).
    // It waits for both the 2.5s delay AND the database check to finish.
    final List<bool> results = await Future.wait<bool>(tasks);

    // 4. It's saying: "If we inserted that timer at index 0, our database check got pushed down to index 1. If we didn't insert the timer, our database check is still sitting at index 0."
    final int onBoardingIndex = includeSplashDelay ? 1 : 0;

    final bool onBoardingCompleted = results[onBoardingIndex];

    // 6. Navigate based on the result
    if (!onBoardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else {
      emit(SplashNavigateToLogin());
    }
  }
}
