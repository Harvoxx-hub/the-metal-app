import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date.formart.dart';
import '../../../features/authentication/provider/user_state_notifier.dart';
import '../../../features/chat/domain/entries/message.model.dart';
import '../../../features/chat/provider/send.message.notifier.dart';

class UnmetalState {
  final bool isLoading;
  final String? error;
  final bool isUnmetalRequestSent;

  const UnmetalState({
    this.isLoading = false,
    this.error,
    this.isUnmetalRequestSent = false,
  });

  UnmetalState copyWith({
    bool? isLoading,
    String? error,
    bool? isUnmetalRequestSent,
  }) {
    return UnmetalState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUnmetalRequestSent: isUnmetalRequestSent ?? this.isUnmetalRequestSent,
    );
  }
}

class UnmetalNotifier extends StateNotifier<UnmetalState> {
  UnmetalNotifier(this.ref) : super(const UnmetalState());

  final Ref ref;

  /// Calculate completed days for unmetal requirement
  int calculateCompletedDays(String connectedOn, int daysRequired) {
  
   final days = daysRemaining(connectedOn, daysRequired);
  print('days: $days');
    return days;
  }

  /// Check if user can proceed with unmetal
  bool canProceedWithUnmetal({
    required int completedDays,
    required int daysRequired,
    required bool hasProfilePhoto,
  }) {
    return completedDays >= daysRequired && hasProfilePhoto;
  }

  /// Send unmetal request
  Future<void> sendUnmetalRequest(String connectionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUser = ref.read(userStateProvider).data;

      if (currentUser?.id == null) {
        throw Exception('User not authenticated');
      }

      final message = MessageModel(
        senderId: currentUser!.id!,
        type: MessageType.un_melt,
        timestamp: DateTime.now().toIso8601String(),
        isRead: false,
        message: "Un-melt Request",
      );

      await ref
          .read(sendMessageProvider.notifier)
          .sendMessage(message, connectionId);

      state = state.copyWith(
        isLoading: false,
        isUnmetalRequestSent: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const UnmetalState();
  }
}

final unmetalNotifierProvider =
    StateNotifierProvider<UnmetalNotifier, UnmetalState>((ref) {
  return UnmetalNotifier(ref);
});
