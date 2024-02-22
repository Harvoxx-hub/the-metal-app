import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/chat/presentation/widget/conver_list_cell.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/chat/presentation/widget/status/status.widget.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatPage extends ConsumerStatefulWidget {
  ChatPage({super.key});

  List<ZIMConversation> _converList = <ZIMConversation>[];
  List<ConverListCell> _converWidgetList = <ConverListCell>[];
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    if (widget._converWidgetList.isEmpty) getMoreConverWidgetList();
    registerConverUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240.h,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35.sp),
                    bottomRight: Radius.circular(35.sp),
                  )),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditFormField(
                      label: 'Search',
                      // controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autoValidate: false,
                      prefixWidget: SvgPicture.asset(
                        Assets.icons.chatsSearch.path,
                        height: 24,
                        width: 24,
                      ),
                      // validator: EmailValidator.validate(email),
                      radius: 34,
                      // fillColor: AppColors.appGrey,
                    ),
                    Gap(10.h),
                    TextView(
                      text: "My Metals",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalWhite,
                    ),
                    Gap(10.h),
                    StatusWidget()
                  ],
                ),
              ),
            ),
            Gap(26.h),
            widget._converList.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Gap(30),
                        Assets.images.emptyChat.image(),
                        Gap(20.h),
                        TextView(
                          text: "You have no messages yet",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        Gap(10.h),
                        TextView(
                          text:
                              "Tap on any of your metals to kickstart a conversation",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    // 显示进度条
                    controller: scrollController,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      controller: scrollController,
                      child: Center(
                        child: Column(children: widget._converWidgetList),
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  getMoreConverWidgetList() async {
    ZIMConversationQueryConfig queryConfig = ZIMConversationQueryConfig();
    queryConfig.count = 20;
    try {
      queryConfig.nextConversation = widget._converList.last;
    } on StateError {
      queryConfig.nextConversation = null;
    }
    try {
      ZIMConversationListQueriedResult result =
          await ZIM.getInstance()!.queryConversationList(queryConfig);
      widget._converList.addAll(result.conversationList);
      List<ConverListCell> newConverWidgetList = [];
      for (ZIMConversation newConversation in result.conversationList) {
        ConverListCell newConverListCell = ConverListCell(newConversation);
        newConverWidgetList.add(newConverListCell);
      }
      widget._converWidgetList.addAll(newConverWidgetList);
      setState(() {});
    } on PlatformException catch (onError) {
      return null;
    }
  }

  registerConverUpdate() {
    ZIMEventHandler.onConversationChanged = (zim, conversationChangeInfoList) {
      for (ZIMConversationChangeInfo changeInfo in conversationChangeInfoList) {
        switch (changeInfo.event) {
          case ZIMConversationEvent.added:
            widget._converList.insert(0, changeInfo.conversation!);
            ConverListCell newConverListCell =
                ConverListCell(changeInfo.conversation!);
            widget._converWidgetList.insert(0, newConverListCell);

            break;
          case ZIMConversationEvent.updated:
            ZIMConversation oldConver = widget._converList.singleWhere(
                (element) =>
                    element.conversationID ==
                    changeInfo.conversation?.conversationID);
            int oldConverIndex = widget._converList.indexOf(oldConver);
            widget._converList[oldConverIndex] = changeInfo.conversation!;
            ConverListCell oldConverListCell = widget._converWidgetList
                .singleWhere((element) => element.conversation == oldConver);
            int oldConverListCellIndex =
                widget._converWidgetList.indexOf(oldConverListCell);
            ConverListCell newConverListCell =
                ConverListCell(changeInfo.conversation!);
            widget._converWidgetList[oldConverListCellIndex] =
                newConverListCell;

            break;
          case ZIMConversationEvent.disabled:
            ZIMConversation oldConver = widget._converList.singleWhere(
                (element) =>
                    element.conversationID ==
                    changeInfo.conversation?.conversationID);
            int oldConverIndex = widget._converList.indexOf(oldConver);
            widget._converList.removeAt(oldConverIndex);
            ConverListCell oldConverListCell = widget._converWidgetList
                .singleWhere((element) => element.conversation == oldConver);
            int oldConverListCellIndex =
                widget._converWidgetList.indexOf(oldConverListCell);
            widget._converWidgetList.removeAt(oldConverListCellIndex);
            break;
          default:
        }
        setState(() {});
      }
    };
  }
}
