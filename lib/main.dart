import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/core/cubit/theme_bloc.dart';
import 'package:todo/data/todo_repository.dart';
import 'package:todo/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/auth/presentation/logic/auth_cubit.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/onboarding/data/datasources/onBoarding_local_datasource.dart';
import 'package:todo/features/onboarding/data/repositories/on_boarding_repository.dart';
import 'package:todo/features/onboarding/presentation/logic/on_boarding_cubit.dart';
import 'package:todo/features/pomodoro/logic/pomodoro_cubit.dart';
import 'package:todo/features/splash/logic/splash_cubit.dart';
import 'package:todo/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(AuthLocalDataSource()),
        ),

        RepositoryProvider<OnBoardingRepository>(
          create:
              (context) => OnBoardingRepository(OnBoardingLocalDataSource()),
        ),

        RepositoryProvider<TodoRepository>(
          create: (context) => TodoRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(initialThemeMode: ThemeMode.system),
          ),

          //Splash Cubit
          BlocProvider(
            create:
                (context) => SplashCubit(
                  onBoardingRepository: context.read<OnBoardingRepository>(),
                ),
          ),

          //Auth Cubit
          BlocProvider<AuthCubit>(
            create:
                (context) =>
                    AuthCubit(context.read<AuthRepository>())..syncAuthState(),
          ),

          //OnBoarding Cubit
          BlocProvider<OnBoardingCubit>(
            create:
                (context) =>
                    OnBoardingCubit(context.read<OnBoardingRepository>()),
          ),

          BlocProvider(
            create: (context) => TodoCubit(context.read<TodoRepository>()),
          ),

          //Pomodoro Cubit
          BlocProvider(create: (context) => PomodoroCubit()),
        ],
        child: Placeholder(),
      ),
    );
  }
}
