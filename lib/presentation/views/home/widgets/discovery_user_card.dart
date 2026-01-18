import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';

import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Discovery User Card - Full screen scrollable layout
/// Displays user information with prompts in a scrollable format
class DiscoveryUserCard extends ConsumerWidget {
  final DiscoveryUserDto user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;

  const DiscoveryUserCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
  });

  /// Get prompts - use dummy prompts if user doesn't have any
  List<UserPromptDto> get _prompts {
    if (user.prompts != null && user.prompts!.isNotEmpty) {
      return user.prompts!;
    }
    return _getDummyPrompts();
  }

  /// Generate dummy prompts for testing
  List<UserPromptDto> _getDummyPrompts() {
    return [
      const UserPromptDto(
        questionId: '1',
        questionText: "I'll fall for you if...",
        answer:
            "You can make me laugh even on my worst days and appreciate the little things in life.",
      ),
      const UserPromptDto(
        questionId: '2',
        questionText: "My simple pleasures",
        answer:
            "Morning coffee, sunset walks, good books, and deep conversations.",
      ),
      const UserPromptDto(
        questionId: '3',
        questionText: "I'm looking for",
        answer:
            "Someone genuine who values connection over perfection. Let's build something real together.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = _prompts;

    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        children: [
          // Scrollable content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metal image at top
                      _buildMetalImage(ref),

                      // User info section
                      const Gap(16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUsernameWithDetails(ref),
                            const Gap(12),
                            if (user.bio != null && user.bio!.isNotEmpty)
                              _buildBio(),
                            const Gap(12),
                          ],
                        ),
                      ),
                      const Gap(12),
                      // First prompt
                      if (prompts.isNotEmpty)
                        _buildPrompt(prompts.first, context),
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Passions"),
                            const SizedBox(height: 12),
                            _buildPassions(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const Gap(12),
                      // Other prompts (middle prompts, excluding first and last)
                      if (prompts.length > 2)
                        ...prompts.sublist(1, prompts.length - 1).map((prompt) {
                          return Column(
                            children: [
                              _buildPrompt(prompt, context),
                              const SizedBox(height: 24),
                            ],
                          );
                        }),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("What you are looking for"),
                            const SizedBox(height: 12),
                            _buildConnectionOptions(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const Gap(12),
                      // Last prompt
                      if (prompts.length > 1)
                        _buildPrompt(prompts.last, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Like and Reject buttons positioned at top left
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: onPass,
                ),
                Spacer(),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: onLike,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalImage(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

    if (metalProperties.isLoading || metalProperties.data?.metals == null) {
      return _buildDefaultBackground();
    }

    final metals = metalProperties.data!.metals!;
    if (metals.isEmpty || user.metal == null) {
      return _buildDefaultBackground();
    }

    final metal = metals.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => metals[0],
    );

    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: metal.img,
              fit: BoxFit.fitHeight,
              height: 270,
              placeholder: (context, url) => _buildDefaultBackground(),
              errorWidget: (context, url, error) => _buildDefaultBackground(),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (user.location?.address != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextView(
                      text: user.location!.address!,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                const Gap(6),
                if (user.location?.address != null || user.distance != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        TextView(
                          text: _formatDistance(user.distance!),
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.withOpacity(0.3),
            Colors.grey.withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildUsernameWithDetails(WidgetRef ref) {
//    final genderText = user.gender ?? '';
    final ageText = user.age != null ? ' ${user.age}' : '';
    final usernameText = '${user.username ?? 'Anonymous'}$ageText';

    return Row(
      children: [
        Expanded(
          child: TextView(
            text: usernameText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (user.isVerified)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified,
              color: Colors.white,
              size: 20,
            ),
          ),
        _buildMetalTitle(ref),
      ],
    );
  }

  Widget _buildMetalTitle(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

    if (metalProperties.isLoading || metalProperties.data?.metals == null) {
      return const SizedBox.shrink();
    }

    final metals = metalProperties.data!.metals!;
    if (metals.isEmpty || user.metal == null) {
      return const SizedBox.shrink();
    }

    final metal = metals.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => metals[0],
    );

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextView(
        text: metal.title,
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBio() {
    return TextView(
      text: user.bio!,
      fontSize: 16,
      color: Colors.black87,
    );
  }

  Widget _buildPrompt(UserPromptDto prompt, BuildContext context) {
    return InkWell(
      onTap: () => _showPromptDialog(context, prompt),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextView(
                    text: prompt.questionText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: Colors.grey.withOpacity(0.4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextView(
              text: '\u201C${prompt.answer}\u201D',
              fontSize: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  void _showPromptDialog(BuildContext context, UserPromptDto prompt) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => _PromptReplyDialog(
        prompt: prompt,
        userName: user.username ?? 'User',
        recipientId: user.id,
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        TextView(
          text: title,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        const Gap(8),
        Icon(Icons.arrow_forward_ios, size: 15, color: Colors.black),
      ],
    );
  }

  Widget _buildPassions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: user.passion!.map((passion) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.metalPinkColour.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.metalPinkColour.withOpacity(0.3)),
          ),
          child: TextView(
            text: passion,
            fontSize: 14,
            color: AppColors.metalPinkColour,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectionOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: user.connectionOption!.map((option) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.metalPinkColour.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.metalPinkColour.withOpacity(0.3),
            ),
          ),
          child: TextView(
            text: option,
            fontSize: 14,
            color: AppColors.metalPinkColour,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance >= 1.0) {
      return '${distance.toStringAsFixed(1)} km';
    } else {
      return '${(distance * 1000).round()} m';
    }
  }
}

/// Custom dialog for replying to a prompt
class _PromptReplyDialog extends ConsumerStatefulWidget {
  final UserPromptDto prompt;
  final String userName;
  final String recipientId;
  final VoidCallback onCancel;

  const _PromptReplyDialog({
    required this.prompt,
    required this.userName,
    required this.recipientId,
    required this.onCancel,
  });

  @override
  ConsumerState<_PromptReplyDialog> createState() => _PromptReplyDialogState();
}

class _PromptReplyDialogState extends ConsumerState<_PromptReplyDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _likeCount = 0;
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User name
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextView(
                text: widget.userName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Prompt card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: widget.prompt.questionText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                    const SizedBox(height: 12),
                    TextView(
                      text: '\u201C${widget.prompt.answer}\u201D',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
            // Comment input
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  // Like button with count
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _likeCount++;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_likeCount > 0)
                            TextView(
                              text: '$_likeCount',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.metalPinkColour,
                            ),
                          if (_likeCount > 0) const SizedBox(width: 6),
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: AppColors.metalPinkColour,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send Like button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSending ? null : _handleSendLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isSending
                              ? Colors.grey.shade300
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : TextView(
                                  text: 'Send Like',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cancel button
            Center(
              child: TextButton(
                onPressed: widget.onCancel,
                child: TextView(
                  text: 'Cancel',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendLike() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);

      await dataSource.sendPromptReaction(
        recipientId: widget.recipientId,
        promptQuestionText: widget.prompt.questionText,
        promptAnswer: widget.prompt.answer,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your reaction has been sent!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reaction: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
