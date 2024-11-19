// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gap/gap.dart';
// import 'package:metal/core/utils/input/validators/validators.dart';

// import 'package:metal/features/authentication/provider/auth.notifier.dart';
// import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
// import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
// import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
// import 'package:metal/features/home_page/provider/like.user.notifier.dart';
// import 'package:metal/features/home_page/provider/melt.user.notifier.dart';
// import 'package:metal/features/home_page/widget/swipe_card.dart';
// import 'package:metal/features/settings/provider/block.user.notifier.dart';

// import 'package:metal/gen/assets.gen.dart';

// import 'package:metal/res/colors/cr_colors.dart';
// import 'package:metal/res/style/text_styles.dart';
// import 'package:metal/route/routes.dart';
// import 'package:metal/widgets/button/base_button.dart';
// import 'package:metal/widgets/dialog/custom.dialog.dart';
// import 'package:metal/widgets/text.field/edit.from.field.dart';
// import 'package:metal/widgets/text_views.dart';

// class MetalUserCard extends ConsumerStatefulWidget {
//   const MetalUserCard({
//     super.key,
//     required this.user,
//   });
//   final ALLUserModel user;

//   @override
//   ConsumerState<MetalUserCard> createState() => _MetalUserCardState();
// }

// class _MetalUserCardState extends ConsumerState<MetalUserCard> {
//   late ConfettiController _controller;
//   // final GlobalKey<SwipeCardState> _swipeCardKey = GlobalKey();
//   bool? liked;
//   @override
//   void initState() {
//     super.initState();
//     liked = widget.user.liked;
//     _controller = ConfettiController(duration: const Duration(seconds: 2));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userState = ref.watch(authProvider).data;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//       margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
//       decoration: BoxDecoration(
//           color: AppColors.metalWhite,
//           borderRadius: BorderRadius.circular(13),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 3,
//               color: Colors.grey.withOpacity(0.5),
//             )
//           ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Spacer(),
//               IconButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       backgroundColor: Colors.white,
//                       context: context,
//                       builder: (BuildContext context) {
//                         return SafeArea(
//                           child: Wrap(
//                             children: <Widget>[
//                               ListTile(
//                                 title: const Text('Block Metal'),
//                                 onTap: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return CustomDialog(
//                                           content: _blockDialog(
//                                               context, widget.user, ref));
//                                     },
//                                   );
//                                 },
//                               ),
//                               ListTile(
//                                   title: const Text('Block and Report'),
//                                   onTap: () => showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return CustomDialog(
//                                               content: _blockAndReportDialog(
//                                                   context, widget.user, ref));
//                                         },
//                                       )),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   icon: Icon(Icons.more_vert))
//             ],
//           ),
//           const Gap(10),
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//               height: 140,
//               width: 140,
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.metalBlack.withOpacity(0.1)),
//               child: ClipRRect(
//                   borderRadius: BorderRadius.circular(70),
//                   child: Image.network(
//                     widget.user.metal!.img!,
//                     fit: BoxFit.cover,
//                   )),
//             ),
//           ),
//           const Gap(20),
//           Row(
//             children: [
//               TextView(
//                 text: '@${widget.user.username}_${widget.user.metal!.title}',
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//               ),
//               const Gap(10),
//               widget.user.verfied
//                   ? SvgPicture.asset(
//                       Assets.icons.checkVerified.path,
//                       height: 24,
//                       width: 24,
//                     )
//                   : const SizedBox.shrink(),
//             ],
//           ),
//           const Gap(6),
//           _buildSubItem('Gender', widget.user.gender!),
//           _buildSubItem(
//               'Age range', getAgeRange(int.parse(widget.user.age_range!))),
//           const Gap(12),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 7,
//               vertical: 4,
//             ),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(3),
//                 color: AppColors.metalPinkColour60.withOpacity(0.2)),
//             child: Text(
//               'Ready to Melt with  ${widget.user.connection_option!.join(', ')}',
//               style: TextStyles.text(weight: FontWeight.w500),
//             ),
//           ),
//           const Gap(15),
//           Text(
//             'Interests: ${widget.user.passion!.join(', ')}',
//             style: TextStyles.text(fontStyle: FontStyle.italic),
//           ),
//           const Gap(15),
//           const Padding(
//             padding: EdgeInsets.only(right: 15),
//             child: Divider(thickness: 1.5),
//           ),
//           const Gap(8),
//           Text(
//             widget.user.description!,
//             style: TextStyles.text(),
//           ),
//           const Gap(20),
//           liked!
//               ? Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(8.0),
//                     decoration: ShapeDecoration(
//                       color: const Color(0xFF07840A).withOpacity(0.2),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(3)),
//                     ),
//                     child: TextView(
//                       text: "you liked @${widget.user.username} profile",
//                     ),
//                   ),
//                 )
//               : const SizedBox(),
//           const Gap(20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   userState!.completed_profile!
//                       ? {
//                           !widget.user.pushedMe
//                               ? _meltUser()
//                               : Navigator.pushNamed(
//                                   context,
//                                   AppRoutes.meltMetal,
//                                   arguments: widget.user,
//                                 ),
//                           // _swipeCardKey.currentState?.swipeLeft()
//                         }
//                       : showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return const CustomDialog(
//                               content: ComplecteProfileDialog(),
//                             );
//                           },
//                         );
//                 },
//                 child: Image.asset(Assets.images.melt.path),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: ConfettiWidget(
//                   confettiController: _controller,
//                   blastDirection: -pi / 2,
//                   emissionFrequency: 0.01,
//                   numberOfParticles: 20,
//                   maxBlastForce: 60,
//                   minBlastForce: 20,
//                   gravity: 0.3,
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: GestureDetector(
//                   onTap: () {
//                     userState!.completed_profile!
//                         ? {
//                             _controller.play(),
//                             setState(() {
//                               liked = true;
//                             }),
//                             ref
//                                 .read(likeUserProvider.notifier)
//                                 .LikeUser(widget.user.id!),
//                           }
//                         : showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return const CustomDialog(
//                                 content: ComplecteProfileDialog(),
//                               );
//                             },
//                           );
//                   },
//                   child: Image.asset(Assets.images.like.path),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   userState!.completed_profile!
//                       ? Navigator.pushNamed(context, AppRoutes.pushMetal,
//                           arguments: widget.user)
//                       : showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return const CustomDialog(
//                               content: ComplecteProfileDialog(),
//                             );
//                           },
//                         );
//                 },
//                 child: Image.asset(Assets.images.pushMetalscreen.path),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Text _buildSubItem(String key, String value) {
//     return Text.rich(TextSpan(
//         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
//         text: '$key: ',
//         children: [
//           TextSpan(
//             text: value,
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           )
//         ]));
//   }

