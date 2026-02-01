import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 尺寸与间距系统
  static const double gridBase = 8.0;
  static const double spacing4 = gridBase * 0.5; // 4px
  static const double spacing8 = gridBase; // 8px
  static const double spacing12 = gridBase * 1.5; // 12px
  static const double spacing16 = gridBase * 2; // 16px
  static const double spacing24 = gridBase * 3; // 24px
  static const double spacing32 = gridBase * 4; // 32px

  // 触控目标最小尺寸
  static const double minTouchTarget = 44.0;

  // 最大内容宽度
  static const double maxContentWidth = 600.0;

  // 圆角
  static const double borderRadius = 16.0;

  // 响应式断点
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1440.0;

  // 色彩体系
  static const Color primaryColor = Color(0xFF007AFF); // Apple 蓝
  static const Color schoolColor = Color(0xFFF5D76E); // 水墨金
  static const Color backgroundColor = Color(0xFFF5F5F5); // 主背景
  static const Color cardBackground = Colors.white; // 卡片背景
  static const Color primaryText = Color(0xFF2E2E48); // 主文本
  static const Color secondaryText = Color(0xFF6C757D); // 次文本
  static const Color disabledText = Color(0xFFADADAD); // 禁用状态

  // 按钮状态颜色
  static const Color buttonHoverColor = Color(0xFF0066CC);
  static const Color buttonPressedColor = Color(0xFF005299);
  static const Color buttonDisabledColor = Color(0xFFEFEFEF);

  // 阴影
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // 获取主题数据
  static ThemeData getThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardBackground,
      textTheme: const TextTheme(
        // 标题 (H1)
        displayLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: primaryText,
          height: 1.6,
        ),
        // 副标题 (H2)
        displayMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: primaryText,
          height: 1.6,
        ),
        // 正文 (Body)
        bodyLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryText,
          height: 1.6,
        ),
        // 辅助文字
        bodyMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: secondaryText,
          height: 1.6,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: schoolColor,
        background: backgroundColor,
        surface: cardBackground,
        onPrimary: Colors.white,
        onSecondary: primaryText,
        onBackground: primaryText,
        onSurface: primaryText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return const Color(0xFFF5F5F5);
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return primaryText;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color.fromARGB(255, 28, 24, 24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        margin: const EdgeInsets.all(spacing8),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: secondaryText,
        indicatorColor: primaryColor,
        labelStyle: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
