import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:metal/domain/entities/notification_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Notification item card matching design spec:
/// Avatar left (56px, dotted border), content right, optional action buttons
class NotificationItemCard extends StatelessWidget {
  final NotificationDto notification;
  final VoidCallback? onTap;
  final void Function(String action)? onAction;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.metalPinkColour.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColors.metalPinkColour.withOpacity(0.2)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: notification.type.isActionable ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatar(context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContent(context, isUnread),
                          const SizedBox(height: 4),
                          TextView(
                            text: timeago.format(notification.createdAt),
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.metalPinkColour,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (notification.actions != null &&
                    notification.actions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final photoUrl = notification.effectiveSenderPhoto;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.metalPinkColour.withOpacity(0.5),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholderAvatar(),
                      errorWidget: (_, __, ___) => _buildPlaceholderAvatar(),
                    )
                  : _buildPlaceholderAvatar(),
            ),
          ),
          if (notification.badge != null)
            Positioned(
              bottom: -2,
              right: -2,
              child: _buildBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: _buildIconForType(notification.type),
      ),
    );
  }

  Widget _buildBadge() {
    final variant = notification.badge!.variant;
    Color bgColor;
    IconData icon;
    switch (variant) {
      case 'success':
        bgColor = Colors.green;
        icon = Icons.check;
        break;
      case 'love':
        bgColor = AppColors.metalPinkColour;
        icon = Icons.favorite;
        break;
      case 'alert':
        bgColor = Colors.purple;
        icon = Icons.notifications;
        break;
      case 'premium':
        bgColor = Colors.blue;
        icon = Icons.bolt_rounded;
        break;
      case 'warning':
        bgColor = Colors.amber;
        icon = Icons.notification_important;
        break;
      default:
        bgColor = AppColors.metalPinkColour;
        icon = Icons.circle;
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }

  Widget _buildContent(BuildContext context, bool isUnread) {
    final username = notification.effectiveSenderName;
    final showUsername = username.isNotEmpty && username != 'Someone';
    final displayMessage = notification.displayMessage;
    final effectiveMessage = displayMessage.isNotEmpty ? displayMessage : 'New notification';

    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w400,
      ),
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w400,
          ),
          children: [
            if (showUsername)
              TextSpan(
                text: '@$username ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            TextSpan(text: effectiveMessage),
            if (notification.content?.inlineAction != null)
              TextSpan(
                text: ' ${notification.content!.inlineAction!.text}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalPinkColour,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (onTap != null && !notification.type.isActionable) {
                      onTap!();
                    }
                  },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = notification.actions!;
    return Row(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(buttons[i]),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(NotificationActionButtonDto btn) {
    final isPrimary = btn.variant == 'primary';
    final isOutline = btn.style == 'outline';

    if (isOutline) {
      return OutlinedButton(
        onPressed: () => onAction?.call(btn.action),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.metalPinkColour,
          side: const BorderSide(color: AppColors.metalPinkColour),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(btn.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );
    }
    return ElevatedButton(
      onPressed: () => onAction?.call(btn.action),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.metalPinkColour : AppColors.metalPinkColour.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(btn.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.profileLiked:
        return Image.asset(
          Assets.images.likeNotification.path,
          width: 28,
          height: 28,
        );
      case NotificationType.melted:
      case NotificationType.meltRequest:
        return Icon(Icons.favorite, size: 28, color: Colors.grey.shade600);
      case NotificationType.sparksSent:
        return Icon(Icons.bolt_rounded, size: 28, color: Colors.grey.shade600);
      case NotificationType.referralJoined:
        return Icon(Icons.person_add, size: 28, color: Colors.grey.shade600);
      case NotificationType.unmetalRequest:
      case NotificationType.unmetalAcceptance:
        return Icon(Icons.visibility, size: 28, color: Colors.grey.shade600);
      case NotificationType.unmetalRequiresMoreTime:
        return Icon(Icons.schedule, size: 28, color: Colors.grey.shade600);
      case NotificationType.meetupInvite:
      case NotificationType.meetupReminder:
      case NotificationType.meetupRsvpDeclined:
      case NotificationType.meetupRsvpUpdate:
      case NotificationType.meetupCreated:
        return Icon(Icons.event, size: 28, color: Colors.grey.shade600);
      case NotificationType.message:
      case NotificationType.promptReaction:
      case NotificationType.directMessage:
        return Icon(Icons.message_rounded, size: 28, color: Colors.grey.shade600);
      case NotificationType.comment:
        return Icon(Icons.comment_rounded, size: 28, color: Colors.grey.shade600);
      default:
        return Icon(Icons.notifications, size: 28, color: Colors.grey.shade600);
    }
  }
}