//

//   void _meltUser() {
//     ref.watch(meltUserProvider(widget.user.id!));
//   }

//   Widget _blockDialog(BuildContext context, ALLUserModel data, WidgetRef ref) {
//     return Column(
//       children: [
//         const Gap(38),
//         SvgPicture.asset(
//           Assets.icons.meltedMetalsSmileyXEyes.path,
//           height: 45,
//           width: 45,
//         ),
//         const Gap(15),
//         TextView(
//           text: "Block  ${data.username} ",
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//         ),
//         const Gap(15),
//         const TextView(
//           text:
//               "Blocked metals cannot call or send you messages. This Metal will not be notified",
//           fontSize: 16,
//           textAlign: TextAlign.center,
//           fontWeight: FontWeight.w400,
//         ),
//         const Gap(38),
//         BaseButton(
//             buttonText: "Block  ${data.username}",
//             onPressed: () {
//               ref
//                   .read(blockUserProvider.notifier)
//                   .BlockUser(data.username!, data.id!);
//               ref.read(getAllUserProvider.notifier).removeUser(data.id!);
//               Navigator.pop(context);
//               Navigator.pop(context);
//             }),
//         const Gap(23),
//         TextView(
//           text: "Cancel",
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           onTap: () => Navigator.pop(context),
//         ),
//         const Gap(21),
//       ],
//     );
//   }

//   Widget _blockAndReportDialog(
//       BuildContext context, ALLUserModel data, WidgetRef ref) {
//     TextEditingController _controller = TextEditingController();
//     return Column(
//       children: [
//         const Gap(38),
//         SvgPicture.asset(
//           Assets.icons.meltedMetalsSmileyXEyes.path,
//           height: 45,
//           width: 45,
//         ),
//         const Gap(15),
//         TextView(
//           text: "Block and Report  ${data.username} ",
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//         ),
//         const Gap(15),
//         const TextView(
//           text:
//               "Blocked metals cannot call or send you messages. This Metal will not be notified",
//           fontSize: 16,
//           textAlign: TextAlign.center,
//           fontWeight: FontWeight.w400,
//         ),
//         EditFormField(
//           floatingLabel: '',
//           label: 'Reason for Reporting ',
//           controller: _controller,
//           keyboardType: TextInputType.name,
//           minLines: 5,
//           maxLines: 5,
//           validator: Validators.validateString(),
//           autoValidate: true,
//         ),
//         const Gap(38),
//         BaseButton(
//             buttonText: "Block ${data.username}",
//             onPressed: () {
//               ref
//                   .read(blockUserProvider.notifier)
//                   .BlockUser(data.username!, data.id!);
//               ref.read(getAllUserProvider.notifier).removeUser(data.id!);
//               Navigator.pop(context);
//               Navigator.pop(context);
//             }),
//         const Gap(23),
//         TextView(
//           text: "Cancel",
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           onTap: () => Navigator.pop(context),
//         ),
//         const Gap(21),
//       ],
//     );
//   }
// }
