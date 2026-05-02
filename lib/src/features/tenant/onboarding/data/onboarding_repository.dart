import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  throw UnimplementedError();
}

class OnboardingRepository {
  final SharedPreferences _sharedPreferences;

  OnboardingRepository(this._sharedPreferences);

  static const _onboardingCompleteKey = 'onboardingComplete';

  Future<void> setOnboardingComplete() async {
    await _sharedPreferences.setBool(_onboardingCompleteKey, true);
  }

  bool isOnboardingComplete() {
    return _sharedPreferences.getBool(_onboardingCompleteKey) ?? false;
  }
}
