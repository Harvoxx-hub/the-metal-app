import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/data/repositories/community/community_repository_providers.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Community Multi-Select Dialog
/// Allows users to select multiple communities for meetup broadcasting
class CommunityMultiSelectDialog extends ConsumerStatefulWidget {
  final List<String> initiallySelectedIds;

  const CommunityMultiSelectDialog({
    super.key,
    this.initiallySelectedIds = const [],
  });

  @override
  ConsumerState<CommunityMultiSelectDialog> createState() => _CommunityMultiSelectDialogState();

  /// Show dialog and return selected community IDs
  static Future<List<String>?> show(
    BuildContext context, {
    List<String> initiallySelectedIds = const [],
  }) async {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => CommunityMultiSelectDialog(
        initiallySelectedIds: initiallySelectedIds,
      ),
    );
  }
}

class _CommunityMultiSelectDialogState extends ConsumerState<CommunityMultiSelectDialog> {
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<CommunityDto> _allCommunities = [];
  List<CommunityDto> _filteredCommunities = [];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initiallySelectedIds);
    _searchController.addListener(_onSearchChanged);
    _loadCommunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterCommunities();
    });
  }

  void _filterCommunities() {
    if (_searchQuery.isEmpty) {
      _filteredCommunities = _allCommunities;
    } else {
      _filteredCommunities = _allCommunities.where((community) {
        final name = community.name.toLowerCase();
        final description = community.description.toLowerCase();
        final category = (community.category ?? '').toLowerCase();
        return name.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(communityRepositoryProvider);
      final result = await repository.getCommunities(
        type: 'my-communities', // Only show communities user is part of
        limit: 100,
      );

      if (mounted) {
        if (result.isSuccess && result.data != null) {
          setState(() {
            _allCommunities = result.data!;
            _filterCommunities();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelection(String communityId) {
    setState(() {
      if (_selectedIds.contains(communityId)) {
        _selectedIds.remove(communityId);
      } else {
        _selectedIds.add(communityId);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedIds.toList());
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                      text: 'Select Communities',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBlack,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.metalBlack),
                    onPressed: _cancel,
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  prefixIcon: const Icon(Icons.search),
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

            // Communities list
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _filteredCommunities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const Gap(16),
                                TextView(
                                  text: _searchQuery.isEmpty
                                      ? 'You are not part of any communities yet'
                                      : 'No communities found',
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredCommunities.length,
                          itemBuilder: (context, index) {
                            final community = _filteredCommunities[index];
                            final isSelected = _selectedIds.contains(community.id);

                            return InkWell(
                              onTap: () => _toggleSelection(community.id),
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
                                    // Checkbox
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
                                    const Gap(12),

                                    // Community info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextView(
                                            text: community.name,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.metalBlack,
                                          ),
                                          if (community.description.isNotEmpty) ...[
                                            const Gap(4),
                                            TextView(
                                              text: community.description,
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              maxLines: 1,
                                              textOverflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const Gap(4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              const Gap(4),
                                              TextView(
                                                text: '${community.memberCount} members',
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                              if (community.category != null) ...[
                                                const Gap(8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: TextView(
                                                    text: community.category!,
                                                    fontSize: 10,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Footer with action buttons
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
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedIds.isEmpty ? null : _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.metalPinkColour,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: TextView(
                        text: _selectedIds.isEmpty
                            ? 'Select Communities'
                            : 'Select (${_selectedIds.length})',
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
