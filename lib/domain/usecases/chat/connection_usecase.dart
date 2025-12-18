import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Parameters for getting connections
class GetConnectionsParams {
  final int limit;
  final String? cursor;

  GetConnectionsParams({
    this.limit = 20,
    this.cursor,
  });
}

/// Use case for fetching all connections (chat list)
class GetConnectionsUseCase implements BaseUseCase<List<ChatConnectionDto>, GetConnectionsParams> {
  final ChatRepositoryAbstract repository;

  GetConnectionsUseCase(this.repository);

  @override
  Future<BaseState<List<ChatConnectionDto>>> call(GetConnectionsParams params) async {
    return await repository.getConnections(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters for getting a single connection
class GetConnectionByIdParams {
  final String connectionId;

  GetConnectionByIdParams({required this.connectionId});
}

/// Use case for fetching a single connection
class GetConnectionByIdUseCase implements BaseUseCase<ChatConnectionDto, GetConnectionByIdParams> {
  final ChatRepositoryAbstract repository;

  GetConnectionByIdUseCase(this.repository);

  @override
  Future<BaseState<ChatConnectionDto>> call(GetConnectionByIdParams params) async {
    return await repository.getConnectionById(params.connectionId);
  }
}

/// Parameters for updating game in connection
class UpdateGameParams {
  final String connectionId;
  final String? gameTitle;

  UpdateGameParams({
    required this.connectionId,
    this.gameTitle,
  });
}

/// Use case for updating game in a connection
class UpdateGameUseCase implements BaseUseCase<ChatConnectionDto, UpdateGameParams> {
  final ChatRepositoryAbstract repository;

  UpdateGameUseCase(this.repository);

  @override
  Future<BaseState<ChatConnectionDto>> call(UpdateGameParams params) async {
    return await repository.updateGame(
      connectionId: params.connectionId,
      gameTitle: params.gameTitle,
    );
  }
}

/// Parameters for clearing chat
class ClearChatParams {
  final String connectionId;

  ClearChatParams({required this.connectionId});
}

/// Use case for clearing chat history
class ClearChatUseCase implements BaseUseCase<void, ClearChatParams> {
  final ChatRepositoryAbstract repository;

  ClearChatUseCase(this.repository);

  @override
  Future<BaseState<void>> call(ClearChatParams params) async {
    return await repository.clearChat(params.connectionId);
  }
}
