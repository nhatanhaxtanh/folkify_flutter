import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/progress_service.dart';
import 'auth_provider.dart';

final userProgressProvider = FutureProvider<UserProgress>((ref) {
  final isLoggedIn = ref.watch(authStateProvider).isLoggedIn;
  if (!isLoggedIn) throw Exception('not_logged_in');
  return ProgressService.getProgress();
});

final achievementsProvider = FutureProvider<AchievementsData>((ref) {
  final isLoggedIn = ref.watch(authStateProvider).isLoggedIn;
  if (!isLoggedIn) throw Exception('not_logged_in');
  return ProgressService.getAchievements();
});

final weeklyActivityProvider = FutureProvider<List<ActivityDay>>((ref) {
  final isLoggedIn = ref.watch(authStateProvider).isLoggedIn;
  if (!isLoggedIn) throw Exception('not_logged_in');
  return ProgressService.getWeeklyActivity();
});
