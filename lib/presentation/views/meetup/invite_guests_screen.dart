import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// Full-screen "Invite Guests" for LinkUp: capacity stats, progress bar,
/// search, and network list with invite toggle. Uses project design system.
class InviteGuestsScreen extends ConsumerStatefulWidget {
  /// Max guests for this LinkUp (capacity).
  final int maxGuests;
  /// Initially selected user IDs (already invited).
  final List<String> initialSelectedIds;

  const InviteGuestsScreen({
    super.key,
    this.maxGuests = 10,
    this.initialSelectedIds = const [],
  });

  @override
  ConsumerState<InviteGuestsScreen> createState() => _InviteGuestsScreenState();
}

class _InviteGuestsScreenState extends ConsumerState<InviteGuestsScreen> {
  final Set<String> _selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const double _cardRadius = 16;
  static const double _sectionGap = 24;
  static const double _paddingH = 20;

  @override
  void initState() {
    super.initState();
    _selectedUserIds.addAll(widget.initialSelectedIds);
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

  int get _sentCount => _selectedUserIds.length;
  int get _maxGuests => widget.maxGuests.clamp(1, 10);
  int get _availableCount => (_maxGuests - _sentCount).clamp(0, _maxGuests);
  int get _percentage => _maxGuests > 0 ? ((_sentCount / _maxGuests) * 100).round() : 0;

  String? _otherUserId(ConnectionApiModel c) {
    final currentUserId = ref.read(userStateProvider).user?.id;
    if (currentUserId == null) return null;
    try {
      return c.users.firstWhere((id) => id != currentUserId, orElse: () => '');
    } catch (_) {
      return null;
    }
  }

  List<ConnectionApiModel> _filteredConnections(List<ConnectionApiModel> connections) {
    if (_searchQuery.isEmpty) return connections;
    return connections.where((c) {
      final name = (c.otherUser?.username ?? c.otherUser?.firstName ?? '').toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  void _toggleInvitation(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else if (_selectedUserIds.length < _maxGuests) {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _completeInvitation() {
    Navigator.pop(context, _selectedUserIds.toList());
  }

  Future<void> _refreshNetwork() async {
    await ref.read(connectionViewModelProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionViewModelProvider);
    final connections = connectionState.connections;
    final filtered = _filteredConnections(connections);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: AppBar(
        backgroundColor: AppColors.metalWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.metalBrownColourForText,
          onPressed: () => Navigator.pop(context),
        ),
        title: TextView(
          text: 'Invite Guests',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _completeInvitation,
            child: TextView(
              text: 'Done',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.metalPinkColour,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _paddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(_sectionGap),
                  _buildCapacityCards(),
                  const Gap(_sectionGap),
                  _buildProgressSection(),
                  const Gap(_sectionGap),
                  _buildSearchBar(),
                  const Gap(_sectionGap),
                  _buildNetworkList(connectionState.isLoading, filtered),
                  const Gap(100),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCapacityCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.metalWhite,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: AppColors.metalButtonStroke.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.metalBlack.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: 'SENT',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
                const Gap(4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.metalBrownColourForText,
                      fontFamily: 'Plus_Jakarta',
                    ),
                    children: [
                      TextSpan(text: '$_sentCount'),
                      TextSpan(
                        text: ' /$_maxGuests',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.metalBrownColourForText.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.metalWhite,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: AppColors.metalButtonStroke.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.metalBlack.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: 'AVAILABLE',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
                const Gap(4),
                TextView(
                  text: '$_availableCount',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.metalPinkColour,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Guest List Capacity',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.metalBrownColourForText,
            ),
            TextView(
              text: '$_percentage%',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.metalPinkColour,
            ),
          ],
        ),
        const Gap(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _maxGuests > 0 ? _sentCount / _maxGuests : 0,
            minHeight: 6,
            backgroundColor: AppColors.metalTabBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.metalPinkColour),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.metalTabBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.metalButtonStroke.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Find someone to invite...',
          hintStyle: TextStyle(
            color: AppColors.metalBrownColourForText.withOpacity(0.5),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.metalBrownColourForText.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          color: AppColors.metalBrownColourForText,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildNetworkList(bool isLoading, List<ConnectionApiModel> filtered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Your Network',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.metalBrownColourForText,
            ),
            TextButton(
              onPressed: isLoading ? null : _refreshNetwork,
              child: TextView(
                text: 'REFRESH',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const Gap(12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: AppColors.metalPinkColour.withOpacity(0.5),
                ),
                const Gap(12),
                TextView(
                  text: _searchQuery.isEmpty
                      ? "You don't have any connections yet"
                      : 'No one matches your search',
                  fontSize: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...filtered.map((connection) => _buildContactItem(connection)),
      ],
    );
  }

  Widget _buildContactItem(ConnectionApiModel connection) {
    final otherUserId = _otherUserId(connection);
    final otherUser = connection.otherUser;
    if (otherUserId == null || otherUser == null) return const SizedBox.shrink();

    final isInvited = _selectedUserIds.contains(otherUserId);
    final canAdd = _sentCount < _maxGuests;
    final displayName = otherUser.username ?? otherUser.firstName ?? 'Friend';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfilePhoto(
                size: 52,
                verfly: false,
                meltId: otherUser.metal ?? '',
                imgUrl: null, // Invite list: show metal icon only, not profile photo
              ),
              if (otherUser.isVerified)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.metalWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: displayName,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.metalBrownColourForText,
                ),
                const Gap(2),
                TextView(
                  text: 'Connected',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isInvited || canAdd) _toggleInvitation(otherUserId);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isInvited
                    ? AppColors.metalPinkColour.withOpacity(0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isInvited ? AppColors.metalPinkColour : AppColors.metalButtonStroke,
                  width: 2,
                ),
              ),
              child: Icon(
                isInvited ? Icons.check : Icons.add,
                size: 22,
                color: isInvited ? AppColors.metalPinkColour : AppColors.metalBrownColourForText.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(_paddingH, 16, _paddingH, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.metalWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.metalBlack.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeInvitation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.metalPinkColour,
                foregroundColor: AppColors.metalWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: TextView(
                text: 'Continue to Gathering',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.metalWhite,
              ),
            ),
          ),
          const Gap(10),
          TextView(
            text: 'CURATED FOR AN EXCLUSIVE EXPERIENCE',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
