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
import '../../widgets/loading_animation.dart';

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
  /// Creates an [AISuggestionsScreen].
  const AISuggestionsScreen({super.key});

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
    _addSystemMessage(
      'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin '
      'sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _addSystemMessage(String content, {Workout? workout}) {
    setState(() {
      _messages.add({
        'type': MessageType.ai,
        'content': content,
        'workout': workout,
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
    _addUserMessage('Tôi đã xác nhận thông tin.');
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

        final suggestedWorkout = Workout(
          id: 0,
          title: workoutPlan.title,
          description: workoutPlan.notes,
          level: workoutPlan.level,
        );

        _addSystemMessage(
          'Tôi gợi ý bạn nên thực hiện lộ trình: ${workoutPlan.title}. '
          'đây là kế hoạch tối ưu cho mục tiêu ${workoutPlan.goal}.',
          workout: suggestedWorkout,
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
    ref.read(healthFormProvider.notifier).setAge(newState.age);
    ref.read(healthFormProvider.notifier).setWeight(newState.weight);
    ref.read(healthFormProvider.notifier).setHeight(newState.height);
    ref.read(healthFormProvider.notifier).setDietType(newState.dietType);

    _addSystemMessage('Thông tin đã được cập nhật thành công!');
    _handleValidationConfirm();
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
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFF7F00), size: 20),
            SizedBox(width: 8),
            Text(
              'Gợi ý từ AI',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.lg,
              ),
            ),
          ],
        ),
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
                    return _buildInteractiveStep(healthState);
                  }
                  final msg = _messages[index];
                  return ChatMessageBubble(
                    content: msg['content'] as String,
                    type: msg['type'] as MessageType,
                    child: msg['workout'] != null
                        ? WorkoutSuggestionCard(
                            workout: msg['workout'] as Workout,
                          )
                        : null,
                  );
                },
              ),
            ),
            if (_currentStep == AISuggestionStep.askingRequirement ||
                _currentStep == AISuggestionStep.results)
              _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveStep(HealthUpdateParams healthState) {
    switch (_currentStep) {
      case AISuggestionStep.validating:
        return HealthValidationCard(
          healthData: healthState,
          onConfirm: _handleValidationConfirm,
          onEdit: _handleEditRequest,
        );
      case AISuggestionStep.editing:
        return HealthEditForm(
          initialState: healthState,
          onSave: _handleEditSave,
          onCancel: () =>
              setState(() => _currentStep = AISuggestionStep.validating),
        );
      case AISuggestionStep.askingRequirement:
        return const SizedBox.shrink();
      case AISuggestionStep.generating:
<<<<<<< HEAD
      case AISuggestionStep.generating:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: AppLoading(
            message: 'AI đang phân tích dữ liệu của bạn...',
          ),
        );
      case AISuggestionStep.results:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _chatController,
                  onSubmitted: _handleRequirementSubmit,
                  decoration: const InputDecoration(
                    hintText: 'Hỏi thêm điều gì đó...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF7F00),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleRequirementSubmit(_chatController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
