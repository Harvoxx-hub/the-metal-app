// import 'dart:convert';

// import 'package:worker_manager/worker_manager.dart';

// class Coder {
//   Future<String> encode(Object? toEncode) {
//     return Executor().execute(arg1: toEncode, fun1: _encode);
//   }

//   Future<dynamic> decode(String text) {
//     return Executor().execute(arg1: text, fun1: _decode);
//   }
// }

// // Must be top-level function
// String _encode(Object? toEncode, TypeSendPort _) => jsonEncode(toEncode);

// // Must be top-level function
// dynamic _decode(String response, TypeSendPort _) => jsonDecode(response);
