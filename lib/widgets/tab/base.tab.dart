import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/res/colors/cr_colors.dart';

class BaseTab extends StatefulWidget {
  const BaseTab({super.key, required this.tabs});
  final List<BaseTabModel> tabs;

  @override
  State<BaseTab> createState() => _BaseTabiewState();
}

class _BaseTabiewState extends State<BaseTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 43,
          decoration: const BoxDecoration(
            color: AppColors.metalTabBg,
          ),
          child: TabBar(
            onTap: (index) {
              currentIndex = index;
              setState(() {});
            },
            padding: EdgeInsets.zero,
            controller: _tabController,
            indicator: const UnderlineTabIndicator(
                borderSide:
                    BorderSide(width: 2.0, color: AppColors.metalPinkColour)),
            labelColor: AppColors.metalBrownColourForText,
            unselectedLabelColor:
                AppColors.metalBrownColourForText.withOpacity(0.5),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            tabs: [
              for (final tab in widget.tabs)
                Tab(
                  text: tab.title,
                ),
            ],
          ),
        ),
        const Gap(24),
        Center(
          child: [
            for (final tab in widget.tabs)
              SizedBox(
                child: tab.child,
              ),
          ][_tabController.index],
        ),
      ],
    );
  }
}

class BaseTabModel {
  final String title;
  final Widget child;

  BaseTabModel({
    required this.title,
    required this.child,
  });
}
