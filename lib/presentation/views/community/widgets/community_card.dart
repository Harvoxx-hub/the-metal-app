import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metal/domain/entities/community_dto.dart';

class CommunityCard extends StatelessWidget {
  final CommunityDto community;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (community.bannerImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: community.bannerImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(height: 120, color: Colors.grey[300]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        community.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      community.isPublic ? Icons.public : Icons.lock,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  community.description,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${community.memberCount} members'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: community.isJoined ? onLeave : onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: community.isJoined ? Colors.grey : Theme.of(context).primaryColor,
                      ),
                      child: Text(community.isJoined ? 'Leave' : 'Join'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
