import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';
import 'widgets/health_validation_card.dart';
import 'widgets/health_edit_form.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/workout_suggestion_card.dart';

enum AISuggestionStep { validating, editing, generating, results }

class AISuggestionsScreen extends ConsumerStatefulWidget {
  const AISuggestionsScreen({super.key});

  @override
  ConsumerState<AISuggestionsScreen> createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends ConsumerState<AISuggestionsScreen> {
  AISuggestionStep _currentStep = AISuggestionStep.validating;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addSystemMessage(
      'Hệ thống AI đã sẵn sàng. Trước khi bắt đầu, hãy xác nhận thông tin sức khỏe của bạn để tôi có thể đưa ra gợi ý chính xác nhất.',
    );
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
    setState(() => _currentStep = AISuggestionStep.generating);
    try {
      final workouts = await ref.read(workoutsProvider.future);

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _currentStep = AISuggestionStep.results);
        _addSystemMessage(
          'Tuyệt vời! Dựa trên thông tin của bạn, tôi đã phân tích và chuẩn bị một lộ trình cá nhân hóa.',
        );

        if (workouts.isNotEmpty) {
          final suggestedWorkout = workouts.first;
          _addSystemMessage(
            'Tôi gợi ý bạn nên thực hiện bài tập: ${suggestedWorkout.title}. Đây là bài tập tối ưu nhất cho thể trạng hiện tại của bạn.',
            workout: suggestedWorkout,
          );
        } else {
          _addSystemMessage(
            'Rất tiếc, tôi chưa tìm thấy bài tập phù hợp ngay lúc này. Hãy thử lại sau nhé!',
          );
        }

        _addSystemMessage(
          'Dinh dưỡng: Tăng cường Protein, nên dùng ức gà và rau xanh vào bữa trưa.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentStep = AISuggestionStep.results);
        _addSystemMessage(
          'Đã có lỗi xảy ra khi lấy dữ liệu bài tập. Vui lòng thử lại sau.',
        );
      }
    }
  }

  void _handleEditRequest() {
    _addUserMessage('Tôi cần cập nhật lại thông tin.');
    setState(() => _currentStep = AISuggestionStep.editing);
  }

  void _handleEditSave(HealthFormState newState) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F00)),
              ),
              SizedBox(height: 16),
              Text('Đang tải thông tin sức khỏe...'),
            ],
          ),
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
                    content: msg['content'],
                    type: msg['type'],
                    child: msg['workout'] != null
                        ? WorkoutSuggestionCard(workout: msg['workout'])
                        : null,
                  );
                },
              ),
            ),
            if (_currentStep == AISuggestionStep.results) _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveStep(HealthFormState healthState) {
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
      case AISuggestionStep.generating:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7F00)),
              ),
              const SizedBox(height: 16),
              Text(
                'AI đang phân tích dữ liệu của bạn...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
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
                child: const TextField(
                  decoration: InputDecoration(
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
                onPressed: () {
                  // Logic to send custom chat queries
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
