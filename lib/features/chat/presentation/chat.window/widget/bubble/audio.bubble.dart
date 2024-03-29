 
// import 'package:flutter/material.dart';
 

 

// class AudioMessage extends StatefulWidget {
//   final Message? message;

//   const AudioMessage({Key? key, this.message}) : super(key: key);

//   @override
//   State<AudioMessage> createState() => _AudioMessageState();
// }

// class _AudioMessageState extends State<AudioMessage> {
//  bool _isPlaying = false;
//  Duration duration = Duration() ;

//  final AudioPlayer _audioPlayer = AudioPlayer();
//   void _onPlayButtonPressed() {

//     if (!_isPlaying) {
//       _isPlaying = true;

//       _audioPlayer.play(widget.message?.url);
//       _audioPlayer.onAudioPositionChanged.listen((Duration  p) => {
//     print('Current position: $p'),
//     setState(() => duration = p)
//     });


//       _audioPlayer.onPlayerCompletion.listen((duration) {
//         setState(() {
//           _isPlaying = false;
//         });
//       });

//     } else {
//       _audioPlayer.pause();
//       _isPlaying = false;
//     }

//     setState(() {});
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.35,
//       padding: EdgeInsets.symmetric(
//         horizontal: kDefaultPadding * 0.75,
//         vertical: kDefaultPadding / 2.5,
//       ),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         color: kPrimaryColor.withOpacity(widget.message!.isSender ? 1 : 0.1),
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             color: widget.message!.isSender ? Colors.white : kPrimaryColor, icon: !_isPlaying?Icon(Icons.play_arrow):Icon(Icons.pause), onPressed: () {
//             _onPlayButtonPressed();
//           },
//           ),

//           Text(
//             duration.toString().split('.')[0],
//             style: TextStyle(
//                 fontSize: 12, color: widget.message!.isSender ? Colors.white : null),
//           ),
//         ],
//       ),
//     );
//   }
// }