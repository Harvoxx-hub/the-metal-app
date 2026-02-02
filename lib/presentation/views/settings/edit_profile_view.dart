import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/data/models/metal_properties_model.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/res/colors/cr_colors.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key, this.isPersonal = false});
  final bool isPersonal;

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final metalProperties = ref.watch(metalPropertiesProvider).data;

    if (user == null || metalProperties == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final metal = metalProperties.metals!.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => metalProperties.metals![0],
    );

    return widget.isPersonal
        ? BaseScreen(
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildPersonalProfile(user, metal, metalProperties),
                ],
              ),
            ),
          )
        : _buildPersonalProfile(user, metal, metalProperties);
  }

  Widget _buildPersonalProfile(
    UserDto user,
    Metal metal,
    MetalPropertiesModel metalProperties,
  ) {
    return  Padding(
              padding:   EdgeInsets.only(top: widget.isPersonal ? 0 : 29, left: 9, right: 9),
              child: Container(
                padding:   EdgeInsets.only(top: widget.isPersonal ? 0 : 55, left: 22, right: 22),
                decoration: const BoxDecoration(
                  color: AppColors.metalWhite,
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
                child: Column(
                  children: [
                    EditField(
                      text: user.fullname ?? "Your name here",
                      floatingLabel: "First name & Last name",
                    ),
                    const Gap(20),
                    EditField(
                      text: "@${user.username ?? ''}",
                      floatingLabel: "Username",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.email,
                      floatingLabel: "Email address",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.phone ?? "Phone Number",
                      floatingLabel: "Phone Number",
                    ),
                    const Gap(20),
                    EditField(
                      text: user.gender ?? "Gender",
                      floatingLabel: "Gender",
                      subLabel: "Edit",
                      dropDownItems: const [
                        "Male",
                        "Female",
                        "Prefer not to say",
                        "Others",
                      ],
                      editType: EditType.dropdown,
                      onSubLabel: (value) => _updateField('gender', value),
                    ),
                    const Gap(20),
                    EditField(
                      text: metal.title.isNotEmpty
                          ? metal.title
                          : "Metal that represents your value",
                      floatingLabel: "Metal that represents your value",
                      subLabel: "Edit",
                      dropDownItems: metalProperties.metals
                              ?.map((m) => m.title)
                              .toList() ??
                          [],
                      editType: EditType.dropdown,
                      onSubLabel: (value) {
                        if (value != null && metalProperties.metals != null) {
                          var selectedMetal = metalProperties.metals!.firstWhere(
                            (m) => m.title == value,
                          );
                          if (selectedMetal.id != null) {
                            _updateField('metal', selectedMetal.id!);
                          }
                        }
                      },
                    ),
                    const Gap(20),
                    EditField(
                      text: user.passion?.join(",") ?? "Passion/Interest",
                      floatingLabel: "Passion/Interest",
                      subLabel: "Edit",
                      dropDownItems: metalProperties.passions!
                          .map((passion) => passion.title ?? "")
                          .toList(),
                      editType: EditType.dropdown,
                      onSubLabel: (p0) => _updateField('passion', [p0!]),
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.marriageStatus ?? "Marital status",
                      floatingLabel: "Marital status",
                      subLabel: "Edit",
                      dropDownItems: metalProperties.marriageStatus,
                      editType: EditType.dropdown,
                      onSubLabel: (p0) {
                        final updated = {
                          ...user.extraData?.toJson() ?? {},
                          'marriageStatus': p0,
                        };
                        _updateField('extraData', updated);
                      },
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.religion ?? "Religion",
                      floatingLabel: "Religion",
                      subLabel: "Edit",
                      dropDownItems: metalProperties.religion,
                      editType: EditType.dropdown,
                      onSubLabel: (p0) {
                        final updated = {
                          ...user.extraData?.toJson() ?? {},
                          'religion': p0,
                        };
                        _updateField('extraData', updated);
                      },
                    ),
                    const Gap(20),
                    EditField(
                      text: user.extraData?.profession ?? "Profession",
                      floatingLabel: "Profession",
                      subLabel: "Edit",
                      dropDownItems: metalProperties.profession,
                      editType: EditType.dropdown,
                      onSubLabel: (p0) {
                        final updated = {
                          ...user.extraData?.toJson() ?? {},
                          'profession': p0,
                        };
                        _updateField('extraData', updated);
                      },
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            );
        
  }

  /// Update user field via single source of truth (userStateProvider)
  Future<void> _updateField(String field, dynamic value) async {
    final success = await ref.read(userStateProvider.notifier).updateUserField(
      field: field,
      value: value,
    );

    if (!success && mounted) {
      final errorMessage = ref.read(userStateProvider).errorMessage;
      Fluttertoast.showToast(msg: errorMessage ?? 'Failed to update profile');
    }
  }
}
