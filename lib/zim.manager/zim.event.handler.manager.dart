  
import 'package:zego_zim/zego_zim.dart';

class ZIMEventHandlerManger {
  
  // static LoadingEventHandler(){
  //   ZIMEventHandlerManger.onConnectionStateChange = (ZIMConnectionState state) {
  //     print('Connection state changed: $state');
  //   };
  // }

  // The callback for receiving error codes. This callback will be triggered when SDK returns error codes. 
static void Function(ZIMError errorInfo)? onError;

// The callback for Token expires. This callback will be triggered when the Token is about to expire, and you can customize a UI for this event.  
static void Function(int second)? onTokenWillExpire;

// The callback for connection status changes. This callback will be triggered when the connection status changes, and you can customize a UI for this event.
static void Function(ZIMConnectionState state, ZIMConnectionEvent event, Map extendedData)? onConnectionStateChanged;

// The callback for receiving one-on-one messages. You can receive message notifications through this callback after login. 
static void Function(List<ZIMMessage> messageList, String fromUserID)? onReceivePeerMessage;

// The callback for receiving the in-room massages. You can receive in-room message notifications through this callback after login and joining a room.  
static void Function(List<ZIMMessage> messageList, String fromRoomID)? onReceiveRoomMessage;

// The callback for a new user joins the room. You can receive notifications when a new user joins the room through this callback after logging in and joining a room.
static void Function(List<ZIMUserInfo> memberList, String roomID)? onRoomMemberJoined;

// The callback for an existing user leaves the room. You can receive notifications when an existing user leaves the room through this callback after login and joining a room.
static void Function(List<ZIMUserInfo> memberList, String roomID)? onRoomMemberLeft;
}