import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class MentalDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final Widget? prefixIcon;
  final String? hint;
  final String? floatingLabel;

  MentalDropdown({
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

class _MentalDropdownState extends State<MentalDropdown> {
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
                fontSize: 14.sp,
                color: AppColors.metalBrownColourForText,
                textAlign: TextAlign.left,
              )
            : SizedBox(),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.metalButtonStroke)),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: widget.prefixIcon,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextView(
                        text: widget.value ??
                            widget.hint ??
                            '', // Show hint if no value is selected
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
                return ListTile(
                  title: TextView(text: item),
                  onTap: () {
                    widget.onChanged(item);
                    setState(() {
                      isDropdownOpen = false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
