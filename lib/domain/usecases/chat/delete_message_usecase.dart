import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Parameters for deleting a message
class DeleteMessageParams {
  final String messageId;
  final String connectionId;

  DeleteMessageParams({
    required this.messageId,
    required this.connectionId,
  });
}

/// Use case for deleting a message
class DeleteMessageUseCase implements BaseUseCase<void, DeleteMessageParams> {
  final ChatRepositoryAbstract repository;

  DeleteMessageUseCase(this.repository);

  @override
  Future<BaseState<void>> call(DeleteMessageParams params) async {
    return await repository.deleteMessage(
      params.messageId,
      params.connectionId,
    );
  }
}

/// Parameters for marking a message as read
class MarkMessageReadParams {
  final String messageId;

  MarkMessageReadParams({required this.messageId});
}

/// Use case for marking a message as read
class MarkMessageReadUseCase implements BaseUseCase<void, MarkMessageReadParams> {
  final ChatRepositoryAbstract repository;

  MarkMessageReadUseCase(this.repository);

  @override
  Future<BaseState<void>> call(MarkMessageReadParams params) async {
    return await repository.markMessageAsRead(params.messageId);
  }
}

/// Parameters for marking all messages as read
class MarkAllMessagesReadParams {
  final String connectionId;

  MarkAllMessagesReadParams({required this.connectionId});
}

/// Use case for marking all messages in a connection as read
class MarkAllMessagesReadUseCase implements BaseUseCase<void, MarkAllMessagesReadParams> {
  final ChatRepositoryAbstract repository;

  MarkAllMessagesReadUseCase(this.repository);

  @override
  Future<BaseState<void>> call(MarkAllMessagesReadParams params) async {
    return await repository.markAllMessagesAsRead(params.connectionId);
  }
}
