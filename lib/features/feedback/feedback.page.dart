import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/rate.widget.dart';
import 'package:metal/widgets/text_views.dart';

import '../../widgets/text.field/edit.from.field.dart';

class FeedBackPage extends StatelessWidget {
  const FeedBackPage({super.key});
  static const name = 'feedbackPage';
  static const route = '$name';
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        subAppBar: true,
        appBarState: AppBarState.HambugerWithHeader,
        Header: "Let’s hear from you",
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            children: [
              Gap(30.h),
              Image.asset(Assets.images.letsHearFromYouGroup.path),
              Gap(24.h),
              TextView(
                text:
                    "Tell us how your experience has been using our app. Let us know the areas we can improve in order to make your Metal experience a delightful one.",
                fontSize: 16.sp,
                fontWeight: FontWeight.w300,
              ),
              Gap(47.h),
              EditFormField(
                floatingLabel: 'Can you tell us how to improve the app?',
                label: '',
                //  controller: _dobController,
                keyboardType: TextInputType.name,
                minLines: 5,
                maxLines: 15,
                // validator: EmailValidator.validate(email),
                radius: 10,

                // fillColor: AppColors.appGrey,
              ),
              Gap(19.h),
              TextView(
                text: "Rate us on the app store!",
                fontSize: 12.sp,
              ),
              Gap(14.h),
              Center(
                child: RatingWidget(
                  initialRating: 3, // Set the initial rating as needed
                  onRatingChanged: (rating) {
                    print('Selected rating: $rating');
                  },
                ),
              ),
              Gap(20.h),
              BaseButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        content: confirmationDialog(context),
                      );
                    },
                  );
                },
                buttonText: 'Submit review',
              )
            ],
          ),
        ));
  }

  Widget confirmationDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Image.asset(Assets.images.handshake.path),
        Gap(15.h),
        TextView(
          text: "Thank you for your review!",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Your feedback is invaluable which drives us to improve the Metal app experience. If you have more thoughts or suggestions, please don't hesitate to share a review. We are here to listen!",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Got it!",
            onPressed: () {
         Navigator.pop(context);
            }),
        Gap(23.h),
      ],
    );
  }
}
