// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:metal/base/page/base_page_state.dart';
 
 

// class WelcomePage extends ConsumerWidget {
//   WelcomePage({Key? key}) : super(key: key);
//   static const name = 'welcomePage';
//   static const route = '/$name';

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return BaseScreen(
//       appBarEnabled: false,
//      //bgImage: Assets.images.welcome.path,
//       body: Container(
//         //add image as background

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Gap(70),
//             SvgPicture.asset(
//               Assets.images.logoSvg.path,
//               height: 142,
//               width: 113,
//             ),
//             Gap(316.h),
//             Column(
//               children: [
//                 TextView(
//                     text: 'Welcome to GymPal',
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600),
//                 Gap(35.h),
//                 TextView(
//                     text:
//                         'For people who like to stay active.',
//                     fontSize: 14,
//                     textAlign: TextAlign.center,
//                     fontWeight: FontWeight.w300),
//                 Gap(54.h),
//                 BaseButton(
//                   onPressed: () {
//                     context.pushNamed(GettingStartedPage.route);
//                   },
//                   buttonText: 'Get Started',
//                 ),
//                 Gap(22.h),
//                 BaseButton(
//                   onPressed: () {
//                     context.pushNamed(LoginPage.route);
//                   },
//                   buttonText: 'i already have an account',
//                   outlined: true,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
