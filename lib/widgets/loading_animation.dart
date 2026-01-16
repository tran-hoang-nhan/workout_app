import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'dart:math' as math;

class AppLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoading({
    super.key,
    this.size = 50.0,
    this.color,
    this.message,
  });

  @override
  State<AppLoading> createState() => _AppLoadingState();
  static Widget fullScreen({String? message}) {
    return Container(
      color: Colors.white.withValues(alpha: 0.8),
      child: Center(
        child: AppLoading(message: message),
      ),
    );
  }
}

class _AppLoadingState extends State<AppLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SCenter(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.1),
                          width: widget.size * 0.1,
                        ),
                      ),
                      child: CircularProgressIndicator(
                        value: 0.25,
                        strokeWidth: widget.size * 0.1,
                        color: color,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale + (0.1 * math.sin(_controller.value * 2 * math.pi)),
                        child: Container(
                          width: widget.size * 0.3,
                          height: widget.size * 0.3,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.message!,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class SCenter extends StatelessWidget {
  final Widget child;
  const SCenter({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Center(child: child);
  }
}
