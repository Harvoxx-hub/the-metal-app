import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.profile.dart';
import 'package:metal/res/colors/cr_colors.dart';

class EditPage extends ConsumerWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Make Changes to Profile",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                  padding: const EdgeInsets.only(top: 55, left: 22, right: 22),
                  decoration: const BoxDecoration(
                      color: AppColors.metalWhite,
                      borderRadius: BorderRadius.all(
                        Radius.circular(35),
                      )),
                  child: const EditProfile()),
            ),
          ],
        ),
      ),
    );
  }

  void updateUser(UserModel user, ref) {
    ref.watch(updateProfileProvider.notifier).updateParticularInfor(user);
  }
}
