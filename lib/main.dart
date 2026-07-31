import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/core/cubit/theme_bloc.dart';
import 'package:todo/data/todo_repository.dart';
import 'package:todo/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/auth/presentation/logic/auth_manager.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:todo/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:todo/features/onboarding/presentation/logic/onboarding_manager.dart';
import 'package:todo/features/pomodoro/logic/pomodoro_cubit.dart';
import 'package:todo/features/splash/logic/splash_manager.dart';

import 'package:todo/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final AuthRepository _authRepository;
  late final OnboardingRepository _onboardingRepository;

  late final ThemeBloc _themeBloc;
  late final SplashManager _splashManager;
  late final AuthManager _authManager;
  late final OnboardingManager _onboardingManager;
  late final TodoCubit _taskManager;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(AuthLocalDataSource());
    _onboardingRepository = OnboardingRepository(OnboardingLocalDataSource());
    _themeBloc = ThemeBloc(initialThemeMode: ThemeMode.light);
    _authManager = AuthManager(_authRepository);
    _onboardingManager = OnboardingManager(_onboardingRepository);
    _splashManager = SplashManager(onboardingRepository: _onboardingRepository);
    _taskManager = TodoCubit(TodoRepository());
    _router = createAppRouter(splashManager: _splashManager);

    unawaited(_authManager.syncAuthState());
    unawaited(_onboardingManager.syncOnboardingState());
  }

  @override
  void dispose() {
    _taskManager.close();
    _onboardingManager.close();
    _authManager.close();
    _splashManager.close();
    _themeBloc.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: _themeBloc),
        BlocProvider<SplashManager>.value(value: _splashManager),
        BlocProvider<AuthManager>.value(value: _authManager),
        BlocProvider<OnboardingManager>.value(value: _onboardingManager),
        BlocProvider<TodoCubit>.value(value: _taskManager),
        BlocProvider<PomodoroCubit>(create: (context) => PomodoroCubit()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Todo App',
            theme: themeState.themeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
