import '../datasources/onBoarding_local_datasource.dart';

class OnBoardingRepository {
  final OnBoardingLocalDataSource _dataSource;

  OnBoardingRepository(this._dataSource);

  //check if onboarding is completed
  Future<bool> isOnboardingCompleted() => _dataSource.isOnboardingCompleted();

  //set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) =>
      _dataSource.setOnboardingCompleted(completed);
}
