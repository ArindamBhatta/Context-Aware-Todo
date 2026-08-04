import 'package:todo/features/onboarding/data/service/on_boarding_local_service.dart';

class OnBoardingRepository {
  final OnBoardingLocalService _service;

  OnBoardingRepository(this._service);

  //check if onboarding is completed
  Future<bool> isOnboardingCompleted() => _service.isOnboardingCompleted();

  //set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) =>
      _service.setOnboardingCompleted(completed);
}
