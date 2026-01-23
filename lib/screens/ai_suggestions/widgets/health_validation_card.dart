import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HealthValidationCard extends StatelessWidget {
  final HealthFormState healthData;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const HealthValidationCard({
    super.key,
    required this.healthData,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Xác nhận thông tin sức khỏe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.md,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow('Tuổi', '${healthData.age}'),
          _buildInfoRow('Cân nặng', '${healthData.weight} kg'),
          _buildInfoRow('Chiều cao', '${healthData.height} cm'),
          _buildInfoRow('Chế độ ăn', _mapDietType(healthData.dietType)),
          if (healthData.medicalConditions.isNotEmpty)
            _buildInfoRow('Tình trạng', healthData.medicalConditions.join(', ')),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chỉnh sửa', style: TextStyle(color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  String _mapDietType(String type) {
    switch (type) {
      case 'normal': return 'Bình thường';
      case 'vegan': return 'Thuần chay';
      case 'vegetarian': return 'Ăn chay';
      case 'keto': return 'Keto';
      case 'paleo': return 'Paleo';
      case 'low_carb': return 'Low Carb';
      default: return type;
    }
  }
}
