import 'package:flutter/material.dart';
import 'package:metal/widgets/text_views.dart';

class ChooseYourMetal extends StatefulWidget {
  const ChooseYourMetal({super.key, required this.onNextPress});
  final Future<void> Function() onNextPress;
  @override
  State<ChooseYourMetal> createState() => _ChooseYourMetalState();
}

class _ChooseYourMetalState extends State<ChooseYourMetal> {
  String? text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [TextView(text: text!)],
    );
  }
}
