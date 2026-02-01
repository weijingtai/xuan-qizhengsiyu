import 'dart:math' as math;
import 'package:common/module.dart';

import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:tuple/tuple.dart';

import '../../../domain/entities/models/naming_degree_pair.dart';
import 'enum_ring_text_direction.dart';
import 'sector_painter.dart';

enum DiZhiTextLayoutStyle {
  // 字体排列在宫位的中心，呈一条线
  line,
  // 字体为宫位的中心，呈三角形
  triangle,
  antiTriangle,
}

/// 重构版本的十二地支宫位环组件
class Gong12DiZhiRing extends StatelessWidget {
  final Map<EnumTwelveGong, List<Text>> shenShaMapper;
  final double outerRadius;
  final double innerRadius;
  final RingTextDirection shaTextDirection;
  final DiZhiTextLayoutStyle textLayoutStyle;
  final bool isShi;
  final bool isXu;
  final double baseGongOffsetAngle;

  final ZhouTianModel? zhouTianModel;

  const Gong12DiZhiRing({
    super.key,
    required this.shenShaMapper,
    required this.outerRadius,
    required this.innerRadius,
    this.zhouTianModel,
    this.baseGongOffsetAngle = 60,
    this.shaTextDirection = RingTextDirection.gravity,
    this.textLayoutStyle = DiZhiTextLayoutStyle.triangle,
    this.isShi = true,
    this.isXu = true,
  });

  @override
  Widget build(BuildContext context) {
    final double itemSize = outerRadius * 2;
    final List<GongDegree> gongs = zhouTianModel?.gongDegreeSeq ??
        EnumTwelveGong.values
            .map((e) => GongDegree(gong: e, degree: 30))
            .toList();
    double cumulativeAngle = 0;

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < gongs.length; i++) ...[
            _buildGongSector(
              gong: gongs[i],
              shenShaList: shenShaMapper[gongs[i].gong]!,
              itemSize: itemSize,
              rotationAngle: cumulativeAngle,
              gongIndex: i,
            ),
            () {
              cumulativeAngle += gongs[i].degree;
              return const SizedBox.shrink();
            }(), // This is a trick to update the cumulativeAngle in a declarative way.
          ]
        ],
      ),
    );
  }

  /// 构建单个宫位扇区
  Widget _buildGongSector({
    required GongDegree gong,
    required List<Text> shenShaList,
    required double itemSize,
    required double rotationAngle,
    required int gongIndex,
  }) {
    final double rotationRadian =
        (rotationAngle + baseGongOffsetAngle) * math.pi / 180;

    return Transform.rotate(
      angle: rotationRadian,
      child: SizedBox(
        width: itemSize,
        height: itemSize,
        child: CustomPaint(
          size: Size(itemSize, itemSize),
          painter: SectorPainter(
            startAngle: 0,
            sweepRadian: gong.degree * math.pi / 180, // Use dynamic sweep angle
            color: Colors.transparent,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            borderColor: Colors.black12,
          ),
          child: ShenShaRingV2(
            shenShaList: shenShaList,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            gongIndex: gongIndex,
            textDirection: shaTextDirection,
            textLayoutStyle: textLayoutStyle,
            isShi: isShi,
            isXu: isXu,
            baseGongOffsetAngle: baseGongOffsetAngle,
          ),
        ),
      ),
    );
  }
}

/// 重构版本的神煞环组件
class ShenShaRingV2 extends StatelessWidget {
  final List<Text> shenShaList;
  final double outerRadius;
  final double innerRadius;
  final int gongIndex;
  final RingTextDirection textDirection;
  final DiZhiTextLayoutStyle textLayoutStyle;

  late final double middleRadius;
  late final ShenShaLayout layout;
  late final double baseGongOffsetRadian;

  // List<bool> shiXuList;
  final bool isShi;
  final bool isXu;

  ShenShaRingV2(
      {super.key,
      required this.shenShaList,
      required this.outerRadius,
      required this.innerRadius,
      required this.gongIndex,
      required this.textDirection,
      required this.textLayoutStyle,
      required this.isShi,
      required this.isXu,
      required double baseGongOffsetAngle}) {
    // middleRadius = innerRadius + (outerRadius - innerRadius) / 2;
    baseGongOffsetRadian = baseGongOffsetAngle * math.pi / 180;
    middleRadius = innerRadius + (outerRadius - innerRadius) / 2;
    layout = ShenShaLayout.calculate(shenShaList.length);
  }

