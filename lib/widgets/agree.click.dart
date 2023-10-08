import 'package:flutter/material.dart';

class AgreeClick extends StatefulWidget {
  const AgreeClick(
      {super.key,
      required this.title,
      required this.isAgree,
      required this.onChanged});
  final String title;
  final bool isAgree;
  final Function(bool) onChanged;

  @override
  State<AgreeClick> createState() => _AgreeClickState();
}

class _AgreeClickState extends State<AgreeClick> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.isAgree,
          onChanged: (value) {
            widget.onChanged(value!);
            setState(() {});
          },
        ),
        Text(widget.title),
      ],
    );
  }
}
