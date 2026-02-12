import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_chat_message.dart';

class ChatHistoryNotifier extends Notifier<List<AIChatMessage>> {
  @override
  List<AIChatMessage> build() {
    return [];
  }

  void addMessage(AIChatMessage message) {
    state = [...state, message];
  }

  void clearHistory() {
    state = [];
  }
}

final chatHistoryProvider = NotifierProvider<ChatHistoryNotifier, List<AIChatMessage>>(() {
  return ChatHistoryNotifier();
});
