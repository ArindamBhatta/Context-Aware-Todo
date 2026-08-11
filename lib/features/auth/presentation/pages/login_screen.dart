import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/router/app_router.dart';
import 'package:todo/features/auth/presentation/logic/auth_cubit.dart';
import 'package:todo/features/auth/presentation/logic/biometric_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  bool _isLoading = false;
  bool _canUseDeviceAuth = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _prepareScreen();
  }

  Future<void> _prepareScreen() async {
    final AuthCubit authManager = context.read<AuthCubit>();

    final results = await Future.wait<dynamic>([
      authManager.isLoggedIn(),
      _biometricAuthService.canUseDeviceAuth(),
    ]);

    final bool isLoggedIn = results[0] as bool;
    final bool canUseDeviceAuth = results[1] as bool;

    if (!mounted) return;

    setState(() {
      _isLoggedIn = isLoggedIn;
      _canUseDeviceAuth = canUseDeviceAuth;
    });

    // If user is already logged in, trigger OS biometric verification natively
    if (isLoggedIn && canUseDeviceAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyBiometric();
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthCubit authManager = context.read<AuthCubit>();
      final bool success = await authManager.signInWithGoogle();

      if (!success) {
        _showMessage('Google sign-in was cancelled.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoggedIn = true;
      });

      // Verify device security after Google sign-in
      if (_canUseDeviceAuth) {
        await _verifyBiometric();
      } else {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      _showMessage('Sign-in failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyBiometric() async {
    if (!_canUseDeviceAuth) {
      context.go(AppRoutes.home);
      return;
    }

    try {
      final bool authenticated =
          await _biometricAuthService.authenticateWithDeviceCredentials();

      if (authenticated && mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      _showMessage('Device authentication failed.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceBright,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding Logo
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 46,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Welcome Heading
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Sign in to manage your tasks, track daily progress, and stay organized.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 44),

                  // Google Sign-In Button (Production Standard)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        elevation: 2,
                        shadowColor: colorScheme.shadow.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.primary,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 20,
                                    color: Color(0xFF4285F4),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  // Quick Biometric Trigger (if logged in and device auth available)
                  if (_isLoggedIn && _canUseDeviceAuth) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _verifyBiometric,
                        icon: Icon(
                          Icons.fingerprint_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        label: Text(
                          'Unlock with Biometrics',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),

                  // Footer security badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secured with Google & Device Protection',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
