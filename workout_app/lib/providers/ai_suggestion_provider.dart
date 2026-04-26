import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../models/chat_message.dart';
import 'health_form_provider.dart';
import 'workout_provider.dart';

enum AISuggestionStep {
  validating,
  editing,
  askingRequirement,
  generating,
  results,
}

class AISuggestionState {
  final List<ChatMessage> messages;
  final AISuggestionStep currentStep;

  AISuggestionState({
    required this.messages,
    required this.currentStep,
  });

  factory AISuggestionState.initial() {
    return AISuggestionState(
      messages: [],
      currentStep: AISuggestionStep.validating,
    );
  }

  AISuggestionState copyWith({
    List<ChatMessage>? messages,
    AISuggestionStep? currentStep,
  }) {
    return AISuggestionState(
      messages: messages ?? this.messages,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class AISuggestionNotifier extends Notifier<AISuggestionState> {
  @override
  AISuggestionState build() {
    return AISuggestionState.initial();
  }

  void init({AISuggestionHistory? historyItem}) {
    if (historyItem == null && state.messages.isNotEmpty) return;
    state = AISuggestionState.initial();

    if (historyItem != null) {
      loadHistoryItem(historyItem);
    } else {
      _addSystemMessage(
        'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin '
        'sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
      );
    }
  }

  void loadHistoryItem(AISuggestionHistory item) {
    final List<ChatMessage> historyMessages = [];

    historyMessages.add(ChatMessage(
      type: MessageType.ai,
      content: 'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin '
          'sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
    ));

    historyMessages.add(ChatMessage(
      type: MessageType.user,
      content: 'Tôi đã xác nhận hồ sơ sức khỏe.',
    ));

    if (item.healthContext != null) {
      historyMessages.add(ChatMessage(
        type: MessageType.ai,
        content: _formatHealthSummary(item.healthContext!),
      ));
    }

    if (item.userPrompt != null) {
      historyMessages.add(ChatMessage(
        type: MessageType.user,
        content: item.userPrompt!,
      ));
    }

    if (item.plan != null) {
      final workoutPlan = item.plan!;
      final suggestedWorkout = workoutPlan.toWorkout();
      final workoutDetail = workoutPlan.toWorkoutDetail();

      historyMessages.add(ChatMessage(
        type: MessageType.ai,
        content: 'Tuyệt vời! Dựa trên thông tin và yêu cầu của bạn, '
            'tôi đã phân tích và chuẩn bị một lộ trình cá nhân hóa.',
      ));

      historyMessages.add(ChatMessage(
        type: MessageType.ai,
        content: 'Tôi gợi ý bạn nên thực hiện lộ trình: ${workoutPlan.title}. '
            'đây là kế hoạch tối ưu cho mục tiêu ${workoutPlan.goal}.',
        workout: suggestedWorkout,
        detail: workoutDetail,
      ));

      if (workoutPlan.exercises.isNotEmpty) {
        final exercisesText = workoutPlan.exercises.map((e) => '- ${e.name}').join('\n');
        historyMessages.add(ChatMessage(
          type: MessageType.ai,
          content: 'Các bài tập bao gồm:\n$exercisesText',
        ));
      }

      if (workoutPlan.notes != null) {
        historyMessages.add(ChatMessage(
          type: MessageType.ai,
          content: 'Lưu ý: ${workoutPlan.notes}',
        ));
      }
    }

    state = state.copyWith(
      messages: historyMessages,
      currentStep: AISuggestionStep.results,
    );
  }

  Future<void> handleValidationConfirm() async {
    _addUserMessage('Tôi đã xác nhận hồ sơ sức khỏe.');

    final healthState = ref.read(healthFormProvider);
    _addSystemMessage(_formatHealthSummary(healthState.toJson()));

    state = state.copyWith(currentStep: AISuggestionStep.askingRequirement);

    await Future.delayed(const Duration(milliseconds: 500));
    _addSystemMessage(
      'Cảm ơn bạn. Bạn có yêu cầu gì đặc biệt cho buổi tập hôm nay không? (Ví dụ: Tập nhanh 10 phút, không dùng thiết bị, tập trung vào x, ...)',
    );
  }

  Future<void> handleRequirementSubmit(String requirement) async {
    if (requirement.trim().isEmpty) {
      _addUserMessage('Không có yêu cầu đặc biệt.');
    } else {
      _addUserMessage(requirement);
    }

    state = state.copyWith(currentStep: AISuggestionStep.generating);

    try {
      final healthState = ref.read(healthFormProvider);
      final workoutPlan = await ref.read(workoutRepositoryProvider).createWorkoutSuggestion(
        weight: healthState.weight,
        height: healthState.height,
        goal: healthState.goal,
        dietType: healthState.dietType,
        medicalConditions: healthState.medicalConditions,
        requirement: requirement.trim().isEmpty ? null : requirement,
      );

      state = state.copyWith(currentStep: AISuggestionStep.results);
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
        final exercisesText = workoutPlan.exercises.map((e) => '- ${e.name}').join('\n');
        _addSystemMessage('Các bài tập bao gồm:\n$exercisesText');
      }

      if (workoutPlan.notes != null) {
        _addSystemMessage('Lưu ý: ${workoutPlan.notes}');
      }
    } catch (e) {
      state = state.copyWith(currentStep: AISuggestionStep.results);
      _addSystemMessage('Đã có lỗi xảy ra khi tạo gợi ý từ AI: $e');
    }
  }

  void handleEditRequest() {
    _addUserMessage('Tôi cần cập nhật lại thông tin.');
    state = state.copyWith(currentStep: AISuggestionStep.editing);
  }

  void handleEditSave(HealthUpdateParams newState) {
    ref.read(healthFormProvider.notifier).updateAndSave(newState);
    _addSystemMessage('Thông tin đã được cập nhật thành công!');
    handleValidationConfirm();
  }

  void cancelEdit() {
    state = state.copyWith(currentStep: AISuggestionStep.validating);
  }

  void _addSystemMessage(String content, {Workout? workout, WorkoutDetail? detail}) {
    final newMsg = ChatMessage(
      type: MessageType.ai,
      content: content,
      workout: workout,
      detail: detail,
    );
    state = state.copyWith(messages: [...state.messages, newMsg]);
  }

  void _addUserMessage(String content) {
    final newMsg = ChatMessage(type: MessageType.user, content: content);
    state = state.copyWith(messages: [...state.messages, newMsg]);
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
}

final aiSuggestionProvider = NotifierProvider<AISuggestionNotifier, AISuggestionState>(AISuggestionNotifier.new,);
