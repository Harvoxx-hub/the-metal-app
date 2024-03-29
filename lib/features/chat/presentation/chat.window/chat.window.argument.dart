import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

class ChatWindowArgument {
  ChatWindowArgument({
    required this.user,
    this.conversationId,
  });

  final MeltUserModel user;

  final String? conversationId;
}
