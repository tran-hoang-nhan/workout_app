import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import '../../providers/workout_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_input.dart';
import 'widgets/suggestion_interactive_step.dart';
import '../../widgets/loading_animation.dart';
import 'ai_suggestions_history_screen.dart';
import '../../providers/ai_suggestion_provider.dart';

/// A screen that provides AI-powered workout suggestions.
class AISuggestionsScreen extends ConsumerStatefulWidget {
  /// Optional history item to display.
  final AISuggestionHistory? historyItem;

  /// Creates an [AISuggestionsScreen].
  const AISuggestionsScreen({super.key, this.historyItem});

  @override
  ConsumerState<AISuggestionsScreen> createState() =>
      _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends ConsumerState<AISuggestionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatController = TextEditingController();
  late final ProviderSubscription<AISuggestionState> _aiListener;

  @override
  void initState() {
    super.initState();
    _aiListener = ref.listenManual<AISuggestionState>(
      aiSuggestionProvider,
      (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiSuggestionProvider.notifier).init(historyItem: widget.historyItem);
    });
  }

  @override
  void dispose() {
    _aiListener.close();
    _scrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthFormProvider);
    final syncAsync = ref.watch(syncHealthProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFF7F00), size: 20),
            const SizedBox(width: 8),
            Text(
              widget.historyItem != null ? 'Chi tiết gợi ý' : 'Gợi ý từ AI',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.lg,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.black),
            onPressed: () {
              ref.invalidate(aiSuggestionHistoryProvider);
              ref.invalidate(aiSuggestionProvider);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AISuggestionsHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: syncAsync.when(
        loading: () => const Center(
          child: AppLoading(message: 'Đang tải thông tin sức khỏe...'),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Lỗi khi tải dữ liệu: $error'),
              TextButton(
                onPressed: () => ref.invalidate(syncHealthProfileProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (_) {
          final aiState = ref.watch(aiSuggestionProvider);
          final notifier = ref.read(aiSuggestionProvider.notifier);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: aiState.messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == aiState.messages.length) {
                      return SuggestionInteractiveStep(
                        currentStep: aiState.currentStep,
                        healthState: healthState,
                        onConfirm: notifier.handleValidationConfirm,
                        onEdit: notifier.handleEditRequest,
                        onSaveEdit: notifier.handleEditSave,
                        onCancelEdit: notifier.cancelEdit,
                      );
                    }
                    return ChatMessageBubble(message: aiState.messages[index]);
                  },
                ),
              ),
              if (aiState.currentStep == AISuggestionStep.askingRequirement ||
                  aiState.currentStep == AISuggestionStep.results)
                ChatInput(
                  controller: _chatController,
                  isEnabled: aiState.currentStep != AISuggestionStep.generating,
                  onSubmitted: (val) {
                    _chatController.clear();
                    notifier.handleRequirementSubmit(val);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
