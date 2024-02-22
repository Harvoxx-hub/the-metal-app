import 'dart:developer';

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:badges/badges.dart';

class ConverListCell extends StatefulWidget {
  ZIMConversation conversation;

  ConverListCell(ZIMConversation zimConversation)
      : conversation = zimConversation;

  String getTitleValue() {
    String targetTitle;
    if (conversation.conversationName != '') {
      targetTitle = conversation.conversationName;
    } else {
      targetTitle = conversation.conversationID;
    }
    return targetTitle;
  }

  bool get isShowBadge {
    if (conversation.unreadMessageCount == 0) {
      return false;
    } else {
      return true;
    }
  }

  String getTime() {
    if (conversation.lastMessage == null) {
      return '';
    }
    // 时间显示，刚刚，x分钟前

    // 当前时间
    int timeStamp = (conversation.lastMessage!.timestamp / 1000).round();

    int time = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    // 对比
    int _distance = time - timeStamp;
    if (_distance <= 60) {
      //return 'now';
      return '${CustomStamp_str(Timestamp: timeStamp, Date: 'MM/DD hh:mm', toInt: false)}';
    } else if (_distance <= 3600) {
      // return '${(_distance / 60).floor()} mintues ago';
      return '${CustomStamp_str(Timestamp: timeStamp, Date: 'MM/DD hh:mm', toInt: false)}';
    } else if (_distance <= 43200) {
      // return '${(_distance / 60 / 60).floor()} hours ago';
      return '${CustomStamp_str(Timestamp: timeStamp, Date: 'MM/DD hh:mm', toInt: false)}';
    } else if (DateTime.fromMillisecondsSinceEpoch(time * 1000).year ==
        DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).year) {
      return '${CustomStamp_str(Timestamp: timeStamp, Date: 'MM/DD hh:mm', toInt: false)}';
    } else {
      return '${CustomStamp_str(Timestamp: timeStamp, Date: 'YY/MM/DD hh:mm', toInt: false)}';
    }
  }

  // 时间戳转时间
  String CustomStamp_str({
    int? Timestamp, // 为空则显示当前时间
    String? Date, // 显示格式，比如：'YY年MM月DD日 hh:mm:ss'
    bool toInt = true, // 去除0开头
  }) {
    Timestamp ??= (new DateTime.now().millisecondsSinceEpoch / 1000).round();
    String Time_str =
        (DateTime.fromMillisecondsSinceEpoch(Timestamp * 1000)).toString();

    dynamic Date_arr = Time_str.split(' ')[0];
    dynamic Time_arr = Time_str.split(' ')[1];

    String YY = Date_arr.split('-')[0];
    String MM = Date_arr.split('-')[1];
    String DD = Date_arr.split('-')[2];

    String hh = Time_arr.split(':')[0];
    String mm = Time_arr.split(':')[1];
    String ss = Time_arr.split(':')[2];

    ss = ss.split('.')[0];

    // 去除0开头
    if (toInt) {
      MM = (int.parse(MM)).toString();
      DD = (int.parse(DD)).toString();
      hh = (int.parse(hh)).toString();
      mm = (int.parse(mm)).toString();
    }

    if (Date == null) {
      return Time_str;
    }

    Date = Date.replaceAll('YY', YY)
        .replaceAll('MM', MM)
        .replaceAll('DD', DD)
        .replaceAll('hh', hh)
        .replaceAll('mm', mm)
        .replaceAll('ss', ss);

    return Date;
  }

  IconData getAvatar() {
    IconData targetIcon;
    switch (conversation.type) {
      case ZIMConversationType.peer:
        targetIcon = Icons.person;
        break;
      case ZIMConversationType.room:
        targetIcon = Icons.home_sharp;
        break;
      case ZIMConversationType.group:
        targetIcon = Icons.people;
        break;
      default:
        targetIcon = Icons.person;
    }
    return targetIcon;
  }

  String getLastMessageValue() {
    String targetMessage;
    if (conversation.lastMessage == null) return '';
    switch (conversation.lastMessage!.type) {
      case ZIMMessageType.text:
        targetMessage = (conversation.lastMessage as ZIMTextMessage).message;
        break;
      case ZIMMessageType.command:
        targetMessage = '[cmd]';
        break;
      case ZIMMessageType.barrage:
        targetMessage = (conversation.lastMessage as ZIMBarrageMessage).message;
        break;
      case ZIMMessageType.audio:
        targetMessage = '[audio]';
        break;
      case ZIMMessageType.video:
        targetMessage = '[video]';
        break;
      case ZIMMessageType.file:
        targetMessage = '[file]';
        break;
      case ZIMMessageType.image:
        targetMessage = '[image]';
        break;
      default:
        {
          targetMessage = '[unknown message type]';
        }
    }
    return targetMessage;
  }

  @override
  State<StatefulWidget> createState() => _MyState();
}

class _MyState extends State<ConverListCell> {
  @override
  Widget build(BuildContext context) {
    //最外层容器
    return GestureDetector(
      onTap: () {
        context.pushNamed(ChatWindowsPage.name, extra: widget.conversation.conversationID);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            ProfilePhoto(
              size: 40,
            ),
            Gap(19.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: widget.conversation.conversationName,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                TextView(
                  text: widget.getLastMessageValue(),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextView(
                  text: widget.getTime(),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.metalBrownColourForText.withOpacity(0.3),
                ),
                const Gap(3),
                widget.isShowBadge
                    ? Container(
                        width: 20,
                        height: 20,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFD9197B),
                          shape: OvalBorder(),
                        ),
                        child: Center(
                            child: TextView(
                          text:
                              widget.conversation.unreadMessageCount.toString(),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.metalWhite,
                        )),
                      )
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
