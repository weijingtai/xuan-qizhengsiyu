import 'package:flutter/material.dart';
import 'package:enumeration/enums.dart';

import '../theme/gan_zhi_gua_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Light.background,
    cardColor: Light.surface,
    dividerColor: Light.divider,
    colorScheme: ColorScheme.light(
      primary: GanZhiGuaColors.zodiacZhiColors[DiZhi.ZI]!,
      secondary: GanZhiGuaColors.zodiacGanColors[TianGan.JIA]!,
      surface: Light.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Light.primaryText,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Light.primaryText),
      bodyMedium: TextStyle(color: Light.primaryText),
      titleMedium: TextStyle(color: Light.secondaryText),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Dark.background,
    cardColor: Dark.surface,
    dividerColor: Dark.divider,
    colorScheme: ColorScheme.dark(
      primary: GanZhiGuaColors.zodiacZhiColors[DiZhi.ZI]!,
      secondary: GanZhiGuaColors.zodiacGanColors[TianGan.JIA]!,
      surface: Dark.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Dark.primaryText,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Dark.primaryText),
      bodyMedium: TextStyle(color: Dark.primaryText),
      titleMedium: TextStyle(color: Dark.secondaryText),
    ),
  );

  static Color _getColorForDiZhi(DiZhi diZhi, bool isDarkMode) {
    switch (diZhi.fiveXing) {
      case FiveXing.MU:
        return isDarkMode ? Colors.green[300]! : Colors.green;
      case FiveXing.HUO:
        return isDarkMode ? Colors.red[300]! : Colors.red;
      case FiveXing.TU:
        return isDarkMode ? Colors.brown[300]! : Colors.brown;
      case FiveXing.JIN:
        return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
      case FiveXing.SHUI:
        return isDarkMode ? Colors.blue[300]! : Colors.blue;
    }
  }

  static ThemeData getThemeForDiZhi(DiZhi diZhi, Brightness brightness) {
    final bool isDarkMode = brightness == Brightness.dark;
    final Color primaryColor = _getColorForDiZhi(diZhi, isDarkMode);
    final ThemeData baseTheme = isDarkMode ? darkTheme : lightTheme;

    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
      ),
    );
  }
}
