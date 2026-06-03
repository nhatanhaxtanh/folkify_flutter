import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/learn/presentation/screens/learn_screen.dart';
import '../../features/learn/presentation/screens/instrument_detail_screen.dart';
import '../../features/learn/presentation/screens/lesson_detail_screen.dart';
import '../../features/practice/presentation/screens/practice_screen.dart';
import '../../features/sheets/presentation/screens/sheet_music_screen.dart';
import '../../features/premium/presentation/screens/premium_plans_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/main_shell.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/learn', builder: (_, __) => const LearnScreen()),
          GoRoute(
            path: '/learn/:id',
            builder: (_, state) => InstrumentDetailScreen(
              instrumentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/learn/:id/lesson/:lessonId',
            builder: (_, state) => LessonDetailScreen(
              instrumentId: state.pathParameters['id']!,
              lessonId: state.pathParameters['lessonId']!,
            ),
          ),
          GoRoute(path: '/practice', builder: (_, __) => const PracticeScreen()),
          GoRoute(path: '/sheets', builder: (_, __) => const SheetMusicScreen()),
          GoRoute(path: '/premium', builder: (_, __) => const PremiumPlansScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.error}'),
      ),
    ),
  );
});
