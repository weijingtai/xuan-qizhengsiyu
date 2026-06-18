import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ChartSemanticColors {
  final Color ringStroke;
  final Color divider;
  final Color border;
  final Color shadow;
  final Color scaleTick;
  final Color scaleTickAccent;
  final Color labelDefault;
  final Color labelMuted;
  final Color annotationYin;
  final Color annotationSu;
  final Color sectorBorder;
  final Color northLine;

  const ChartSemanticColors({
    required this.ringStroke,
    required this.divider,
    required this.border,
    required this.shadow,
    required this.scaleTick,
    required this.scaleTickAccent,
    required this.labelDefault,
    required this.labelMuted,
    required this.annotationYin,
    required this.annotationSu,
    required this.sectorBorder,
    required this.northLine,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartSemanticColors &&
          ringStroke == other.ringStroke &&
          divider == other.divider &&
          border == other.border &&
          shadow == other.shadow &&
          scaleTick == other.scaleTick &&
          scaleTickAccent == other.scaleTickAccent &&
          labelDefault == other.labelDefault &&
          labelMuted == other.labelMuted &&
          annotationYin == other.annotationYin &&
          annotationSu == other.annotationSu &&
          sectorBorder == other.sectorBorder &&
          northLine == other.northLine;

  @override
  int get hashCode => Object.hash(
        ringStroke,
        divider,
        border,
        shadow,
        scaleTick,
        scaleTickAccent,
        labelDefault,
        labelMuted,
        annotationYin,
        annotationSu,
        sectorBorder,
        northLine,
      );

  ChartSemanticColors copyWith({
    Color? ringStroke,
    Color? divider,
    Color? border,
    Color? shadow,
    Color? scaleTick,
    Color? scaleTickAccent,
    Color? labelDefault,
    Color? labelMuted,
    Color? annotationYin,
    Color? annotationSu,
    Color? sectorBorder,
    Color? northLine,
  }) {
    return ChartSemanticColors(
      ringStroke: ringStroke ?? this.ringStroke,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      scaleTick: scaleTick ?? this.scaleTick,
      scaleTickAccent: scaleTickAccent ?? this.scaleTickAccent,
      labelDefault: labelDefault ?? this.labelDefault,
      labelMuted: labelMuted ?? this.labelMuted,
      annotationYin: annotationYin ?? this.annotationYin,
      annotationSu: annotationSu ?? this.annotationSu,
      sectorBorder: sectorBorder ?? this.sectorBorder,
      northLine: northLine ?? this.northLine,
    );
  }

  static ChartSemanticColors fallback() => const ChartSemanticColors(
        ringStroke: Colors.black,
        divider: Colors.black87,
        border: Colors.grey,
        shadow: Colors.black38,
        scaleTick: Colors.black87,
        scaleTickAccent: Colors.blueAccent,
        labelDefault: Colors.black,
        labelMuted: Colors.black45,
        annotationYin: Colors.black45,
        annotationSu: Colors.red,
        sectorBorder: Colors.black12,
        northLine: Colors.red,
      );
}

class ChartTypographyRole {
  final String family;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;

  const ChartTypographyRole({
    required this.family,
    required this.fontSize,
    required this.fontWeight,
    required this.height,
  });

  TextStyle toTextStyle({Color? color, List<BoxShadow>? shadows}) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      shadows: shadows,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartTypographyRole &&
          family == other.family &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          height == other.height;

  @override
  int get hashCode => Object.hash(family, fontSize, fontWeight, height);

  ChartTypographyRole copyWith({
    String? family,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return ChartTypographyRole(
      family: family ?? this.family,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      height: height ?? this.height,
    );
  }
}

class ChartTypography {
  final ChartTypographyRole constellationName;
  final ChartTypographyRole starName;
  final ChartTypographyRole gongName;
  final ChartTypographyRole degree;
  final ChartTypographyRole yearMonth;
  final ChartTypographyRole shenSha;

  const ChartTypography({
    required this.constellationName,
    required this.starName,
    required this.gongName,
    required this.degree,
    required this.yearMonth,
    required this.shenSha,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartTypography &&
          constellationName == other.constellationName &&
          starName == other.starName &&
          gongName == other.gongName &&
          degree == other.degree &&
          yearMonth == other.yearMonth &&
          shenSha == other.shenSha;

  @override
  int get hashCode => Object.hash(
        constellationName,
        starName,
        gongName,
        degree,
        yearMonth,
        shenSha,
      );

  ChartTypography copyWith({
    ChartTypographyRole? constellationName,
    ChartTypographyRole? starName,
    ChartTypographyRole? gongName,
    ChartTypographyRole? degree,
    ChartTypographyRole? yearMonth,
    ChartTypographyRole? shenSha,
  }) {
    return ChartTypography(
      constellationName: constellationName ?? this.constellationName,
      starName: starName ?? this.starName,
      gongName: gongName ?? this.gongName,
      degree: degree ?? this.degree,
      yearMonth: yearMonth ?? this.yearMonth,
      shenSha: shenSha ?? this.shenSha,
    );
  }

  static ChartTypography fallback() => const ChartTypography(
        constellationName: ChartTypographyRole(
          family: 'MaShanZheng',
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          height: 1.0,
        ),
        starName: ChartTypographyRole(
          family: 'NotoSansSC',
          fontSize: 24.0,
          fontWeight: FontWeight.normal,
          height: 1.0,
        ),
        gongName: ChartTypographyRole(
          family: 'NotoSansSC',
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          height: 1.2,
        ),
        degree: ChartTypographyRole(
          family: 'NotoSansSC',
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
        yearMonth: ChartTypographyRole(
          family: 'NotoSansSC',
          fontSize: 10.0,
          fontWeight: FontWeight.normal,
          height: 1.0,
        ),
        shenSha: ChartTypographyRole(
          family: 'NotoSansSC',
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          height: 1.0,
        ),
      );
}

class ChartGeometry {
  final double ringStrokeWidth;
  final double tickLength;
  final double longTickLength;
  final double innerPadding;
  final double outerPadding;
  final double guideDotRadius;
  final double starHolderRadius;

  const ChartGeometry({
    required this.ringStrokeWidth,
    required this.tickLength,
    required this.longTickLength,
    required this.innerPadding,
    required this.outerPadding,
    required this.guideDotRadius,
    required this.starHolderRadius,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartGeometry &&
          ringStrokeWidth == other.ringStrokeWidth &&
          tickLength == other.tickLength &&
          longTickLength == other.longTickLength &&
          innerPadding == other.innerPadding &&
          outerPadding == other.outerPadding &&
          guideDotRadius == other.guideDotRadius &&
          starHolderRadius == other.starHolderRadius;

  @override
  int get hashCode => Object.hash(
        ringStrokeWidth,
        tickLength,
        longTickLength,
        innerPadding,
        outerPadding,
        guideDotRadius,
        starHolderRadius,
      );

  ChartGeometry copyWith({
    double? ringStrokeWidth,
    double? tickLength,
    double? longTickLength,
    double? innerPadding,
    double? outerPadding,
    double? guideDotRadius,
    double? starHolderRadius,
  }) {
    return ChartGeometry(
      ringStrokeWidth: ringStrokeWidth ?? this.ringStrokeWidth,
      tickLength: tickLength ?? this.tickLength,
      longTickLength: longTickLength ?? this.longTickLength,
      innerPadding: innerPadding ?? this.innerPadding,
      outerPadding: outerPadding ?? this.outerPadding,
      guideDotRadius: guideDotRadius ?? this.guideDotRadius,
      starHolderRadius: starHolderRadius ?? this.starHolderRadius,
    );
  }

  static ChartGeometry fallback() => const ChartGeometry(
        ringStrokeWidth: 0.5,
        tickLength: 5.0,
        longTickLength: 10.0,
        innerPadding: 12.0,
        outerPadding: 12.0,
        guideDotRadius: 2.0,
        starHolderRadius: 6.0,
      );
}

class QiZhengChartStyle {
  final ChartSemanticColors colors;
  final ChartTypography typography;
  final ChartGeometry geometry;
  final Brightness brightness;

  const QiZhengChartStyle({
    required this.colors,
    required this.typography,
    required this.geometry,
    this.brightness = Brightness.light,
  });

  QiZhengChartStyle copyWith({
    ChartSemanticColors? colors,
    ChartTypography? typography,
    ChartGeometry? geometry,
    Brightness? brightness,
  }) {
    return QiZhengChartStyle(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      geometry: geometry ?? this.geometry,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QiZhengChartStyle &&
          colors == other.colors &&
          typography == other.typography &&
          geometry == other.geometry &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(colors, typography, geometry, brightness);

  static QiZhengChartStyle fallback({Brightness brightness = Brightness.light}) {
    return QiZhengChartStyle(
      colors: ChartSemanticColors.fallback(),
      typography: ChartTypography.fallback(),
      geometry: ChartGeometry.fallback(),
      brightness: brightness,
    );
  }
}
