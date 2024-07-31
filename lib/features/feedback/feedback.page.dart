import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/feedback/provider/send.feedback.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/rate.widget.dart';
import 'package:metal/widgets/text_views.dart';
import '../../widgets/text.field/edit.from.field.dart';

class FeedBackPage extends ConsumerWidget {
  FeedBackPage({super.key});
  static const name = 'feedbackPage';
  static const route = name;
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(sendFeedbackProvider);

    return BaseScreen(
      subAppBar: true,
      appBarState: AppBarState.HambugerWithHeader,
      Header: "Let’s hear from you",
      body: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Gap(30),
              Image.asset(Assets.images.letsHearFromYouGroup.path),
              const Gap(24),
              const TextView(
                text:
                    "Tell us how your experience has been using our app. Let us know the areas we can improve in order to make your Metal experience a delightful one.",
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              const Gap(47),
              EditFormField(
                floatingLabel: 'Can you tell us how to improve the app?',
                label: '',
                controller: controller,
                keyboardType: TextInputType.text,
                minLines: 5,
                maxLines: 15,
                validator: Validators.validateString(),
                radius: 10,
              ),
              const Gap(19),
              const TextView(
                text: "Rate us on the app store!",
                fontSize: 12,
              ),
              const Gap(14),
              Center(
                child: RatingWidget(
                  initialRating: 3,
                  onRatingChanged: (rating) {
                    print('Selected rating: $rating');
                  },
                ),
              ),
              const Gap(20),
              BaseButton(
                loading: feedbackState.isLoading,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          content: confirmationDialog(context, ref),
                        );
                      },
                    );
                  }
                },
                buttonText: 'Submit review',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget confirmationDialog(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Gap(38),
        Image.asset(Assets.images.handshake.path),
        const Gap(15),
        const TextView(
          text: "Thank you for your review!",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text:
              "Your feedback is invaluable which drives us to improve the Metal app experience. If you have more thoughts or suggestions, please don't hesitate to share a review. We are here to listen!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Got it!",
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(sendFeedbackProvider.notifier)
                .sendFeedback(controller.text);
            controller.text = "";
          },
        ),
        const Gap(23),
      ],
    );
  }
}
