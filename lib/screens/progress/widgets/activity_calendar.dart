import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../constants/app_constants.dart';

class ActivityCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;

  const ActivityCalendar({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
