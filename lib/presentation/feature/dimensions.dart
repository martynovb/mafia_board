import 'package:mafia_board/data/constants.dart';

class Dimensions {
  static const double defaultIconSize = 24;
  static const double defaultSidePadding = 16;
  static const double sidePadding0_25x = defaultSidePadding/4;
  static const double sidePadding0_5x = defaultSidePadding/2;
  static const double sidePadding2x = defaultSidePadding*2;
  static const double sidePadding3x = defaultSidePadding*3;
  static const double sidePadding4x = defaultSidePadding*4;
  static const double playerItemHeight = 32;
  static const double playerSheetHeaderHeight = 40;
  static const double roleViewWidth = 96;
  static const double foulItemWidth = 18;
  static const double foulsViewWidth = foulItemWidth * Constants.maxFouls;
}
