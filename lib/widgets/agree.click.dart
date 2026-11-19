import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text_views.dart';

class CustomCheckWidget extends StatefulWidget {
  final String? title;
  final Function(bool) onChanged;
  final bool initialValue;
  final bool boarder;

  const CustomCheckWidget({
    super.key,
    this.title,
    required this.onChanged,
    this.initialValue = false,
    this.boarder = false,
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
  void didUpdateWidget(CustomCheckWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      isChecked = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.boarder
        ? GestureDetector(
            onTap: () {
              setState(() {
                isChecked = !isChecked;
                widget.onChanged(isChecked);
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: isChecked
                  ? ShapeDecoration(
                      color: const Color(0xFFFBF0F8),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFFF5553)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 1,
                          offset: Offset(0, 2),
                          spreadRadius: 0,
                        )
                      ],
                    )
                  : ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: AppColors.metalButtonStroke),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C076DF3),
                          blurRadius: 40,
                          offset: Offset(0, 30),
                          spreadRadius: 0,
                        )
                      ],
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: AppColors.metalBrownColourForText
                                  .withOpacity(0.1)),
                        ),
                  const SizedBox(width: 8.0),
                  if (widget.title != null)
                    Expanded(
                      child: TextView(
                        text: widget.title!,
                        fontSize: 13,
                        color: AppColors.metalBrownColourForText
                            .withOpacity(0.5),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                isChecked = !isChecked;
                widget.onChanged(isChecked);
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isChecked
                    ? SvgPicture.asset(
                        Assets.icons.checked.path,
                        height: 24,
                        width: 24,
                      )
                    : SvgPicture.asset(
                        Assets.icons.tickSquare.path,
                        height: 24,
                        width: 24,
                      ),
                const SizedBox(width: 8.0),
                if (widget.title != null)
                  Expanded(
                    child: TextView(
                      text: widget.title!,
                      fontSize: 13,
                      color:
                          AppColors.metalBrownColourForText.withOpacity(0.5),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          );
  }
}
