import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/data/repositories/discovery/discovery_repository.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// Full-screen "Invite Guests" for Meetup: capacity stats, progress bar,
/// search, and list of users to invite. When [broadcastRadiusKm] is set, shows
/// everybody within that radius (friends or not); otherwise shows connections only.
class InviteGuestsScreen extends ConsumerStatefulWidget {
  /// Max guests for this Meetup (capacity).
  final int maxGuests;

  /// Initially selected user IDs (already invited).
  final List<String> initialSelectedIds;

  /// When set, fetch and show users within this radius (km) instead of connections only.
  final int? broadcastRadiusKm;

  /// Center for radius (optional; uses current user location if null).
  final double? centerLat;
  final double? centerLng;

  const InviteGuestsScreen({
    super.key,
    this.maxGuests = 10,
    this.initialSelectedIds = const [],
    this.broadcastRadiusKm,
    this.centerLat,
    this.centerLng,
  });

  @override
  ConsumerState<InviteGuestsScreen> createState() => _InviteGuestsScreenState();
}

class _InviteGuestsScreenState extends ConsumerState<InviteGuestsScreen> {
  final Set<String> _selectedUserIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// When using broadcast radius: users within radius (not connections only).
  List<DiscoveryUserDto>? _usersInRadius;
  bool _usersInRadiusLoading = false;
  String? _usersInRadiusError;

  static const double _cardRadius = 16;
  static const double _sectionGap = 24;
  static const double _paddingH = 20;

  bool get _useRadiusMode => widget.broadcastRadiusKm != null;

  @override
  void initState() {
    super.initState();
    _selectedUserIds.addAll(widget.initialSelectedIds);
    _searchController.addListener(_onSearchChanged);
    if (_useRadiusMode) _loadUsersInRadius();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  Future<void> _loadUsersInRadius() async {
    final radiusKm = widget.broadcastRadiusKm;
    if (radiusKm == null) return;
    setState(() {
      _usersInRadiusLoading = true;
      _usersInRadiusError = null;
    });
    try {
      final repo = ref.read(discoveryRepositoryProvider);
      final response = await repo.getUsersWithinRadius(
        radiusKm: radiusKm,
        lat: widget.centerLat,
        lng: widget.centerLng,
      );
      if (mounted) {
        setState(() {
          _usersInRadius = response.users;
          _usersInRadiusLoading = false;
          _usersInRadiusError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usersInRadius = null;
          _usersInRadiusLoading = false;
          _usersInRadiusError = e.toString();
        });
      }
    }
  }

  int get _sentCount => _selectedUserIds.length;
  int get _maxGuests => widget.maxGuests.clamp(1, 10);
  int get _availableCount => (_maxGuests - _sentCount).clamp(0, _maxGuests);
  int get _percentage =>
      _maxGuests > 0 ? ((_sentCount / _maxGuests) * 100).round() : 0;

  String? _otherUserId(ConnectionApiModel c) {
    final currentUserId = ref.read(userStateProvider).user?.id;
    if (currentUserId == null) return null;
    try {
      return c.users.firstWhere((id) => id != currentUserId, orElse: () => '');
    } catch (_) {
      return null;
    }
  }

  List<ConnectionApiModel> _filteredConnections(
      List<ConnectionApiModel> connections) {
    if (_searchQuery.isEmpty) return connections;
    return connections.where((c) {
      final name =
          (c.otherUser?.username ?? c.otherUser?.firstName ?? '').toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  List<DiscoveryUserDto> _filteredUsersInRadius(List<DiscoveryUserDto> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((u) {
      final name = (u.username ?? u.fullname ?? '').toLowerCase();
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
    final filteredConnections = _filteredConnections(connections);
    final usersInRadius = _usersInRadius ?? [];
    final filteredUsersInRadius = _filteredUsersInRadius(usersInRadius);
    final useRadius = _useRadiusMode;
    final isLoading =
        useRadius ? _usersInRadiusLoading : connectionState.isLoading;
    final error = useRadius ? _usersInRadiusError : null;

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
                  if (useRadius)
                    _buildUsersInRadiusList(
                      isLoading: isLoading,
                      error: error,
                      users: filteredUsersInRadius,
                      onRefresh: _loadUsersInRadius,
                    )
                  else
                    _buildNetworkList(isLoading, filteredConnections),
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
              border: Border.all(
                  color: AppColors.metalButtonStroke.withOpacity(0.5)),
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
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.5),
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
              border: Border.all(
                  color: AppColors.metalButtonStroke.withOpacity(0.5)),
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
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.metalPinkColour),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          color: AppColors.metalBrownColourForText,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildUsersInRadiusList({
    required bool isLoading,
    required String? error,
    required List<DiscoveryUserDto> users,
    required VoidCallback onRefresh,
  }) {
    final radiusKm = widget.broadcastRadiusKm ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Within $radiusKm km',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.metalBrownColourForText,
            ),
            TextButton(
              onPressed: isLoading ? null : onRefresh,
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
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const Gap(12),
                TextView(
                  text: error,
                  fontSize: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                TextButton(
                  onPressed: onRefresh,
                  child: const TextView(text: 'Retry', fontSize: 14),
                ),
              ],
            ),
          )
        else if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (users.isEmpty)
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
                      ? 'No one within $radiusKm km'
                      : 'No one matches your search',
                  fontSize: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...users.map((user) => _buildUserInRadiusItem(user)),
      ],
    );
  }

  Widget _buildUserInRadiusItem(DiscoveryUserDto user) {
    final isInvited = _selectedUserIds.contains(user.id);
    final canAdd = _sentCount < _maxGuests;
    final displayName = user.username ?? user.fullname ?? 'User';
    final distanceStr = user.distance != null
        ? '${user.distance!.toStringAsFixed(1)} km away'
        : '';

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
                meltId: user.metal ?? '',
                imgUrl: user.profilePhoto,
              ),
              if (user.isVerified)
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
                if (distanceStr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextView(
                      text: distanceStr,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.metalBrownColourForText.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isInvited || canAdd) _toggleInvitation(user.id);
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
                  color: isInvited
                      ? AppColors.metalPinkColour
                      : AppColors.metalButtonStroke,
                  width: 2,
                ),
              ),
              child: Icon(
                isInvited ? Icons.check : Icons.add,
                size: 22,
                color: isInvited
                    ? AppColors.metalPinkColour
                    : AppColors.metalBrownColourForText.withOpacity(0.5),
              ),
            ),
          ),
        ],
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
    if (otherUserId == null || otherUser == null)
      return const SizedBox.shrink();

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
                imgUrl:
                    null, // Invite list: show metal icon only, not profile photo
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
                  color: isInvited
                      ? AppColors.metalPinkColour
                      : AppColors.metalButtonStroke,
                  width: 2,
                ),
              ),
              child: Icon(
                isInvited ? Icons.check : Icons.add,
                size: 22,
                color: isInvited
                    ? AppColors.metalPinkColour
                    : AppColors.metalBrownColourForText.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          _paddingH, 16, _paddingH, 16 + MediaQuery.of(context).padding.bottom),
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
