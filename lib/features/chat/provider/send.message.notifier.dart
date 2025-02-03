import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/firebase.service.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';

class SendMessageNotifier extends StateNotifier<SendMessageState> {
  SendMessageNotifier(this.ref) : super(SendMessageState.initial());

  final Ref ref;

  Future<void> sendMessage(
      MessageModel message, String? conversationsId) async {
    try {
      state = SendMessageState.loading();

      // If it's an audio message, upload the audio file to Firestore
      if (message.type == MessageType.audio) {
        message = await _uploadAudioMessage(message);
      }

      final messageRepository = ref.watch(messageRepositoryProvider);
      final response = await messageRepository.sendMessage(
          message: message, conversationsId: conversationsId!);

      if (response.success!) {
        if (mounted) state = SendMessageState.success(response.data);
      } else {
        state = SendMessageState.error(
            response.message ?? 'Failed to send message');
      }
    } catch (e) {
      print('Failed to send message: $e');
      state = SendMessageState.error('Failed to send message: $e');
    }
  }

  Future<MessageModel> _uploadAudioMessage(MessageModel message) async {
    final firebaseService = FirebaseService();
    final audioUrl = await firebaseService.uploadAudio(message.content!);
    // Create a new Message object with updated content
    message.content = audioUrl;
    MessageModel updatedMessage = message;
    // Return the updated Message object wrapped in a Future
    return Future.value(updatedMessage);
  }
}

typedef SendMessageState = BaseState<String>;

final sendMessageProvider =
    StateNotifierProvider.autoDispose<SendMessageNotifier, SendMessageState>(
  (ref) => SendMessageNotifier(ref),
);
