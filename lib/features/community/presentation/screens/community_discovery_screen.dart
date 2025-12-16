import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/community/widgets/community_card.dart';
import 'package:metal/features/community/provider/community_notifier.dart';
import 'package:metal/route/routes.dart';

class CommunityDiscoveryScreen extends ConsumerStatefulWidget {
  const CommunityDiscoveryScreen({super.key});

  @override
  ConsumerState<CommunityDiscoveryScreen> createState() =>
      _CommunityDiscoveryScreenState();
}

class _CommunityDiscoveryScreenState
    extends ConsumerState<CommunityDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Tech',
    'Faith',
    'Afrobeat',
    'Career',
    'Sports',
    'Music',
    'Art',
    'Food',
    'Travel',
    'LifeStyle',
    'Health',
    'Finance',
    'Education',
    'Entertainment',
    'Science',
    'Technology',
    'Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Load communities when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityNotifierProvider.notifier).getAllCommunities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityNotifierProvider);

    // Listen to state changes for feedback
    ref.listen<CommunityState>(communityNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.metalRed,
          ),
        );
      } else if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.metalPinkColour,
          ),
        );
      }
    });

    return Scaffold(
        body: BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: 'Communities',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.metalButtonStroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.metalButtonStroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.metalPinkColour),
                ),
                filled: true,
                fillColor: AppColors.metalWhite,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  ref
                      .read(communityNotifierProvider.notifier)
                      .getAllCommunities();
                } else {
                  ref
                      .read(communityNotifierProvider.notifier)
                      .searchCommunities(value);
                }
              },
            ),

            const Gap(20),

            // Categories
            Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText,
              ),
            ),

            const Gap(12),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });

                        if (category == 'All') {
                          ref
                              .read(communityNotifierProvider.notifier)
                              .getAllCommunities();
                        } else {
                          ref
                              .read(communityNotifierProvider.notifier)
                              .getCommunitiesByCategory(category);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.metalPinkColour
                              : AppColors.metalTabBg,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.metalButtonStroke,
                                  width: 1,
                                ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.metalWhite
                                : AppColors.metalBrownColourForText,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Gap(24),

            // Suggested Communities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested Communities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalBrownColourForText,
                  ),
                ),
                Text(
                  '${communityState.communities.length} communities',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.metalBrownColourForText.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const Gap(16),

            // Community Cards
            if (communityState.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: AppColors.metalPinkColour,
                  ),
                ),
              )
            else if (communityState.communities.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Gap(40),
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: AppColors.metalGray,
                    ),
                    const Gap(16),
                    Text(
                      'No communities found',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.6),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Try adjusting your search or category filter',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: communityState.communities.length,
                itemBuilder: (context, index) {
                  final community = communityState.communities[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CommunityCard(
                      community: community,
                      onJoin: () {
                        // Use the notifier to join the community
                        ref
                            .read(communityNotifierProvider.notifier)
                            .joinCommunity(community.id);
                      },
                      onLeave: () {
                        // Use the notifier to leave the community
                        ref
                            .read(communityNotifierProvider.notifier)
                            .leaveCommunity(community.id);
                      },
                      onTap: () {
                        // Navigate to community profile
                        Navigator.pushNamed(
                          context,
                          AppRoutes.communityProfile,
                          arguments: community.id,
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, AppRoutes.createCommunity);
          if (result == true) {
            // Refresh the communities list
            ref.read(communityNotifierProvider.notifier).getAllCommunities();
          }
        },
        backgroundColor: AppColors.metalPinkColour,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ));
  }
}
