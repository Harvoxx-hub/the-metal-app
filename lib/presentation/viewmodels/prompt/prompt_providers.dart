import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/prompt/prompt_repository_providers.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_viewmodel.dart';

/// Provider for PromptViewModel
/// Use autoDispose to clean up state when not in use
final promptViewModelProvider =
    StateNotifierProvider.autoDispose<PromptViewModel, PromptState>((ref) {
  final repository = ref.watch(promptRepositoryProvider);
  return PromptViewModel(repository: repository);
});
