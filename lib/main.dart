import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/cubit/theme_bloc.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/core/theme/app_theme.dart';
import 'package:todo/data/todo_repository.dart';
import 'package:todo/features/auth/data/service/local_auth_service.dart';
import 'package:todo/features/auth/data/repositories/auth_repository.dart';
import 'package:todo/features/auth/presentation/logic/auth_cubit.dart';
import 'package:todo/features/home/presentation/logic/todo_cubit.dart';
import 'package:todo/features/onboarding/data/service/on_boarding_local_service.dart';
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
    //Now Reposotory access like context.read<AuthRepository>()
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(LocalAuthService()),
        ),

        RepositoryProvider<OnBoardingRepository>(
          create: (context) => OnBoardingRepository(OnBoardingLocalService()),
        ),

        RepositoryProvider<TodoRepository>(
          create: (context) => TodoRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(initialThemeMode: ThemeMode.system),
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
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});
  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Access providers via context once providers are mounted
    _router = createAppRouter(splashManager: context.read<SplashCubit>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Todo App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
