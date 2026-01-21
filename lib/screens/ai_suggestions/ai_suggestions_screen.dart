import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AISuggestionsScreen extends StatelessWidget {
  const AISuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gợi ý từ AI',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.lg,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIStatusHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('Lộ trình hôm nay'),
            const SizedBox(height: AppSpacing.md),
            _buildPlaceholderCard('Buổi tập cường độ cao', 'Dựa trên hiệu suất hôm qua của bạn'),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Dinh dưỡng gợi ý'),
            const SizedBox(height: AppSpacing.md),
            _buildPlaceholderCard('Thực đơn giàu Protein', 'Tối ưu cho quá trình phục hồi cơ bắp'),
            const SizedBox(height: AppSpacing.xxl),
            _buildAIInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7F00), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7F00).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Hệ thống AI đang hoạt động',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dữ liệu của bạn đã được cập nhật 5 phút trước',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: AppFontSize.sm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppFontSize.lg,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildPlaceholderCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7F00).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Color(0xFFFF7F00)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.md,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: Color(0xFFFF7F00), size: 18),
              SizedBox(width: 8),
              Text(
                'Phân tích từ AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.md,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Bạn đang có xu hướng tập luyện tốt ở nhóm cơ ngực. AI gợi ý bạn nên tập trung thêm vào nhóm cơ lưng để cân bằng thể trạng.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppFontSize.sm,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Xem báo cáo chi tiết →',
              style: TextStyle(color: Color(0xFFFF7F00), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
