import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/Profile/profile.dart';
import 'package:todo/features/add_todo/presentation/add_todo_page.dart';
import 'package:todo/features/auth/presentation/pages/login_screen.dart';
import 'package:todo/features/home/presentation/page/home_navigation_page.dart';
import 'package:todo/features/onboarding/presentation/page/on_boarding_screen.dart';
import 'package:todo/features/splash/logic/splash_cubit.dart';
import 'package:todo/features/splash/page/splash_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const addTodo = '/add-todo';
  static const profile = '/profile';
}

GoRouter createAppRouter({required SplashCubit splashManager}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeNavigationPage(),
      ),
      GoRoute(
        path: AppRoutes.addTodo,
        builder: (context, state) => const AddTodoPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],

    // Redirect logic based on the current state of the application
    redirect: (context, state) {
      final String currentPath = state.matchedLocation;

      final SplashState splashState = splashManager.state;

      if (splashState is SplashLoading) {
        return (currentPath == AppRoutes.splash) ? null : AppRoutes.splash;
      }
      // If the splash state is not loading, we can navigate away from the splash screen
      if (currentPath != AppRoutes.splash) {
        return null;
      }

      if (splashState is SplashNavigateToOnboarding) {
        return AppRoutes.onboarding;
      }

      if (splashState is SplashNavigateToLogin) {
        return AppRoutes.login;
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(splashManager.stream),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
