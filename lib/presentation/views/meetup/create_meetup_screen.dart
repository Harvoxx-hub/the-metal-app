import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/create_meetup_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_providers.dart';
import 'package:metal/presentation/views/settings/edit_preferences_view.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Create Meetup Screen
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
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _placeUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _maxParticipants = 10;
  String _broadcastType = 'all'; // 'all', 'preferences', 'communities'
  int _broadcastRadius = 97;
  List<String> _selectedCommunityIds = [];
  List<String> _invitedUsernames = [];
  UserPreferencesModel? _preferences;
  bool _isLoading = false;

  @override
  void dispose() {
    _eventNameController.dispose();
    _placeUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectPreferences() async {
    // Reuse preferences view logic
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditPreferencesView(),
      ),
    );

    if (result != null && result is UserPreferencesModel) {
      setState(() {
        _preferences = result;
      });
    }
  }

  void _showUserSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _InviteUserDialog(
        onUsersSelected: (usernames) {
          setState(() {
            _invitedUsernames = usernames;
          });
        },
        existingUsernames: _invitedUsernames,
      ),
    );
  }

  void _showCommunitySelection() {
    // TODO: Implement community multi-select dialog
    // For now, just show a message
    Fluttertoast.showToast(msg: 'Community selection coming soon');
  }

  Future<void> _createMeetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      Fluttertoast.showToast(msg: 'Please select a date');
      return;
    }

    if (_selectedTime == null) {
      Fluttertoast.showToast(msg: 'Please select a time');
      return;
    }

    // Validate date is in future
    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (eventDateTime.isBefore(DateTime.now())) {
      Fluttertoast.showToast(msg: 'Event date and time must be in the future');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final createData = CreateMeetupDto(
        eventName: _eventNameController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        time: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        placeUrl: _placeUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        maxParticipants: _maxParticipants,
        broadcastType: _broadcastType,
        broadcastRadius: _broadcastRadius,
        selectedCommunityIds: _broadcastType == 'communities'
            ? _selectedCommunityIds
            : [],
        preferences: _broadcastType == 'preferences' ? _preferences : null,
        communityId: widget.communityId,
      );

      final viewModel = ref.read(createMeetupViewModelProvider.notifier);
      final success = await viewModel.createMeetup(createData);

      if (mounted) {
        if (success) {
          // Invite users if any selected
          if (_invitedUsernames.isNotEmpty) {
            final createdMeetup = ref.read(createMeetupViewModelProvider).createdMeetup;
            if (createdMeetup != null) {
              try {
                final repository = ref.read(meetupRepositoryProvider);
                await repository.inviteUsers(
                  meetupId: createdMeetup.id,
                  usernames: _invitedUsernames,
                );
              } catch (e) {
                // Invite failure shouldn't block meetup creation
                debugPrint('Failed to invite users: $e');
              }
            }
          }

          Fluttertoast.showToast(msg: 'Meetup created successfully!');
          Navigator.pop(context, true);
        } else {
          final error = ref.read(createMeetupViewModelProvider).errorMessage;
          Fluttertoast.showToast(msg: error ?? 'Failed to create meetup');
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(createMeetupViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.metalBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextView(
          text: 'Create Meetup',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBlack,
        ),
        centerTitle: true,
        actions: [
          if (_isLoading || viewModelState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _createMeetup,
              child: const TextView(
                text: 'Create',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalPinkColour,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              EditFormField(
                controller: _eventNameController,
                label: 'Event Name',
                hint: 'Enter event name',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Event name is required';
                  }
                  if (value.trim().length > 200) {
                    return 'Event name must not exceed 200 characters';
                  }
                  return null;
                },
              ),
              const Gap(16),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextView(
                              text: 'Date',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            const Gap(4),
                            TextView(
                              text: _selectedDate != null
                                  ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                  : 'Select date',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _selectedDate != null
                                  ? AppColors.metalBlack
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextView(
                              text: 'Time',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            const Gap(4),
                            TextView(
                              text: _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Select time',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _selectedTime != null
                                  ? AppColors.metalBlack
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Max Participants
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Number of People (Max: $_maxParticipants)',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalBlack,
                  ),
                  const Gap(8),
                  Slider(
                    value: _maxParticipants.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _maxParticipants.toString(),
                    activeColor: AppColors.metalPinkColour,
                    onChanged: (value) {
                      setState(() {
                        _maxParticipants = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              const Gap(16),

              // Place URL
              EditFormField(
                controller: _placeUrlController,
                label: 'Place URL',
                hint: 'Enter restaurant/venue URL (Google Maps, etc.)',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Place URL is required';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const Gap(16),

              // Description
              EditFormField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add any additional details...',
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                validator: (value) {
                  if (value != null && value.length > 1000) {
                    return 'Description must not exceed 1000 characters';
                  }
                  return null;
                },
              ),
              const Gap(16),

              // Broadcast Section
              const TextView(
                text: 'Broadcast Settings',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBlack,
              ),
              const Gap(12),

              // Broadcast Type
              DropdownButtonFormField<String>(
                value: _broadcastType,
                decoration: InputDecoration(
                  labelText: 'Broadcast To',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(
                      value: 'preferences', child: Text('By Preferences')),
                  DropdownMenuItem(
                      value: 'communities', child: Text('Communities')),
                ],
                onChanged: (value) {
                  setState(() {
                    _broadcastType = value ?? 'all';
                  });
                },
              ),
              const Gap(12),

              // Broadcast Radius
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Radius: $_broadcastRadius km',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalBlack,
                  ),
                  const Gap(8),
                  Slider(
                    value: _broadcastRadius.toDouble(),
                    min: 1,
                    max: 97,
                    divisions: 96,
                    label: '$_broadcastRadius km',
                    activeColor: AppColors.metalPinkColour,
                    onChanged: (value) {
                      setState(() {
                        _broadcastRadius = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              const Gap(12),

              // Preferences button (if broadcast type is preferences)
              if (_broadcastType == 'preferences')
                OutlinedButton.icon(
                  onPressed: _selectPreferences,
                  icon: const Icon(Icons.tune, size: 18),
                  label: const TextView(
                    text: 'Set Preferences',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              // Community selection (if broadcast type is communities)
              if (_broadcastType == 'communities')
                OutlinedButton.icon(
                  onPressed: _showCommunitySelection,
                  icon: const Icon(Icons.group, size: 18),
                  label: TextView(
                    text: _selectedCommunityIds.isEmpty
                        ? 'Select Communities'
                        : '${_selectedCommunityIds.length} Communities Selected',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const Gap(24),

              // Invite Users Section
              const TextView(
                text: 'Invite Users (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBlack,
              ),
              const Gap(12),
              OutlinedButton.icon(
                onPressed: _showUserSearchDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: TextView(
                  text: _invitedUsernames.isEmpty
                      ? 'Invite by Username'
                      : '${_invitedUsernames.length} Users Selected',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_invitedUsernames.isNotEmpty) ...[
                const Gap(8),
                Wrap(
                  spacing: 8,
                  children: _invitedUsernames.map((username) {
                    return Chip(
                      label: Text('@$username'),
                      onDeleted: () {
                        setState(() {
                          _invitedUsernames.remove(username);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Invite User Dialog (simplified version)
class _InviteUserDialog extends ConsumerStatefulWidget {
  final Function(List<String>) onUsersSelected;
  final List<String> existingUsernames;

  const _InviteUserDialog({
    required this.onUsersSelected,
    required this.existingUsernames,
  });

  @override
  ConsumerState<_InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends ConsumerState<_InviteUserDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final Set<String> _selectedUsernames = {};

  @override
  void initState() {
    super.initState();
    _selectedUsernames.addAll(widget.existingUsernames);
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_usernameController.text.isNotEmpty) {
      ref
          .read(getUserByNameProvider.notifier)
          .getUserByquery(query: _usernameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSearchState = ref.watch(getUserByNameProvider);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextView(
              text: 'Invite Users',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const Gap(16),
            EditFormField(
              controller: _usernameController,
              hint: 'Search username',
            ),
            const Gap(8),
            if (_usernameController.text.isNotEmpty &&
                userSearchState.data != null &&
                userSearchState.data!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userSearchState.data!.length,
                  itemBuilder: (context, index) {
                    final user = userSearchState.data![index];
                    final isSelected = _selectedUsernames.contains(user.username);

                    return CheckboxListTile(
                      title: Text('@${user.username ?? 'Unknown'}'),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (user.username != null) {
                              _selectedUsernames.add(user.username!);
                            }
                          } else {
                            _selectedUsernames.remove(user.username);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onUsersSelected(_selectedUsernames.toList());
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
