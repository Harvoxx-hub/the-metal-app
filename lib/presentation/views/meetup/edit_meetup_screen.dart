import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_detail_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Edit Meetup Screen
class EditMeetupScreen extends ConsumerStatefulWidget {
  final String meetupId;
  final MeetupDto meetup;

  const EditMeetupScreen({
    super.key,
    required this.meetupId,
    required this.meetup,
  });

  @override
  ConsumerState<EditMeetupScreen> createState() => _EditMeetupScreenState();
}

class _EditMeetupScreenState extends ConsumerState<EditMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _eventNameController;
  late final TextEditingController _placeUrlController;
  late final TextEditingController _descriptionController;
  
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late int _maxParticipants;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing meetup data
    _eventNameController = TextEditingController(text: widget.meetup.eventName);
    _placeUrlController = TextEditingController(text: widget.meetup.placeUrl);
    _descriptionController = TextEditingController(text: widget.meetup.description ?? '');
    
    // Parse existing date and time
    _selectedDate = widget.meetup.eventDateTime;
    final timeParts = widget.meetup.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    _maxParticipants = widget.meetup.maxParticipants;
  }

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
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
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
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateMeetup() async {
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
      final updateData = UpdateMeetupDto(
        eventName: _eventNameController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        time: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        placeUrl: _placeUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        maxParticipants: _maxParticipants,
      );

      final viewModel = ref.read(meetupDetailViewModelProvider(widget.meetupId).notifier);
      final success = await viewModel.updateMeetup(widget.meetupId, updateData);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Meetup updated successfully!');
          Navigator.pop(context, true);
        } else {
          final state = ref.read(meetupDetailViewModelProvider(widget.meetupId));
          Fluttertoast.showToast(msg: state.errorMessage ?? 'Failed to update meetup');
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
          text: 'Edit Meetup',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBlack,
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
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
              onPressed: _updateMeetup,
              child: const TextView(
                text: 'Save',
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
                    min: widget.meetup.acceptedCount.toDouble(), // Can't go below current accepted count
                    max: 10,
                    divisions: (10 - widget.meetup.acceptedCount).toInt(),
                    label: _maxParticipants.toString(),
                    activeColor: AppColors.metalPinkColour,
                    onChanged: (value) {
                      setState(() {
                        _maxParticipants = value.toInt();
                      });
                    },
                  ),
                  if (widget.meetup.acceptedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: TextView(
                        text: 'Note: ${widget.meetup.acceptedCount} people have already accepted',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
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

              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}
