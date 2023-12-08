import 'package:flutter/material.dart';
import 'package:metal/res/res.dart';

class CustomToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  CustomToggle({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  _CustomToggleState createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _value = !_value;
          widget.onChanged(_value);
        });
      },
      child: Stack(
        children: [
          Container(
            width: 50.0, // Adjust width as needed
            height: 24.0,
            // Adjust height as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                  color: _value ? AppColors.metalPinkColour : Colors.grey,
                  width: 2),
            ),
          ),
          Positioned(
            right: _value ? 0 : null,
            left: !_value ? 0 : null,
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _value ? AppColors.metalPinkColour : Colors.white,
                  border: Border.all(
                      color: _value ? AppColors.metalPinkColour : Colors.grey,
                      width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
