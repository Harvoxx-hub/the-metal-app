import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/referral/referral_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:share_plus/share_plus.dart';

/// Referral View (Refer & Earn)
/// Displays user's referral code, stats, and history
class ReferralView extends ConsumerStatefulWidget {
  static const String route = '/referral';

  const ReferralView({super.key});

  @override
  ConsumerState<ReferralView> createState() => _ReferralViewState();
}

class _ReferralViewState extends ConsumerState<ReferralView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(referralViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(referralViewModelProvider.notifier).loadReferralInfo();
        },
        child: state.isLoading && state.referralInfo == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const Gap(24),
                    if (state.referralInfo != null) ...[
                      _buildReferralCodeCard(state.referralInfo!.referralCode),
                      const Gap(24),
                      _buildStatsCards(state.referralInfo!),
                      const Gap(24),
                      _buildApplyCodeSection(state),
                      const Gap(24),
                      _buildHistorySection(state.referralInfo!),
                    ],
                    if (state.errorMessage != null) ...[
                      _buildErrorMessage(state.errorMessage!),
                      const Gap(16),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.card_giftcard,
          size: 80,
          color: AppColors.metalPinkColour,
        ),
        const Gap(16),
        const TextView(
          text: 'Refer Friends & Earn Sparks',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        TextView(
          text: 'Share your code and earn sparks when friends sign up!',
          fontSize: 14,
          color: Colors.grey[600],
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard(String code) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.metalPinkColour.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const TextView(
            text: 'Your Referral Code',
            fontSize: 14,
            color: Colors.white70,
          ),
          const Gap(8),
          TextView(
            text: code,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: PlainButton(
                  buttonText: 'Copy Code',
                  color: Colors.white,
                  textColor: AppColors.metalPinkColour,
                  leftIcon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyCode(code),
                ),
              ),
              const Gap(12),
              Expanded(
                child: PlainButton(
                  buttonText: 'Share',
                  color: Colors.white,
                  textColor: AppColors.metalPinkColour,
                  leftIcon: const Icon(Icons.share, size: 18),
                  onPressed: () => _shareCode(code),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(referralInfo) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Referrals',
            '${referralInfo.referralCount}',
            Icons.people,
            Colors.blue,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _buildStatCard(
            'Sparks Earned',
            '${referralInfo.sparksEarned}',
            Icons.bolt,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const Gap(8),
          TextView(
            text: value,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const Gap(4),
          TextView(
            text: label,
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyCodeSection(ReferralState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Have a Referral Code?',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Enter code',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
            ),
            const Gap(12),
            PlainButton(
              buttonText: 'Apply',
              loading: state.isApplying,
              width: 100,
              onPressed: state.isApplying ? null : _handleApplyCode,
            ),
          ],
        ),
        if (state.successMessage != null) ...[
          const Gap(12),
          _buildSuccessMessage(state.successMessage!),
        ],
      ],
    );
  }

  Widget _buildHistorySection(referralInfo) {
    if (referralInfo.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.history, size: 60, color: Colors.grey[400]),
            const Gap(16),
            TextView(
              text: 'No referrals yet',
              fontSize: 16,
              color: Colors.grey[600],
            ),
            const Gap(8),
            TextView(
              text: 'Share your code to start earning!',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextView(
          text: 'Referral History',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        const Gap(12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: referralInfo.history.length,
          itemBuilder: (context, index) {
            final item = referralInfo.history[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: TextView(
                  text: item.referredUserName ?? 'User',
                  fontWeight: FontWeight.w600,
                ),
                subtitle: TextView(
                  text: _formatDate(item.createdAt),
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 16),
                    const Gap(4),
                    TextView(
                      text: '+${item.sparksAwarded}',
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            );
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

  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: TextView(
        text: message,
        fontSize: 14,
        color: Colors.green[700],
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

  Future<void> _handleApplyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a referral code');
      return;
    }

    final success = await ref
        .read(referralViewModelProvider.notifier)
        .applyReferralCode(code);

    if (success) {
      _codeController.clear();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
