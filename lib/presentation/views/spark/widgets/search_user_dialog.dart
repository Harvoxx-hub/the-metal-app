import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/dialog/dialogs.dart';
import 'package:metal/widgets/text_views.dart';

/// Dialog to search users by username and select a recipient.
/// Used by Send Spark screen and dialog.
class SearchUserDialog {
  /// Shows the dialog. Returns the selected [UserDto] or null if cancelled.
  static Future<UserDto?> show(BuildContext context) async {
    return showDialog<UserDto>(
      context: context,
      builder: (context) => CustomDialog(
        isScrollable: false,
        maxHeight: 420,
        content: const _SearchUserDialogContent(),
      ),
    );
  }
}

class _SearchUserDialogContent extends ConsumerStatefulWidget {
  const _SearchUserDialogContent();

  @override
  ConsumerState<_SearchUserDialogContent> createState() =>
      _SearchUserDialogContentState();
}

class _SearchUserDialogContentState extends ConsumerState<_SearchUserDialogContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      ref.read(getUserByNameProvider.notifier).clear();
    } else {
      ref.read(getUserByNameProvider.notifier).getUserByquery(
            query: _searchController.text,
          );
    }
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(getUserByNameProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: TextView(
                text: 'Select recipient',
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
              onPressed: _close,
            ),
          ],
        ),
        const Gap(8),
        TextView(
          text: 'Search by username to find who to send sparks to',
          fontSize: 13,
          color: AppColors.metalBrownColourForText.withOpacity(0.7),
        ),
        const Gap(16),
        // Search field
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search by username',
            hintStyle: TextStyle(
              color: AppColors.metalBrownColourForText.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.metalPinkColour,
              size: 22,
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
        const Gap(12),
        // Results
        SizedBox(
          height: 220,
          child: _buildResults(searchState),
        ),
      ],
    );
  }

  Widget _buildResults(GetUsersByQueryState searchState) {
    if (searchState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchState.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TextView(
            text: searchState.errorMessage ?? 'Search failed',
            fontSize: 14,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (searchState.data == null || searchState.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TextView(
            text: _searchController.text.trim().isEmpty
                ? 'Type a username to search'
                : 'No users found for this username',
            fontSize: 14,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchState.data!.length,
      itemBuilder: (context, index) {
        final user = searchState.data![index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePhoto != null
                ? NetworkImage(user.profilePhoto!)
                : null,
            backgroundColor: AppColors.metalPinkColour.withOpacity(0.2),
            child: user.profilePhoto == null
                ? Text(
                    user.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.metalPinkColour,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          title: TextView(
            text: '@${user.username ?? 'Unknown'}',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.metalBrownColourForText,
          ),
          onTap: () => Navigator.pop(context, user),
        );
      },
    );
  }
}
