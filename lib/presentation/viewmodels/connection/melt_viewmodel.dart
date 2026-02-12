import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/data/repositories/connection/connection_repository.dart';

// ============ Melt Status ViewModel ============

/// State for melt status check
class MeltStatusState {
  final MeltStatusModel? status;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const MeltStatusState({
    this.status,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  factory MeltStatusState.initial() => const MeltStatusState();

  factory MeltStatusState.loading() => const MeltStatusState(isLoading: true);

  factory MeltStatusState.success(MeltStatusModel status) =>
      MeltStatusState(status: status);

  factory MeltStatusState.error(String message) =>
      MeltStatusState(isError: true, errorMessage: message);

  MeltStatusState copyWith({
    MeltStatusModel? status,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return MeltStatusState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => status?.isConnected ?? false;
  bool get isPending => status?.isPending ?? false;
  bool get isNone => status?.isNone ?? true;
}

/// ViewModel for checking melt status with a specific user
class MeltStatusViewModel extends StateNotifier<MeltStatusState> {
  final ConnectionRepository _repository;
  final String targetUserId;

  MeltStatusViewModel({
    required ConnectionRepository repository,
    required this.targetUserId,
  })  : _repository = repository,
        super(MeltStatusState.initial()) {
    checkStatus();
  }

  /// Check melt status
  Future<void> checkStatus() async {
    state = MeltStatusState.loading();

    final result = await _repository.checkMeltStatus(targetUserId);

    if (result.isSuccess && result.data != null) {
      state = MeltStatusState.success(result.data!);
    } else if (result.isError) {
      state = MeltStatusState.error(
        result.errorMessage ?? 'Failed to check melt status',
      );
    } else {
      state = MeltStatusState.success(MeltStatusModel(status: 'none'));
    }
  }

  /// Refresh status
  Future<void> refresh() async {
    await checkStatus();
  }
}

// ============ Melt Action ViewModel ============

/// State for melt actions (melt, unmelt, cancel)
class MeltActionState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final MeltResponseModel? response;

  const MeltActionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.response,
  });

  factory MeltActionState.initial() => const MeltActionState();

  factory MeltActionState.loading() => const MeltActionState(isLoading: true);

  factory MeltActionState.success(MeltResponseModel? response) =>
      MeltActionState(isSuccess: true, response: response);

  factory MeltActionState.error(String message) =>
      MeltActionState(isError: true, errorMessage: message);
}

/// ViewModel for melt actions
class MeltActionViewModel extends StateNotifier<MeltActionState> {
  final ConnectionRepository _repository;

  MeltActionViewModel({
    required ConnectionRepository repository,
  })  : _repository = repository,
        super(MeltActionState.initial());

  /// Create a melt request
  Future<bool> meltUser(String recipientId) async {
    state = MeltActionState.loading();

    final result = await _repository.createMeltRequest(recipientId);

    if (result.isSuccess && result.data != null) {
      state = MeltActionState.success(result.data);
      return true;
    } else {
      state = MeltActionState.error(
        result.errorMessage ?? 'Failed to melt user',
      );
      return false;
    }
  }

  /// Unmelt from a user
  Future<bool> unmeltUser(String userId) async {
    state = MeltActionState.loading();

    final result = await _repository.unmeltUser(userId);

    if (result.isSuccess) {
      state = MeltActionState.success(null);
      return true;
    } else {
      state = MeltActionState.error(
        result.errorMessage ?? 'Failed to unmelt user',
      );
      return false;
    }
  }

  /// Cancel a melt request
  Future<bool> cancelMeltRequest(String userId) async {
    state = MeltActionState.loading();

    final result = await _repository.cancelMeltRequest(userId);

    if (result.isSuccess) {
      state = MeltActionState.success(null);
      return true;
    } else {
      state = MeltActionState.error(
        result.errorMessage ?? 'Failed to cancel melt request',
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = MeltActionState.initial();
  }
}
