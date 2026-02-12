import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/presentation/viewmodels/referral/referral_viewmodel.dart';
import 'package:metal/presentation/viewmodels/spark/spark_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:share_plus/share_plus.dart';

/// Referral View (Refer & Earn)
/// Displays user's referral code, balance, and referral actions
class ReferralView extends ConsumerStatefulWidget {
  static const String route = '/referral';

  const ReferralView({super.key});

  @override
  ConsumerState<ReferralView> createState() => _ReferralViewState();
}

class _ReferralViewState extends ConsumerState<ReferralView> {
  @override
  void initState() {
    super.initState();
    // Load referral info when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(referralViewModelProvider.notifier).loadReferralInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final referralState = ref.watch(referralViewModelProvider);
    final sparkState = ref.watch(sparkViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.metalWhite,
      appBar: CustomAppBar(
        appBarState: AppBarState.BackWithHeader,
        headerText: "Refer & Earn",
        appBarEnabled: true,
        onBackButtonPressed: () => Navigator.pop(context),
        onHamburgerPressed: () {},
        onSkipButtonPressed: () {},
        onNotificationPressed: () {
          Navigator.pushNamed(context, AppRoutes.notificationPage);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sparks Balance Card - Pink
            _buildBalanceCard(sparkState.balance.toString(), referralState),
            
            const Gap(24),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Your Referral Code Box
                    if (referralState.referralInfo != null)
                      _buildReferralCodeBox(referralState.referralInfo!.referralCode),
                    
                    const Gap(16),
                    
                    // Instructional Text
                    const TextView(
                      text: "Share your code with friends to earn bonus sparks!",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.metalBrownColourForText,
                      textAlign: TextAlign.center,
                    ),
                    
                    const Gap(32),
                    
                    // Invite to Metal Button (Gradient)
                    BaseButton(
                      buttonText: "Invite to Metal",
                      onPressed: referralState.referralInfo != null
                          ? () => _shareCode(referralState.referralInfo!.referralCode)
                          : null,
                      width: double.infinity,
                      enabled: referralState.referralInfo != null,
                    ),
                    
                    const Gap(16),
                    
                    // Copy invite Code Button
                    OutilineButton(
                      buttonText: "Copy invite Code",
                      onPressed: referralState.referralInfo != null
                          ? () => _copyCode(referralState.referralInfo!.referralCode)
                          : null,
                      width: double.infinity,
                      enabled: referralState.referralInfo != null,
                    ),
                    
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

  Widget _buildBalanceCard(String balance, ReferralState referralState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              TextView(
                text: "Sparks Balance ",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalWhite,
              ),
              Text(
                "✨",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Gap(12),
          TextView(
            text: balance,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.metalWhite,
          ),
          const Gap(16),
          // Refer & Earn button in bottom left - tap to share when code available
          GestureDetector(
            onTap: referralState.referralInfo != null
                ? () => _shareCode(referralState.referralInfo!.referralCode)
                : null,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFA500), // Orange
                        Color(0xFFFFD700), // Yellow/Gold
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    color: AppColors.metalWhite,
                    size: 24,
                  ),
                ),
                const Gap(12),
                const TextView(
                  text: "Refer & Earn",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalWhite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeBox(String code) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const TextView(
            text: "Your Referral Code",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.metalBrownColourForText,
          ),
          const Gap(12),
          TextView(
            text: code,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.metalBrownColourForText,
          ),
        ],
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Fluttertoast.showToast(msg: 'Code copied to clipboard!');
  }

  Future<void> _shareCode(String code) async {
    await Share.share(
      'Join me on Metal! Use my referral code $code when signing up to earn bonus sparks!',
      subject: 'Join Metal with my referral code',
    );
  }
}
