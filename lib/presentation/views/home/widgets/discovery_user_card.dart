import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/views/home/widgets/enhanced_swipe_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Discovery User Card for swipe interface — old UI with prompt flow and direct message.
/// Uses [DiscoveryUserDto] and [EnhancedSwipeCard] for Tinder-like swipe feedback.
/// Swipe up or star/message buttons open the direct message dialog.
class DiscoveryUserCard extends ConsumerWidget {
  final DiscoveryUserDto user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMessage;
  final void Function(String userId)? onDirectMessageSent;

  const DiscoveryUserCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
    this.onMessage,
    this.onDirectMessageSent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

    return EnhancedSwipeCard(
      onSwipeLeft: onPass,
      onSwipeRight: onLike,
      onSwipeUp: () => _showDirectMessageDialog(context),
      swipeUpLabelText: 'MESSAGE',
      swipeUpIcon: Icons.message,
      swipeUpColor: AppColors.metalPinkColour,
      swipeThreshold: 120.0,
      velocityThreshold: 500.0,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.userProfile,
            arguments: <String, String>{'userId': user.id},
          );
        },
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.metalPinkColour.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 300,
                    child: _buildMetalBackground(metalProperties),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildUserInfo(context, metalProperties),
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildLocationBadge(),
                ),

                if (user.isOnline)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetalBackground(MetalPropertiesState metalProperties) {
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

    return CachedNetworkImage(
      imageUrl: metal.img,
      fit: BoxFit.fill,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: 400,
      memCacheHeight: 400,
      placeholder: (context, url) => _buildDefaultBackground(),
      errorWidget: (context, url, error) => _buildDefaultBackground(),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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

  Widget _buildUserInfo(BuildContext context, MetalPropertiesState metalProperties) {
    final prompts = user.prompts ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and verified badge
          Row(
            children: [
              Expanded(
                child: TextView(
                  text: user.username ?? 'Anonymous',
                  fontSize: 24,
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
                    size: 16,
                  ),
                ),
              _buildMetalTitle(metalProperties),
            ],
          ),

          const SizedBox(height: 8),

          // Gender
          if (user.gender != null && user.gender!.isNotEmpty)
            TextView(
              text: user.gender!,
              fontSize: 16,
              color: Colors.black87,
            ),

          const SizedBox(height: 8),

          // Age
          if (user.age != null)
            TextView(
              text: '${user.age} Years Old',
              fontSize: 16,
              color: Colors.black87,
            ),

          const SizedBox(height: 8),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            TextView(
              text: user.bio!,
              fontSize: 16,
              color: Colors.black87,
              maxLines: 2,
            ),

          // Prompts (kept from new flow)
          if (prompts.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPromptsSection(prompts, context),
          ],

          const SizedBox(height: 12),

          // Passions
          if (user.passion != null && user.passion!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (user.passion!.take(3)).map((passion) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: TextView(
                    text: passion,
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

          // Connection options
          if (user.connectionOption != null && user.connectionOption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const TextView(
              text: "Looking for:",
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (user.connectionOption!.take(3)).map((option) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.metalPinkColour.withOpacity(0.3)),
                  ),
                  child: TextView(
                    text: option,
                    fontSize: 12,
                    color: AppColors.metalPinkColour,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons (BUG-007: include text labels)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Pass',
                color: Colors.red,
                onTap: onPass,
              ),
              _buildActionButton(
                icon: Icons.message,
                label: 'Message',
                color: AppColors.metalPinkColour,
                onTap: () {
                  onMessage?.call();
                  _showDirectMessageDialog(context);
                },
              ),
              _buildActionButton(
                icon: Icons.favorite,
                label: 'Like',
                color: Colors.green,
                onTap: onLike,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetalTitle(MetalPropertiesState metalProperties) {
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

  Widget _buildLocationBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.location?.address != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextView(
              text: user.location?.address ?? "No Address",
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        if (user.distance != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                TextView(
                  text: _formatDistance(user.distance!),
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDistance(double distance) {
    if (distance >= 1.0) {
      return '${distance.toStringAsFixed(1)} km';
    } else {
      return '${(distance * 1000).round()} m';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
          const SizedBox(height: 6),
          TextView(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  // ─── Prompt flow (kept from new flow) ───────────────────────────────────

  Widget _buildPromptsSection(List<UserPromptDto> prompts, BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.85;
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
        userName: user.username ?? 'User',
        recipientId: user.id,
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  void _showDirectMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => _DirectMessageDialog(
        userName: user.username ?? 'User',
        recipientId: user.id,
        onCancel: () => Navigator.pop(dialogContext),
        onSent: () {
          Navigator.pop(dialogContext);
          onDirectMessageSent?.call(user.id);
        },
      ),
    );
  }
}

// ─── Prompt reply dialog (kept from new flow) ───────────────────────────────

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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextView(
                text: widget.userName,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
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

// ─── Direct message dialog (kept from new flow) ────────────────────────────

class _DirectMessageDialog extends ConsumerStatefulWidget {
  final String userName;
  final String recipientId;
  final VoidCallback onCancel;
  final VoidCallback onSent;

  const _DirectMessageDialog({
    required this.userName,
    required this.recipientId,
    required this.onCancel,
    required this.onSent,
  });

  @override
  ConsumerState<_DirectMessageDialog> createState() =>
      _DirectMessageDialogState();
}

class _DirectMessageDialogState extends ConsumerState<_DirectMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextView(
                text: 'Message ${widget.userName}',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextView(
                text:
                    'Send a quick message. They can accept to start chatting.',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Write your message...',
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
                    vertical: 14,
                  ),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSending ? null : widget.onCancel,
                      child: TextView(
                        text: 'Cancel',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _isSending ? null : _handleSend,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isSending
                              ? Colors.grey.shade300
                              : AppColors.metalPinkColour,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const TextView(
                                  text: 'Send Message',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);

      await dataSource.sendDirectMessage(
        recipientId: widget.recipientId,
        message: message,
      );

      if (mounted) {
        widget.onSent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent! They can accept to start chatting.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
