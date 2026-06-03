import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext ctx) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Đăng xuất', style: AppTextStyles.headlineMedium),
        content: Text('Bạn có chắc muốn đăng xuất?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Wait for dialog dismiss animation before triggering auth state change
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader(context, auth)),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context),
            _buildBadgesTab(),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState auth) {
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
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D7A52),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                ),
                alignment: Alignment.center,
                child: FaIcon(FontAwesomeIcons.solidStar, color: Colors.white, size: 30),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2D7A52), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.pencil, color: AppColors.primary, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            auth.userName ?? 'Người dùng',
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Học viên · 30 ngày',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(icon: FontAwesomeIcons.clock, value: '7', label: 'Bài học'),
              const SizedBox(width: 10),
              _StatChip(icon: FontAwesomeIcons.fire, value: '7', label: 'Streak'),
              const SizedBox(width: 10),
              _StatChip(icon: FontAwesomeIcons.bolt, value: '230', label: 'XP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.titleMedium,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.border,
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Huy hiệu'),
          Tab(text: 'Cài đặt'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubscriptionCard(context),
          const SizedBox(height: 14),
          _buildActivityChart(),
          const SizedBox(height: 14),
          _buildInstrumentProgress(),
          const SizedBox(height: 14),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/premium'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const FaIcon(FontAwesomeIcons.crown, color: Color(0xFFF59E0B), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subscription', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text('Gói hiện tại: Free', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    const data = [
      ('T2', 40.0, false),
      ('T3', 55.0, false),
      ('T4', 30.0, false),
      ('T5', 70.0, false),
      ('T6', 80.0, true),
      ('T7', 50.0, false),
      ('CN', 35.0, false),
    ];
    const maxH = 80.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoạt động tuần này', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: maxH + 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final barH = (d.$2 / 80.0) * maxH;
                final isToday = d.$3;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barH,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [const Color(0xFF166534), AppColors.primary]
                              : [const Color(0xFF4ADE80), AppColors.primary],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.$1,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: isToday ? AppColors.primary : AppColors.textMuted,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Tổng: '),
                TextSpan(
                  text: '225 phút',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' trong tuần'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentProgress() {
    const instruments = [
      ('Đàn Tranh', 70, 2, 5),
      ('Sáo Trúc', 65, 2, 4),
      ('Đàn Bầu', 30, 1, 3),
      ('Đàn Nguyệt', 30, 1, 2),
      ('Đàn Nhị', 0, 0, 2),
      ('Đàn Tỳ Bà', 35, 1, 2),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiến độ theo nhạc cụ', style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          ...instruments.asMap().entries.map((e) {
            final i = e.key;
            final inst = e.value;
            final xp = inst.$2;
            final done = inst.$3;
            final total = inst.$4;
            final progress = total > 0 ? done / total : 0.0;
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(inst.$1, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      ),
                      if (xp > 0) ...[
                        FaIcon(FontAwesomeIcons.bolt, color: const Color(0xFFF59E0B), size: 11),
                        const SizedBox(width: 3),
                        Text('$xp XP', style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFFF59E0B), fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(width: 8),
                      ],
                      Text('$done/$total', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  if (xp > 0) ...[
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const FaIcon(FontAwesomeIcons.fire, color: Color(0xFFF97316), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('7 ngày liên tiếp!', style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFFF97316), fontWeight: FontWeight.w700,
                  )),
                  Text('Hãy giữ vững phong độ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(14, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 22,
                decoration: BoxDecoration(
                  color: i < 7
                      ? const Color(0xFFF97316)
                      : const Color(0xFFF97316).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),
          Text('14 ngày gần nhất', style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFFF97316), fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
    final badges = [
      (FontAwesomeIcons.bullseye, 'Bắt đầu', const Color(0xFF16A34A), true),
      (FontAwesomeIcons.fire, '7 ngày', const Color(0xFFF97316), true),
      (FontAwesomeIcons.music, 'Đầu tiên', AppColors.primary, true),
      (FontAwesomeIcons.star, '100 XP', const Color(0xFFF59E0B), false),
      (FontAwesomeIcons.crown, 'Master', const Color(0xFFF59E0B), false),
      (FontAwesomeIcons.trophy, 'Champion', const Color(0xFFDC2626), false),
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.9,
        children: badges.map((b) {
          final unlocked = b.$4;
          final color = unlocked ? b.$3 : AppColors.textMuted.withValues(alpha: 0.3);
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? b.$3.withValues(alpha: 0.1) : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked ? b.$3.withValues(alpha: 0.35) : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(b.$1, color: color, size: 30),
                const SizedBox(height: 8),
                Text(b.$2,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final menuItems = [
      _MenuItem(icon: FontAwesomeIcons.bell, label: 'Thông báo', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: FontAwesomeIcons.language, label: 'Ngôn ngữ', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: FontAwesomeIcons.circleQuestion, label: 'Trợ giúp & Hỗ trợ', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: FontAwesomeIcons.circleInfo, label: 'Về Folkify', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(
        icon: FontAwesomeIcons.rightFromBracket,
        label: 'Đăng xuất',
        color: AppColors.error,
        onTap: () => _handleLogout(context),
      ),
    ];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: menuItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: FaIcon(item.icon, color: item.color, size: 16),
                    ),
                    title: Text(item.label, style: AppTextStyles.titleMedium.copyWith(
                      color: item.color == AppColors.error ? AppColors.error : AppColors.textPrimary,
                    )),
                    trailing: item.color != AppColors.error
                        ? FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.textMuted, size: 14)
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    minLeadingWidth: 0,
                  ),
                  if (i < menuItems.length - 1)
                    const Divider(height: 0, indent: 64, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final FaIconData icon;
  final String value;
  final String label;
  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Column(
          children: [
            FaIcon(icon, color: Colors.white.withValues(alpha: 0.85), size: 17),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final FaIconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap});
}
