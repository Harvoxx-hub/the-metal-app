// final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<ChatMessage>, String>((ref, chatId) {
//   return ChatMessagesNotifier(chatId);
// });

// class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
//   final String chatId;

//   ChatMessagesNotifier(this.chatId) : super([]);

//   void addMessage(ChatMessage message) {
//     state = [...state, message];
//   }
// }