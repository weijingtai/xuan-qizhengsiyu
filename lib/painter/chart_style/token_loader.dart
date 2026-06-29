import 'dart:ui';

/// Utility class with static parsing helpers for theme tokens.
///
/// Public static methods [parseColor] and [parseFontWeight] are reused by
/// [ThemeChartStyleResolver] to convert raw token values to typed Dart objects.
class TokenLoader {
  TokenLoader._();

  /// Parses a hex color string to [Color].
  ///
  /// Supports formats:
  /// - `#RRGGBB` (6-digit, fully opaque, alpha = 0xFF)
  /// - `#AARRGGBB` (8-digit, with alpha channel)
  ///
  /// Returns null if [hex] is null.
  static Color? parseColor(dynamic hex) {
    if (hex == null) return null;
    if (hex is! String) return null;
    var h = hex.startsWith('#') ? hex.substring(1) : hex;
    if (h.length == 6) {
      h = 'FF$h'; // default fully opaque
    } else if (h.length != 8) {
      throw FormatException('Invalid hex color format: $hex');
    }
    final value = int.tryParse(h, radix: 16);
    if (value == null) {
      throw FormatException('Invalid hex color value: $hex');
    }
    return Color(value);
  }

  /// Parses a font weight string to [FontWeight].
  ///
  /// Mapping rules:
  /// - `normal` → [FontWeight.w400]
  /// - `bold` → [FontWeight.w700]
  /// - `w100` ~ `w900` → corresponding [FontWeight]
  static FontWeight parseFontWeight(dynamic value) {
    if (value is! String) return FontWeight.normal;
    return switch (value) {
      'normal' => FontWeight.w400,
      'bold' => FontWeight.w700,
      'w100' => FontWeight.w100,
      'w200' => FontWeight.w200,
      'w300' => FontWeight.w300,
      'w400' => FontWeight.w400,
      'w500' => FontWeight.w500,
      'w600' => FontWeight.w600,
      'w700' => FontWeight.w700,
      'w800' => FontWeight.w800,
      'w900' => FontWeight.w900,
      _ => throw FormatException('Unknown fontWeight value: $value'),
    };
  }
}