  @override
  Widget build(BuildContext context) {
    final double itemSize = outerRadius * 2;

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // for (int i = 0; i < shenShaList.length + shiXuList.length; i++)
          //   i < shenShaList.length
          //       ? _buildShenShaItem(
          //           i,
          //           itemSize,
          //           shenShaList.length,
          //         )
          //       : _buildExtraSticky(i, shiXuList[i - shenShaList.length])
          for (int i = 0; i < shenShaList.length; i++)
            _buildShenShaItem(
              i,
              itemSize,
              shenShaList.length,
            ),
          if (isShi) _buildExtraSticky(0, true),
          if (isXu) _buildExtraSticky(1, true)
        ],
      ),
    );
  }

  Widget _buildExtraSticky(int index, bool apper) {
    double holderSize = 12;
    // 从中间开始计算，向外和内分别计算
    double radialPosition = outerRadius - holderSize * .6;
    double baseAngleOffset = 3.6;
    double angleOffset = (index == 0) ? baseAngleOffset : 30 - baseAngleOffset;
    double angle = angleOffset * math.pi / 180;
    // final double radialPosition = innerRadius + radius - innerRadius;

    final double x = radialPosition * math.cos(angle);
    final double y = radialPosition * math.sin(angle);
    final textOffset = Offset(x, y);
    final double textRotation = -(angleOffset + gongIndex * 30) * math.pi / 180;

    return Transform.translate(
        offset: textOffset,
        child: Transform.rotate(
            angle: (index == 0)
                ? textRotation +
                    -baseGongOffsetRadian +
                    baseAngleOffset * math.pi / 180
                : textRotation +
                    -baseGongOffsetRadian +
                    ((30 - baseAngleOffset) * math.pi / 180),
            // angle: textRotation,
            child: apper
                ? Container(
                    width: holderSize,
                    height: holderSize,
                    child: (index == 0)
                        ? Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                            size: holderSize,
                          )
                        : Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                            size: holderSize,
                          ),
                  )
                : SizedBox(
                    width: holderSize,
                    height: holderSize,
                  )));
  }

  /// 构建单个神煞项
  Widget _buildShenShaItem(
    int index,
    double itemSize,
    int totalCount,
  ) {
    final bool isInner = index >= layout.outerCount;
    ShenShaPosition position;

    switch (textLayoutStyle) {
      case DiZhiTextLayoutStyle.line:
        position = _calculateLineStylePosition(index, isInner, totalCount,
            shenShaList[index].style!, defaultFontSize);
        break;
      case DiZhiTextLayoutStyle.triangle:
        position = _calculateTriangleStylePosition(index, isInner, totalCount,
            shenShaList[index].style!, defaultFontSize);
      case DiZhiTextLayoutStyle.antiTriangle:
        position = _calculateAntiTriangleStylePosition(index, isInner,
            totalCount, shenShaList[index].style!, defaultFontSize);
    }

    return ShenShaItemV2(
      name: shenShaList[index],
      position: position,
      itemSize: itemSize,
      textDirection: textDirection,
      gongIndex: gongIndex,
      baseGongOffsetRadian: baseGongOffsetRadian,
    );
  }

  double defaultFontSize = 18;

  /// 计算神煞位置
  ShenShaPosition _calculateLineStylePosition(int index, bool isInner,
      int totalCount, TextStyle style, double defaultFontSize) {
    // 从中间开始计算，向外和内分别计算
    double radius = 0;
    double fontSize = style.fontSize ?? defaultFontSize;
    if (totalCount.isOdd) {
      if (index == 1) {
        radius = middleRadius - fontSize * .5;
      } else if (index == 2) {
        radius = middleRadius + fontSize * .5 + fontSize * .2;
      } else {
        radius = middleRadius - fontSize * .5 - fontSize * .2 - fontSize;
      }
    } else {
      if (index == 0) {
        radius = middleRadius - fontSize * .5 - fontSize;
      } else if (index == 1) {
        radius = middleRadius + fontSize * .5;
      }
    }

    // final double radius =
    //     innerRadius + (fontSize * 1.1) * index + fontSize * .5; // 每个神煞间隔32像素
    final double innerR = innerRadius;
    final int localIndex = isInner ? index - layout.outerCount : index;
    final int totalInLayer = isInner ? layout.innerCount : layout.outerCount;

    const double angleOffset = 30.0 * .5; // 使用总数而不是层数
    const double angle = angleOffset * math.pi / 180; // 所有神煞使用相同角度

    return ShenShaPosition(
      radius: radius,
      innerRadius: innerR,
      outerRadius: outerRadius,
      angle: angle, // 固定角度，确保垂直对齐
      layerIndex: index, // 使用全局索引
      isInner: isInner,
    );
  }

  ShenShaPosition _calculateAntiTriangleStylePosition(int index, bool isInner,
      int cout, TextStyle style, double defaultFontSize) {
    // 从中间开始计算，向外和内分别计算
    double radius = 0;
    double angle = 0;
    double currentInnerRadius = 0;
    if (index == 0) {
      // first text 为顶点
      currentInnerRadius = middleRadius + 4;
      radius = currentInnerRadius + 2;
      const double angleOffset = 30.0 * .5;
      angle = angleOffset * math.pi / 180;
      logger.d(
          '$innerRadius, $middleRadius, $outerRadius, radius: $radius, fontSize: ${style.fontSize}');
    } else {
      // 其余为三角形的另两个低角
      // 通过调整不同index的radius来避免重叠
      currentInnerRadius = innerRadius + 4;
      radius = currentInnerRadius + 2;
      logger.d(
          '$innerRadius, $middleRadius, $outerRadius, radius: $radius, fontSize: ${style.fontSize}');

      var angleOffset = 8;
      // 第一个低角为10度，其余为20度
      if (index == 2) {
        angleOffset = 30 - angleOffset; // 使用总数而不是层数
      }
      angle = angleOffset * math.pi / 180; // 所有神煞使用相同角度
    }

    // 计算可用的径向空间
    final double availableSpace = outerRadius - innerRadius;
    final double fontSize = style.fontSize ?? defaultFontSize;

    final double innerR = currentInnerRadius;

    return ShenShaPosition(
      radius: radius,
      innerRadius: innerR,
      outerRadius: outerRadius,
      angle: angle, // 固定角度，确保垂直对齐
      layerIndex: index, // 使用全局索引
      isInner: isInner,
    );
  }

  ShenShaPosition _calculateTriangleStylePosition(int index, bool isInner,
      int cout, TextStyle style, double defaultFontSize) {
    // 从中间开始计算，向外和内分别计算
    double radius = 0;
    double angle = 0;

    double currentInnerRadius = 0;
    if (index == 0) {
      // first text 为顶点
      // radius = middleRadius - (style.fontSize ?? defaultFontSize) * 1;
      currentInnerRadius = innerRadius + 4 + 2;
      radius = currentInnerRadius + 2;
      const double angleOffset = 30.0 * .5;
      angle = angleOffset * math.pi / 180;
    } else {
      // 其余为三角形的另两个低角
      // 通过调整不同index的radius来避免重叠
      currentInnerRadius = middleRadius + (outerRadius - innerRadius) * .1;
      radius = currentInnerRadius;
      var angleOffset = 0.0;
      // 第一个低角为10度，其余为20度
      if (index == 1) {
        angleOffset = 10; // 使用总数而不是层数
      } else {
        angleOffset = 20; // 使用总数而不是层数
      }

      angle = angleOffset * math.pi / 180; // 所有神煞使用相同角度
    }

    // 计算可用的径向空间
    // final double availableSpace = outerRadius - innerRadius;
    // final double fontSize = style.fontSize ?? defaultFontSize;

    // final double innerR = currentInnerRadius;
    return ShenShaPosition(
      radius: radius,
      innerRadius: currentInnerRadius,
      outerRadius: outerRadius,
      angle: angle, // 固定角度，确保垂直对齐
      layerIndex: index, // 使用全局索引
      isInner: isInner,
    );
  }
}

