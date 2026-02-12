import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/feedback/feedback_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';

/// Feedback Review View
/// Lets users submit app feedback and rate the app store
class FeedbackView extends ConsumerStatefulWidget {
  static const String route = '/feedback';

  const FeedbackView({super.key});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  final _improvementController = TextEditingController();
  int _starRating = 0;

  @override
  void dispose() {
    _improvementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.metalPinkColour,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.metalWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextView(
            text: 'Let\'s hear from you',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.metalWhite),
      ),
      body:
          state.isSubmitted ? _buildSuccessMessage() : _buildContentCard(state),
    );
  }

  Widget _buildContentCard(FeedbackState state) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIntroSection(),
            const Gap(24),
            _buildFeedbackFormSection(),
            const Gap(32),
            _buildRatingSection(),
            const Gap(32),
            if (state.errorMessage != null) ...[
              _buildErrorMessage(state.errorMessage!),
              const Gap(16),
            ],
            _buildSubmitButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Column(
      children: [
        const Gap(32),  
        Assets.icons.edit04.svg(width: 100, height: 100),
        const Gap(16),
        TextView(
          text:
              "Tell us how your experience has been using our app. Let us know the areas we can improve in order to make your Metal experience a delightful one. 😋",
          fontSize: 15,
          color: AppColors.metalBrownColourForText.withOpacity(0.9),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildFeedbackFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Can you tell us how to improve the app?',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(8),
        Semantics(
          label: 'Can you tell us how to improve the app?',
          hint:
              'Please share how you think we can make Metal app more safe and better for you or other users next time',
          textField: true,
          child: TextField(
            controller: _improvementController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText:
                  'Please share how you think we can make Metal app more safe and better for you or other users next time',
              hintStyle: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.metalBrownColourForText.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.metalWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.metalPinkColour.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.metalPinkColour.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.metalPinkColour,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.metalBrownColourForText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        const TextView(
          text: 'Rate us on the app store!',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.metalBrownColourForText,
          textAlign: TextAlign.center,
        ),
        const Gap(16),
        Semantics(
          label: 'Rate app from 1 to 5 stars. Current rating: $_starRating',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _starRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SvgPicture.asset(
                    index < _starRating
                        ? Assets.images.activeStar.path
                        : Assets.images.inactiveStar.path,
                    width: 40,
                    height: 40,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: TextView(
        text: message,
        fontSize: 14,
        color: Colors.red[700],
      ),
    );
  }

  Widget _buildSubmitButton(FeedbackState state) {
    return Semantics(
      label: 'Submit review',
      button: true,
      child: PlainButton(
        buttonText: 'Submit review',
        loading: state.isSubmitting,
        onPressed: state.isSubmitting ? null : _handleSubmit,
        height: 56,
        width: double.infinity,
        radius: 28,
        lowerCase: false,
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green[600],
            ),
            const Gap(24),
            TextView(
              text: 'Thank You!',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            const Gap(12),
            TextView(
              text:
                  'Your feedback has been submitted successfully. We appreciate you taking the time to help us improve.',
              fontSize: 15,
              color: AppColors.metalBrownColourForText.withOpacity(0.9),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            PlainButton(
              buttonText: 'Back to App',
              onPressed: () => Navigator.of(context).pop(),
              height: 56,
              width: double.infinity,
              radius: 28,
              lowerCase: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final improvementText = _improvementController.text.trim();
    final rating = _starRating > 0 ? _starRating : null;

    await ref.read(feedbackViewModelProvider.notifier).submitReviewFeedback(
          improvementFeedback:
              improvementText.isNotEmpty ? improvementText : null,
          appStoreRating: rating,
        );
  }
}
