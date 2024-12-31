// import 'package:flutter/services.dart';

// import '../../constant/constants.dart';

// class InputFormatters {
//   InputFormatters._();

//   static final cardMaskFormatter = MaskTextInputFormatter(
//     mask: '#### #### #### ####',
//     filter: {'#': RegExp('[0-9]')},
//   );

//   static final expireDateFormatter = MaskTextInputFormatter(
//     mask: '##/##',
//     filter: {'#': RegExp('[0-9]')},
//   );

//   static final cvvFormatter = MaskTextInputFormatter(
//     mask: '####',
//     filter: {'#': RegExp('[0-9]')},
//   );

//   static TextInputFormatter get name {
//     return FilteringTextInputFormatter.allow(
//       RegExp(
//         kNamePattern,
//         caseSensitive: false,
//         unicode: true,
//         dotAll: true,
//       ),
//     );
//   }

//   static MaskTextInputFormatter get zipCodeFormatter => MaskTextInputFormatter(
//         mask: '#' * kMaxZipCodeLength,
//         filter: {'#': RegExp('[0-9]')},
//       );

//   static List<TextInputFormatter> get percent => [
//         MaskTextInputFormatter(mask: '##'),
//         TextInputFormatter.withFunction(
//           (_, newValue) => newValue.copyWith(text: '${newValue.text}%'),
//         ),
//       ];

//   static List<TextInputFormatter> get currency => [
//         _replaceCommaWithDot,
//         _currency,
//       ];

//   static TextInputFormatter get _replaceCommaWithDot =>
//       TextInputFormatter.withFunction((oldValue, newValue) {
//         return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
//       });

//   static TextInputFormatter get _currency =>
//       FilteringTextInputFormatter.allow(RegExp('^[0-9]*[.]?[0-9]?[0-9]?'));
// }
