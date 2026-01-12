import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/progress_user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/progress_user.dart';

class RunningCard extends ConsumerStatefulWidget {
  const RunningCard({super.key});

  @override
  ConsumerState<RunningCard> createState() => _RunningCardState();
}

class _RunningCardState extends ConsumerState<RunningCard> {
  bool _isTracking = false;
  double _totalDistance = 0.0; // in meters
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  int _secondsElapsed = 0;
  
  // Approximate conversion: 1 meter = 1.3 steps
  static const double _stepsPerMeter = 1.31;

  int get _stepsCount => (_totalDistance * _stepsPerMeter).round();

  String _formatDuration(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _stopTracking();
    } else {
      await _startTracking();
    }
  }

  Future<void> _startTracking() async {
    // Provide immediate feedback
    setState(() {
      _isTracking = true;
      _totalDistance = 0.0;
      _secondsElapsed = 0;
      _lastPosition = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí')),
          );
        }
        _resetTrackingState();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
            );
          }
          _resetTrackingState();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quyền vị trí bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.')),
          );
        }
        _resetTrackingState();
        return;
      }

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "Đang theo dõi quãng đường chạy bộ của bạn",
            notificationTitle: "Chạy bộ đang hoạt động",
            enableWakeLock: true,
          ),
        ),
      ).listen((Position position) {
        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          setState(() {
            _totalDistance += distance;
          });
        }
        _lastPosition = position;
      });
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      _resetTrackingState();
    }
  }

  void _resetTrackingState() {
    if (mounted) {
      setState(() {
        _isTracking = false;
        _timer?.cancel();
        _positionStream?.cancel();
      });
    }
  }

  Future<void> _stopTracking() async {
    _timer?.cancel();
    await _positionStream?.cancel();
    _positionStream = null;

    final stepsToAdd = _stepsCount;
    if (stepsToAdd > 0) {
      await _saveProgress(stepsToAdd);
    }

    setState(() {
      _isTracking = false;
      _totalDistance = 0.0;
      _lastPosition = null;
      _secondsElapsed = 0;
    });
  }

  Future<void> _saveProgress(int steps) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      final repo = ref.read(progressUserRepositoryProvider);
      final userId = (await ref.read(currentUserIdProvider.future));
      
      if (userId == null) return;

      final existingProgress = await repo.getProgress(userId, today);
      
      final updatedProgress = (existingProgress ?? ProgressUser(userId: userId, date: today)).copyWith(
        steps: (existingProgress?.steps ?? 0) + steps,
      );

      await repo.saveProgress(updatedProgress);
      
      // Invalidate provider to refresh UI
      ref.invalidate(progressDailyProvider(today));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu thêm $steps bước chân!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving running progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _isTracking ? Colors.teal.shade50 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: _isTracking ? Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: _isTracking 
                ? Colors.teal.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isTracking ? Colors.teal : Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_run, 
                    color: _isTracking ? Colors.white : Colors.teal,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isTracking ? 'Đang chạy bộ...' : 'Chạy bộ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        _isTracking ? 'Duy trì tốc độ nhé!' : 'Theo dõi quãng đường di chuyển',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isTracking)
                  _buildMetricColumn(
                    'Thời gian',
                    _formatDuration(_secondsElapsed),
                    '',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Quãng đường',
                  (_totalDistance / 1000).toStringAsFixed(2),
                  'km',
                ),
                _buildMetricColumn(
                  'Số bước (ước tính)',
                  _stepsCount.toString(),
                  'bước',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _toggleTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isTracking ? Icons.stop_circle : Icons.play_circle_filled),
                    const SizedBox(width: 8),
                    Text(
                      _isTracking ? 'Kết thúc chạy bộ' : 'Bắt đầu chạy bộ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
