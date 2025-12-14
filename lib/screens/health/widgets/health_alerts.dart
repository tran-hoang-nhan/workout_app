import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HealthAlerts extends StatelessWidget {
  final HealthFormState formState;

  const HealthAlerts({
    super.key,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.orange.shade600, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Lưu ý sức khỏe',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (formState.injuries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    'Chấn thương: ',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      formState.injuries.join(', '),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (formState.medicalConditions.isNotEmpty)
            Row(
              children: [
                Text(
                  'Tình trạng: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    formState.medicalConditions.join(', '),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
