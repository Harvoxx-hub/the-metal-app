import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/widgets/settings/edit_connection_option.dart';
import 'package:metal/presentation/widgets/settings/edit_preference.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

enum EditType { text, dropdown }

class EditField extends ConsumerStatefulWidget {
  const EditField({
    super.key,
    required this.text,
    this.floatingLabel,
    this.subLabel,
    this.onSubLabel,
    this.suffixIcon,
    this.prefixIcon,
    this.dropDownItems,
    this.editType = EditType.text,
    this.onTap,
    this.outboundWidget = false,
    this.isAddressField = false,
    this.isConnectionOption = false,
    this.isEditPreferences = false,
  });

  final String text;
  final String? floatingLabel;
  final String? subLabel;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<String>? dropDownItems;
  final EditType editType;
  final Function(dynamic)? onSubLabel;
  final Function()? onTap;
  final bool outboundWidget;
  final bool isAddressField;
  final bool isConnectionOption;
  final bool isEditPreferences;

  @override
  ConsumerState<EditField> createState() => _EditFieldState();
}

class _EditFieldState extends ConsumerState<EditField> {
  late TextEditingController _controller;
  late String _selectedItem;
  bool _onEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _selectedItem = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.floatingLabel != null)
              TextView(
                text: widget.floatingLabel!,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.metalBrownColourForText,
                textAlign: TextAlign.left,
              ),
            const Spacer(),
            TextView(
              text: _onEdit ? "Save" : widget.subLabel ?? "",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.blueAccent,
              underline: true,
              onTap: (widget.isConnectionOption && widget.outboundWidget)
                  ? () {
                      final currentConnectionOption =
                          ref.read(userStateProvider).user?.connectionOption;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            isScrollable: true,
                            content: EditConnectionOption(
                              initialConnectionOption: currentConnectionOption,
                              onPress: (newConnectionOption) {
                                widget.onSubLabel?.call(newConnectionOption);
                              },
                            ),
                          );
                        },
                      );
                    }
                  : (widget.isEditPreferences && widget.outboundWidget)
                      ? () {
                          final currentPreferences =
                              ref.read(userStateProvider).user?.preferences;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                isScrollable: true,
                                content: EditPreference(
                                  initialPreferences: currentPreferences,
                                  onPress: (newPreferences) {
                                    widget.onSubLabel?.call(newPreferences);
                                  },
                                ),
                              );
                            },
                          );
                        }
                      : _toggleEdit,
            ),
          ],
        ),
        if (widget.floatingLabel != null) const SizedBox(height: 8),
        _onEdit
            ? _buildEditableField()
            : GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 16,
                    bottom: 16,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.metalButtonStroke,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.suffixIcon != null) widget.suffixIcon!,
                      const Gap(10),
                      Expanded(
                        child: TextView(
                          text: widget.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      if (widget.prefixIcon != null) widget.prefixIcon!,
                      const Gap(10),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildEditableField() {
    return widget.editType == EditType.text
        ? EditFormField(
            label: widget.floatingLabel,
            controller: _controller,
            keyboardType: TextInputType.name,
          )
        : MentalDropdown(
            items: widget.dropDownItems ?? [],
            onChanged: (String? value) {
              setState(() {
                _selectedItem = value ?? '';
              });
            },
            value: _selectedItem,
            hint: "Please Select",
          );
  }

  void _toggleEdit() {
    setState(() {
      if (_onEdit) {
        widget.onSubLabel?.call(_getEditedValue());
      }
      _onEdit = !_onEdit;
    });
  }

  String? _getEditedValue() {
    return widget.editType == EditType.text ? _controller.text : _selectedItem;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
