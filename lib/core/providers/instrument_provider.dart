import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/instrument_service.dart';
import '../../features/learn/domain/models/instrument.dart';

final instrumentListProvider = FutureProvider<List<InstrumentSummary>>((ref) {
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
