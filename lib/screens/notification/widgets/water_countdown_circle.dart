import 'dart:async';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class WaterCountdownCircle extends StatefulWidget {
  final DateTime startTime;
  final Duration duration;

  const WaterCountdownCircle({
    super.key,
    required this.startTime,
    required this.duration,
  });

  @override
  State<WaterCountdownCircle> createState() => _WaterCountdownCircleState();
}

class _WaterCountdownCircleState extends State<WaterCountdownCircle> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final end = widget.startTime.add(widget.duration);
    final diff = end.difference(now);

    if (diff.isNegative) {
      _remaining = Duration.zero;
      _timer.cancel();
    } else {
      _remaining = diff;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) return const SizedBox.shrink();

    final totalSeconds = widget.duration.inSeconds;
    final remainingSeconds = _remaining.inSeconds;
    final progress = remainingSeconds / totalSeconds;

    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                strokeWidth: 3,
              ),
            ),
            const Icon(
              Icons.timer_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ly tiếp theo sau:',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
