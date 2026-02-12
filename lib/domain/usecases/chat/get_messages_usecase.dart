import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Parameters for getting messages
class GetMessagesParams {
  final String connectionId;
  final int limit;
  final String? cursor;

  GetMessagesParams({
    required this.connectionId,
    this.limit = 50,
    this.cursor,
  });
}

/// Use case for fetching messages in a conversation
class GetMessagesUseCase implements BaseUseCase<MessagesResponseDto, GetMessagesParams> {
  final ChatRepositoryAbstract repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<BaseState<MessagesResponseDto>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      params.connectionId,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters for getting new messages (polling)
class GetMessagesSinceParams {
  final String connectionId;
  final String sinceMessageId;

  GetMessagesSinceParams({
    required this.connectionId,
    required this.sinceMessageId,
  });
}

/// Use case for polling new messages
class GetMessagesSinceUseCase implements BaseUseCase<List<MessageDto>, GetMessagesSinceParams> {
  final ChatRepositoryAbstract repository;

  GetMessagesSinceUseCase(this.repository);

  @override
  Future<BaseState<List<MessageDto>>> call(GetMessagesSinceParams params) async {
    return await repository.getMessagesSince(
      params.connectionId,
      sinceMessageId: params.sinceMessageId,
    );
  }
}
