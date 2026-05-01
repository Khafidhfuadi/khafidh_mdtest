import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khafidh_mdtest/core/constants/app_colors.dart';
import 'package:khafidh_mdtest/core/widgets/verification_badge.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 24),
            _buildInfoSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nama
          Text(
            user.name.isNotEmpty ? user.name : 'Tanpa Nama',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Badge verifikasi
          VerificationBadge(isVerified: user.isEmailVerified),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    final dateFormatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    final Duration memberSince = DateTime.now().difference(user.createdAt);

    String memberDuration;
    if (memberSince.inDays >= 365) {
      final years = (memberSince.inDays / 365).floor();
      final months = ((memberSince.inDays % 365) / 30).floor();
      memberDuration = '$years tahun';
      if (months > 0) memberDuration += ' $months bulan';
    } else if (memberSince.inDays >= 30) {
      final months = (memberSince.inDays / 30).floor();
      memberDuration = '$months bulan';
    } else if (memberSince.inDays >= 1) {
      memberDuration = '${memberSince.inDays} hari';
    } else if (memberSince.inHours >= 1) {
      memberDuration = '${memberSince.inHours} jam';
    } else {
      memberDuration = 'Baru saja';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Akun',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            theme,
            children: [
              _buildInfoRow(
                theme,
                icon: Icons.badge_outlined,
                label: 'User ID',
                value: user.uid,
              ),
              _buildDivider(theme),
              _buildInfoRow(
                theme,
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _buildDivider(theme),
              _buildInfoRow(
                theme,
                icon: Icons.verified_user_outlined,
                label: 'Status Verifikasi',
                valueWidget: VerificationBadge(
                  isVerified: user.isEmailVerified,
                ),
              ),
              _buildDivider(theme),
              _buildInfoRow(
                theme,
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal Bergabung',
                value: _formatDate(user.createdAt, dateFormatter),
              ),
              _buildDivider(theme),
              _buildInfoRow(
                theme,
                icon: Icons.access_time_outlined,
                label: 'Lama Bergabung',
                value: memberDuration,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, DateFormat formatter) {
    try {
      return formatter.format(date);
    } catch (_) {
      // Fallback jika locale id_ID belum diinisialisasi
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }

  Widget _buildInfoCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (valueWidget != null)
                  valueWidget
                else
                  Text(
                    value ?? '-',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 48,
      color: AppColors.borderLight.withOpacity(0.3),
    );
  }
}
