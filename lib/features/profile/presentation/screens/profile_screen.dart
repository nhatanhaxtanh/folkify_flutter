import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Hồ sơ', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: Icon(Iconsax.setting_2, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildProfileHeader(auth),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            _buildAchievements(),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (auth.userName?.isNotEmpty == true ? auth.userName![0].toUpperCase() : '?'),
                    style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceCard, width: 2),
                  ),
                  child: Icon(Iconsax.tick_square, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auth.userName ?? 'Người dùng', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 2),
                Text(auth.userEmail ?? '', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.planFree.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Gói Miễn phí', style: AppTextStyles.bodySmall.copyWith(color: AppColors.planFree, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Iconsax.edit_2, color: AppColors.textMuted, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('🔥', '7', 'Ngày liên tiếp'),
      ('⭐', '450', 'Tổng XP'),
      ('📚', '3', 'Bài đã học'),
      ('🎵', '1', 'Nhạc cụ'),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                Text(s.$1, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(s.$2, style: AppTextStyles.headlineMedium),
                Text(s.$3, style: AppTextStyles.bodySmall.copyWith(fontSize: 9), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      ('🎯', 'Bắt đầu', true),
      ('🔥', '7 ngày', true),
      ('🎵', 'Đầu tiên', true),
      ('⭐', '100 XP', false),
      ('👑', 'Master', false),
      ('🏆', 'Champion', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Huy hiệu', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9,
          children: badges.map((b) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: b.$3 ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: b.$3 ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  b.$1,
                  style: TextStyle(
                    fontSize: 28,
                    color: b.$3 ? null : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  b.$2,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: b.$3 ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(icon: Iconsax.crown5, label: 'Nâng cấp Premium', color: AppColors.primary, onTap: () => context.go('/premium')),
      _MenuItem(icon: Iconsax.notification, label: 'Thông báo', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: Iconsax.language_square, label: 'Ngôn ngữ', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: Iconsax.message_question, label: 'Trợ giúp & Hỗ trợ', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(icon: Iconsax.info_circle, label: 'Về Folkify', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(
        icon: Iconsax.logout,
        label: 'Đăng xuất',
        color: AppColors.error,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              title: Text('Đăng xuất', style: AppTextStyles.headlineMedium),
              content: Text('Bạn có chắc muốn đăng xuất?', style: AppTextStyles.bodyMedium),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(authStateProvider.notifier).logout();
          }
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
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
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                title: Text(item.label, style: AppTextStyles.titleMedium.copyWith(
                  color: item.color == AppColors.error ? AppColors.error : AppColors.textPrimary,
                )),
                trailing: item.color != AppColors.error
                    ? Icon(Iconsax.arrow_right_2, color: AppColors.textMuted, size: 20)
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
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap});
}
