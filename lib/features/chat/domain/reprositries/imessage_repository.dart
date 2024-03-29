import 'package:metal/core/model/responces.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';

import '../entries/message.model.dart';

abstract class IMessageRepository {
  Future<Responses> sendMessage({
    required MessageModel message,
    String? conversationsId
 
  });
   Stream<List<MessageModel>> getMessages(
     String conversationId
  );

 

   Stream<List<ConversationsModel>> getChatList(String userId);

}


 