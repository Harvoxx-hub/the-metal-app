import 'dart:typed_data';

import 'package:flutter/material.dart';
 

double getDeviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// get device height
double getDeviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

String formatChatTime( DateTime messageTime) {
 

  // get current time
  DateTime now = DateTime.now();

  // check if message was sent today
  if (now.year == messageTime.year &&
      now.month == messageTime.month &&
      now.day == messageTime.day) {
    // return time only
    return "  ${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
  }

  // check if message was sent yesterday
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  if (yesterday.year == messageTime.year &&
      yesterday.month == messageTime.month &&
      yesterday.day == messageTime.day) {
    return "  Yesterday ${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
  }

  // Otherwise, display the date in format 'dd MMM'
  String day =
      messageTime.day < 10 ? '0${messageTime.day}' : '${messageTime.day}';
  String month = '';
  switch (messageTime.month) {
    case DateTime.january:
      month = 'Jan';
      break;
    case DateTime.february:
      month = 'Feb';
      break;
    case DateTime.march:
      month = 'Mar';
      break;
    case DateTime.april:
      month = 'Apr';
      break;
    case DateTime.may:
      month = 'May';
      break;
    case DateTime.june:
      month = 'Jun';
      break;
    case DateTime.july:
      month = 'Jul';
      break;
    case DateTime.august:
      month = 'Aug';
      break;
    case DateTime.september:
      month = 'Sep';
      break;
    case DateTime.october:
      month = 'Oct';
      break;
    case DateTime.november:
      month = 'Nov';
      break;
    case DateTime.december:
      month = 'Dec';
      break;
    default:
      month = '';
      break;
  }
  return '  $day $month';

  // message was sent on a different day, return date and time
  // return "${messageTime.day}/${messageTime.month}/${messageTime.year} ${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
}

// // Future<Uint8List> bytes(video) async {
// //   Uint8List? uint8List;
// //   await VideoThumbnail.thumbnailData(
// //     video: video,
// //     imageFormat: ImageFormat.JPEG,
// //     maxWidth:
// //         128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
// //     quality: 80,
// //   ).then((value) => {uint8List = value!});

// //   return uint8List!;
// // }

// // onshare(BuildContext context) async {
// //   final box = context.findRenderObject() as RenderBox?;

// //   await Share.share(
// //     'Test share animalia',
// //     subject: 'Animalia App',
// //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
// //   );
// // }

// bool isLink(String input) {
//   final regex = RegExp(
//     r'^https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}$',
//     caseSensitive: false,
//     multiLine: false,
//   );
//   return regex.hasMatch(input);
// }

// bool isYoutubeLink(String input) {
//   RegExp regExp = RegExp(
//       r'((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?');
//   return regExp.hasMatch(input);
// }
