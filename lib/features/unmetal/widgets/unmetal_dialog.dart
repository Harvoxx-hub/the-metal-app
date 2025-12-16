import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../features/authentication/domain/entries/user.model.dart';
import '../../../features/authentication/provider/unmelt_days_notifier.dart';
import '../../../features/authentication/provider/user_state_notifier.dart';
import '../../thought/data/domain/entries/connection.model.dart';
import '../../../features/unmetal/provider/unmetal_notifier.dart';
import '../../../widgets/button/base_button.dart';
import '../../../widgets/dialog/custom.dialog.dart';
import '../../../widgets/text_views.dart';

class UnmetalDialog extends ConsumerWidget {
  final UserModel otherUser;
  final ConnectionModel connectionModel;

  const UnmetalDialog({
    super.key,
    required this.otherUser,
    required this.connectionModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unmetalNotifier = ref.read(unmetalNotifierProvider.notifier);
    final unmetalState = ref.watch(unmetalNotifierProvider);

    final daysRequired = ref.watch(numberDaysProvider);
    final completedDays = unmetalNotifier.calculateCompletedDays(
        connectionModel.connectedOn, daysRequired);

    final currentUser = ref.watch(userStateProvider).data;

    final hasProfilePhoto = currentUser?.profilePhoto != null &&
        currentUser!.profilePhoto!.isNotEmpty &&
        currentUser.profilePhoto!.trim().isNotEmpty;

    return CustomDialog(
      content: hasProfilePhoto
          ? _buildUnmetalDialog(context, ref, unmetalNotifier, unmetalState,
              completedDays, daysRequired)
          : _buildMissingPhotoDialog(context),
    );
  }

  Widget _buildMissingPhotoDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        const TextView(
          text: "Profile Photo Required",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text: "You need to add a profile photo before you can unmetal.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Return to chat",
          onPressed: () => Navigator.pop(context),
        ),
        const Gap(23),
      ],
    );
  }

  Widget _buildUnmetalDialog(
    BuildContext context,
    WidgetRef ref,
    UnmetalNotifier unmetalNotifier,
    UnmetalState unmetalState,
    int completedDays,
    int daysRequired,
  ) {
    final canProceed = unmetalNotifier.canProceedWithUnmetal(
      completedDays: completedDays,
      daysRequired: daysRequired,
      hasProfilePhoto: true,
    );

    return Column(
      children: [
        const Gap(38),
        const TextView(
          text: "Want to Unmetal?",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        TextView(
          text:
              "To Unmetal, we require a minimum of $daysRequired days of conversations between you and @${otherUser.username}",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(15),
        TextView(
          text: canProceed
              ? "You have completed all $daysRequired days required"
              : "You have ${(daysRequired - completedDays)} days remaining out of $daysRequired days to unmetal",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        if (unmetalState.isLoading)
          const CircularProgressIndicator()
        else if (unmetalState.isUnmetalRequestSent)
          _buildRequestSentDialog(context)
        else
          !canProceed
              ? BaseButton(
                  buttonText: "Return to chat",
                  onPressed: () => Navigator.pop(context),
                )
              : BaseButton(
                  buttonText: "Unmetal",
                  onPressed: () =>
                      _handleUnmetalPressed(context, ref, unmetalNotifier),
                ),
        if (unmetalState.error != null) ...[
          const Gap(16),
          Text(
            unmetalState.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        const Gap(23),
      ],
    );
  }

  Widget _buildRequestSentDialog(BuildContext context) {
    return Column(
      children: [
        const TextView(
          text: "Unmetal request sent",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        TextView(
          text:
              "We have sent your request to @${otherUser.username}. We will notify you when we get a response",
          fontSize: 14,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(16),
        BaseButton(
          buttonText: "Return to chat",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _handleUnmetalPressed(
      BuildContext context, WidgetRef ref, UnmetalNotifier unmetalNotifier) {
    unmetalNotifier.sendUnmetalRequest(connectionModel.connectionId);
  }
}
