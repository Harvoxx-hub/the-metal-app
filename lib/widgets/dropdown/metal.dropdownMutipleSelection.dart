import 'package:flutter/material.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/text_views.dart';

class MentalDropdownMutipleSelection extends StatefulWidget {
  final List<String> items;
  final List<String>? value;
  final ValueChanged<List<String>> onChanged;
  final Widget? prefixIcon;
  final String? hint;
  final String? floatingLabel;

  const MentalDropdownMutipleSelection({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
    this.floatingLabel,
  });

  @override
  _MentalDropdownState createState() => _MentalDropdownState();
}

class _MentalDropdownState extends State<MentalDropdownMutipleSelection> {
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.floatingLabel != null
            ? TextView(
                text: widget.floatingLabel!,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.metalBrownColourForText,
                textAlign: TextAlign.left,
              )
            : const SizedBox(),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.metalButtonStroke),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: widget.prefixIcon,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextView(
                        text: (widget.value == null || widget.value!.isEmpty)
                            ? widget.hint!
                            : widget.value!.join(','),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDropdownOpen = !isDropdownOpen;
                        });
                      },
                      child: Icon(
                        isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.metalPinkColour),
            ),
            child: Column(
              children: widget.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      TextView(text: item),
                      const Spacer(),
                      CustomCheckWidget(
                        initialValue: widget.value == null
                            ? false
                            : widget.value!.contains(item),
                        onChanged: (bool value) {
                          value
                              ? widget.onChanged([...widget.value ?? [], item])
                              : widget.onChanged(
                                  widget.value == null ? [] : widget.value!
                                    ..remove(item));
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String listToString(List<String> data) {
    return data.join(',');
  }
}