/// 重构版本的神煞项组件
class ShenShaItemV2 extends StatelessWidget {
  final Text name;
  final ShenShaPosition position;
  final double itemSize;
  final RingTextDirection textDirection;
  final int gongIndex;
  final double baseGongOffsetRadian;

  const ShenShaItemV2({
    super.key,
    required this.name,
    required this.position,
    required this.itemSize,
    required this.textDirection,
    required this.gongIndex,
    required this.baseGongOffsetRadian,
  });

  @override
  Widget build(BuildContext context) {
    // final TextStyle textStyle = _getTextStyle();
    final Offset textOffset = _calculateTextOffset();
    final double textRotation = _calculateTextRotation();

    return Transform.translate(
      offset: textOffset,
      child: Transform.rotate(
        angle: textRotation,
        child: _buildTextContainer(),
      ),
    );
  }

  /// 获取文字样式
  TextStyle _getTextStyle() {
    // final double ringThickness = position.radius - position.innerRadius;
    // double fontSize = ringThickness * 0.3;
    // fontSize = math.max(12, math.min(16, fontSize));

    double fontSize = 18;
    return TextStyle(
      fontSize: fontSize,
      height: 1,
      color: Colors.black87,
      shadows: const [
        Shadow(
          color: Colors.black26,
          offset: Offset(1, 1),
          blurRadius: 3,
        ),
      ],
    );
  }

