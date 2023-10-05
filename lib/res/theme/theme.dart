// // ignore_for_file: long-method
 
// import 'package:flutter/cupertino.dart' as theme;
// import 'package:flutter/material.dart';
// import 'package:metal/res/colors/cr_colors.dart';
// import 'package:metal/res/res.dart';
// import 'package:metal/res/theme/theme_value.dart';

// import 'cr_list_tile_style.dart';
// import 'elevated_button_style.dart';
// import 'outlined_button_style.dart';

// ThemeData get lightTheme => ThemeData(
//       cupertinoOverrideTheme: const theme.CupertinoThemeData(
//         primaryColor: CRColors.primaryColor,
//         brightness: theme.Brightness.light,
//         barBackgroundColor: CRColors.wWhite,
//       ),
//       hintColor: CRColors.hintColor,
//       dialogBackgroundColor: CRColors.dialogBackgroundColor,
//       scaffoldBackgroundColor: CRColors.wWhite,
//       dialogTheme: const DialogTheme(
//         backgroundColor: CRColors.dialogBackgroundColor,
//       ),
//       backgroundColor: CRColors.backgroundColor,
//       primaryColor: CRColors.primaryColor,
//       unselectedWidgetColor: CRColors.wGray2,
//       toggleableActiveColor: CRColors.primaryColor,
//       errorColor: CRColors.wRed,
//       textTheme: const TextTheme(
//         button: CRStyle.button1Semibold16Black,
//         headline2: CRStyle.h2Semibold26Black,
//         headline3: CRStyle.h3Semibold20Black,
//         headline4: CRStyle.h4Semibold16Black,
//         subtitle1: CRStyle.b2Regular14Black,
//         caption: CRStyle.captionRegular12Black,
//         bodyText1: CRStyle.b1Regular16Black,
//         bodyText2: CRStyle.b2Regular14Black,
//       ),
//       textSelectionTheme: const TextSelectionThemeData(
//         cursorColor: CRColors.cursorColor,
//         selectionColor: CRColors.wLightBlue,
//         selectionHandleColor: CRColors.wOrange,
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           textStyle: CRStyle.button1Semibold16Black,
//           foregroundColor: CRColors.tBlack,
//           side: const BorderSide(color: CRColors.wBlack, width: 2),
//           minimumSize: _minButtonSize,
//           shape: const StadiumBorder(),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           textStyle: CRStyle.button1Semibold16White,
//           minimumSize: _minButtonSize,
//           backgroundColor: CRColors.wOrange,
//           foregroundColor: CRColors.tWhite,
//           disabledBackgroundColor: CRColors.wOrange4,
//           disabledForegroundColor: CRColors.tOrange,
//           shape: const StadiumBorder(),
//           elevation: 0,
//         ),
//       ),
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           minimumSize: _minButtonSize,
//           textStyle: CRStyle.button1Semibold16Black,
//           foregroundColor: CRColors.tOrange,
//           disabledForegroundColor: CRColors.tOrange3,
//           shape: const StadiumBorder(),
//         ),
//       ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: CRColors.wOrange,
//         foregroundColor: CRColors.tWhite,
//         extendedTextStyle: CRStyle.button1Semibold16White,
//         extendedPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
//       ),
//       appBarTheme: const AppBarTheme(
//         elevation: 0.4,
//         shadowColor: CRColors.wGray1,
//         backgroundColor: CRColors.tWhite,
//         centerTitle: true,
//         titleTextStyle: CRStyle.h4Semibold16Black,
//         toolbarTextStyle: CRStyle.h4Semibold16Black,
//         iconTheme: IconThemeData(
//           color: CRColors.tOrange,
//         ),
//       ),
//       timePickerTheme: TimePickerThemeData(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         dialHandColor: CRColors.wOrange2,
//         dayPeriodShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         hourMinuteColor: CRColors.wOrange2_30,
//         hourMinuteTextStyle: CRStyle.b0Regular56Orange,
//         dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return CRColors.wOrange2;
//           }

