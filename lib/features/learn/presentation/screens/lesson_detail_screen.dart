import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../data/instruments_data.dart';
import '../../domain/models/instrument.dart';

class LessonDetailScreen extends StatefulWidget {
  final String instrumentId;
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.instrumentId,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentStep = 0;
  bool _completed = false;

  Instrument? get _instrument =>
      kInstruments.where((i) => i.id == widget.instrumentId).firstOrNull;

  Lesson? get _lesson => _instrument?.lessons
      .where((l) => l.id == widget.lessonId)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final inst = _instrument;
    final lesson = _lesson;

    if (inst == null || lesson == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Không tìm thấy bài học')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/learn/${widget.instrumentId}'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inst.name, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            Text(lesson.title, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('+${lesson.xp} XP', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: _completed ? _buildCompletionView(context, lesson) : _buildLessonView(context, lesson),
    );
  }

  Widget _buildLessonView(BuildContext context, Lesson lesson) {
    return Column(
      children: [
        _buildProgressBar(lesson),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildVideoPlaceholder(lesson),
                const SizedBox(height: 24),
                _buildDescription(lesson),
                const SizedBox(height: 24),
                _buildStepsSection(lesson),
                const SizedBox(height: 24),
                _buildTipsSection(lesson),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomActions(context, lesson),
      ],
    );
  }

  Widget _buildProgressBar(Lesson lesson) {
    final progress = ((_currentStep + 1) / lesson.steps.length).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bước ${_currentStep + 1}/${lesson.steps.length}', style: AppTextStyles.bodySmall),
              Text('${(progress * 100).toInt()}%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(Lesson lesson) {
    if (lesson.youtubeUrl != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 8),
              Text('Xem video hướng dẫn', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.video, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 8),
            Text('Video sắp ra mắt', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giới thiệu', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(lesson.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
      ],
    );
  }

  Widget _buildStepsSection(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Các bước thực hiện', style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        ...lesson.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isDone = index < _currentStep;
          final isCurrent = index == _currentStep;
          return GestureDetector(
            onTap: () => setState(() => _currentStep = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border,
                  width: 0.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.primary
                              : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDone
                          ? FaIcon(FontAwesomeIcons.squareCheck, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isCurrent ? Colors.white : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTipsSection(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.lightbulb, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text('Mẹo luyện tập', style: AppTextStyles.titleMedium.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 10),
          ...lesson.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning)),
                    Expanded(child: Text(tip, style: AppTextStyles.bodyMedium.copyWith(height: 1.5))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Lesson lesson) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Trước'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: GradientButton(
              text: _currentStep < lesson.steps.length - 1 ? 'Bước tiếp theo' : 'Hoàn thành!',
              onPressed: () {
                if (_currentStep < lesson.steps.length - 1) {
                  setState(() => _currentStep++);
                } else {
                  setState(() => _completed = true);
                }
              },
              icon: _currentStep < lesson.steps.length - 1
                  ? FontAwesomeIcons.arrowRight
                  : FontAwesomeIcons.circleCheck,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, Lesson lesson) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.trophy, color: AppColors.primary, size: 80),
            const SizedBox(height: 24),
            Text('Bài học hoàn thành!', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Bạn vừa hoàn thành "${lesson.title}"',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.star, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text('+${lesson.xp}', style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary)),
                      Text('XP nhận được', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Tiếp tục học',
              onPressed: () => context.go('/learn/${widget.instrumentId}'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
