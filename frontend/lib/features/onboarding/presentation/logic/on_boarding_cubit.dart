import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/onboarding/data/repositories/on_boarding_repository.dart';

class OnBoardingCubit extends Cubit<bool> {
  final OnBoardingRepository _repository;

  OnBoardingCubit(this._repository) : super(false);

  Future<void> syncOnboardingState() async {
    final bool isCompleted = await _repository.isOnboardingCompleted();
    emit(isCompleted);
  }

  Future<void> completeOnboarding() async {
    await _repository.setOnboardingCompleted(true);
    emit(true);
  }
}
