import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExerciseAnimationWidget extends StatefulWidget {
  final String animationUrl;
  final double? width;
  final double? height;
  final bool autoPlay;

  const ExerciseAnimationWidget({
    super.key,
    required this.animationUrl,
    this.width,
    this.height,
    this.autoPlay = true,
  });

  @override
  State<ExerciseAnimationWidget> createState() => _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isPlaying = widget.autoPlay;
    
    // Validate URL khi init
    if (widget.animationUrl.isEmpty) {
      _hasError = true;
      _errorMessage = 'URL không hợp lệ';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _retryLoad() {
    // Reset state và rebuild widget để retry load
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isPlaying = widget.autoPlay;
    });
    // Reset controller
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _errorMessage != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 48),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _retryLoad,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Lottie.network(
              widget.animationUrl,
              controller: _controller,
              fit: BoxFit.contain,
              repeat: true,
              animate: widget.autoPlay,
              onLoaded: (composition) {
                if (mounted) {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _controller.duration = composition.duration;
                  if (widget.autoPlay) {
                    _controller.repeat();
                  }
                }
              },
              errorBuilder: (context, error, stackTrace) {
                // Log error để debug
                debugPrint('❌ Lỗi tải animation: $error');
                debugPrint('📎 URL: ${widget.animationUrl}');
                debugPrint('📚 StackTrace: $stackTrace');
                
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _hasError = true;
                      _errorMessage = 'Không thể tải animation';
                    });
                  });
                }
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Không thể tải animation',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.animationUrl,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _retryLoad,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              },
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return child;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
              iconSize: 36,
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () {
                _controller.reset();
                if (_isPlaying) {
                  _controller.repeat();
                }
              },
              icon: const Icon(Icons.replay),
              iconSize: 28,
              color: Colors.grey[700],
            ),
          ],
        ),
      ],
    );
  }
}