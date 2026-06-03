import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
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

// Bridges Riverpod auth state → GoRouter refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authStateProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }
  final Ref _ref;

  bool get isLoggedIn => _ref.read(authStateProvider).isLoggedIn;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const HomeScreen())),
          GoRoute(path: '/learn', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const LearnScreen())),
          GoRoute(
            path: '/learn/:id',
            pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: InstrumentDetailScreen(
              instrumentId: s.pathParameters['id']!,
            )),
          ),
          GoRoute(
            path: '/learn/:id/lesson/:lessonId',
            pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: LessonDetailScreen(
              instrumentId: s.pathParameters['id']!,
              lessonId: s.pathParameters['lessonId']!,
            )),
          ),
          GoRoute(path: '/practice', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const PracticeScreen())),
          GoRoute(path: '/sheets', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const SheetMusicScreen())),
          GoRoute(path: '/premium', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const PremiumPlansScreen())),
          GoRoute(path: '/profile', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const ProfileScreen())),
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
