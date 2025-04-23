import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';

class RedeemReferralNotifier extends StateNotifier<RedeemReferralState> {
  RedeemReferralNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // Redeem a referral code
  void redeemReferralCode(String referralCode) async {
    if (!mounted) return;
    state = RedeemReferralState.loading();

    try {
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final response = await sparkRepository.redeemReferralCode(referralCode);

      if (!mounted) return;

      if (response.success == true) {
        state = RedeemReferralState.success(response.data ?? {});
      } else {
        state = RedeemReferralState.error(
            response.message ?? "Failed to redeem referral code");
      }
    } catch (e, s) {
      if (!mounted) return;
      state = RedeemReferralState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef RedeemReferralState = BaseState<Map<String, dynamic>>;

final redeemReferralProvider = StateNotifierProvider.autoDispose<
    RedeemReferralNotifier, RedeemReferralState>(
  (ref) => RedeemReferralNotifier(RedeemReferralState.initial(), ref),
);
