import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'widgets/ai_suggestions_section.dart';

import '../../providers/notification_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/progress_provider.dart';
import '../notification/notification_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    // Sync health data to ensure correct calorie goals
    ref.watch(syncHealthProfileProvider);
    ref.watch(syncDailySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            90,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        userAsync.when(
                          data: (user) {
                            final avatarUrl = user?.avatarUrl;
                            final fullName = user?.fullName ?? 'User';
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1.5,
                                ),
                                image: DecorationImage(
                                  image:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : NetworkImage(
                                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=FF7F00&color=fff',
                                        ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          loading: () => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              color: AppColors.grey.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          error: (_, _) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://ui-avatars.com/api/?name=User&background=FF7F00&color=fff',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: userAsync.when(
                            data: (user) {
                              final fullName = user?.fullName ?? 'User';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chào mừng trở lại! 👋',
                                    style: TextStyle(
                                      fontSize: AppFontSize.xs,
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontSize: AppFontSize.lg,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                            loading: () => const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chào mừng trở lại! 👋',
                                  style: TextStyle(
                                    fontSize: AppFontSize.xs,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: AppFontSize.lg,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                            error: (_, _) => const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chào mừng trở lại! 👋',
                                  style: TextStyle(
                                    fontSize: AppFontSize.xs,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'User',
                                  style: TextStyle(
                                    fontSize: AppFontSize.lg,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBorder.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(fontSize: 9),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.black,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // AI Suggestions Section
              const AISuggestionsSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
