import 'package:flutter/material.dart';

class CRColors {
  /// Text colors
  //#region
  static const tGray = _CRColors.grey;
  static const tDarkBlue = _CRColors.darkBlue;
  static const tTransparent = _CRColors.transparent;

  /// Mockup palette
  static const tOrange = _CRColors.orange;
  static const tOrange2 = _CRColors.orange2;
  static const tOrange3 = _CRColors.orange3;
  static const tOrange4 = _CRColors.orange4;

  static const tBlack = _CRColors.black;
  static const tGray4 = _CRColors.gray4;
  static const tGray3 = _CRColors.gray3;
  static const tGray2 = _CRColors.gray2;
  static const tGray1 = _CRColors.gray1;

  static const tWhite = _CRColors.white;
  static const tGreen = _CRColors.green;
  static const tGreen2 = _CRColors.green2;
  static const tRed = _CRColors.red;
  static const tBlue = _CRColors.blue;
  static const tPurple = _CRColors.purple;

  //#endregion

  /// Widget colors
  //#region
  static const wWhite80 = _CRColors.white80;
  static const wGrey = _CRColors.grey;
  static const wDarkBlue = _CRColors.darkBlue;
  static const wTransparent = _CRColors.transparent;
  static const wLightGrey = _CRColors.lightGrey;
  static const wLightBlue = _CRColors.lightBlue;

  /// Mockup palette
  static const wOrange = _CRColors.orange;
  static const wOrange2 = _CRColors.orange2;
  static const wOrange2_30 = _CRColors.orange2_30;
  static const wOrange3 = _CRColors.orange3;
  static const wOrange4 = _CRColors.orange4;
  static const wOrange5 = _CRColors.orange5;

  static const wBlack = _CRColors.black;
  static const wGray4 = _CRColors.gray4;
  static const wGray3 = _CRColors.gray3;
  static const wGray2 = _CRColors.gray2;
  static const wGray1 = _CRColors.gray1;

  static const wWhite = _CRColors.white;
  static const wGreen = _CRColors.green;
  static const wGreen2 = _CRColors.green2;
  static const wGreen2_200 = _CRColors.green2_200;
  static const wRed = _CRColors.red;
  static const wRed3 = _CRColors.red3;
  static const wRed_10 = _CRColors.red_10;
  static const wRed_20 = _CRColors.red_20;
  static const wBlue = _CRColors.blue;
  static const wBlue2 = _CRColors.blue2;
  static const wBlue2_20 = _CRColors.blue2_20;

  static const wPurple = _CRColors.purple;
  static const wPurple_20 = _CRColors.purple_20;
  static const wOrange5_20 = _CRColors.orange5_20;
  static const wGreen2_20 = _CRColors.green2_20;

  //#endregion

  /// Theme colors
  //#region
  static const primaryColor = _CRColors.orange;
  static const backgroundColor = _CRColors.white;
  static const dialogBackgroundColor = _CRColors.white;

  /// hint text or placeholder text,
  static const hintColor = CRColors.tGray;

  /// scroll color(android), FAB, ProgressBar
  static const accentColor = _CRColors.orange;
  static const cursorColor = _CRColors.black;
//#endregion
}

class _CRColors {
  _CRColors._();

  static const transparent = Colors.transparent;
  static const white80 = Color(0xCCFFFFFF);
  static const lightBlue = Color(0xFFF1F6FF);
  static const lightGrey = Color(0xFFF7F7F8);
  static const grey = Color(0xFF878B95);
  static const darkBlue = Color(0xFF00314A);

  /// Mockup palette
  static const purple = Color(0xFFD64176);
  static const purple_20 = Color(0x33D64176);
  static const orange5_20 = Color(0x33EFA044);
  static const green2_20 = Color(0x334FAAA6);

  static const orange = Color(0xFFFF5300);
  static const orange2 = Color(0xFFFF7532);
  static const orange2_30 = Color(0x4DFF7532);
  static const orange3 = Color(0xFFFFBA99);
  static const orange4 = Color(0xFFFFDCCC);
  static const orange5 = Color(0xFFEFA044);

  static const black = Color(0xFF0D0D0D);
  static const gray3 = Color(0xFF636363);
  static const gray4 = Color(0xFFDCE2E6);
  static const gray2 = Color(0xFFC5C5C5);
  static const gray1 = Color(0xFFF2F4F5);

  static const white = Color(0xFFFFFFFF);
  static const green = Color(0xFF1AB800);
  static const green2 = Color(0xFF4FAAA6);
  static const green2_200 = Color(0xFFDCEEED);
  static const red = Color(0xFFE30000);
  static const red3 = Color(0xFFF9CCCC);
  static const red_10 = Color(0x1AE30000);
  static const red_20 = Color(0x33E30000);
  static const blue = Color(0xFF007AFF);
  static const blue2 = Color(0xFF459CDC);
  static const blue2_20 = Color(0x33459CDC);
}

/**
    <!--100% — FF
    99% — FC
    98% — FA
    97% — F7
    96% — F5
    95% — F2
    94% — F0
    93% — ED
    92% — EB
    91% — E8
    90% — E6
    89% — E3
    88% — E0
    87% — DE
    86% — DB
    85% — D9
    84% — D6
    83% — D4
    82% — D1
    81% — CF
    80% — CC
    79% — C9
    78% — C7
    77% — C4
    76% — C2
    75% — BF
    74% — BD
    73% — BA
    72% — B8
    71% — B5
    70% — B3
    69% — B0
    68% — AD
    67% — AB
    66% — A8
    65% — A6
    64% — A3
    63% — A1
    62% — 9E
    61% — 9C
    60% — 99
    59% — 96
    58% — 94
    57% — 91
    56% — 8F
    55% — 8C
    54% — 8A
    53% — 87
    52% — 85
    51% — 82
    50% — 80
    49% — 7D
    48% — 7A
    47% — 78
    46% — 75
    45% — 73
    44% — 70
    43% — 6E
    42% — 6B
    41% — 69
    40% — 66
    39% — 63
    38% — 61
    37% — 5E
    36% — 5C
    35% — 59
    34% — 57
    33% — 54
    32% — 52
    31% — 4F
    30% — 4D
    29% — 4A
    28% — 47
    27% — 45
    26% — 42
    25% — 40
    24% — 3D
    23% — 3B
    22% — 38
    21% — 36
    20% — 33
    19% — 30
    18% — 2E
    17% — 2B
    16% — 29
    15% — 26
    14% — 24
    13% — 21
    12% — 1F
    11% — 1C
    10% — 1A
    9% — 17
    8% — 14
    7% — 12
    6% — 0F
    5% — 0D
    4% — 0A
    3% — 08
    2% — 05
    1% — 03
    0% — 00-->
 */
