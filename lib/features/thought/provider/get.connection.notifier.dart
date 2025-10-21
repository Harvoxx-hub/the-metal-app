import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/data/domain/entries/connection.model.dart';

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
      final response = await homeRepository.getConnection(connectionId);

      if (response.success == true && response.data != null) {
        state = GetConnectionState.success(response.data as ConnectionModel);
      } else {
        state = GetConnectionState.error(
            response.message ?? "Connection not found");
      }
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
