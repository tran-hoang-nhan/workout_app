import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/user.dart';

class ProfileHeaderCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onEditTap;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: AppFontSize.xl,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.mail_outline, size: 16, color: Colors.white70),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: AppFontSize.sm,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEditTap,
                    child: const Icon(Icons.edit, size: 20, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard('${user.height?.toStringAsFixed(1) ?? '0.0'} cm', 'Chiều cao'),
              _buildInfoCard(user.goal ?? 'N/A', 'Mục tiêu'),
              _buildInfoCard(user.gender ?? 'N/A', 'Giới tính'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppFontSize.xs,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
