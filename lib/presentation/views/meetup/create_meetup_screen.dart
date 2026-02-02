import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/create_meetup_viewmodel.dart';
import 'package:metal/presentation/views/meetup/invite_guests_screen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:place_picker_google/place_picker_google.dart';

/// Create a Meetup - modal screen matching the design spec.
/// Uses project theme colors (metalPinkColour, metalBrownColourForText, etc.).
class CreateMeetupScreen extends ConsumerStatefulWidget {
  final String? communityId;

  const CreateMeetupScreen({
    super.key,
    this.communityId,
  });

  @override
  ConsumerState<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends ConsumerState<CreateMeetupScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Event date: only dates after today (tomorrow and forward).
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedMonth = DateTime.now();

  /// True if this calendar day can be selected (must be after today).
  bool _isDateSelectable(int year, int month, int day) {
    final today = DateTime.now();
    final d = DateTime(year, month, day);
    return d.isAfter(DateTime(today.year, today.month, today.day));
  }

  int _guestCapacity = 8;
  int _broadcastRadius = 25;
  String _inviteType = 'broadcast'; // 'broadcast' | 'select_friends'
  List<String> _selectedFriendIds =
      []; // user IDs from connection list (melted metals)
  bool _isLoading = false;

  /// Picked place from PlacePicker (place_picker_google).
  String? _pickedPlaceName;
  LatLng? _pickedPlaceLatLng;

