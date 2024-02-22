import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/chat.bottom.sheet.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/chat.bubble.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/chat.windows.appbar.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/downloading_progress_model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/msg_bottom_box/msg_bottom_model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/msg_converter.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/msg_list.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/receive_items/receive_image_msg_cell.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/receive_items/receive_text_msg_cell.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/receive_items/receive_video_msg_cell.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/send_items/send_text_msg_cell.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/uploading_progress_model.dart';
import 'package:metal/res/res.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatWindowsPage extends ConsumerStatefulWidget {
  ChatWindowsPage({super.key, required this.conversationID}) {
    ZIM.getInstance()!.clearConversationUnreadMessageCount(
        conversationID!, ZIMConversationType.peer);
    clearUnReadMessage();
    //  conversationName = conversation.name;
  }
  static const name = 'chatWindowsPage';
  static const route = '$name';

  // final ZIMKitConversation conversation;
  final String conversationID;

  // String? conversationName;
  double sendTextFieldBottomMargin = 40;
  bool emojiShowing = false;
  List<ZIMMessage> _historyZIMMessageList = <ZIMMessage>[];
  List<Widget> _historyMessageWidgetList = <Widget>[];

  double progress = 0.0;

  bool queryHistoryMsgComplete = false;

  clearUnReadMessage() {
    ZIM.getInstance()!.clearConversationUnreadMessageCount(
        conversationID, ZIMConversationType.peer);
  }

  @override
  ConsumerState<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends ConsumerState<ChatWindowsPage> {
  @override
  void initState() {
    registerZIMEvent();
    if (widget._historyZIMMessageList.isEmpty) {
      queryMoreHistoryMessageWidgetList();
    }

    super.initState();
  }

  @override
  void dispose() {
    unregisterZIMEvent();
    super.dispose();
  }

  UserModel? currentUserData;

  @override
  Widget build(BuildContext context) {
    currentUserData = ref.watch(authProvider).data;
    return BaseScreen(
      appBarEnabled: false,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.metalPinkColour,
        child: Container(
          padding: EdgeInsets.only(left: 18.w, right: 18.w),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              color: AppColors.metalWhite),
          child: Column(
            children: [
              Gap(20.h),
              ChatWindowsAppBar(
                key: widget.key,
                phone: widget.conversationID,
              ),
              Expanded(
                child: GestureDetector(
                    onTap: (() {
                      setState(() {
                        MsgBottomModel.nonselfOnTapResponse();
                      });
                    }),
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.topCenter,
                      child: MsgList(
                        widget._historyMessageWidgetList,
                        loadMoreHistoryMsg: () {
                          queryMoreHistoryMessageWidgetList();
                        },
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatBottomSheet(
                  onSend: (p0) {
                    sendTextMessage(p0);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  sendTextMessage(String message) async {
    ZIMTextMessage textMessage = ZIMTextMessage(message: message);
    textMessage.senderUserID = currentUserData!.phone!;
    ZIMMessageSendConfig sendConfig = ZIMMessageSendConfig();
    widget._historyZIMMessageList.add(textMessage);

    SendTextMsgCell cell = SendTextMsgCell(message: textMessage);
    setState(() {
      widget._historyMessageWidgetList.add(cell);
    });
    try {
      ZIMMessageSentResult result = await ZIM.getInstance()!.sendMessage(
          textMessage,
          widget.conversationID!,
          ZIMConversationType.peer,
          sendConfig,
          ZIMMessageSendNotification(onMessageAttached: ((message) async {})));

      int index = widget._historyZIMMessageList
          .lastIndexWhere((element) => element == textMessage);
      widget._historyZIMMessageList[index] = result.message;
      SendTextMsgCell cell =
          SendTextMsgCell(message: (result.message as ZIMTextMessage));

      setState(() {
        widget._historyMessageWidgetList[index] = cell;
      });
    } on PlatformException catch (onError) {
      log('send error,code:' + onError.code + 'message:' + onError.message!);
      setState(() {
        int index = widget._historyZIMMessageList
            .lastIndexWhere((element) => element == textMessage);
        widget._historyZIMMessageList[index].sentStatus =
            ZIMMessageSentStatus.failed;
        SendTextMsgCell cell = SendTextMsgCell(
            message: (widget._historyZIMMessageList[index] as ZIMTextMessage));
        widget._historyMessageWidgetList[index] = cell;
      });
    }
  }

  sendMediaMessage(String? path, ZIMMessageType messageType) async {
    if (path == null) return;
    ZIMMediaMessage mediaMessage =
        MsgConverter.mediaMessageFactory(path, messageType);
    mediaMessage.senderUserID = currentUserData!.phone!;
    UploadingprogressModel uploadingprogressModel = UploadingprogressModel();
    Widget sendMsgCell = MsgConverter.sendMediaMessageCellFactory(
        mediaMessage, uploadingprogressModel);

    setState(() {
      widget._historyZIMMessageList.add(mediaMessage);
      widget._historyMessageWidgetList.add(sendMsgCell);
    });
    try {
      log(mediaMessage.fileLocalPath);
      ZIMMediaMessageSendNotification notification =
          ZIMMediaMessageSendNotification(
        onMediaUploadingProgress: (message, currentFileSize, totalFileSize) {
          uploadingprogressModel.uploadingprogress!(
              message, currentFileSize, totalFileSize);
        },
      );
      ZIMMessageSentResult result = await ZIM.getInstance()!.sendMediaMessage(
          mediaMessage,
          widget.conversationID!,
          ZIMConversationType.peer,
          ZIMMessageSendConfig(),
          notification);
      int index = widget._historyZIMMessageList
          .lastIndexWhere((element) => element == mediaMessage);
      Widget resultCell = MsgConverter.sendMediaMessageCellFactory(
          result.message as ZIMMediaMessage, null);
      setState(() {
        widget._historyMessageWidgetList[index] = resultCell;
      });
    } on PlatformException catch (onError) {
      int index = widget._historyZIMMessageList
          .lastIndexWhere((element) => element == mediaMessage);
      widget._historyZIMMessageList[index].sentStatus =
          ZIMMessageSentStatus.failed;
      Widget failedCell = MsgConverter.sendMediaMessageCellFactory(
          widget._historyZIMMessageList[index] as ZIMMediaMessage, null);
      setState(() {
        widget._historyMessageWidgetList[index] = failedCell;
      });
    }
  }

  queryMoreHistoryMessageWidgetList() async {
    if (widget.queryHistoryMsgComplete) {
      return;
    }

    ZIMMessageQueryConfig queryConfig = ZIMMessageQueryConfig();
    queryConfig.count = 20;
    queryConfig.reverse = true;
    try {
      queryConfig.nextMessage = widget._historyZIMMessageList.first;
    } catch (onerror) {
      queryConfig.nextMessage = null;
    }
    try {
      ZIMMessageQueriedResult result = await ZIM
          .getInstance()!
          .queryHistoryMessage(
              widget.conversationID!, ZIMConversationType.peer, queryConfig);
      if (result.messageList.length < 20) {
        widget.queryHistoryMsgComplete = true;
      }
      List<Widget> oldMessageWidgetList =
          MsgConverter.cnvMessageToWidget(result.messageList, currentUserData!);
      result.messageList.addAll(widget._historyZIMMessageList);
      widget._historyZIMMessageList = result.messageList;

      oldMessageWidgetList.addAll(widget._historyMessageWidgetList);
      widget._historyMessageWidgetList = oldMessageWidgetList;

      setState(() {});
    } on PlatformException catch (onError) {
      //log(onError.code);
    }
  }

  registerZIMEvent() {
    ZIMEventHandler.onMessageSentStatusChanged =
        (zim, messageSentStatusChangedInfoList) {
      for (var element in messageSentStatusChangedInfoList) {
        print(
            "sentStatus:${element.status},message:${(element.message as ZIMTextMessage).message}");
      }
    };
    ZIMEventHandler.onReceivePeerMessage = (zim, messageList, fromUserID) {
      if (fromUserID != widget.conversationID) {
        return;
      }
      widget.clearUnReadMessage();
      widget._historyZIMMessageList.addAll(messageList);
      for (ZIMMessage message in messageList) {
        switch (message.type) {
          case ZIMMessageType.text:
            ReceiveTextMsgCell cell =
                ReceiveTextMsgCell(message: (message as ZIMTextMessage));
            widget._historyMessageWidgetList.add(cell);
            break;
          case ZIMMessageType.image:
            if ((message as ZIMImageMessage).fileLocalPath == "") {
              DownloadingProgressModel downloadingProgressModel =
                  DownloadingProgressModel();

              ReceiveImageMsgCell resultCell;
              ZIM
                  .getInstance()!
                  .downloadMediaFile(message, ZIMMediaFileType.originalFile,
                      (message, currentFileSize, totalFileSize) {})
                  .then((value) => {
                        resultCell = ReceiveImageMsgCell(
                            message: (value.message as ZIMImageMessage),
                            downloadingProgress: null,
                            downloadingProgressModel: downloadingProgressModel),
                        widget._historyMessageWidgetList.add(resultCell),
                        setState(() {})
                      });
            } else {
              ReceiveImageMsgCell resultCell = ReceiveImageMsgCell(
                  message: message,
                  downloadingProgress: null,
                  downloadingProgressModel: null);
              widget._historyMessageWidgetList.add(resultCell);
            }

            break;
          case ZIMMessageType.video:
            if ((message as ZIMVideoMessage).fileLocalPath == "") {
              ReceiveVideoMsgCell resultCell;
              ZIM
                  .getInstance()!
                  .downloadMediaFile(message, ZIMMediaFileType.originalFile,
                      (message, currentFileSize, totalFileSize) {})
                  .then((value) => {
                        resultCell = ReceiveVideoMsgCell(
                            message: value.message as ZIMVideoMessage,
                            downloadingProgressModel: null),
                        widget._historyMessageWidgetList.add(resultCell),
                        setState(() {})
                      });
            } else {
              ReceiveVideoMsgCell resultCell = ReceiveVideoMsgCell(
                  message: message, downloadingProgressModel: null);
              widget._historyMessageWidgetList.add(resultCell);
              setState(() {});
            }
            break;
          default:
        }
      }
      setState(() {});
    };

    ZIMEventHandler.onMessageSentStatusChanged = (zim, infos) {
      //window.console.warn(infos);
    };

    ZIMEventHandler.onMessageDeleted = (zim, deletedInfo) {};

    ZIMEventHandler.onUserInfoUpdated = (zim, info) {};
  }

  unregisterZIMEvent() {
    ZIMEventHandler.onReceivePeerMessage = null;
    ZIMEventHandler.onMessageSentStatusChanged = null;
  }
}

class dateDivider extends StatelessWidget {
  const dateDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
        Gap(10.w),
        TextView(text: "Today"),
        Gap(10.w),
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
      ],
    );
  }
}
