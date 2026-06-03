import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SheetMusicScreen extends StatefulWidget {
  const SheetMusicScreen({super.key});

  @override
  State<SheetMusicScreen> createState() => _SheetMusicScreenState();
}

class _SheetMusicScreenState extends State<SheetMusicScreen> {
  String _selectedFilter = 'Tất cả';
  final _filters = ['Tất cả', 'Cơ bản', 'Trung cấp', 'Nâng cao'];
  final _searchController = TextEditingController();

  final _sheets = const [
    _SheetData(title: 'Lý con sáo', instrument: 'Sáo Trúc', level: 'Cơ bản', emoji: '🎋'),
    _SheetData(title: 'Bèo dạt mây trôi', instrument: 'Đàn Tranh', level: 'Trung cấp', emoji: '🎵'),
    _SheetData(title: 'Lưu thủy hành vân', instrument: 'Đàn Nguyệt', level: 'Nâng cao', emoji: '🌙'),
    _SheetData(title: 'Ly con sáo sang sông', instrument: 'Đàn Bầu', level: 'Trung cấp', emoji: '🎶'),
    _SheetData(title: 'Tiếng đàn bầu', instrument: 'Đàn Bầu', level: 'Cơ bản', emoji: '🎶'),
    _SheetData(title: 'Trống hội', instrument: 'Trống Cơm', level: 'Cơ bản', emoji: '🥁'),
    _SheetData(title: 'Xuân về trên bản', instrument: 'Đàn Tranh', level: 'Trung cấp', emoji: '🎵'),
    _SheetData(title: 'Đà cổ hoài lang', instrument: 'Đàn Nguyệt', level: 'Nâng cao', emoji: '🌙'),
  ];

  List<_SheetData> get _filtered {
    var result = _sheets;
    if (_selectedFilter != 'Tất cả') result = result.where((s) => s.level == _selectedFilter).toList();
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) result = result.where((s) => s.title.toLowerCase().contains(query) || s.instrument.toLowerCase().contains(query)).toList();
    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Bản nhạc', style: AppTextStyles.headlineLarge),
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilters(),
          Expanded(child: _buildSheetList()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bản nhạc...',
          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Iconsax.close_square, color: AppColors.textMuted),
                  onPressed: () { _searchController.clear(); setState(() {}); },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final isSelected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(f, style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetList() {
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎼', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Không tìm thấy bản nhạc', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: filtered.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _SheetCard(sheet: filtered[index]),
    );
  }
}

class _SheetData {
  final String title;
  final String instrument;
  final String level;
  final String emoji;
  const _SheetData({required this.title, required this.instrument, required this.level, required this.emoji});
}

class _SheetCard extends StatelessWidget {
  final _SheetData sheet;
  const _SheetCard({required this.sheet});

  Color get _levelColor => switch (sheet.level) {
    'Cơ bản' => AppColors.success,
    'Trung cấp' => AppColors.warning,
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(sheet.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sheet.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 3),
                Text(sheet.instrument, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(sheet.level, style: AppTextStyles.bodySmall.copyWith(color: _levelColor, fontWeight: FontWeight.w600, fontSize: 10)),
              ),
              const SizedBox(height: 8),
              Icon(Iconsax.document5, color: AppColors.primary, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}
