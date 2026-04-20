import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/loading_animation.dart';
import 'ai_suggestions_screen.dart';

class AISuggestionsHistoryScreen extends ConsumerWidget {
  const AISuggestionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(aiSuggestionHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử gợi ý AI',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.lg,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(aiSuggestionHistoryProvider.future),
        child: historyAsync.when(
          loading: () => const Center(
            child: AppLoading(message: 'Đang tải lịch sử...'),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Lỗi: $error'),
                TextButton(
                  onPressed: () => ref.invalidate(aiSuggestionHistoryProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (history) {
            if (history.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: AppColors.grey, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có lịch sử gợi ý nào.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.recordedAt);
                final title = item.plan?.title ?? 'Gợi ý không tên';
                final prompt = item.userPrompt ?? 'Không có yêu cầu đặc biệt';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7F00).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFF7F00),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Yêu cầu: $prompt',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (item.plan != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AISuggestionsScreen(
                              historyItem: item,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
