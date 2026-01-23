import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

enum MessageType { ai, user }

class ChatMessageBubble extends StatelessWidget {
  final String content;
  final MessageType type;
  final Widget? child;

  const ChatMessageBubble({
    super.key,
    required this.content,
    required this.type,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = type == MessageType.ai;
    final CrossAxisAlignment alignment = isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isAI ? AppColors.white : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isAI ? 4 : 20),
                      bottomRight: Radius.circular(isAI ? 20 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        style: TextStyle(
                          color: isAI ? AppColors.black : Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (child != null) ...[
                        const SizedBox(height: 12),
                        child!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isAI) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7F00), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.greyLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.grey, size: 16),
    );
  }
}
