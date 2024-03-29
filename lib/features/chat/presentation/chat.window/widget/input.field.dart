// import 'package:flutter/material.dart';
 

// class ChatInputField extends StatefulWidget {
//   final Chat chat;
//   const ChatInputField({
//     Key? key, required this.chat,
//   }) : super(key: key);

//   @override
//   State<ChatInputField> createState() => _ChatInputFieldState();
// }

// class _ChatInputFieldState extends State<ChatInputField> {
//   var roomid = '';
//   @override
//   void initState() {
//     // TODO: implement initState
//     P.message.messageController.addListener(() {
//       P.message.onTextChange();
//     });

//     if (P.auth.users.uid.compareTo(widget.chat.id) > 0) {
//       roomid = P.auth.users.uid+'-'+widget.chat.id;
//     } else {
//       roomid = widget.chat.id+'-'+P.auth.users.uid;
//     }
//     super.initState();
//   }

//   void _modalBottomSheetMenu(){
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         context: context,
//         builder: (builder){
//           return Container(
//             height: 200.0,
//             color: Colors.transparent,
//          child: Padding(
//            padding: const EdgeInsets.all(20.0),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                GestureDetector(
//                  onTap: (){
//                    P.message.getImage(roomid, P.auth.users.uid);
//                    Get.back();
//                  },
//                  child: Row(
//                    children: const [
//                      Icon(Icons.image, color: kPrimaryColor),
//                      Padding(
//                        padding: EdgeInsets.all(15.0),
//                        child: Text('Select image',   style: TextStyle(fontSize: 18,  fontWeight:  FontWeight.w400,),),
//                      ),
//                    ],
//                  ),
//                ),
//                SizedBox(height: 10,),
//                Divider(height: 1,),
//                SizedBox(height: 10,),
//                GestureDetector(
//                  onTap: (){
//                    P.message.getVideo(roomid, P.auth.users.uid);
//                  },
//                  child: Row(

//                    children: [
//                      Icon(Icons.video_collection, color: kPrimaryColor),

//                      Padding(
//                        padding: const EdgeInsets.all(15.0),
//                        child: Text('Select video',   style: TextStyle(fontSize: 18, fontWeight:  FontWeight.w400,),),
//                      ),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),

//           );
//         }
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return  Container(
     
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//             offset: Offset(0, 4),
//             blurRadius: 32,
//             color: Color(0xFF087949).withOpacity(0.08),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: P.message.messageType.value?
//         Row(
//           children: [
//             GestureDetector(
//               onTap: (){
//                P.message.messageType.value = false;


//               },
//               child: Icon(Icons.mic, color: kPrimaryColor),
//             ),

//             SizedBox(width: kDefaultPadding),
//             Expanded(
//               child:  Obx(()=> Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: kDefaultPadding * 0.75,
//                 ),
//                 decoration: BoxDecoration(
//                   color: kPrimaryColor.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.sentiment_satisfied_alt_outlined,
//                       color: Theme.of(context)
//                           .textTheme
//                           .bodyText1!
//                           .color!
//                           .withOpacity(0.64),
//                     ),
//                     SizedBox(width:  4),
//                     Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "Type message",
//                           border: InputBorder.none,
//                         ),
//                         controller: P.message.messageController,
//                       ),
//                     ),
//                     P.message.textMessage.value ?
//                         GestureDetector(
//                           onTap: (){

//                             P.message.sendText(roomid, P.auth.users.uid);
//                           },
//                           child:  Icon(
//                             Icons.send,

//                             color: Theme.of(context)
//                                 .textTheme
//                                 .bodyText1!
//                                 .color!
//                                 .withOpacity(0.64),
//                           ) ,
//                         )
//                   :
//                    // SizedBox(width: kDefaultPadding / 4),
//                     GestureDetector(
//                       onTap: (){

//                        // P.message.getImage(roomid, P.auth.users.uid);
//                         _modalBottomSheetMenu();
//                       },
//                       child:  Icon(
//                         Icons.attach_file,
//                         color: Theme.of(context)
//                             .textTheme
//                             .bodyText1!
//                             .color!
//                             .withOpacity(0.64),
//                       ) ,
//                     )

//                   ],
//                 ),
//               )),
//             ),
//           ],
//         ):
//       P.message.isRecorded.value
//             ? P.message.isUploading.value
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: LinearProgressIndicator()),
//             Text('Uplaoding...'),
//           ],
//         )
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(Icons.delete_forever, color: kPrimaryColor,),
//               onPressed: P.message.onRecordAgainButtonPressed,
//             ),
//             Spacer(),
//             IconButton(
//               icon: Icon(P.message.isPlaying.value ? Icons.pause : Icons.play_arrow, color: kPrimaryColor,),
//               onPressed: P.message.onPlayButtonPressed,
//             ),
//             Spacer(),

//             IconButton(
//               icon: Icon(Icons.send, color: kPrimaryColor,),
//               onPressed: (){
//                 P.message.onFileUploadButtonPressed(roomid, P.auth.users.uid);
//               },
//             ),
//           ],
//         )
//             : IconButton(
//           icon: P.message.isRecording.value
//               ? Icon(Icons.pause,  color: kPrimaryColor,)
//               : Icon(Icons.fiber_manual_record,  color: kPrimaryColor,),
//           onPressed: P.message.onRecordButtonPressed,
//         ),
//       ),
//     ));
//   }
// }