import 'package:flutter/material.dart';

class MentalDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final Widget? prefixIcon;

  MentalDropdown({
    required this.items,
    required this.value,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  _MentalDropdownState<T> createState() => _MentalDropdownState<T>();
}

class _MentalDropdownState<T> extends State<MentalDropdown<T>> {
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: widget.prefixIcon,
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.items
                      .firstWhere((item) => item.value == widget.value)
                      .child
                      .toString(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                child: Icon(
                  isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
            ],
          ),
        ),
        if (isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              children: widget.items.map((item) {
                return ListTile(
                  title: Text(item.child.toString()),
                  onTap: () {
                    widget.onChanged(item.value as T);
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
