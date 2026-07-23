import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';

class SheetMusicScreen extends StatefulWidget {
  const SheetMusicScreen({super.key});

  @override
  State<SheetMusicScreen> createState() => _SheetMusicScreenState();
}

class _SheetMusicScreenState extends State<SheetMusicScreen> {
  String _genre = 'Tất cả';
  String _difficulty = 'Tất cả';
  final _searchCtrl = TextEditingController();

  final _genres = ['Tất cả', 'Dân ca', 'Vọng cổ', 'Nhạc mới', 'Nhạc cổ'];
  final _difficulties = ['Tất cả', 'Dễ', 'Trung bình', 'Khó'];

  static const _sheets = [
    _Sheet(title: 'Lý Con Sáo', author: 'Dân ca Nam Bộ', genre: 'Dân ca', difficulty: 'Dễ', pages: 2, isPremium: false),
    _Sheet(title: 'Dạ Cổ Hoài Lang', author: 'Cao Văn Lầu', genre: 'Vọng cổ', difficulty: 'Trung bình', pages: 4, isPremium: false),
    _Sheet(title: 'Bèo Dạt Mây Trôi', author: 'Dân ca Bắc Bộ', genre: 'Dân ca', difficulty: 'Dễ', pages: 3, isPremium: true),
    _Sheet(title: 'Tiếng Đàn Bầu', author: 'Nguyễn Đình Phúc', genre: 'Nhạc mới', difficulty: 'Trung bình', pages: 3, isPremium: true),
    _Sheet(title: 'Thủy Hành Vân', author: 'Nhạc lễ Nam Bộ', genre: 'Nhạc cổ', difficulty: 'Khó', pages: 6, isPremium: true),
    _Sheet(title: 'Tứ Đại Cảnh', author: 'Nhã nhạc cung đình Huế', genre: 'Cổ nhạc', difficulty: 'Trung bình', pages: 3, isPremium: false),
    _Sheet(title: 'Xuân Về Trên Bản', author: 'Hoàng Việt', genre: 'Nhạc mới', difficulty: 'Trung bình', pages: 4, isPremium: true),
    _Sheet(title: 'Lý Ngựa Ô', author: 'Dân ca Bắc Bộ', genre: 'Dân ca', difficulty: 'Dễ', pages: 2, isPremium: false),
  ];

  List<_Sheet> get _filtered {
    return _sheets.where((s) {
      final matchGenre = _genre == 'Tất cả' || s.genre == _genre;
      final matchDiff = _difficulty == 'Tất cả' || s.difficulty == _difficulty;
      final q = _searchCtrl.text.toLowerCase();
      final matchSearch = q.isEmpty || s.title.toLowerCase().contains(q) || s.author.toLowerCase().contains(q);
      return matchGenre && matchDiff && matchSearch;
    }).toList();
  }

  int get _freeCount => _sheets.where((s) => !s.isPremium).length;
  int get _premiumCount => _sheets.where((s) => s.isPremium).length;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildGenreFilters()),
          SliverToBoxAdapter(child: _buildDifficultyFilters()),
          _buildGrid(),
          SliverToBoxAdapter(child: _buildUpdateBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        image: DecorationImage(
          image: AssetImage('assets/images/header_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', width: 36, height: 36, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Text('Folkify', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.fileLines, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Sheet nhạc', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$_freeCount miễn phí · $_premiumCount premium',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                FaIcon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primary, size: 15),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tìm bài nhạc, tác giả...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchCtrl.clear(); setState(() {}); },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FaIcon(FontAwesomeIcons.circleXmark, color: AppColors.textMuted, size: 16),
                    ),
                  )
                else
                  const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _genres.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final g = _genres[i];
            final selected = _genre == g;
            return GestureDetector(
              onTap: () => setState(() => _genre = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(g, style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 16),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _difficulties.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = _difficulties[i];
            final selected = _difficulty == d;
            return GestureDetector(
              onTap: () => setState(() => _difficulty = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(d, style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final sheets = _filtered;
    if (sheets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Column(
              children: [
                FaIcon(FontAwesomeIcons.music, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('Không tìm thấy bản nhạc', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _SheetCard(sheet: sheets[i]),
          childCount: sheets.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  Widget _buildUpdateBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.calendar, color: Colors.white.withValues(alpha: 0.9), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cập nhật định kỳ', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'Thư viện sheet nhạc được bổ sung hàng tuần với các bản nhạc dân tộc và hiện đại.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet {
  final String title;
  final String author;
  final String genre;
  final String difficulty;
  final int pages;
  final bool isPremium;
  const _Sheet({
    required this.title, required this.author, required this.genre,
    required this.difficulty, required this.pages, required this.isPremium,
  });
}

class _SheetCard extends ConsumerWidget {
  final _Sheet sheet;
  const _SheetCard({required this.sheet});

  Color get _diffColor => switch (sheet.difficulty) {
    'Dễ' => const Color(0xFF16A34A),
    'Trung bình' => const Color(0xFFD97706),
    _ => const Color(0xFFDC2626),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sheet premium chỉ mở khóa khi user là thành viên premium (BASIC hoặc PRO).
    final locked = sheet.isPremium && !ref.watch(authStateProvider).isPremium;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet preview image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: _SheetPreview(),
              ),
              if (sheet.isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(FontAwesomeIcons.crown, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        Text('Premium', style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10,
                        )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sheet.title, style: AppTextStyles.titleMedium.copyWith(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(sheet.author, style: AppTextStyles.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _diffColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(sheet.difficulty, style: AppTextStyles.bodySmall.copyWith(
                          color: _diffColor, fontWeight: FontWeight.w600, fontSize: 10,
                        )),
                      ),
                      const SizedBox(width: 6),
                      Text('${sheet.pages} trang', style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (locked) {
                          context.push('/premium');
                        } else {
                          _showDownloadSheet(context, sheet);
                        }
                      },
                      icon: FaIcon(
                        locked ? FontAwesomeIcons.lock : FontAwesomeIcons.download,
                        size: 11, color: Colors.white,
                      ),
                      label: Text(locked ? 'Mở khóa' : 'Tải về'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: locked ? const Color(0xFFF59E0B) : AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                        minimumSize: Size.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDownloadSheet(BuildContext context, _Sheet sheet) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DownloadBottomSheet(sheet: sheet),
  );
}

class _DownloadBottomSheet extends StatefulWidget {
  final _Sheet sheet;
  const _DownloadBottomSheet({required this.sheet});

  @override
  State<_DownloadBottomSheet> createState() => _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends State<_DownloadBottomSheet> {
  bool _downloading = false;
  bool _done = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _downloading = false; _done = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: FaIcon(FontAwesomeIcons.fileLines, color: AppColors.primary, size: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.sheet.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${widget.sheet.author} · ${widget.sheet.pages} trang',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_done)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                const SizedBox(width: 8),
                Text('Đã lưu vào thư viện', style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF16A34A), fontWeight: FontWeight.w600,
                )),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const FaIcon(FontAwesomeIcons.download, size: 16, color: Colors.white),
                label: Text(_downloading ? 'Đang tải...' : 'Tải xuống PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Placeholder trông như tờ sheet nhạc
class _SheetPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(8, (i) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          height: 1.5,
          width: double.infinity,
          color: Colors.black.withValues(alpha: i % 4 == 0 ? 0.25 : 0.1),
        )),
      ),
    );
  }
}
