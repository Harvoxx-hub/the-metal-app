import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/domain/usecases/chat/connection_usecase.dart';
import 'package:metal/domain/usecases/chat/delete_message_usecase.dart';
import 'package:metal/domain/usecases/chat/get_messages_usecase.dart';
import 'package:metal/domain/usecases/chat/send_message_usecase.dart';

// ============ Message Use Cases ============

/// Provider for GetMessagesUseCase
final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for GetMessagesSinceUseCase (polling)
final getMessagesSinceUseCaseProvider = Provider<GetMessagesSinceUseCase>((ref) {
  return GetMessagesSinceUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for SendMessageUseCase
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for DeleteMessageUseCase
final deleteMessageUseCaseProvider = Provider<DeleteMessageUseCase>((ref) {
  return DeleteMessageUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for MarkMessageReadUseCase
final markMessageReadUseCaseProvider = Provider<MarkMessageReadUseCase>((ref) {
  return MarkMessageReadUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for MarkAllMessagesReadUseCase
final markAllMessagesReadUseCaseProvider = Provider<MarkAllMessagesReadUseCase>((ref) {
  return MarkAllMessagesReadUseCase(ref.watch(chatRepositoryProvider));
});

// ============ Connection Use Cases ============

/// Provider for GetConnectionsUseCase
final getConnectionsUseCaseProvider = Provider<GetConnectionsUseCase>((ref) {
  return GetConnectionsUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for GetConnectionByIdUseCase
final getConnectionByIdUseCaseProvider = Provider<GetConnectionByIdUseCase>((ref) {
  return GetConnectionByIdUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for UpdateGameUseCase
final updateGameUseCaseProvider = Provider<UpdateGameUseCase>((ref) {
  return UpdateGameUseCase(ref.watch(chatRepositoryProvider));
});

/// Provider for ClearChatUseCase
final clearChatUseCaseProvider = Provider<ClearChatUseCase>((ref) {
  return ClearChatUseCase(ref.watch(chatRepositoryProvider));
});
