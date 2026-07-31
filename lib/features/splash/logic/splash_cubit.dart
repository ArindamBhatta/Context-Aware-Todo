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
    required bool includeSplashDelay,
  }) async {
    // Keep splash visible for at least 2.5 seconds
    final List<Future<dynamic>> tasks = <Future<dynamic>>[
      _onBoardingRepository.isOnboardingCompleted(),
    ];

    if (includeSplashDelay) {
      tasks.insert(0, Future.delayed(const Duration(milliseconds: 2500)));
    }

    final List<dynamic> results = await Future.wait<dynamic>(tasks);

    final int onBoardingIndex = includeSplashDelay ? 1 : 0;
    final bool onBoardingCompleted = results[onBoardingIndex] as bool;

    if (!onBoardingCompleted) {
      emit(SplashNavigateToOnboarding());
    } else {
      emit(SplashNavigateToLogin());
    }
  }
}
