import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/eyes/domain/entries/status.model.dart';
import 'package:metal/features/eyes/presentation/view.eyes.dart';
import 'package:metal/features/eyes/provider/get.all.eyes.notifier.dart';
import 'package:metal/features/eyes/provider/get.current.eyes.notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';

class StatusWidget extends ConsumerStatefulWidget {
  const StatusWidget({super.key});

  @override
  ConsumerState<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends ConsumerState<StatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        myStatus(),
        Gap(10),
        meltStatus()
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     children: [
        //       meltStatus()

        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget myStatus() {
    final currentStatus = ref.watch(getCurrentEyesProvider);
    return ShimmerLoading(
        isLoading: currentStatus.isLoading,
        child: chat("You", currentStatus.data));
  }

  Widget meltStatus() {
    final currentStatus = ref.watch(getAllEyesProvider);

    return ShimmerLoading(
      isLoading: currentStatus.isLoading,
      child: Row(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: currentStatus.data?.length ?? 0,
            itemBuilder: (context, index) {
              final status = currentStatus.data![index];
              return chat(status.username, status);
            },
          ),
        ],
      ),
    );
  }

  Widget chat(String title, StatusData? status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          ProfileImage(
            onTap: () {
              if (status!.status.isNotEmpty) {
                Navigator.pushNamed(context, AppRoutes.viewEyes, arguments: status.status
                );
 
              }
            },
          ),
          TextView(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.metalWhite,
          ),
        ],
      ),
    );
  }
}
