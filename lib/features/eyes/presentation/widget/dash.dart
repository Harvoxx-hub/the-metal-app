import 'package:flutter/material.dart';

class DashWidget extends StatelessWidget {
  final int items;
  final int currentIndex;

  const DashWidget({
    Key? key,
    required this.items,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double dashWidth = MediaQuery.of(context).size.width / items;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: List.generate(
          items,
          (index) => _buildDash(index, dashWidth),
        ),
      ),
    );
  }

  Widget _buildDash(int index, double dashWidth) {
    final bool isCurrent = index == currentIndex;
    return Expanded(
      child: Container(
        // Adjust width as needed
        height: 1, // Adjust height as needed
        margin: EdgeInsets.symmetric(horizontal: 2), // Adjust spacing as needed
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: isCurrent
                  ? Colors.red
                  : Colors.grey, // Change color if current index
            ),
          ),
        ),
      ),
    );
  }
}
