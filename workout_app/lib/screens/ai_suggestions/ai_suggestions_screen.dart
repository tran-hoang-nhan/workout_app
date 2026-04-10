import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import '../../providers/workout_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/health_edit_form.dart';
import 'widgets/health_validation_card.dart';
import 'widgets/workout_suggestion_card.dart';
import 'widgets/chat_input.dart';
import 'widgets/suggestion_interactive_step.dart';
import '../../widgets/loading_animation.dart';
import 'ai_suggestions_history_screen.dart';

/// The steps in the AI workout suggestion flow.
enum AISuggestionStep {
  /// User confirms/edits health data.
  validating,

  /// User is editing health data manually.
  editing,

  /// AI is asking for specific workout requirements.
  askingRequirement,

  /// AI is generating the workout plan.
  generating,

  /// AI has provided the results.
  results,
}

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
  AISuggestionStep _currentStep = AISuggestionStep.validating;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.historyItem != null) {
      _loadHistoryItem(widget.historyItem!);
    } else {
      _addSystemMessage(
        'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin '
        'sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
      );
    }
  }

  void _loadHistoryItem(AISuggestionHistory item) {
    // Add initial system message and user confirmation for consistency with real chat
    _messages.add({
      'type': MessageType.ai,
      'content': 'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin '
          'sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
    });

    _messages.add({
      'type': MessageType.user,
      'content': 'Tôi đã xác nhận hồ sơ sức khỏe.',
    });

    if (item.healthContext != null) {
      _messages.add({
        'type': MessageType.ai,
        'content': _formatHealthSummary(item.healthContext!),
      });
    }

    if (item.userPrompt != null) {
      _messages.add({
        'type': MessageType.user,
        'content': item.userPrompt!,
      });
    }

    if (item.plan != null) {
      final workoutPlan = item.plan!;
      final suggestedWorkout = workoutPlan.toWorkout();
      final workoutDetail = workoutPlan.toWorkoutDetail();

      _messages.add({
        'type': MessageType.ai,
        'content': 'Tuyệt vời! Dựa trên thông tin và yêu cầu của bạn, '
            'tôi đã phân tích và chuẩn bị một lộ trình cá nhân hóa.',
      });

      _messages.add({
        'type': MessageType.ai,
        'content': 'Tôi gợi ý bạn nên thực hiện lộ trình: ${workoutPlan.title}. '
            'đây là kế hoạch tối ưu cho mục tiêu ${workoutPlan.goal}.',
        'workout': suggestedWorkout,
        'detail': workoutDetail,
      });

      if (workoutPlan.exercises.isNotEmpty) {
        final exercisesText =
            workoutPlan.exercises.map((e) => '- ${e.name}').join('\n');
        _messages.add({
          'type': MessageType.ai,
          'content': 'Các bài tập bao gồm:\n$exercisesText',
        });
      }

      if (workoutPlan.notes != null) {
        _messages.add({
          'type': MessageType.ai,
          'content': 'Lưu ý: ${workoutPlan.notes}',
        });
      }
    }

    _currentStep = AISuggestionStep.results;
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _addSystemMessage(String content, {Workout? workout, WorkoutDetail? detail}) {
    setState(() {
      _messages.add({
        'type': MessageType.ai,
        'content': content,
        'workout': workout,
        'detail': detail,
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String content) {
    setState(() {
      _messages.add({'type': MessageType.user, 'content': content});
    });
    _scrollToBottom();
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

  Future<void> _handleValidationConfirm() async {
    _addUserMessage('Tôi đã xác nhận hồ sơ sức khỏe.');
    
    final healthState = ref.read(healthFormProvider);
    _addSystemMessage(_formatHealthSummary(healthState.toJson()));

    setState(() => _currentStep = AISuggestionStep.askingRequirement);
    
    await Future.delayed(const Duration(milliseconds: 500));
    _addSystemMessage(
      'Cảm ơn bạn. Bạn có yêu cầu gì đặc biệt cho buổi tập hôm nay không? (Ví dụ: Tập nhanh 10 phút, không dùng thiết bị, tập trung vào x, ...)',
    );
  }

  /// Submits the user's specific workout requirements and triggers generation.
  Future<void> _handleRequirementSubmit(String requirement) async {
    if (requirement.trim().isEmpty) {
      _addUserMessage('Không có yêu cầu đặc biệt.');
    } else {
      _addUserMessage(requirement);
    }

    setState(() => _currentStep = AISuggestionStep.generating);
    _chatController.clear();

    try {
      final healthState = ref.read(healthFormProvider);
      debugPrint(
        '[AISuggestionsScreen] Requesting workout for: '
        'weight=${healthState.weight}, height=${healthState.height}, '
        'goal=${healthState.goal}, diet=${healthState.dietType}, '
        'conditions=${healthState.medicalConditions.join(", ")}, '
        'requirement=$requirement',
      );

      final workoutPlan = await ref
          .read(workoutRepositoryProvider)
          .createWorkoutSuggestion(
            weight: healthState.weight,
            height: healthState.height,
            goal: healthState.goal,
            dietType: healthState.dietType,
            medicalConditions: healthState.medicalConditions,
            requirement: requirement.trim().isEmpty ? null : requirement,
          );

      final encoder = JsonEncoder.withIndent('  ');
      debugPrint('[AISuggestionsScreen] Received WorkoutPlan:');
      debugPrint(encoder.convert(workoutPlan.toJson()));

      if (mounted) {
        setState(() => _currentStep = AISuggestionStep.results);
        _addSystemMessage(
          'Tuyệt vời! Dựa trên thông tin và yêu cầu của bạn, '
          'tôi đã phân tích và chuẩn bị một lộ trình cá nhân hóa.',
        );

        final suggestedWorkout = workoutPlan.toWorkout();
        final workoutDetail = workoutPlan.toWorkoutDetail();

        _addSystemMessage(
          'Tôi gợi ý bạn nên thực hiện lộ trình: ${workoutPlan.title}. '
          'đây là kế hoạch tối ưu cho mục tiêu ${workoutPlan.goal}.',
          workout: suggestedWorkout,
          detail: workoutDetail,
        );
        if (workoutPlan.exercises.isNotEmpty) {
          final exercisesText =
              workoutPlan.exercises.map((e) => '- ${e.name}').join('\n');
          _addSystemMessage('Các bài tập bao gồm:\n$exercisesText');
        }

        if (workoutPlan.notes != null) {
          _addSystemMessage('Lưu ý: ${workoutPlan.notes}');
        }
      }
    } catch (e) {
      debugPrint('[AISuggestionsScreen] ERROR creating workout: $e');
      if (mounted) {
        setState(() => _currentStep = AISuggestionStep.results);
        _addSystemMessage(
          'Đã có lỗi xảy ra khi tạo gợi ý từ AI: $e',
        );
      }
    }
  }

  void _handleEditRequest() {
    _addUserMessage('Tôi cần cập nhật lại thông tin.');
    setState(() => _currentStep = AISuggestionStep.editing);
  }

  void _handleEditSave(HealthUpdateParams newState) {
    ref.read(healthFormProvider.notifier).updateAndSave(newState);

    _addSystemMessage('Thông tin đã được cập nhật thành công!');
    _handleValidationConfirm();
  }

  String _formatHealthSummary(Map<String, dynamic> hc) {
    final weight = hc['weight'] ?? '--';
    final height = hc['height'] ?? '--';
    final goal = hc['goal'] ?? '--';
    final diet = hc['diet_type'] ?? '--';
    final conditions = hc['medical_conditions'] as List?;

    String summary = 'Hồ sơ sức khỏe: $weight kg, $height cm, Mục tiêu: $goal, Chế độ: $diet.';
    if (conditions != null && conditions.isNotEmpty) {
      summary += '\nTình trạng: ${conditions.join(", ")}';
    }
    return summary;
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
        data: (_) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return SuggestionInteractiveStep(
                      currentStep: _currentStep,
                      healthState: healthState,
                      onConfirm: _handleValidationConfirm,
                      onEdit: _handleEditRequest,
                      onSaveEdit: _handleEditSave,
                      onCancelEdit: () => setState(
                          () => _currentStep = AISuggestionStep.validating),
                    );
                  }
                  final msg = _messages[index];
                  return ChatMessageBubble(
                    content: msg['content'] as String,
                    type: msg['type'] as MessageType,
                    child: msg['workout'] != null
                        ? WorkoutSuggestionCard(
                            workout: msg['workout'] as Workout,
                            detail: msg['detail'] as WorkoutDetail?,
                          )
                        : null,
                  );
                },
              ),
            ),
            if (_currentStep == AISuggestionStep.askingRequirement ||
                _currentStep == AISuggestionStep.results)
              ChatInput(
                controller: _chatController,
                onSubmitted: _handleRequirementSubmit,
              ),
          ],
        ),
      ),
    );
  }
}
