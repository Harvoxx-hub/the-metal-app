import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// Dialog to select friends (connections / melted metals) to invite to a LinkUp.
/// If the user has no connections, shows an empty state explaining they need
/// to connect with people first.
class SelectFriendsDialog extends ConsumerStatefulWidget {
  final List<String> initiallySelectedUserIds;

  const SelectFriendsDialog({
    super.key,
    this.initiallySelectedUserIds = const [],
  });

  @override
  ConsumerState<SelectFriendsDialog> createState() => _SelectFriendsDialogState();

  /// Show dialog and return selected friend user IDs, or null if cancelled.
  static Future<List<String>?> show(
    BuildContext context, {
    List<String> initiallySelectedUserIds = const [],
  }) async {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => SelectFriendsDialog(
        initiallySelectedUserIds: initiallySelectedUserIds,
      ),
    );
  }
}

class _SelectFriendsDialogState extends ConsumerState<SelectFriendsDialog> {
  final Set<String> _selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedUserIds.addAll(widget.initiallySelectedUserIds);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  /// Other user ID in the connection (the friend, not current user).
  String? _otherUserId(ConnectionApiModel connection) {
    final currentUserId = ref.read(userStateProvider).user?.id;
    if (currentUserId == null) return null;
    try {
      return connection.users.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
    } catch (_) {
      return null;
    }
  }

  List<ConnectionApiModel> _filteredConnections(
    List<ConnectionApiModel> connections,
  ) {
    if (_searchQuery.isEmpty) return connections;
    return connections.where((c) {
      final name = (c.otherUser?.username ?? c.otherUser?.firstName ?? '')
          .toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedUserIds.toList());
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionViewModelProvider);
    final connections = connectionState.connections;
    final filtered = _filteredConnections(connections);
    final isLoading = connectionState.isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextView(
                      text: 'Select Friends to Invite',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBrownColourForText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.metalBrownColourForText,
                    ),
                    onPressed: _cancel,
                  ),
                ],
              ),
            ),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextView(
                  text: 'Invite people from your melted metal list',
                  fontSize: 13,
                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                ),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(
                    color: AppColors.metalBrownColourForText.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.metalBrownColourForText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // List or empty state
            Flexible(
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 56,
                                  color: AppColors.metalPinkColour.withOpacity(0.6),
                                ),
                                const Gap(16),
                                TextView(
                                  text: _searchQuery.isEmpty
                                      ? "You don't have any melted metals yet"
                                      : 'No friends match your search',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.metalBrownColourForText,
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(8),
                                TextView(
                                  text: _searchQuery.isEmpty
                                      ? 'To invite friends to a LinkUp, connect with people first from your melted metal list.'
                                      : 'Try a different name.',
                                  fontSize: 13,
                                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final connection = filtered[index];
                            final otherUserId = _otherUserId(connection);
                            final otherUser = connection.otherUser;
                            if (otherUserId == null || otherUser == null) {
                              return const SizedBox.shrink();
                            }
                            final isSelected = _selectedUserIds.contains(otherUserId);
                            final displayName = otherUser.username ??
                                otherUser.firstName ??
                                'Friend';

                            return InkWell(
                              onTap: () => _toggleSelection(otherUserId),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.metalPinkColour.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ProfilePhoto(
                                      size: 44,
                                      verfly: false,
                                      meltId: otherUser.metal ?? '',
                                      imgUrl: null, // Invite list: show metal icon only
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: TextView(
                                        text: displayName,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.metalBrownColourForText,
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.metalPinkColour
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? AppColors.metalPinkColour
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const TextView(
                        text: 'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedUserIds.isEmpty ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.metalPinkColour,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: TextView(
                        text: _selectedUserIds.isEmpty
                            ? 'Select Friends'
                            : 'Invite (${_selectedUserIds.length})',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}
