import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/feedback_dto.dart';
import 'package:metal/presentation/viewmodels/feedback/feedback_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';

/// Feedback View
/// Allows users to submit feedback (bug reports, feature requests, general feedback)
class FeedbackView extends ConsumerStatefulWidget {
  static const String route = '/feedback';

  const FeedbackView({super.key});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.general;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!state.isSubmitted) ...[
                const Icon(
                  Icons.feedback_outlined,
                  size: 80,
                  color: AppColors.metalPinkColour,
                ),
                const Gap(24),
                const TextView(
                  text: 'We Value Your Feedback',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                TextView(
                  text:
                      'Help us improve by sharing your thoughts, reporting bugs, or suggesting new features.',
                  fontSize: 14,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),
                const Gap(32),
                _buildTypeSelector(),
                const Gap(24),
                _buildMessageField(),
                const Gap(24),
                _buildEmailField(),
                const Gap(32),
                if (state.errorMessage != null) ...[
                  _buildErrorMessage(state.errorMessage!),
                  const Gap(16),
                ],
                PlainButton(
                  buttonText: 'Submit Feedback',
                  loading: state.isSubmitting,
                  onPressed: state.isSubmitting ? null : _handleSubmit,
                ),
              ] else
                _buildSuccessMessage(),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Feedback Type',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          children: [
            _buildTypeChip(
              FeedbackType.bug,
              'Bug Report',
              Icons.bug_report,
            ),
            _buildTypeChip(
              FeedbackType.feature,
              'Feature Request',
              Icons.lightbulb_outline,
            ),
            _buildTypeChip(
              FeedbackType.general,
              'General',
              Icons.chat_bubble_outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(FeedbackType type, String label, IconData icon) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const Gap(8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
      selectedColor: AppColors.metalPinkColour.withOpacity(0.2),
      checkmarkColor: AppColors.metalPinkColour,
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Your Message',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextFormField(
          controller: _messageController,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tell us what\'s on your mind...',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your message';
            }
            if (value.trim().length < 10) {
              return 'Message must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Email (Optional)',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextView(
          text: 'Provide your email if you\'d like us to follow up.',
          fontSize: 12,
          color: Colors.grey[600],
        ),
        const Gap(8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'your.email@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: TextView(
        text: message,
        fontSize: 14,
        color: Colors.red[700],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green[600],
          ),
          const Gap(24),
          const TextView(
            text: 'Thank You!',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          const Gap(12),
          TextView(
            text:
                'Your feedback has been submitted successfully. We appreciate you taking the time to help us improve.',
            fontSize: 14,
            color: Colors.grey[700],
            textAlign: TextAlign.center,
          ),
          const Gap(32),
          PlainButton(
            buttonText: 'Back to App',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(feedbackViewModelProvider.notifier).submitFeedback(
          type: _selectedType,
          message: _messageController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

    if (success) {
      // Success is shown via state.isSubmitted
    }
  }
}
