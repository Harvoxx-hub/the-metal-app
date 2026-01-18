import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_providers.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Question Selection View
/// Full page showing list of available prompt questions
/// Clicking a question opens a dialog to enter answer
class QuestionSelectionView extends ConsumerStatefulWidget {
  final List<String> selectedQuestionIds;
  final Function(PromptQuestionDto, String) onQuestionAnswered;

  const QuestionSelectionView({
    super.key,
    required this.selectedQuestionIds,
    required this.onQuestionAnswered,
  });

  @override
  ConsumerState<QuestionSelectionView> createState() =>
      _QuestionSelectionViewState();
}

class _QuestionSelectionViewState
    extends ConsumerState<QuestionSelectionView> {
  @override
  void initState() {
    super.initState();
    // Load questions if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(promptViewModelProvider);
      if (state.questions.isEmpty && !state.isLoading) {
        ref.read(promptViewModelProvider.notifier).loadQuestions();
      }
    });
  }

  void _showAnswerDialog(PromptQuestionDto question) {
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: TextView(
          text: question.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBrownColourForText,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              EditFormField(
                controller: answerController,
                label: 'Your answer',
                hint: 'Enter your answer...',
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 2,
                radius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final answer = answerController.text.trim();
              if (answer.isNotEmpty) {
                widget.onQuestionAnswered(question, answer);
                Navigator.pop(context);
                Navigator.pop(context); // Close selection page too
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.metalPinkColour,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promptViewModelProvider);

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
          text: 'Select a Question',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PromptState state) {
    if (state.isLoading && state.questions.isEmpty) {
      return const LoadingState();
    }

    if (state.isError && state.questions.isEmpty) {
      return ErrorState(
        text: state.errorMessage ?? 'Failed to load questions',
        retry: () {
          ref.read(promptViewModelProvider.notifier).loadQuestions();
        },
      );
    }

    if (state.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const Gap(16),
            const TextView(
              text: 'No questions available',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.questions.length,
      itemBuilder: (context, index) {
        final question = state.questions[index];
        final isSelected = widget.selectedQuestionIds.contains(question.id);

        return GestureDetector(
          onTap: isSelected
              ? null
              : () => _showAnswerDialog(question),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[200] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.grey[300]!
                    : AppColors.metalButtonStroke,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextView(
                    text: question.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.grey[600]
                        : AppColors.metalBrownColourForText,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.metalPinkColour,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
