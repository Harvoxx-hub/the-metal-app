import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Discover Meetup event card: cover image, distance + spots badges, title, time, JOIN/VIEW.
/// Creators see "View" (no join); non-creators see JOIN / JOINED / FULL.
class DiscoverMeetupEventCard extends ConsumerWidget {
  final MeetupDto meetup;

  const DiscoverMeetupEventCard({super.key, required this.meetup});

  int get _spotsLeft => (meetup.maxParticipants - meetup.acceptedCount).clamp(0, meetup.maxParticipants);
  bool get _isFull => _spotsLeft == 0;
  bool get _isUrgent => _spotsLeft > 0 && _spotsLeft <= 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isCreator = currentUser?.id != null && meetup.creatorId == currentUser!.id;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.meetupDetails,
          arguments: meetup.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.metalBlack.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover image (placeholder - no image_url in MeetupDto)
            SizedBox(
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.metalPinkColour.withOpacity(0.25),
                          AppColors.metalBrownColourForText.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event,
                        size: 56,
                        color: AppColors.metalPinkColour.withOpacity(0.6),
                      ),
                    ),
                  ),
                  // Badges
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildBadge(
                      _distanceText(),
                      light: true,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildBadge(
                      _spotsText(),
                      light: false,
                      urgent: _isUrgent,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: meetup.eventName,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.metalBrownColourForText,
                          maxLines: 2,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        const Gap(6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.metalBrownColourForText.withOpacity(0.7),
                            ),
                            const Gap(6),
                            Expanded(
                              child: TextView(
                                text: _timeDisplay(),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.metalBrownColourForText.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  _buildActionButton(context, isCreator),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceText() {
    if (meetup.distance == null) return '— KM AWAY';
    final d = meetup.distance!;
    if (d < 1) return '${(d * 1000).round()}M AWAY';
    return '${d.toStringAsFixed(1)}KM AWAY';
  }

  String _spotsText() {
    if (_isFull) return 'FULL';
    if (_spotsLeft == 1) return '1 SPOT LEFT';
    return '$_spotsLeft SPOTS LEFT';
  }

  String _timeDisplay() {
    try {
      final dt = meetup.eventDateTime;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDate = DateTime(dt.year, dt.month, dt.day);
      final timeStr = DateFormat.jm().format(dt);
      if (eventDate == today) {
        return 'Tonight, $timeStr';
      }
      if (eventDate == today.add(const Duration(days: 1))) {
        return 'Tomorrow, $timeStr';
      }
      final diff = dt.difference(now);
      if (diff.inMinutes < 60 && diff.inMinutes >= 0) {
        return 'In ${diff.inMinutes} mins';
      }
      return 'Starts at $timeStr';
    } catch (_) {
      return '${meetup.date} at ${meetup.time}';
    }
  }

  Widget _buildBadge(String text, {required bool light, bool urgent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light
            ? AppColors.metalBlack.withOpacity(0.6)
            : (urgent ? AppColors.metalPinkColour : AppColors.metalBrownColourForText.withOpacity(0.85)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextView(
        text: text,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.metalWhite,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isCreator) {
    // Creator: show "View" only — they can't join their own Meetup; tap opens detail/dashboard.
    if (isCreator) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.metalPinkColour.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.metalPinkColour),
        ),
        child: TextView(
          text: 'View',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.metalPinkColour,
        ),
      );
    }
    if (_isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextView(
          text: 'FULL',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText.withOpacity(0.6),
        ),
      );
    }
    final hasAccepted = meetup.userRsvpStatus == 'accepted';
    if (hasAccepted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.metalPinkColour.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.metalPinkColour),
        ),
        child: TextView(
          text: 'JOINED',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.metalPinkColour,
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.meetupDetails, arguments: meetup.id);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.metalPinkColour,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextView(
            text: 'JOIN',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.metalWhite,
          ),
        ),
      ),
    );
  }
}