  /// 计算文字偏移位置
  Offset _calculateTextOffset() {
    // 确保文字位置在扇环范围内
    final double maxRadius = position.innerRadius +
        (position.outerRadius - position.innerRadius) * 0.9; // 留10%边距
    final double minRadius = position.innerRadius +
        (position.outerRadius - position.innerRadius) * 0.1; // 留10%边距

    // 限制径向位置在有效范围内
    final double radialPosition =
        math.max(minRadius, math.min(maxRadius, position.radius));

    final double x = radialPosition * math.cos(position.angle);
    final double y = radialPosition * math.sin(position.angle);

    return Offset(x, y);
  }

  /// 计算文字旋转角度
  double _calculateTextRotation() {
    switch (textDirection) {
      case RingTextDirection.center:
        return position.angle + math.pi; // 指向圆心
      case RingTextDirection.outer:
        return position.angle; // 指向外侧
      case RingTextDirection.gravity:
        // 垂直于半径方向
        return position.angle + math.pi / 2 - baseGongOffsetRadian; // 垂直于半径方向;
    }
  }

  /// 构建文字容器
  Widget _buildTextContainer() {
    // 将文字按字符分割，垂直排列
    // final List<String> characters = name.split('');

    return Stack(
      alignment: Alignment.center,
      children: [
        // 文字容器 - 垂直排列
        Container(
            width: name.style!.fontSize,
            height: name.style!.fontSize, // 根据字符数调整高度
            alignment: Alignment.center,
            child: Transform.rotate(
                angle:
                    -position.angle - ((gongIndex * 30 + 90) * math.pi / 180),
                child: name)),
      ],
    );
  }
}

/// 神煞布局计算类
class ShenShaLayout {
  final int outerCount;
  final int innerCount;
  final int total;

  const ShenShaLayout({
    required this.outerCount,
    required this.innerCount,
    required this.total,
  });

  /// 计算神煞布局
  static ShenShaLayout calculate(int totalCount) {
    if (totalCount == 0) {
      return const ShenShaLayout(outerCount: 0, innerCount: 0, total: 0);
    }

    final bool isOdd = totalCount % 2 != 0;
    final int outerCount = isOdd ? totalCount ~/ 2 + 1 : totalCount ~/ 2;
    final int innerCount = totalCount - outerCount;

    return ShenShaLayout(
      outerCount: outerCount,
      innerCount: innerCount,
      total: totalCount,
    );
  }
}

/// 神煞位置信息类
class ShenShaPosition {
  final double radius;
  final double innerRadius;
  final double outerRadius;
  final double angle;
  final int layerIndex;
  final bool isInner;

  const ShenShaPosition({
    required this.radius,
    required this.innerRadius,
    required this.outerRadius,
    required this.angle,
    required this.layerIndex,
    required this.isInner,
  });
}
