import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/community/community_viewmodel.dart';
import 'package:metal/presentation/viewmodels/community/community_viewmodel_providers.dart';
import 'package:metal/presentation/views/community/widgets/community_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Community List View - displays all communities with search
class CommunityListView extends ConsumerStatefulWidget {
  final bool showHeader;

  const CommunityListView({
    super.key,
    this.showHeader = false,
  });

  @override
  ConsumerState<CommunityListView> createState() => _CommunityListViewState();
}

class _CommunityListViewState extends ConsumerState<CommunityListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load communities on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityViewModelProvider.notifier)
          .loadCommunities(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        // Clear search and reload all communities
        ref
            .read(communityViewModelProvider.notifier)
            .loadCommunities(refresh: true);
      } else {
        // Trigger search via API
        ref.read(communityViewModelProvider.notifier).loadCommunities(
              refresh: true,
              search: query,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always show search header when in tab view (showHeader=false)
    // When standalone (showHeader=true), header is handled in _buildCommunityList
    if (!widget.showHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Gap(8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildListContent(ref.watch(communityViewModelProvider)),
            ),
          ),
        ],
      );
    }

    // Standalone mode with full layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Gap(26),
        Expanded(child: _buildCommunityList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: EditFormField(
        controller: _searchController,
        label: 'Search communities',
        hint: 'Search by name, description, or category',
        keyboardType: TextInputType.text,
        autoValidate: false,
        prefixWidget: SvgPicture.asset(
          Assets.icons.chatsSearch.path,
          height: 20,
          width: 20,
        ),
        radius: 12,
        fillColor: AppColors.metalTabBg,
        isFilled: true,
      ),
    );
  }

  Widget _buildCommunityList() {
    final communityState = ref.watch(communityViewModelProvider);

    // This is only called in standalone mode (showHeader=true)
    // Show "Communities" title section
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextView(
            text: "Communities",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          Expanded(child: _buildListContent(communityState)),
        ],
      ),
    );
  }

  Widget _buildListContent(CommunityState communityState) {
    if (communityState.isLoading && communityState.communities.isEmpty) {
      return const LoadingState();
    }

    if (communityState.isError && communityState.communities.isEmpty) {
      return ErrorState(
        text: communityState.errorMessage ?? 'Failed to load communities',
        retry: () {
          ref
              .read(communityViewModelProvider.notifier)
              .loadCommunities(refresh: true);
        },
      );
    }

    final communities = communityState.filteredCommunities;

    if (communities.isEmpty) {
      if (communityState.searchQuery.isNotEmpty) {
        return _buildNoSearchResults(communityState.searchQuery);
      }
      return const EmptyState(
        text: 'No communities found\nBe the first to create one!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(communityViewModelProvider.notifier)
          .loadCommunities(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommunityCard(
              community: community,
              onJoin: () => ref
                  .read(communityViewModelProvider.notifier)
                  .joinCommunity(community.id),
              onLeave: () => ref
                  .read(communityViewModelProvider.notifier)
                  .leaveCommunity(community.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextView(
            text: "No matches found",
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          const Gap(10),
          TextView(
            text: "No communities match '$query'",
            fontSize: 13,
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
