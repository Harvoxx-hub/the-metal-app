// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:metal/features/authentication/domain/entries/user.model.dart';

// import 'package:metal/features/chat/presentation/widget/profile.image.dart';

// import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
// import 'package:metal/res/colors/cr_colors.dart';
// import 'package:metal/route/routes.dart';
// import 'package:metal/widgets/shimmer.loading.dart';
// import 'package:metal/widgets/text_views.dart';

// class StatusWidget extends ConsumerStatefulWidget {
//   const StatusWidget({super.key});

//   @override
//   ConsumerState<StatusWidget> createState() => _StatusWidgetState();
// }

// class _StatusWidgetState extends ConsumerState<StatusWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             // myStatus(),
//             // const Gap(10),
//             meltStatus(),
//           ],
//         ));
//   }

//   // Widget myStatus() {
//   // //  final currentStatus = ref.watch(getCurrentEyesProvider);
//   //   return eyeWidget("You");
//   // }

//   Widget meltStatus() {
//     final myMelt = ref.watch(getMeltUserProvider);

//     return ShimmerLoading(
//       isLoading: myMelt.isLoading,
//       child: Row(
//         children: [
//           for (final metal in myMelt.data ?? [])
//             Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: eyeWidget(metal.username, status: metal),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget eyeWidget(String title, {UserModel? status}) {
//     return Column(
//       children: [
//         ProfileImage(
//           onTap: () {
//             if (status != null) {
//               Navigator.pushNamed(
//                 context,
//                 AppRoutes.chatWindowsPage,
//                 arguments: status.id,
//               );
//             }
//           },
//           metalID: status!.metal!,
//         ),
//         TextView(
//           text: title,
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: AppColors.metalWhite,
//         ),
//       ],
//     );
//   }
// }
