import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';

class UnreadCountNotifier extends StateNotifier<UnreadCountState> {
  UnreadCountNotifier(this.ref) : super(UnreadCountState.initial()) {
    final user = ref.watch(authProvider).data;
   
// 

   // Listen to changes in melt users to update unread count
    ref.listen(getMeltUserProvider, (previous, next) {
      if (next.data != null) {
        final totalUnread = next.data!.fold<int>(
          0,
          (sum, connection) => sum + (connection.lastSenderId == user?.id ? 0 : connection.unreadCount),
        );
        state = UnreadCountState.success(totalUnread);
      }
    }
   );
  }

  final Ref ref;
}

typedef UnreadCountState = BaseState<int>;

final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, UnreadCountState>(
  (ref) => UnreadCountNotifier(ref),
); 