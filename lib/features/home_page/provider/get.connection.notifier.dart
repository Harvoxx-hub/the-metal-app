import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';

class GetConnectionNotifier extends StateNotifier<GetConnectionState> {
  GetConnectionNotifier(super.state, this.ref, this.connectionId) {
    getConnection();
  }

  final Ref ref;
  final String connectionId;

  Future<void> getConnection() async {
    try {
      state = GetConnectionState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final connection = await homeRepository.getConnection(connectionId);
      state = GetConnectionState.success(connection.data);
    } catch (e, s) {
      state = GetConnectionState.error(e.toString(), stackTrace: s);
    }
  }
}

typedef GetConnectionState = BaseState<ConnectionModel>;

final getConnectionProvider = StateNotifierProvider.family<
    GetConnectionNotifier, GetConnectionState, String>((ref, connectionId) {
  return GetConnectionNotifier(GetConnectionState.initial(), ref, connectionId);
});
