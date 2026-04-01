import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutCountdownOverlay extends StatefulWidget {
  final String text;
  final VoidCallback onComplete;
  /// Khi true (vd. đang mở dialog thoát), bộ đếm 3–2–1 tạm dừng.
  final bool paused;

  const WorkoutCountdownOverlay({
    super.key,
    required this.text,
    required this.onComplete,
    this.paused = false,
  });

  @override
  State<WorkoutCountdownOverlay> createState() => _WorkoutCountdownOverlayState();
}

class _WorkoutCountdownOverlayState extends State<WorkoutCountdownOverlay> with SingleTickerProviderStateMixin {
  int _counter = 3;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 60),
    ]).animate(_animationController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_animationController);

    _startCountdown();
  }

  void _startCountdown() {
    _animationController.forward(from: 0.0);
    HapticFeedback.mediumImpact();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (widget.paused) return;
      if (_counter > 1) {
        setState(() {
          _counter--;
        });
        _animationController.forward(from: 0.0);
        HapticFeedback.mediumImpact();
      } else {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text(
                          '$_counter',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 140,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
