import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class CalendarSlider extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarSlider({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<CalendarSlider> createState() => _CalendarSliderState();
}

class _CalendarSliderState extends State<CalendarSlider> {
  late ScrollController _scrollController;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      1,
    );
    _scrollController = ScrollController();

    // Scroll to selected day after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(widget.selectedDay.day);
    });
  }

  @override
  void didUpdateWidget(CalendarSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay.month != _visibleMonth.month ||
        widget.selectedDay.year != _visibleMonth.year) {
      setState(() {
        _visibleMonth = DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          1,
        );
      });
      _scrollToDay(widget.selectedDay.day);
    }
  }

  void _scrollToDay(int day) {
    if (_scrollController.hasClients) {
      final position = (day - 1) * 60.0; // 45 width + 15 spacing approx
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final days = List.generate(
      daysInMonth,
      (index) => DateTime(_visibleMonth.year, _visibleMonth.month, index + 1),
    );

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hoạt động',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedDay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      helpText: 'Chọn tháng',
                    );
                    if (picked != null) {
                      widget.onDaySelected(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Tháng ${_visibleMonth.month}, ${_visibleMonth.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = _isSameDay(day, widget.selectedDay);
                final isToday = _isSameDay(day, DateTime.now());
                final dayName = _getViDayName(day);

                return GestureDetector(
                  onTap: () => widget.onDaySelected(day),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1)
                          : Border.all(
                              color: AppColors.cardBorder.withValues(
                                alpha: 0.5,
                              ),
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  String _getViDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
