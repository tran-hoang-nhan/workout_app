import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/weight_provider.dart';
import '../../../models/body_metric.dart';

enum ChartType { weight, bmi }
enum TimeRange { days7, days30, all }

class WeightProgressChart extends StatefulWidget {
  const WeightProgressChart({super.key});

  @override
  State<WeightProgressChart> createState() => _WeightProgressChartState();
}

class _WeightProgressChartState extends State<WeightProgressChart> {
  ChartType _selectedChart = ChartType.weight;
  TimeRange _selectedRange = TimeRange.days7;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BIỂU ĐỒ TIẾN TRÌNH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  letterSpacing: 1,
                ),
              ),
              _buildChartTypeSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildRangeSelector(),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final historyAsync = ref.watch(weightHistoryProvider);

                return historyAsync.when(
                  data: (history) {
                    final filteredData = _filterData(history);
                    if (filteredData.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có dữ liệu thông số',
                          style: TextStyle(color: AppColors.grey, fontSize: 13),
                        ),
                      );
                    }
                    return _buildLineChart(filteredData);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Lỗi tải biểu đồ')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeButton('Cân nặng', ChartType.weight),
          _buildTypeButton('BMI', ChartType.bmi),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, ChartType type) {
    final isSelected = _selectedChart == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedChart = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRangeChip('7 ngày', TimeRange.days7),
        const SizedBox(width: 8),
        _buildRangeChip('30 ngày', TimeRange.days30),
        const SizedBox(width: 8),
        _buildRangeChip('Tất cả', TimeRange.all),
      ],
    );
  }

  Widget _buildRangeChip(String label, TimeRange range) {
    final isSelected = _selectedRange == range;
    return GestureDetector(
      onTap: () => setState(() => _selectedRange = range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.grey,
          ),
        ),
      ),
    );
  }

  List<BodyMetric> _filterData(List<BodyMetric> data) {
    if (data.isEmpty) return [];
    
    final sortedData = data.toList()..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final now = DateTime.now();
    switch (_selectedRange) {
      case TimeRange.days7:
        return sortedData.where((m) => now.difference(m.recordedAt).inDays <= 7).toList();
      case TimeRange.days30:
        return sortedData.where((m) => now.difference(m.recordedAt).inDays <= 30).toList();
      case TimeRange.all:
        return sortedData;
    }
  }

  Widget _buildLineChart(List<BodyMetric> data) {
    final spots = data.asMap().entries.map((entry) {
      final value = _selectedChart == ChartType.weight 
          ? entry.value.weight 
          : (entry.value.bmi ?? 0.0);
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.cardBorder.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                
                if (index == 0 || index == data.length - 1 || (data.length > 5 && index == (data.length / 2).floor())) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(data[index].recordedAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: AppColors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
