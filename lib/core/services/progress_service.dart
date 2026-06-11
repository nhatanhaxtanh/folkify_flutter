import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_service.dart';

class InstrumentProgress {
  final String slug;
  final String name;
  final String emoji;
  final String color;
  final int completedLessons;
  final int totalLessons;
  final double progressPercent;

  const InstrumentProgress({
    required this.slug,
    required this.name,
    required this.emoji,
    required this.color,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercent,
  });

  factory InstrumentProgress.fromJson(Map<String, dynamic> json) =>
      InstrumentProgress(
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '🎵',
        color: json['color'] as String? ?? '#1a5c2e',
        completedLessons: json['completedLessons'] as int? ?? 0,
        totalLessons: json['totalLessons'] as int? ?? 0,
        progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      );
}

class UserProgress {
  final int totalXp;
  final int totalLessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final List<InstrumentProgress> instruments;

  const UserProgress({
    required this.totalXp,
    required this.totalLessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.instruments,
  });

  int get totalLessons =>
      instruments.fold(0, (sum, i) => sum + i.totalLessons);

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
        totalLessonsCompleted: json['totalLessonsCompleted'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        instruments: (json['instruments'] as List?)
                ?.map((e) =>
                    InstrumentProgress.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class ActivityDay {
  final String dayLabel;
  final int xpEarned;
  final int minutes;
  final bool isToday;

  const ActivityDay({
    required this.dayLabel,
    required this.xpEarned,
    required this.minutes,
    required this.isToday,
  });

  factory ActivityDay.fromJson(Map<String, dynamic> json) => ActivityDay(
        dayLabel: json['dayLabel'] as String? ?? '',
        xpEarned: json['xpEarned'] as int? ?? 0,
        minutes: json['minutes'] as int? ?? 0,
        isToday: json['today'] as bool? ?? false,
      );
}

class Achievement {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedAt;

  const Achievement({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json,
          {required bool unlocked}) =>
      Achievement(
        id: json['id'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? 'medal',
        unlocked: unlocked,
        unlockedAt: json['unlockedAt'] as String?,
      );
}

class AchievementsData {
  final List<Achievement> unlocked;
  final List<Achievement> locked;

  const AchievementsData({required this.unlocked, required this.locked});

  List<Achievement> get all => [...unlocked, ...locked];

  factory AchievementsData.fromJson(Map<String, dynamic> json) =>
      AchievementsData(
        unlocked: (json['unlocked'] as List?)
                ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>,
                    unlocked: true))
                .toList() ??
            const [],
        locked: (json['locked'] as List?)
                ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>,
                    unlocked: false))
                .toList() ??
            const [],
      );
}

class CompleteLessonResult {
  final int xpEarned;
  final int totalXp;
  final int currentStreak;
  final List<Achievement> newAchievements;

  const CompleteLessonResult({
    required this.xpEarned,
    required this.totalXp,
    required this.currentStreak,
    required this.newAchievements,
  });

  factory CompleteLessonResult.fromJson(Map<String, dynamic> json) =>
      CompleteLessonResult(
        xpEarned: json['xpEarned'] as int? ?? 0,
        totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        newAchievements: (json['newAchievements'] as List?)
                ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>,
                    unlocked: true))
                .toList() ??
            const [],
      );
}

class ProgressService {
  static final _dio = ApiClient.instance;

  static Future<UserProgress> getProgress() async {
    try {
      final res = await _dio.get('/api/progress');
      return UserProgress.fromJson(res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<AchievementsData> getAchievements() async {
    try {
      final res = await _dio.get('/api/progress/achievements');
      return AchievementsData.fromJson(
          res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<List<ActivityDay>> getWeeklyActivity() async {
    try {
      final res = await _dio.get('/api/progress/activity');
      final list = res.data['result'] as List;
      return list
          .map((e) => ActivityDay.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<CompleteLessonResult> completeLesson(String lessonUuid) async {
    try {
      final res =
          await _dio.post('/api/progress/lessons/$lessonUuid/complete');
      return CompleteLessonResult.fromJson(
          res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'] as String;
      }
    } catch (_) {}
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Kết nối quá thời gian, vui lòng thử lại',
      DioExceptionType.connectionError => 'Không thể kết nối máy chủ',
      _ => 'Lỗi không xác định',
    };
  }
}
