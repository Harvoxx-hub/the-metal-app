import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';
import 'package:intl/intl.dart';
import 'package:metal/features/home_page/widget/enhanced_swipe_card.dart';

class SwipeUserCard extends ConsumerStatefulWidget {
  final UserModel user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;

  const SwipeUserCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
    this.onSuperLike,
  });

  @override
  ConsumerState<SwipeUserCard> createState() => _SwipeUserCardState();
}

class _SwipeUserCardState extends ConsumerState<SwipeUserCard> {
  List<ThoughtModel> _userThoughts = [];
  bool _isLoadingThoughts = false;
  bool _thoughtsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThoughts();
  }

  Future<void> _loadThoughts() async {
    if (_thoughtsLoaded || _isLoadingThoughts) return;

    setState(() {
      _isLoadingThoughts = true;
    });

    try {
      final homeRepository = ref.read(homeRepositoryProvider);
      final response =
          await homeRepository.getThoughtsByUserId(widget.user.id!);

      if (response.success == true && mounted) {
        final List<ThoughtModel> thoughts = [];
        for (var thought in response.data) {
          thoughts.add(ThoughtModel.fromJson(thought));
        }
        setState(() {
          _userThoughts = MetalHelper.sortThoughtsByDate(thoughts);
          _thoughtsLoaded = true;
          _isLoadingThoughts = false;
        });
      } else if (mounted) {
        setState(() {
          _userThoughts = [];
          _thoughtsLoaded = true;
          _isLoadingThoughts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userThoughts = [];
          _thoughtsLoaded = true;
          _isLoadingThoughts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedSwipeCard(
      onSwipeLeft: widget.onPass,
      onSwipeRight: widget.onLike,
      onSwipeUp: widget.onSuperLike,
      swipeThreshold: 120.0,
      velocityThreshold: 500.0,
      child: GestureDetector(
        onTap: () {
          // Navigate to user profile
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": widget.user.id},
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                // Metal image at the top
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 300,
                    child: _buildMetalBackground(ref),
                  ),
                ),

                // Gradient overlay for better text readability

                // User information overlay at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
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
                        // Name and metal title
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextView(
                                    text: widget.user.username ?? 'Anonymous',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.user.isVerified == true)
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
                            _buildMetalTitle(ref),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Gender
                        if (widget.user.gender != null)
                          TextView(
                            text: widget.user.gender!,
                            fontSize: 16,
                            color: Colors.black87,
                          ),

                        const SizedBox(height: 8),

                        // Age range
                        if (widget.user.dob != null)
                          TextView(
                            text: MetalHelper.getAgeRange(widget.user.dob!),
                            fontSize: 16,
                            color: Colors.black87,
                          ),

                        const SizedBox(height: 8),

                        // Bio
                        if (widget.user.bio != null &&
                            widget.user.bio!.isNotEmpty)
                          TextView(
                            text: widget.user.bio!,
                            fontSize: 16,
                            color: Colors.black87,
                            maxLines: 2,
                          ),

                        const SizedBox(height: 12),

                        // Passions
                        if (widget.user.passion != null &&
                            widget.user.passion!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ...(widget.user.passion ?? [])
                                  .take(3)
                                  .map((passion) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.3)),
                                        ),
                                        child: TextView(
                                          text: passion,
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                            ],
                          ),

                        // Connection Options (What they're looking for)
                        if (widget.user.connectionOption != null &&
                            widget.user.connectionOption!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextView(
                            text: "Looking for:",
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              ...(widget.user.connectionOption ?? [])
                                  .take(3)
                                  .map((option) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.metalPinkColour
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: AppColors.metalPinkColour
                                                  .withOpacity(0.3)),
                                        ),
                                        child: TextView(
                                          text: option,
                                          fontSize: 12,
                                          color: AppColors.metalPinkColour,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                            ],
                          ),
                        ],

                        // Recent Thoughts Carousel
                        _buildThoughtsCarousel(ref),

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pass button
                            _buildActionButton(
                              icon: Icons.close,
                              color: Colors.red,
                              onTap: widget.onPass,
                            ),

                            // Super like button
                            _buildActionButton(
                              icon: Icons.star,
                              color: Colors.blue,
                              onTap: widget.onSuperLike,
                            ),

                            // Like button
                            _buildActionButton(
                              icon: Icons.favorite,
                              color: Colors.green,
                              onTap: widget.onLike,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

// location
                if (widget.user.location?.address != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextView(
                        text:
                            widget.user.location?.address ?? "No Address Found",
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Online indicator
                if (widget.user.isOnline)
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

  Widget _buildMetalTitle(WidgetRef ref) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    if (getMetalProperties.isLoading ||
        getMetalProperties.data?.metals == null) {
      return const SizedBox.shrink();
    }

    final metals = getMetalProperties.data!.metals!;
    if (metals.isEmpty) {
      return const SizedBox.shrink();
    }

    final metal = metals.firstWhere(
      (element) => element.id == widget.user.metal,
      orElse: () => metals[0],
    );

    return Container(
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

  Widget _buildMetalBackground(WidgetRef ref) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    if (getMetalProperties.isLoading ||
        getMetalProperties.data?.metals == null) {
      return _buildDefaultBackground();
    }

    final metals = getMetalProperties.data!.metals!;
    if (metals.isEmpty) {
      return _buildDefaultBackground();
    }

    final metal = metals.firstWhere(
      (element) => element.id == widget.user.metal,
      orElse: () => metals[0],
    );

    return CachedNetworkImage(
      imageUrl: metal.img,
      fit: BoxFit.fill,
      width: double.infinity,
      height: double.infinity,
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

  Widget _buildThoughtsCarousel(WidgetRef ref) {
    if (_isLoadingThoughts) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_userThoughts.isEmpty) {
      return const SizedBox.shrink();
    }

    final thoughts = _userThoughts.take(3).toList(); // Show max 3 thoughts

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextView(
          text: "Recent thoughts:",
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: thoughts.length,
            itemBuilder: (context, index) {
              final thought = thoughts[index];
              return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < thoughts.length - 1 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.metalPinkColour.withOpacity(0.3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextView(
                          text: thought.content,
                          fontSize: 12,
                          color: Colors.black87,
                          maxLines: 2,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        TextView(
                          text: _formatDate(thought.createdAt),
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
