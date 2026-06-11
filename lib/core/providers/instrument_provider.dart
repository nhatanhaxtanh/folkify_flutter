import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/instrument_service.dart';
import '../providers/auth_provider.dart';
import '../../features/learn/domain/models/instrument.dart';

final instrumentListProvider = FutureProvider<List<InstrumentSummary>>((ref) {
  final isLoggedIn = ref.watch(authStateProvider).isLoggedIn;
  if (!isLoggedIn) throw Exception('not_logged_in');
  return InstrumentService.getAll();
});

final instrumentDetailProvider =
    FutureProvider.family<Instrument, String>((ref, slug) {
  return InstrumentService.getDetail(slug);
});

typedef LessonParams = ({String instrumentSlug, String lessonSlug});

final lessonDetailProvider =
    FutureProvider.family<Lesson, LessonParams>((ref, params) {
  return InstrumentService.getLessonDetail(
      params.instrumentSlug, params.lessonSlug);
});
