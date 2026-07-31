import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingLocalDataSource {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  //Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  //Set onboarding completed status
  Future<void> setOnboardingCompleted(bool completed) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_onboardingCompletedKey, completed);
  }
}
