import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/theme/app_theme.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required ThemeMode initialThemeMode})
    : super(ThemeState(initialThemeMode));

  void changeTheme(ThemeMode themeMode) {
    emit(ThemeState(themeMode));
  }

  void toggleTheme() {
    final currentMode = state.themeMode;
    emit(
      ThemeState(
        currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }
}

class ThemeState {
  final ThemeMode themeMode;

  ThemeState(this.themeMode);

  ThemeData get themeData {
    return themeMode == ThemeMode.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }
}
