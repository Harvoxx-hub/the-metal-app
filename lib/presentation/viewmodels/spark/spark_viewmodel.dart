import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/spark/spark_repository.dart';
import 'package:metal/data/repositories/spark/spark_repository_providers.dart';
import 'package:metal/domain/entities/spark_dto.dart';

/// Spark State
class SparkState {
  final bool isLoading;
  final bool isSending;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final int balance;
  final List<SparkTransactionDto> transactions;
  final bool hasMore;
  final int currentPage;

  const SparkState({
    this.isLoading = false,
    this.isSending = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.balance = 0,
    this.transactions = const [],
    this.hasMore = true,
    this.currentPage = 1,
  });

  /// Initial state
  factory SparkState.initial() => const SparkState();

  /// Loading state
  factory SparkState.loading({
    int? existingBalance,
    List<SparkTransactionDto>? existingTransactions,
  }) =>
      SparkState(
        isLoading: true,
        balance: existingBalance ?? 0,
        transactions: existingTransactions ?? [],
      );

  /// Success state
  factory SparkState.success({
    required int balance,
    required List<SparkTransactionDto> transactions,
    bool hasMore = true,
    int currentPage = 1,
  }) {
    return SparkState(
      isSuccess: true,
      balance: balance,
      transactions: transactions,
      hasMore: hasMore,
      currentPage: currentPage,
    );
  }

  /// Error state
  factory SparkState.error(
    String message, {
    int? existingBalance,
    List<SparkTransactionDto>? existingTransactions,
  }) =>
      SparkState(
        isError: true,
        errorMessage: message,
        balance: existingBalance ?? 0,
        transactions: existingTransactions ?? [],
      );

  /// Copy with
  SparkState copyWith({
    bool? isLoading,
    bool? isSending,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    int? balance,
    List<SparkTransactionDto>? transactions,
    bool? hasMore,
    int? currentPage,
  }) {
    return SparkState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Spark ViewModel
/// Handles loading spark balance and transaction history
class SparkViewModel extends StateNotifier<SparkState> {
  final SparkRepository _repository;

  SparkViewModel({
    required SparkRepository repository,
  })  : _repository = repository,
        super(SparkState.initial());

  /// Load sparks balance and transaction history
  Future<void> loadSparks({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = SparkState.loading();
    } else {
      state = state.copyWith(isLoading: true);
    }

    final result = await _repository.getSparks();

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = SparkState.success(
          balance: result.data!.balance,
          transactions: result.data!.transactions,
          hasMore: result.data!.hasMore,
          currentPage: result.data!.currentPage ?? 1,
        );
      } else {
        state = SparkState.error(
          result.errorMessage ?? 'Failed to load sparks',
          existingBalance: state.balance,
          existingTransactions: state.transactions,
        );
      }
    }
  }

  /// Send sparks to another user
  Future<bool> sendSparks({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    if (state.isSending) return false;

    state = state.copyWith(isSending: true);

    final result = await _repository.sendSparks(
      recipientId: recipientId,
      amount: amount,
      message: message,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Optimistically update balance and add transaction
        final newBalance = state.balance - amount;
        final newTransactions = [result.data!, ...state.transactions];

        state = state.copyWith(
          isSending: false,
          balance: newBalance,
          transactions: newTransactions,
          isSuccess: true,
        );

        return true;
      } else {
        state = state.copyWith(
          isSending: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to send sparks',
        );

        return false;
      }
    }

    return false;
  }

  /// Refresh sparks data
  Future<void> refreshSparks() async {
    await loadSparks(refresh: true);
  }
}

/// Spark ViewModel Provider
final sparkViewModelProvider =
    StateNotifierProvider.autoDispose<SparkViewModel, SparkState>((ref) {
  final repository = ref.watch(sparkRepositoryProvider);
  final viewModel = SparkViewModel(repository: repository);
  viewModel.loadSparks(); // Auto-load on creation
  return viewModel;
});
