import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
 
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/views/home/widgets/enhanced_swipe_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Discovery User Card for swipe interface
/// Uses DiscoveryUserDto from backend API
class DiscoveryUserCard extends ConsumerWidget {
  final DiscoveryUserDto user;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;
  final VoidCallback? onMessage;

  const DiscoveryUserCard({
    super.key,
    required this.user,
    this.onLike,
    this.onPass,
    this.onSuperLike,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnhancedSwipeCard(
      onSwipeLeft: onPass,
      onSwipeRight: onLike,
      onSwipeUp: onSuperLike,
      swipeThreshold: 120.0,
      velocityThreshold: 500.0,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": user.id},
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
                // Metal image as full background
                Positioned.fill(
                  child: _buildMetalBackground(ref),
                ),

                // Gradient overlay for better text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                ),

                // User info at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildUserInfo(context, ref),
                ),

                // Location and distance badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildLocationBadge(),
                ),

                // Online indicator
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

  Widget _buildMetalBackground(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

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

    // Check if metal image URL is valid
    if (metal.img.isEmpty || metal.img.trim().isEmpty) {
      return _buildDefaultBackground();
    }

    return CachedNetworkImage(
      imageUrl: metal.img,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.withOpacity(0.3),
        child: const Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading metal image: $error, URL: $url');
        return _buildDefaultBackground();
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
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

  Widget _buildUserInfo(BuildContext context, WidgetRef ref) {
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
              _buildMetalTitle(ref),
            ],
          ),

          const SizedBox(height: 8),

          // Gender
          if (user.gender != null)
            TextView(
              text: user.gender!,
              fontSize: 16,
              color: Colors.black87,
            ),

          const SizedBox(height: 8),

          // Age range
          if (user.dob != null)
            TextView(
              text: user.dob!,
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

          const SizedBox(height: 12),

          // Passions
          if (user.passion != null && user.passion!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: user.passion!.take(3).map((passion) {
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
              children: user.connectionOption!.take(3).map((option) {
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

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                onTap: onPass,
              ),
              _buildActionButton(
                icon: Icons.star,
                color: Colors.blue,
                onTap: onSuperLike,
              ),
              _buildActionButton(
                icon: Icons.favorite,
                color: Colors.green,
                onTap: onLike,
              ),
              _buildActionButton(
                icon: Icons.message,
                color: AppColors.metalPinkColour,
                onTap: onMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetalTitle(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

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
}

