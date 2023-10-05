 
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';

// import '../colors/cr_colors.dart';

// class CRStyle {
//   static const semibold60Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 60,
//     fontWeight: _semibold,
//   );

//   static const h0Regular48White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 48,
//     fontWeight: _regular,
//   );

//   static const h1Semibold32Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 32,
//     fontWeight: _semibold,
//   );

//   static const h2Semibold26Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 26,
//     fontWeight: _semibold,
//   );

//   static const h3Semibold20Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 20,
//     fontWeight: _semibold,
//   );

//   static const h3Semibold20Blue = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlue,
//     fontSize: 20,
//     fontWeight: _semibold,
//   );

//   static const h4Semibold16Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const h4Semibold16White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const h4Semibold16Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const h5Semibold14 = TextStyle(
//     fontFamily: 'Outfit',
//     fontSize: 16,
//     fontWeight: _semibold,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular20Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 20,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular20Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 20,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular20Green2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGreen2,
//     fontSize: 20,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular20Red = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tRed,
//     fontSize: 20,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular20Blue = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlue,
//     fontSize: 20,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16BlackW700 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: FontWeight.w700,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Purple = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tPurple,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Green2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGreen2,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Orange2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange2,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Gray2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray2,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b1Regular16Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b0Regular56Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 56,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14Red = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tRed,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14Gray2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray2,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const b2Regular14Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 16,
//     fontWeight: _regular,
//     letterSpacing: -0.3,
//   );

//   static const h1Semibold32Green3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGreen2,
//     fontSize: 32,
//     fontWeight: _semibold,
//   );

//   static const h1Semibold32Purple = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tPurple,
//     fontSize: 32,
//     fontWeight: _semibold,
//   );

//   static const button1Semibold16Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const button1Semibold16Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const button1Semibold16Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const button1Semibold16OrangeInactive = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange3,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const button1Semibold16White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 16,
//     fontWeight: _semibold,
//   );

//   static const button2Semibold14Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 14,
//     fontWeight: _semibold,
//   );

//   static const button2Semibold14Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 14,
//     fontWeight: _semibold,
//   );

//   static const button2Semibold14Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 14,
//     fontWeight: _semibold,
//   );

//   static const button2Semibold14White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 14,
//     fontWeight: _semibold,
//   );

//   static const captionRegular12 = TextStyle(
//     fontFamily: 'Outfit',
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const captionRegular12Black = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tBlack,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const captionRegular12White = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tWhite,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const captionRegular12Gray2 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray2,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const captionRegular12Gray3 = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tGray3,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const captionRegular12Orange = TextStyle(
//     fontFamily: 'Outfit',
//     color: CRColors.tOrange,
//     fontSize: 14,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   static const caption1Regular10 = TextStyle(
//     fontFamily: 'Outfit',
//     fontSize: 10,
//     fontWeight: _regular,
//     letterSpacing: -0.1,
//   );

//   /// Todo: remove starter default styles
//   static const captionRoboto14Gray2 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tGray2,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.22,
//   );

//   static const h2BlackBold22 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 22,
//     fontWeight: FontWeight.w700,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.28,
//   );

//   static const h3BlackBold20 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 20,
//     fontWeight: FontWeight.w700,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.28,
//   );
//   static const h4BlackBold18 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 18,
//     fontWeight: FontWeight.w700,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.26,
//   );

//   static const subtitle1BlackSemiBold17 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 17,
//     fontWeight: FontWeight.w600,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.25,
//   );

//   static const body1BlackMedium16 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.24,
//   );

//   static const body1GreyMedium16 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tGray,
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.24,
//   );

//   static const body2BlackMedium14 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tBlack,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.22,
//   );

//   static const body2GreyMedium14 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tGray,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.22,
//   );

//   static const body2BlueSemiBold14 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tDarkBlue,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.22,
//   );
//   static const body2WhiteSemiBold14 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tWhite,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.22,
//   );

//   static const buttonWhiteSemiBold16 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tWhite,
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.24,
//   );

//   static const captionGreyMedium12 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tGray,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.16,
//   );

//   static const captionRedMedium12 = TextStyle(
//     fontFamily: 'Roboto',
//     color: CRColors.tRed,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     letterSpacing: -0.16,
//   );
// }

// const _semibold = FontWeight.w600;
// const _regular = FontWeight.w400;