//           return CRColors.wGray3;
//         }),
//         dayPeriodColor: MaterialStateColor.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return CRColors.wOrange2_30;
//           }

//           return CRColors.wTransparent;
//         }),
//         hourMinuteTextColor: MaterialStateColor.resolveWith((states) {
//           if (states.contains(MaterialState.selected)) {
//             return CRColors.wOrange2;
//           }

//           return CRColors.wBlack;
//         }),
//         dialBackgroundColor: CRColors.wGray1,
//         inputDecorationTheme: const InputDecorationTheme(
//           hoverColor: CRColors.wOrange2,
//           focusColor: CRColors.wOrange2,
//         ),
//       ),
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         backgroundColor: CRColors.wWhite,
//         selectedItemColor: CRColors.wOrange,
//         unselectedItemColor: CRColors.wBlack,
//         showUnselectedLabels: false,
//         showSelectedLabels: true,
//         selectedIconTheme: IconThemeData(
//           color: CRColors.wOrange,
//         ),
//       ),
//       pageTransitionsTheme: const PageTransitionsTheme(
//         builders: <theme.TargetPlatform, PageTransitionsBuilder>{
//           theme.TargetPlatform.android: CupertinoPageTransitionsBuilder(),
//           theme.TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//         },
//       ),
//       chipTheme: const ChipThemeData(
//         selectedColor: CRColors.wDarkBlue,
//         backgroundColor: CRColors.wLightBlue,
//         labelStyle: CRStyle.body2BlueSemiBold14,
//         secondaryLabelStyle: CRStyle.body2WhiteSemiBold14,
//         secondarySelectedColor: CRColors.wDarkBlue,
//         disabledColor: CRColors.wOrange,
//         brightness: Brightness.light,
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       checkboxTheme: CheckboxThemeData(
//         fillColor: MaterialStateProperty.all(CRColors.wTransparent),
//         checkColor: MaterialStateProperty.resolveWith((states) {
//           if (states.contains(MaterialState.disabled)) {
//             return CRColors.wGray2;
//           }

//           return CRColors.wOrange;
//         }),
//         overlayColor: MaterialStateProperty.all(CRColors.wTransparent),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(4),
//         ),
//       ),
//       toggleButtonsTheme: ToggleButtonsThemeData(
//         textStyle: CRStyle.b2Regular14Black,
//         color: CRColors.tOrange2,
//         selectedColor: CRColors.tWhite,
//         fillColor: MaterialStateColor.resolveWith(
//           (states) => states.contains(MaterialState.selected)
//               ? CRColors.wOrange2
//               : CRColors.wOrange4,
//         ),
//         splashColor: CRColors.wOrange2.withOpacity(0.3),
//         highlightColor: CRColors.wOrange2.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       colorScheme: ColorScheme.fromSwatch().copyWith(
//         secondary: CRColors.accentColor,
//         onSecondary: CRColors.primaryColor,
//       ),
//       dividerTheme: const DividerThemeData(
//         color: CRColors.wGray1,
//         space: 0,
//         thickness: 1,
//       ),
//       listTileTheme: const ListTileThemeData(
//         visualDensity: VisualDensity.compact,
//         horizontalTitleGap: 12,
//         minLeadingWidth: 24,
//         iconColor: CRColors.tBlack,
//       ),
//       snackBarTheme: SnackBarThemeData(
//         contentTextStyle: CRStyle.b2Regular14White,
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: CRColors.wBlack,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//       ),
//       cardTheme: CardTheme(
//         elevation: 0,
//         shadowColor: Colors.black26,
//         color: CRColors.wGray1,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//       ),
//       bottomSheetTheme: const BottomSheetThemeData(
//         backgroundColor: CRColors.dialogBackgroundColor,
//         modalBackgroundColor: CRColors.dialogBackgroundColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(18),
//             topRight: Radius.circular(18),
//           ),
//         ),
//       ),
//       extensions: <ThemeExtension<dynamic>>[
//         ThemeValue(
//           ElevatedButtonStyle(
//             smallBlack: ElevatedButton.styleFrom(
//               textStyle: CRStyle.button2Semibold14White,
//               backgroundColor: CRColors.wBlack,
//               disabledForegroundColor: CRColors.tWhite,
//               disabledBackgroundColor: CRColors.wBlack.withOpacity(0.5),
//             ),
//             icon: ElevatedButton.styleFrom(
//               backgroundColor: CRColors.wGray1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.zero,
//               fixedSize: const Size.square(38),
//               minimumSize: const Size.square(38),
//             ),
//             emergency: ElevatedButton.styleFrom(
//               backgroundColor: CRColors.wPurple,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//             chat: ElevatedButton.styleFrom(
//               backgroundColor: CRColors.wBlue2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//             active: ElevatedButton.styleFrom(
//               backgroundColor: CRColors.tOrange,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//             inActive: ElevatedButton.styleFrom(
//               backgroundColor: CRColors.tOrange3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//           ),
//         ),
//         ThemeValue(
//           OutlinedButtonStyle(
//             red: OutlinedButton.styleFrom(
//               foregroundColor: CRColors.tRed,
//               side: const BorderSide(color: CRColors.tRed, width: 2),
//             ),
//             smallBlack: OutlinedButton.styleFrom(
//               textStyle: CRStyle.button2Semibold14Black,
//             ),
//             white: OutlinedButton.styleFrom(
//               textStyle: CRStyle.button2Semibold14White,
//               foregroundColor: CRColors.wWhite,
//               side: const BorderSide(color: CRColors.wWhite, width: 2),
//             ),
//           ),
//         ),
//         ThemeValue(
//           CRListTileStyle(
//             roundedGray: ListTileThemeData(
//               tileColor: CRColors.wGray1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               visualDensity: VisualDensity.compact,
//               horizontalTitleGap: 12,
//               minLeadingWidth: 24,
//             ),
//             rounded24Gray: ListTileThemeData(
//               tileColor: CRColors.wGray1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               horizontalTitleGap: 12,
//               minLeadingWidth: 24,
//             ),
//             dropdownPicker: ListTileThemeData(
//               tileColor: CRColors.wGray1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               visualDensity: const VisualDensity(
//                 vertical: VisualDensity.minimumDensity,
//               ),
//               horizontalTitleGap: 8,
//               minLeadingWidth: 20,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//               ),
//             ),
//             dropdownPickerCompact: ListTileThemeData(
//               tileColor: CRColors.wGray1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               visualDensity: const VisualDensity(
//                 vertical: VisualDensity.minimumDensity,
//               ),
//               horizontalTitleGap: 4,
//               minLeadingWidth: 20,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 6,
//               ),
//             ),
//             outlinedPicker: ListTileThemeData(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: const BorderSide(color: CRColors.wGray1),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//               visualDensity: const VisualDensity(vertical: -4),
//               horizontalTitleGap: 0,
//             ),
//             compact: const ListTileThemeData(
//               visualDensity: VisualDensity.compact,
//               horizontalTitleGap: 14,
//               minLeadingWidth: 24,
//               dense: true,
//               contentPadding: EdgeInsets.only(left: 14, right: 16),
//             ),
//           ),
//         ),
//       ],
//     );

// const _minButtonSize = Size(64, 48);

// ThemeData get darkTheme => ThemeData.dark();

// const textFieldBorder = UnderlineInputBorder(
//   borderSide: BorderSide(color: CRColors.wGray2),
// );

// const selectedTextFieldBorder = UnderlineInputBorder(
//   borderSide: BorderSide(color: CRColors.wOrange),
// );

// const errorTextFieldBorder = UnderlineInputBorder(
//   borderSide: BorderSide(color: CRColors.wRed),
// );
