import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';

/// Badged navigation icon widget
/// Shows an icon with an optional badge (e.g., unread count)
class BadgedNavIcon extends StatelessWidget {
  final Widget icon;
  final bool showBadge;
  final int? badgeCount;

  const BadgedNavIcon({
    super.key,
    required this.icon,
    this.showBadge = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge || badgeCount == null || badgeCount! <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              badgeCount! > 99 ? '99+' : badgeCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chat nav icon with unread badge
/// Automatically shows badge from unread count provider
class ChatNavIcon extends ConsumerWidget {
  final Widget icon;

  const ChatNavIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListState = ref.watch(chatListViewModelProvider);
    final count = chatListState.totalUnreadCount;

    return BadgedNavIcon(
      icon: icon,
      showBadge: count > 0,
      badgeCount: count,
    );
  }
}

