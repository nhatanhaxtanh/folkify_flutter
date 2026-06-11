import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/progress_service.dart';

final userProgressProvider = FutureProvider<UserProgress>((ref) {
  return ProgressService.getProgress();
});

final achievementsProvider = FutureProvider<AchievementsData>((ref) {
  return ProgressService.getAchievements();
});

final weeklyActivityProvider = FutureProvider<List<ActivityDay>>((ref) {
  return ProgressService.getWeeklyActivity();
});
