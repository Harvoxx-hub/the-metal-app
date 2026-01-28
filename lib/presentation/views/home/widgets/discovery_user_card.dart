import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';

import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/presentation/viewmodels/discovery/discovery_user_thoughts_viewmodel.dart';

/// Discovery User Card - Swipeable card with scrollable content
/// Displays user information with prompts in a scrollable format
/// Supports horizontal swiping (left/right) but not vertical dismissal
class DiscoveryUserCard extends ConsumerStatefulWidget {
  final DiscoveryUserDto user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;

  const DiscoveryUserCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
  });

  @override
  ConsumerState<DiscoveryUserCard> createState() => _DiscoveryUserCardState();
}

class _DiscoveryUserCardState extends ConsumerState<DiscoveryUserCard> {
  double _dragOffset = 0.0;
  bool _isHorizontalSwipe = false;
  double _totalHorizontalDrag = 0.0;
  double _totalVerticalDrag = 0.0;
  final double _swipeThreshold =
      100.0; // Minimum drag distance to trigger swipe
  final double _horizontalSwipeThreshold =
      20.0; // Minimum horizontal movement to start swipe

  /// Get prompts - return ALL actual user prompts with dummy data if needed (for testing)
  /// Dummy data will be removed in production
  List<UserPromptDto> get _prompts {
    final userPrompts = widget.user.prompts ?? [];

    // For testing: If user has less than 3 prompts, add dummy data
    // TODO: Remove dummy data when going to production
    if (userPrompts.length < 3) {
      final dummyPrompts = [
        UserPromptDto(
          questionId: 'dummy1',
          questionText: 'What\'s your ideal first date?',
          answer: 'A cozy coffee shop or a walk in the park',
        ),
        UserPromptDto(
          questionId: 'dummy2',
          questionText: 'What makes you laugh?',
          answer: 'Good memes and witty conversations',
        ),
        UserPromptDto(
          questionId: 'dummy3',
          questionText: 'What\'s something you\'re passionate about?',
          answer: 'Music, art, and meaningful connections',
        ),
      ];

      // Fill with dummy data if needed to reach minimum of 3
      final result = <UserPromptDto>[];
      result.addAll(userPrompts);
      for (int i = userPrompts.length; i < 3; i++) {
        result.add(dummyPrompts[i - userPrompts.length]);
      }
      return result;
    }

    // Return ALL prompts (no maximum limit)
    return userPrompts;
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isHorizontalSwipe = false;
      _totalHorizontalDrag = 0.0;
      _totalVerticalDrag = 0.0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final horizontalDelta = details.delta.dx;
    final verticalDelta = details.delta.dy.abs();

    _totalHorizontalDrag += horizontalDelta.abs();
    _totalVerticalDrag += verticalDelta;

    // Determine if this is primarily a horizontal swipe
    // Only start horizontal dragging if horizontal movement is dominant
    if (!_isHorizontalSwipe) {
      if (_totalHorizontalDrag > _horizontalSwipeThreshold &&
          _totalHorizontalDrag > _totalVerticalDrag) {
        setState(() {
          _isHorizontalSwipe = true;
        });
      }
    }

    // Only update drag offset if we've determined this is a horizontal swipe
    if (_isHorizontalSwipe) {
      setState(() {
        _dragOffset += horizontalDelta;
        // Clamp the offset to prevent excessive dragging
        _dragOffset = _dragOffset.clamp(-300.0, 300.0);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Only trigger swipe action if it was a horizontal swipe
    if (_isHorizontalSwipe && _dragOffset.abs() > _swipeThreshold) {
      if (_dragOffset > 0) {
        // Swiped right - like
        widget.onLike?.call();
      } else {
        // Swiped left - pass
        widget.onPass?.call();
      }
      // Reset position after action
      setState(() {
        _dragOffset = 0.0;
        _isHorizontalSwipe = false;
      });
    } else {
      // Spring back to center
      setState(() {
        _dragOffset = 0.0;
        _isHorizontalSwipe = false;
      });
    }
  }

  void _onPanCancel() {
    setState(() {
      _dragOffset = 0.0;
      _isHorizontalSwipe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prompts = _prompts;
    final screenWidth = MediaQuery.of(context).size.width;
    final rotation = _dragOffset / screenWidth * 0.1; // Slight rotation effect
    final opacity =
        1.0 - (_dragOffset.abs() / screenWidth * 0.3).clamp(0.0, 0.3);

    // Watch thoughts state from ViewModel
    final thoughtsState = ref.watch(
      discoveryUserThoughtsProvider(widget.user.id),
    );

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      // Only accept horizontal gestures when not scrolling vertically
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: Container(
              color: Colors.grey.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Stack(
                children: [
                  // Scrollable content - wrapped to allow vertical scrolling
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.metalPinkColour,
                          blurRadius: 10,
                          spreadRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.metalPinkColour,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Metal image at top
                                _buildMetalImage(ref),

                                // User info section

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildUsernameWithDetails(ref),
                                      const Gap(12),
                                      // Prompts section (replaces bio)
                                      if (prompts.isNotEmpty)
                                        _buildPromptsSection(prompts, context),
                                      const Gap(12),
                                      _buildPassions(),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextView(
                                        text: "Looking for:",
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildConnectionOptions(),
                                    ],
                                  ),
                                ),

                                // Recent Thoughts section
                                if (thoughtsState.thoughts.isNotEmpty ||
                                    thoughtsState.isLoading)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextView(
                                          text: "Recent Thoughts:",
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildRecentThoughtsSection(
                                            thoughtsState),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    //
                  ),
                  // Like and Reject buttons positioned at bottom
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Spacer(),
                        _buildActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: widget.onPass,
                        ),
                        Spacer(),
                        _buildActionButton(
                          icon: Icons.message,
                          color: Colors.black,
                          onTap: widget.onPass,
                        ),
                        Spacer(),
                        _buildActionButton(
                          icon: Icons.favorite,
                          color: Colors.green,
                          onTap: widget.onLike,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetalImage(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

    if (metalProperties.isLoading || metalProperties.data?.metals == null) {
      return _buildDefaultBackground();
    }

    final metals = metalProperties.data!.metals!;
    if (metals.isEmpty || widget.user.metal == null) {
      return _buildDefaultBackground();
    }

    final metal = metals.firstWhere(
      (element) => element.id == widget.user.metal,
      orElse: () => metals[0],
    );

    return Stack(
      children: [
        SizedBox(
          height: 270,
          width: double.infinity,
          child: Container(
            padding:
                const EdgeInsets.only(top: 30, bottom: 0, left: 30, right: 30),
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
                if (widget.user.location?.address != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextView(
                      text: widget.user.location!.address!,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                const Gap(6),
                if (widget.user.location?.address != null ||
                    widget.user.distance != null)
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
                          text: _formatDistance(widget.user.distance!),
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
      height: 270,
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
    );
  }

  Widget _buildUsernameWithDetails(WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: widget.user.username ?? 'Anonymous',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              const Gap(12),
              if (widget.user.age != null) ...[
                const SizedBox(width: 4),
                TextView(
                  text: '${widget.user.age} Years Old',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
              const Gap(12),
              if (widget.user.gender != null &&
                  widget.user.gender!.isNotEmpty) ...[
                const SizedBox(width: 4),
                TextView(
                  text: '${widget.user.gender}',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ],
          ),
        ),
        if (widget.user.isVerified)
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
    if (metals.isEmpty || widget.user.metal == null) {
      return const SizedBox.shrink();
    }

    final metal = metals.firstWhere(
      (element) => element.id == widget.user.metal,
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

  Widget _buildPromptsSection(
      List<UserPromptDto> prompts, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Card width is 85% of screen, leaving 15% visible for next card peek
    final cardWidth = screenWidth * 0.85;
    // Right margin creates the gap and peek effect
    final rightMargin = 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 0, right: screenWidth * 0.15),
            physics: const BouncingScrollPhysics(),
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: rightMargin),
                child: _buildPrompt(prompts[index], context),
              );
            },
          ),
        ),
        // Swipe indicator (only show when there are multiple prompts)
      ],
    );
  }

  Widget _buildPrompt(UserPromptDto prompt, BuildContext context) {
    return InkWell(
      onTap: () => _showPromptDialog(context, prompt),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
        userName: widget.user.username ?? 'User',
        recipientId: widget.user.id,
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  Widget _buildPassions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.user.passion!.map((passion) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextView(
            text: passion,
            fontSize: 14,
            color: Colors.black,
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
      children: widget.user.connectionOption!.map((option) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: TextView(
            text: option,
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentThoughtsSection(DiscoveryUserThoughtsState thoughtsState) {
    if (thoughtsState.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (thoughtsState.isError || thoughtsState.thoughts.isEmpty) {
      return SizedBox(
        height: 80,
        child: EmptyState(
          text: 'no recent thought',
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.15),
        itemCount: thoughtsState.thoughts.length,
        itemBuilder: (context, index) {
          final thought = thoughtsState.thoughts[index];
          return _buildThoughtSnippet(thought);
        },
      ),
    );
  }

  Widget _buildThoughtSnippet(ThoughtDto thought) {
    final dateText = formatTime(datetime: thought.createdAt);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.thoughtDetails,
          arguments: thought.id,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.metalPinkColour.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.metalPinkColour.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextView(
                text: thought.content,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(8),
            TextView(
              text: dateText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.metalPinkColour.withOpacity(0.7),
            ),
          ],
        ),
      ),
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
