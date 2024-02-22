import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/core/services/auth.manager.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/domain/repositories/iauthetication_repository.dart';
import 'package:metal/features/chat/domain/reprositries/imessage_repository.dart';
import 'package:zego_zim/zego_zim.dart';

class MessageRepository implements IMessageRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> getChatList() {
    // TODO: implement getChatList
    throw UnimplementedError();
  }

  @override
  Future<Responses> getMessages({required String receiverId}) {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Future<Responses> sendMessage(  {required String message, required String receiverId}) {
         // TODO: implement getMessages
    throw UnimplementedError();
  }
}

final messageRepositoryProvider = Provider((ref) {
  return MessageRepository();
});
