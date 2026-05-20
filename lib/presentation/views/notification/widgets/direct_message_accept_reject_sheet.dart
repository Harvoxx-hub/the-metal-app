import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/domain/entities/notification_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Modal bottom sheet shown when recipient taps a direct_message notification.
/// Displays message(s) from sender and Accept / Reject actions.
class DirectMessageAcceptRejectSheet extends ConsumerStatefulWidget {
  final NotificationDto notification;

  const DirectMessageAcceptRejectSheet({
    super.key,
    required this.notification,
  });

  /// Show the sheet and return connectionId if accepted, null if rejected or dismissed.
  static Future<String?> show(
      BuildContext context, NotificationDto notification) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DirectMessageAcceptRejectSheet(notification: notification),
    );
  }

  @override
  ConsumerState<DirectMessageAcceptRejectSheet> createState() =>
      _DirectMessageAcceptRejectSheetState();
}

class _DirectMessageAcceptRejectSheetState
    extends ConsumerState<DirectMessageAcceptRejectSheet> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  String? _error;
  bool _accepting = false;
  bool _rejecting = false;

  String get _senderId => widget.notification.effectiveSenderId;
  String get _senderName => widget.notification.effectiveSenderName;
  String? get _senderPhoto => widget.notification.effectiveSenderPhoto;

  @override
  void initState() {
    super.initState();
    _loadPendingMessages();
  }

  Future<void> _loadPendingMessages() async {
    if (_senderId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Unknown sender';
      });
      return;
    }

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);
      final data = await dataSource.getPendingDirectMessages(_senderId);
      final messages = data['messages'] as List<dynamic>? ?? [];
      setState(() {
        _messages = messages
            .map((m) => m is Map<String, dynamic> ? m : <String, dynamic>{})
            .toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleAccept() async {
    if (_accepting || _rejecting) return;

    setState(() => _accepting = true);

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);
      final data = await dataSource.acceptDirectMessage(_senderId);
      final connectionId = data['connectionId'] as String?;

      if (!mounted) return;
      Navigator.of(context).pop(connectionId);
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to accept: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReject() async {
    if (_accepting || _rejecting) return;

    setState(() => _rejecting = true);

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);
      await dataSource.rejectDirectMessage(_senderId);

      if (!mounted) return;
      Navigator.of(context).pop(null);
    } catch (e) {
      if (mounted) {
        setState(() => _rejecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to reject: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _senderId.isNotEmpty
                ? () => Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: _senderId,
                    )
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        _senderPhoto != null && _senderPhoto!.isNotEmpty
                            ? CachedNetworkImageProvider(_senderPhoto!)
                            : null,
                    child: _senderPhoto == null || _senderPhoto!.isEmpty
                        ? TextView(
                            text: _senderName.isNotEmpty
                                ? _senderName.substring(0, 1).toUpperCase()
                                : '?',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: _senderName,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        TextView(
                          text: 'Tap to view profile',
                          fontSize: 12,
                          color: AppColors.metalPinkColour,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextView(
                text: _error!,
                fontSize: 14,
                color: Colors.red,
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Message${_messages.length > 1 ? 's' : ''}',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    ..._messages.map((m) {
                      final text = m['message'] as String? ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextView(
                            text: text.isEmpty ? '(No text)' : text,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (_accepting || _rejecting) ? null : _handleReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: _rejecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const TextView(
                          text: 'Reject',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_accepting || _rejecting) ? null : _handleAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.metalPinkColour,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _accepting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const TextView(
                          text: 'Accept',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
