import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _selectedTab = 0;
  int _selectedRhythm = 0;
  double _bpm = 60;
  bool _isPlaying = false;

  final _tabs = [
    {'icon': Iconsax.music_dashboard, 'label': 'Nhịp điệu'},
    {'icon': Iconsax.music5, 'label': 'Gam âm'},
    {'icon': Iconsax.game, 'label': 'Đố vui'},
    {'icon': Iconsax.cpu, 'label': 'AI Pitch'},
  ];

  final _rhythms = [
    {
      'name': 'Nhịp 4/4 cơ bản',
      'desc': 'Nhịp cơ bản 4/4 để luyện giữ nhịp đều',
      'level': 'Beginner',
      'bpm': 60,
    },
    {
      'name': 'Nhịp chèo',
      'desc': 'Nhịp điệu đặc trưng của hát chèo Bắc Bộ',
      'level': 'Intermediate',
      'bpm': 80,
    },
    {
      'name': 'Nhịp cải lương',
      'desc': 'Nhịp điệu của đờn ca tài tử và cải lương Nam Bộ',
      'level': 'Advanced',
      'bpm': 100,
    },
  ];

  Color _levelColor(String level) {
    switch (level) {
      case 'Beginner':
        return const Color(0xFF16A34A);
      case 'Intermediate':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(),
                  const SizedBox(height: 24),
                  if (_selectedTab == 0) ...[
                    Text('Chọn nhịp luyện tập', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildRhythmList(),
                    const SizedBox(height: 20),
                    _buildMetronomeCard(),
                  ] else
                    _buildComingSoon(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.music5, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Folkify',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('🥁', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Luyện tập',
                style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Rèn kỹ năng âm nhạc mỗi ngày', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab['label'] as String,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRhythmList() {
    return Column(
      children: _rhythms.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        final isSelected = _selectedRhythm == i;
        final level = r['level'] as String;
        final color = _levelColor(level);
        return GestureDetector(
          onTap: () => setState(() {
            _selectedRhythm = i;
            _bpm = (r['bpm'] as int).toDouble();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r['name'] as String,
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(level, style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r['desc'] as String, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '${r['bpm']} BPM',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetronomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Máy đếm nhịp', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Iconsax.clock, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '${_bpm.toInt()} BPM',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('40 BPM', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              Text('160 BPM', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _bpm,
              min: 40,
              max: 160,
              onChanged: (v) => setState(() => _bpm = v),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _iconButton(Iconsax.refresh, onTap: () => setState(() {
                _bpm = (_rhythms[_selectedRhythm]['bpm'] as int).toDouble();
                _isPlaying = false;
              })),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  icon: Icon(_isPlaying ? Iconsax.pause5 : Iconsax.play5, size: 18),
                  label: Text(_isPlaying ? 'Dừng lại' : 'Bắt đầu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: AppTextStyles.labelLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _iconButton(Iconsax.volume_high, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildComingSoon() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Iconsax.clock, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Sắp ra mắt', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('Tính năng đang được phát triển', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
