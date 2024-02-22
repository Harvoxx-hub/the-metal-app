import 'package:metal/core/model/responces.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

abstract class IMessageRepository {
  Future<Responses> sendMessage({
    required String message,
    required String receiverId,
  });

  Future<Responses> getMessages({
    required String receiverId,
  });

  Future<Responses> getChatList();
}
