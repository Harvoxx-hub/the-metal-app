import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/prompt/prompt_repository_abstract.dart';
import 'package:metal/domain/entities/prompt_dto.dart';

/// Prompt State
class PromptState {
  final bool isLoading;
  final bool isSaving;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<PromptQuestionDto> questions;
  final List<UserPromptDto> userPrompts;

  const PromptState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.questions = const [],
    this.userPrompts = const [],
  });

  /// Initial state
  factory PromptState.initial() => const PromptState();

  /// Loading state
  factory PromptState.loading({
    List<PromptQuestionDto>? existingQuestions,
    List<UserPromptDto>? existingPrompts,
  }) =>
      PromptState(
        isLoading: true,
        questions: existingQuestions ?? [],
        userPrompts: existingPrompts ?? [],
      );

  /// Success state
  factory PromptState.success({
    required List<PromptQuestionDto> questions,
    List<UserPromptDto>? userPrompts,
  }) =>
      PromptState(
        isSuccess: true,
        questions: questions,
        userPrompts: userPrompts ?? const [],
      );

  /// Error state
  factory PromptState.error(
    String message, {
    List<PromptQuestionDto>? existingQuestions,
    List<UserPromptDto>? existingPrompts,
  }) =>
      PromptState(
        isError: true,
        errorMessage: message,
        questions: existingQuestions ?? [],
        userPrompts: existingPrompts ?? [],
      );

  /// Copy with
  PromptState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<PromptQuestionDto>? questions,
    List<UserPromptDto>? userPrompts,
  }) {
    return PromptState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      questions: questions ?? this.questions,
      userPrompts: userPrompts ?? this.userPrompts,
    );
  }
}

/// Prompt ViewModel
/// Handles loading questions and managing user prompts
class PromptViewModel extends StateNotifier<PromptState> {
  final PromptRepositoryAbstract _repository;
  final void Function(List<UserPromptDto> prompts)? onPromptsSynced;

  PromptViewModel({
    required PromptRepositoryAbstract repository,
    this.onPromptsSynced,
  })  : _repository = repository,
        super(PromptState.initial());

  /// Load all available questions
  Future<void> loadQuestions() async {
    if (state.isLoading) return;

    state = PromptState.loading(
      existingQuestions: state.questions,
      existingPrompts: state.userPrompts,
    );

    final result = await _repository.getAllQuestions();

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = PromptState.success(
          questions: result.data!,
          userPrompts: state.userPrompts,
        );
      } else {
        state = PromptState.error(
          result.errorMessage ?? 'Failed to load questions',
          existingQuestions: state.questions,
          existingPrompts: state.userPrompts,
        );
      }
    }
  }

  /// Load user's prompts
  Future<void> loadUserPrompts(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final result = await _repository.getUserPrompts(userId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          isLoading: false,
          userPrompts: result.data!,
          isError: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to load user prompts',
        );
      }
    }
  }

  /// Save user prompts
  Future<void> savePrompts(List<UserPromptDto> prompts) async {
    if (state.isSaving) return;

    // Validate minimum 3 prompts
    if (prompts.length < 3) {
      state = state.copyWith(
        isError: true,
        errorMessage: 'Minimum 3 prompts are required',
      );
      return;
    }

    // Validate all prompts have answers
    for (final prompt in prompts) {
      if (prompt.answer.trim().isEmpty) {
        state = state.copyWith(
          isError: true,
          errorMessage: 'All prompts must have answers',
        );
        return;
      }
    }

    state = state.copyWith(isSaving: true, isError: false);

    final result = await _repository.saveUserPrompts(prompts);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        onPromptsSynced?.call(result.data!);
        state = state.copyWith(
          isSaving: false,
          isSuccess: true,
          userPrompts: result.data!,
          isError: false,
        );
      } else {
        state = state.copyWith(
          isSaving: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to save prompts',
        );
      }
    }
  }

  /// Refresh - reload questions and user prompts
  Future<void> refresh(String userId) async {
    await Future.wait([
      loadQuestions(),
      loadUserPrompts(userId),
    ]);
  }
}