  static const double _sectionGap = 24;
  static const double _fieldGap = 12;
  static const double _paddingH = 20;
  static const double _inputRadius = 12;
  static const double _cardRadius = 16;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openPlacePicker() async {
    if (!MapConfig.hasGoogleMapsKey) {
      Fluttertoast.showToast(
          msg: 'Map is not configured. Add a Google Maps API key.');
      return;
    }
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute<LocationResult>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Choose location'),
            backgroundColor: AppColors.metalWhite,
            foregroundColor: AppColors.metalBrownColourForText,
          ),
          body: PlacePicker(
            apiKey: MapConfig.googleMapsApiKey,
            onPlacePicked: (LocationResult res) =>
                Navigator.of(context).pop(res),
            initialLocation:
                _pickedPlaceLatLng ?? const LatLng(37.7749, -122.4194),
            searchInputDecorationConfig: const SearchInputDecorationConfig(
              hintText: 'Search for a place',
            ),
          ),
        ),
      ),
    );
    if (result != null && result.latLng != null && mounted) {
      setState(() {
        _pickedPlaceName = result.formattedAddress ?? result.name ?? '';
        _pickedPlaceLatLng = result.latLng;
      });
    }
  }

  void _closeModal() => Navigator.of(context).pop();

  void _showHelp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create a Meetup'),
        content: const Text(
          'Meetups let you create events and invite people by broadcast area (local discovery) or by selecting friends. Set the title, description, location, date, guest capacity and broadcast radius.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('OK', style: TextStyle(color: AppColors.metalPinkColour)),
          ),
        ],
      ),
    );
  }

  /// Opens the Invite Guests full screen: everybody within broadcast radius (not just connections).
  Future<void> _showFriendsSelection() async {
    final selectedIds = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => InviteGuestsScreen(
          maxGuests: _guestCapacity,
          initialSelectedIds: _selectedFriendIds,
          broadcastRadiusKm: _broadcastRadius,
          centerLat: _pickedPlaceLatLng?.latitude,
          centerLng: _pickedPlaceLatLng?.longitude,
        ),
      ),
    );
    if (selectedIds != null) {
      setState(() => _selectedFriendIds = selectedIds);
    }
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty && _pickedPlaceLatLng != null;

  Future<void> _submit() async {
    if (!_canSubmit) {
      Fluttertoast.showToast(msg: 'Please fill title and choose a location');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final placeName = _pickedPlaceName?.trim().isNotEmpty == true
          ? _pickedPlaceName!.trim()
          : 'Selected location';
      final placeLocation = PlaceLocationDto(
        latitude: _pickedPlaceLatLng!.latitude,
        longitude: _pickedPlaceLatLng!.longitude,
      );

      final desc = _descriptionController.text.trim();
      final createData = CreateMeetupDto(
        eventName: _titleController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: '18:00', // default evening time
        placeName: placeName,
        placeLocation: placeLocation,
        description: desc.isEmpty ? null : desc,
        maxParticipants: _guestCapacity,
        broadcastType: _inviteType == 'broadcast' ? 'all' : 'friends',
        broadcastRadius: _broadcastRadius,
        selectedCommunityIds: [],
        invitedUserIds:
            _inviteType == 'select_friends' ? _selectedFriendIds : [],
        communityId: widget.communityId,
      );

      final viewModel = ref.read(createMeetupViewModelProvider.notifier);
      final success = await viewModel.createMeetup(createData);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Meetup created successfully!');
          Navigator.pop(context, true);
        } else {
          final error = ref.read(createMeetupViewModelProvider).errorMessage;
          Fluttertoast.showToast(
            msg: error ?? 'Failed to create Meetup. Please try again.',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(_paddingH, 16, _paddingH, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEventDetailsSection(),
                    const Gap(_sectionGap),
                    _buildDateTimeSection(),
                    const Gap(_sectionGap),
                    _buildGuestCapacitySection(),
                    const Gap(_sectionGap),
                    _buildBroadcastRadiusSection(),
                    const Gap(_sectionGap),
                    _buildWhoInvitedSection(),
                    const Gap(_sectionGap),
                    _buildFooterButton(),
                    const Gap(32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          TextButton(
            onPressed: _isLoading ? null : _closeModal,
            child: TextView(
              text: 'Cancel',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextView(
            text: 'Create a Meetup',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.metalBrownColourForText,
          ),
          const Spacer(),
          IconButton(
            onPressed: _showHelp,
            icon: Icon(
              Icons.help_outline,
              color: AppColors.metalPinkColour,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: 'EVENT DETAILS',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(_fieldGap),
        _roundedInput(
          controller: _titleController,
          placeholder: 'Title',
          onChanged: (_) => setState(() {}),
        ),
        const Gap(_fieldGap),
        _roundedInput(
          controller: _descriptionController,
          placeholder: 'Description (optional)',
          onChanged: (_) => setState(() {}),
          maxLines: 4,
        ),
        const Gap(_fieldGap),
        _buildLocationSearchField(),
      ],
    );
  }

  Widget _buildLocationSearchField() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _openPlacePicker,
        borderRadius: BorderRadius.circular(_inputRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.metalTabBg,
            borderRadius: BorderRadius.circular(_inputRadius),
            border: Border.all(
              color: AppColors.metalButtonStroke.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextView(
                  text: _pickedPlaceName?.isNotEmpty == true
                      ? _pickedPlaceName!
                      : 'Search for a place',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _pickedPlaceName?.isNotEmpty == true
                      ? AppColors.metalBrownColourForText
                      : AppColors.metalBrownColourForText.withOpacity(0.5),
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.location_on,
                color: AppColors.metalPinkColour,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: 'Date & Time',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(_fieldGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Event Date',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.metalBrownColourForText,
            ),
            TextView(
              text: DateFormat('MMM d, yyyy').format(_selectedDate),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.metalPinkColour,
            ),
          ],
        ),
        const Gap(_fieldGap),
        _buildInlineCalendar(),
      ],
    );
  }

  Widget _buildInlineCalendar() {
    final monthStart = DateTime(_focusedMonth.year, _focusedMonth.month);
    final monthEnd = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = monthStart.weekday % 7; // S=0, M=1, ...
    final daysInMonth = monthEnd.day;
    final rows = <List<int>>[];
    List<int> row = List.filled(7, 0);
    int day = 1;
    for (int i = 0; i < 7; i++) {
      if (i < firstWeekday) {
        row[i] = 0;
      } else {
        row[i] = day++;
      }
    }
    rows.add(List.from(row));
    while (day <= daysInMonth) {
      row = [];
      for (int i = 0; i < 7 && day <= daysInMonth; i++) {
        row.add(day++);
      }
      while (row.length < 7) row.add(0);
      rows.add(row);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metalTabBg,
        borderRadius: BorderRadius.circular(_inputRadius),
        border: Border.all(
          color: AppColors.metalButtonStroke.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.metalBrownColourForText,
                ),
              ),
              TextView(
                text: DateFormat('MMMM yyyy').format(_focusedMonth),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.metalBrownColourForText,
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 32,
                      child: Center(
                        child: TextView(
                          text: d,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.metalWhite60,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Gap(8),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: row.map((d) {
                    if (d == 0) {
                      return const SizedBox(width: 36, height: 36);
                    }
                    final isSelectable = _isDateSelectable(
                        _focusedMonth.year, _focusedMonth.month, d);
                    final isSelected =
                        _selectedDate.year == _focusedMonth.year &&
                            _selectedDate.month == _focusedMonth.month &&
                            _selectedDate.day == d;
                    return GestureDetector(
                      onTap: isSelectable
                          ? () {
                              setState(() {
                                _selectedDate = DateTime(
                                    _focusedMonth.year, _focusedMonth.month, d);
                              });
                            }
                          : null,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.metalPinkColour
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: TextView(
                          text: '$d',
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelectable
                              ? (isSelected
                                  ? AppColors.metalWhite
                                  : AppColors.metalBrownColourForText)
                              : AppColors.metalBrownColourForText
                                  .withOpacity(0.35),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGuestCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Guest Capacity',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.metalBrownColourForText,
            ),
            TextView(
              text: '$_guestCapacity',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.metalPinkColour,
            ),
          ],
        ),
        const Gap(8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.metalPinkColour,
            inactiveTrackColor: AppColors.metalGray,
            thumbColor: AppColors.metalPinkColour,
            overlayColor: AppColors.metalPinkColour40,
          ),
          child: Slider(
            value: _guestCapacity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => setState(() => _guestCapacity = v.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'INTIMATE',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.metalWhite60,
            ),
            TextView(
              text: 'EXCLUSIVE (MAX 10)',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.metalWhite60,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBroadcastRadiusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Broadcast Radius',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.metalBrownColourForText,
            ),
            TextView(
              text: '$_broadcastRadius km',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.metalPinkColour,
            ),
          ],
        ),
        const Gap(8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.metalPinkColour,
            inactiveTrackColor: AppColors.metalGray,
            thumbColor: AppColors.metalPinkColour,
            overlayColor: AppColors.metalPinkColour40,
          ),
          child: Slider(
            value: _broadcastRadius.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            onChanged: (v) => setState(() => _broadcastRadius = v.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: '5 KM',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.metalWhite60,
            ),
            TextView(
              text: '100 KM',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.metalWhite60,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhoInvitedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "Who's Invited?",
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(_fieldGap),
        Row(
          children: [
            Expanded(
              child: _inviteCard(
                icon: Icons.cell_tower,
                title: 'Broadcast Area',
                subtitle: 'Local discovery',
                selected: _inviteType == 'broadcast',
                onTap: () => setState(() => _inviteType = 'broadcast'),
              ),
            ),
            const Gap(12),
            Expanded(
              child: _inviteCard(
                icon: Icons.group,
                title: 'Select Friends',
                subtitle: 'Private invite',
                selected: _inviteType == 'select_friends',
                onTap: () {
                  setState(() => _inviteType = 'select_friends');
                  _showFriendsSelection();
                },
              ),
            ),
          ],
        ),
        if (_inviteType == 'select_friends' && _selectedFriendIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextView(
              text: '${_selectedFriendIds.length} friend(s) selected',
              fontSize: 12,
              color: AppColors.metalPinkColour,
            ),
          ),
      ],
    );
  }

  Widget _inviteCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(
            color: selected
                ? AppColors.metalPinkColour
                : AppColors.metalButtonStroke.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.metalPinkColour),
            const Gap(8),
            TextView(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            TextView(
              text: subtitle,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_canSubmit && !_isLoading) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.metalPinkColour,
          foregroundColor: AppColors.metalWhite,
          disabledBackgroundColor: AppColors.metalPinkColour40,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.bolt, size: 22),
        label: TextView(
          text: 'CREATE MEETUP',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.metalWhite,
        ),
      ),
    );
  }

  Widget _roundedInput({
    required TextEditingController controller,
    required String placeholder,
    Widget? trailing,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.metalTabBg,
        borderRadius: BorderRadius.circular(_inputRadius),
        border: Border.all(
          color: AppColors.metalButtonStroke.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppColors.metalBrownColourForText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: AppColors.metalBrownColourForText.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: trailing != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: trailing,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}
