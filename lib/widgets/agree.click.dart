import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text_views.dart';

class CustomCheckWidget extends StatefulWidget {
  final String title;
  final Function(bool) onChanged;
  final bool initialValue;

  CustomCheckWidget({
    required this.title,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  _CustomCheckWidgetState createState() => _CustomCheckWidgetState();
}

class _CustomCheckWidgetState extends State<CustomCheckWidget> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
          widget.onChanged(isChecked);
        });
      },
      child: Row(
        children: <Widget>[
          isChecked
              ? SvgPicture.asset(
                  Assets.icons.checked.path,
                  height: 24,
                  width: 24,
                )
              : Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          AppColors.metalBrownColourForText.withOpacity(0.1)),
                ),
          const SizedBox(width: 8.0),
          TextView(
            text: widget.title,
            fontSize: 13.sp,
            color: AppColors.metalBrownColourForText.withOpacity(0.5),
            fontWeight: FontWeight.normal,
          ),
        ],
      ),
    );
  }
}
