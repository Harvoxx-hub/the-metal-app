import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';

import 'package:metal/features/profile/presentation/widget/edit.profile.dart';
import 'package:metal/res/colors/cr_colors.dart';

class EditPreferences extends ConsumerStatefulWidget {
  const EditPreferences({super.key});

  @override
  ConsumerState<EditPreferences> createState() => _EditPreferencesState();
}

class _EditPreferencesState extends ConsumerState<EditPreferences> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider).data;
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    final metal = metalProperties!.metals!.firstWhere(
      (element) => element.id == userState!.metal,
      orElse: () =>
          metalProperties.metals![0], // Fallback in case no match is found
    );

    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Edit Preferences",
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
                  child: Column(
                    children: [
                      /// edit prefencded gender to conneect with
                      const Gap(20),
                      EditField(
                        text: userState?.connectWith ?? "Connect with",
                        floatingLabel: "Connect with",
                        subLabel: "Edit",
                        dropDownItems: const [
                          "Male",
                          "Female",
                          "Prefer not to say",
                          "Others",
                        ],
                        editType: EditType.dropdown,
                        onSubLabel: (value) {
                          updateUser('connectWith', value);
                        },
                      ),

                      const Gap(20),
                      EditField(
                        text: userState?.connectionOption?.join(", ") ??
                            "Connection option",
                        floatingLabel: "Connection option",
                        subLabel: "Edit",
                        outboundWidget: true,
                        isConnectionOption: true,
                        onSubLabel: (value) {
                          List<String> connectionOption = value;
                          updateUser('connectionOption', connectionOption);
                        },
                      ),

                      const Gap(20),
                      EditField(
                        text: "Preferences in Metal",
                        floatingLabel: "Preferences in Metal",
                        subLabel: "Edit",
                        outboundWidget: true,
                        isEditPreferences: true,
                        onSubLabel: (value) {
                          print(value.toJson());
                          updateUser('preferences', value.toJson());
                        },
                      ),

                      /// connection option

                      ///
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void updateUser(String field, dynamic value) async {
    try {
      // Use the new UserStateNotifier for batch updates
      await ref.read(userStateProvider.notifier).updateUserField(
            field: field,
            value: value,
          );
    } catch (e) {
      // Handle error - could show snackbar or toast
      debugPrint('Error updating user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
