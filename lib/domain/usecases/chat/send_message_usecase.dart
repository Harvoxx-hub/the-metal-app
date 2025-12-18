import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Parameters for sending a message
class SendMessageParams {
  final String connectionId;
  final MessageDto message;

  SendMessageParams({
    required this.connectionId,
    required this.message,
  });
}

/// Use case for sending a message
class SendMessageUseCase implements BaseUseCase<MessageDto, SendMessageParams> {
  final ChatRepositoryAbstract repository;

  SendMessageUseCase(this.repository);

  @override
  Future<BaseState<MessageDto>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      connectionId: params.connectionId,
      message: params.message,
    );
  }
}
