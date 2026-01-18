import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_providers.dart';
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
          onQuestionAnswered: (question, answer) {
            setState(() {
              _userPrompts.add(
                UserPromptDto(
                  questionId: question.id,
                  questionText: question.text,
                  answer: answer,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _onAnswerChanged(int index, String answer) {
    setState(() {
      _userPrompts[index] = _userPrompts[index].copyWith(answer: answer);
    });
  }

  void _onDeletePrompt(int index) {
    setState(() {
      _userPrompts.removeAt(index);
    });
  }

  Future<void> _savePrompts() async {
    // Validate minimum 3 prompts
    if (_userPrompts.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 3 prompts are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate all prompts have answers
    for (final prompt in _userPrompts) {
      if (prompt.answer.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All prompts must have answers'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final viewModel = ref.read(promptViewModelProvider.notifier);
    await viewModel.savePrompts(_userPrompts);

    final state = ref.read(promptViewModelProvider);
    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompts saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to save prompts'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promptViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

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

    // Initialize prompts from state if not already initialized
    if (state.userPrompts.isNotEmpty && _userPrompts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _userPrompts.addAll(state.userPrompts);
        });
      });
    }

    final canSave = _userPrompts.length >= 3 &&
        _userPrompts.every((p) => p.answer.trim().isNotEmpty) &&
        !state.isSaving;

    return RefreshIndicator(
      onRefresh: () async {
        if (currentUser != null) {
          await ref.read(promptViewModelProvider.notifier).refresh(currentUser.id);
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
                        text: 'Select at least 3 questions and share your answers to help others know you better',
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
                      _userPrompts.length >= 3 ? Icons.check_circle : Icons.info,
                      color: _userPrompts.length >= 3
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: TextView(
                        text: '${_userPrompts.length}/3 prompts (minimum required)',
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

            // Save button
            if (_userPrompts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BaseButton(
                  buttonText: state.isSaving ? 'Saving...' : 'Save Prompts',
                  onPressed: canSave ? _savePrompts : null,
                  enabled: canSave,
                  loading: state.isSaving,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
