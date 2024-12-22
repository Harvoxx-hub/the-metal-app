import 'package:metal/core/model/responces.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';

import '../entries/message.model.dart';

abstract class IMessageRepository {
  Future<Responses> sendMessage(
      {required MessageModel message, required String conversationsId});
  Stream<List<MessageModel>> getMessages(String conversationId);
 
 
    updateGame(String id, String gameTile, {MessageModel? message});
  clearChat(String id);
  Future<Responses> lastActiveTime(String id);
  Future<Responses> deMelt(String id);
}
