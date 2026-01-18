import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/prompt/prompt_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/prompt/prompt_creation_view.dart';
import 'package:metal/presentation/views/prompt/widgets/prompt_answer_card.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Prompt Display View
/// Read-only view showing user's prompts in the profile tab
class PromptDisplayView extends ConsumerStatefulWidget {
  const PromptDisplayView({super.key});

  @override
  ConsumerState<PromptDisplayView> createState() => _PromptDisplayViewState();
}

class _PromptDisplayViewState extends ConsumerState<PromptDisplayView> {
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
    await viewModel.loadUserPrompts(currentUser.id);
  }

  void _navigateToManagePrompts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PromptCreationView(),
      ),
    ).then((_) {
      // Refresh prompts when returning from manage page
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        ref
            .read(promptViewModelProvider.notifier)
            .loadUserPrompts(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promptViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Show loading state
    if (state.isLoading && !_hasInitialized) {
      return const LoadingState();
    }

    // Show empty state
    if (state.userPrompts.isEmpty && !state.isLoading) {
      return RefreshIndicator(
        onRefresh: () async {
          if (currentUser != null) {
            await ref
                .read(promptViewModelProvider.notifier)
                .loadUserPrompts(currentUser.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const Gap(16),
                const TextView(
                  text: 'No Prompts Yet',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextView(
                    text: 'Create your prompts to help others know you better',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: BaseButton(
                    buttonText: 'Add Prompts',
                    onPressed: _navigateToManagePrompts,
                    enabled: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show prompts list
    return RefreshIndicator(
      onRefresh: () async {
        if (currentUser != null) {
          await ref
              .read(promptViewModelProvider.notifier)
              .loadUserPrompts(currentUser.id);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manage button at top
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BaseButton(
                buttonText: 'Manage Prompts',
                onPressed: _navigateToManagePrompts,
                leftIcon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
                enabled: true,
              ),
            ),

            // Prompts list (read-only)
            ...state.userPrompts.map((prompt) {
              return PromptAnswerCard(
                prompt: prompt,
                isReadOnly: true,
                onAnswerChanged: (_) {}, // No-op for read-only
                onDelete: () {}, // No-op for read-only
              );
            }),
          ],
        ),
      ),
    );
  }
}
