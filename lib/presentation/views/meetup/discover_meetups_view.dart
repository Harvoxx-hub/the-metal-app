import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/presentation/views/meetup/widgets/discover_meetup_event_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Discover Meetups: filters (within, date), Nearby Meetups list, empty state.
/// Uses project design system. Shown in the Meetup tab.
class DiscoverMeetupsView extends ConsumerStatefulWidget {
  const DiscoverMeetupsView({super.key});

  @override
  ConsumerState<DiscoverMeetupsView> createState() =>
      _DiscoverMeetupsViewState();
}

class _DiscoverMeetupsViewState extends ConsumerState<DiscoverMeetupsView> {
  static const double _paddingH = 16;
  static const double _sectionGap = 16;

  /// 1st filter: distance (within), 100km–1000km
  String _withinLabel = 'WITHIN 100KM';
  /// 2nd filter: date
  String _dateLabel = 'TONIGHT';
  /// Which filter chip is visually selected (0=within, 1=date)
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupFeedViewModelProvider.notifier).loadMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(meetupFeedViewModelProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(meetupFeedViewModelProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(8),
            _buildFilterSection(),
            const Gap(_sectionGap),
            _buildEventsListHeader(),
            const Gap(12),
            _buildContent(feedState),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            label: _withinLabel,
            isSelected: _selectedFilterIndex == 0,
            onTap: () {
              setState(() => _selectedFilterIndex = 0);
              _showWithinBottomSheet();
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: _FilterChip(
            label: _dateLabel,
            isSelected: _selectedFilterIndex == 1,
            onTap: () {
              setState(() => _selectedFilterIndex = 1);
              _showDateBottomSheet();
            },
          ),
        ),
      ],
    );
  }

  static const List<int> _withinKmOptions = [
    100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
  ];

  void _showWithinBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _withinKmOptions
                .map((km) => _bottomSheetOption('WITHIN ${km}KM', () {
                      setState(() => _withinLabel = 'WITHIN ${km}KM');
                      Navigator.pop(context);
                    }))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showDateBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomSheetOption('TONIGHT', () {
              setState(() => _dateLabel = 'TONIGHT');
              Navigator.pop(context);
            }),
            _bottomSheetOption('THIS WEEK', () {
              setState(() => _dateLabel = 'THIS WEEK');
              Navigator.pop(context);
            }),
            _bottomSheetOption('THIS WEEKEND', () {
              setState(() => _dateLabel = 'THIS WEEKEND');
              Navigator.pop(context);
            }),
            _bottomSheetOption('ANYTIME', () {
              setState(() => _dateLabel = 'ANYTIME');
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetOption(String label, VoidCallback onTap) {
    return ListTile(
      title: TextView(
        text: label,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.metalBrownColourForText,
      ),
      onTap: onTap,
    );
  }

  /// Applies current filter state to meetups (client-side).
  List<MeetupDto> _applyFilters(List<MeetupDto> meetups) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(const Duration(days: 7));
    final endOfWeekendRange = today.add(const Duration(days: 14));

    return meetups.where((m) {
      // 1. Within (distance in km)
      final maxKm = _parseWithinKm(_withinLabel);
      if (maxKm != null) {
        final d = m.distance;
        if (d != null && d > maxKm) return false;
      }

      // 2. Date
      final eventDate = DateTime(
        m.eventDateTime.year,
        m.eventDateTime.month,
        m.eventDateTime.day,
      );
      if (_dateLabel == 'TONIGHT') {
        if (eventDate != today) return false;
      } else if (_dateLabel == 'THIS WEEK') {
        if (m.eventDateTime.isBefore(now) || m.eventDateTime.isAfter(endOfWeek)) {
          return false;
        }
      } else if (_dateLabel == 'THIS WEEKEND') {
        final weekday = m.eventDateTime.weekday; // 6=Sat, 7=Sun
        final isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;
        if (!isWeekend || m.eventDateTime.isBefore(now) || m.eventDateTime.isAfter(endOfWeekendRange)) {
          return false;
        }
      }
      // ANYTIME: no date filter

      return true;
    }).toList();
  }

  /// Parses max distance in km from label (e.g. "WITHIN 5KM" -> 5). Returns null for no limit.
  double? _parseWithinKm(String label) {
    final match = RegExp(r'WITHIN\s+(\d+)KM', caseSensitive: false).firstMatch(label);
    if (match != null) return double.tryParse(match.group(1) ?? '');
    return null;
  }

  Widget _buildEventsListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextView(
          text: 'Nearby Meetups',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        TextButton(
          onPressed: () {
            // VIEW ALL - could push full list or scroll
          },
          child: TextView(
            text: 'VIEW ALL',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.metalPinkColour,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(MeetupFeedState feedState) {
    if (feedState.isLoading && feedState.meetups.isEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (_, __) => SizedBox(
          height: 220,
          child: PostCardShimmer(),
        ),
      );
    }

    if (feedState.isError && feedState.meetups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: ErrorState(
          text: feedState.errorMessage ?? 'Failed to load Meetups',
          retry: () =>
              ref.read(meetupFeedViewModelProvider.notifier).loadMeetups(),
        ),
      );
    }

    if (feedState.meetups.isEmpty) {
      return _buildEmptyState();
    }

    final filtered = _applyFilters(feedState.meetups);

    if (filtered.isEmpty) {
      return _buildNoMatchesState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length + (feedState.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          ref.read(meetupFeedViewModelProvider.notifier).loadMoreMeetups();
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }
        final meetup = filtered[index];
        return DiscoverMeetupEventCard(meetup: meetup);
      },
    );
  }

  Widget _buildNoMatchesState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: AppColors.metalPinkColour.withOpacity(0.5),
          ),
          const Gap(20),
          TextView(
            text: 'No meetups match your filters',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextView(
              text: 'Try changing distance or date.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.metalPinkColour.withOpacity(0.5),
          ),
          const Gap(20),
          TextView(
            text: 'No Meetups nearby yet',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextView(
              text:
                  'Be the first to create a Meetup and invite people around you.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(24),
          Material(
            color: AppColors.metalPinkColour,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.createMeetup)
                  .then((_) {
                ref.read(meetupFeedViewModelProvider.notifier).refresh();
              }),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: TextView(
                  text: 'CREATE MEETUP',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.metalWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single filter chip: label + chevron. Selected = pink; unselected = grey.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.metalPinkColour.withOpacity(0.15)
        : AppColors.metalTabBg;
    final borderColor = isSelected
        ? AppColors.metalPinkColour.withOpacity(0.6)
        : AppColors.metalButtonStroke;
    final textColor = isSelected
        ? AppColors.metalPinkColour
        : AppColors.metalBrownColourForText;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextView(
                  text: label,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
