import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_providers.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/prompt/question_selection_view.dart';
import 'package:metal/presentation/views/prompt/widgets/prompt_answer_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Prompt Creation View
/// Main UI for creating and editing user prompts
class PromptCreationView extends ConsumerStatefulWidget {
  const PromptCreationView({super.key});

  @override
  ConsumerState<PromptCreationView> createState() => _PromptCreationViewState();
}

class _PromptCreationViewState extends ConsumerState<PromptCreationView> {
  final List<UserPromptDto> _userPrompts = [];
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final viewModel = ref.read(promptViewModelProvider.notifier);

    // Load questions and user prompts
    await viewModel.loadQuestions();
    await viewModel.loadUserPrompts(currentUser.id);

    // Initialize user prompts from state
    final state = ref.read(promptViewModelProvider);
    if (state.userPrompts.isNotEmpty) {
      setState(() {
        _userPrompts.addAll(state.userPrompts);
      });
    }
  }

  void _navigateToQuestionSelection() {
    final selectedIds = _userPrompts.map((p) => p.questionId).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionSelectionView(
          selectedQuestionIds: selectedIds,
          onQuestionAnswered: (question, answer) async {
            setState(() {
              _userPrompts.add(
                UserPromptDto(
                  questionId: question.id,
                  questionText: question.text,
                  answer: answer,
                ),
              );
            });
            // Auto-save when a prompt is added
            await _autoSavePrompts();
          },
        ),
      ),
    );
  }

  void _onAnswerChanged(int index, String answer) {
    setState(() {
      _userPrompts[index] = _userPrompts[index].copyWith(answer: answer);
    });
    // Auto-save when answer is changed
    _autoSavePrompts();
  }

  void _onDeletePrompt(int index) async {
    setState(() {
      _userPrompts.removeAt(index);
    });
    // Auto-save when a prompt is deleted - always save, even if list is empty
    await _savePromptsImmediately();
  }

  Future<void> _savePromptsImmediately() async {
    // Save immediately (used for deletion or when we want to save regardless)
    final viewModel = ref.read(promptViewModelProvider.notifier);
    await viewModel.savePrompts(_userPrompts);
  }

  Future<void> _autoSavePrompts() async {
    // Skip auto-save if there are no prompts or if any are incomplete
    if (_userPrompts.isEmpty) return;

    // Validate all prompts have answers before saving
    for (final prompt in _userPrompts) {
      if (prompt.answer.trim().isEmpty) {
        return; // Don't save if any prompt is incomplete
      }
    }

    final viewModel = ref.read(promptViewModelProvider.notifier);
    await viewModel.savePrompts(_userPrompts);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promptViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: AppBar(
        backgroundColor: AppColors.metalPinkColour,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextView(
          text: 'Manage Prompts',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: _buildBody(state, currentUser),
    );
  }

  Widget _buildBody(PromptState state, currentUser) {
    // Show loading state
    if (state.isLoading && !_hasInitialized) {
      return const LoadingState();
    }

    // Show error state
    if (state.isError && state.questions.isEmpty && !_hasInitialized) {
      return ErrorState(
        text: state.errorMessage ?? 'Failed to load questions',
        retry: () {
          ref.read(promptViewModelProvider.notifier).loadQuestions();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (currentUser != null) {
          await ref
              .read(promptViewModelProvider.notifier)
              .refresh(currentUser.id);
          final newState = ref.read(promptViewModelProvider);
          setState(() {
            _userPrompts.clear();
            _userPrompts.addAll(newState.userPrompts);
          });
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            if (_userPrompts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const Gap(16),
                    TextView(
                      text: 'Create Your Prompts',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBrownColourForText,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextView(
                        text:
                            'Select at least 3 questions and share your answers to help others know you better',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

            // Minimum requirement info
            if (_userPrompts.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _userPrompts.length >= 3
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _userPrompts.length >= 3
                          ? Icons.check_circle
                          : Icons.info,
                      color: _userPrompts.length >= 3
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: TextView(
                        text:
                            '${_userPrompts.length}/3 prompts (minimum required)',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _userPrompts.length >= 3
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),

            // Prompt cards
            ...List.generate(_userPrompts.length, (index) {
              return PromptAnswerCard(
                prompt: _userPrompts[index],
                onAnswerChanged: (answer) => _onAnswerChanged(index, answer),
                onDelete: () => _onDeletePrompt(index),
              );
            }),

            // Add question button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: BaseButton(
                buttonText: 'Add Question',
                onPressed: _navigateToQuestionSelection,
                leftIcon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
                enabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
