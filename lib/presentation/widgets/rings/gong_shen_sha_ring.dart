import 'dart:math' as math;

import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/shen_sha_item.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:tuple/tuple.dart';

import '../../../domain/entities/models/naming_degree_pair.dart';
import 'enum_ring_text_direction.dart';
import 'sector_painter.dart';

class _CenterLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;

  _CenterLayoutDelegate({required this.itemCount});

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (hasChild(i)) {
        final childSize = layoutChild(i, BoxConstraints.loose(size));
        positionChild(
          i,
          Offset(
              center.dx - childSize.width / 2, center.dy - childSize.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRelayout(_CenterLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount;
}

class AllShenShaRing extends StatelessWidget {
  final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper;
  final double outerRadius;
  final double innerRadius;
  final RingTextDirection shaTextDirection;

  final List<EnumTwelveGong> gongOrder;
  final ZhouTianModel zhouTianModel;

  const AllShenShaRing({
    super.key,
    required this.shenShaMapper,
    required this.outerRadius,
    required this.innerRadius,
    required this.gongOrder,
    required this.zhouTianModel,
    this.shaTextDirection = RingTextDirection.gravity,
  });

  @override
  Widget build(BuildContext context) {
    final double itemSize = outerRadius * 2;
    final List<GongDegree> gongs = zhouTianModel.gongDegreeSeq;
    final List<double> cumulativeAngles = [];
    double cumulativeAngle = 0;
    for (int i = 0; i < gongs.length; i++) {
      cumulativeAngles.add(cumulativeAngle);
      cumulativeAngle += gongs[i].degree;
    }
    double baseGongAngleOffset = 2 * 30; // This might also need to be dynamic based on zeroPoint

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: CustomMultiChildLayout(
        delegate: _CenterLayoutDelegate(itemCount: gongs.length),
        children: [
          for (int i = 0; i < gongs.length; i++)
            LayoutId(
              id: i,
              child: Transform.rotate(
                angle: (cumulativeAngles[i] + baseGongAngleOffset) * math.pi / 180,
                child: CustomPaint(
                  size: Size(itemSize, itemSize),
                  painter: SectorPainter(
                    startAngle: 0,
                    sweepRadian: gongs[i].degree * math.pi / 180,
                    color: Colors.transparent,
                    outerRadius: outerRadius,
                    innerRadius: innerRadius,
                    borderColor: Colors.black12,
                  ),
                  child: GongShenShaRing(
                    outerRadius: outerRadius,
                    innerRadius: innerRadius,
                    gongAngleOffset: 0,
                    textGongAngleOffset: cumulativeAngles[i] + baseGongAngleOffset,
                    shenShaList: shenShaMapper[gongs[i].gong] ?? [],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 宫位神煞环组件
/// 用于显示十二宫位中的神煞信息
class GongShenShaRing extends StatelessWidget {
  /// 宫位与神煞列表的映射
  final List<ShenSha> shenShaList;

  /// 整个圆环的外半径
  final double outerRadius;

  /// 整个圆环的内半径
  final double innerRadius;

  /// 中间半径，用于分隔内外神煞
  late final double middleRadius;
  final double gongAngleOffset;
  final double textGongAngleOffset;
  late final bool isOdd;
  late final int halfCount;

  // /// 每个神煞的角度偏移量（度数）
  // final double angleOffset;

  late final double outerAngleOffset;
  late final double outerSweepRadians;

  late final double innerAngleOffset;
  late final double innerSweepRadians;

  /// 构造函数
  GongShenShaRing({
    super.key,
    required this.shenShaList,
    required this.outerRadius,
    required this.innerRadius,
    required this.gongAngleOffset,
    required this.textGongAngleOffset,
    // required this.angleOffset,
  }) {
    assert(outerRadius > innerRadius && innerRadius >= 0);
    middleRadius = innerRadius + (outerRadius - innerRadius) / 2;
    isOdd = shenShaList.length % 2 != 0;
    halfCount = (shenShaList.length % 2 != 0)
        ? shenShaList.length ~/ 2 + 1
        : shenShaList.length ~/ 2;
    int totalShenShaForOuterRadius =
        isOdd ? shenShaList.length ~/ 2 + 1 : shenShaList.length ~/ 2;
    outerAngleOffset = 30 / totalShenShaForOuterRadius;
    outerSweepRadians = outerAngleOffset * math.pi / 180;

    int totalShenShaForInnerRadius =
        shenShaList.length - totalShenShaForOuterRadius;
    innerAngleOffset = 30 / totalShenShaForInnerRadius;
    innerSweepRadians = innerAngleOffset * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    // 收集所有神煞
    // 每个item占据的空间是外半径的两倍
    final double itemSize = outerRadius * 2;
    // 将角度转换为弧度
    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: CustomMultiChildLayout(
        delegate: _ShenShaLayoutDelegate(
          itemCount: shenShaList.length,
          radius: 0, // 所有子项都从中心开始布局
          itemSize: itemSize,
        ),
        children: [
          for (int i = 0; i < shenShaList.length; i++)
            eachShenShaItem(
              j: i,
              shenShaIdRange: Tuple2(0, shenShaList.length),
              shenShaList: shenShaList,
              gongAngleOffset: gongAngleOffset,
              itemSize: itemSize,
            ),
        ],
      ),
    );
  }

  Widget eachShenShaItem({
    required int j,
    required Tuple2<int, int> shenShaIdRange,
    required List<ShenSha> shenShaList,
    required double gongAngleOffset,
    required double itemSize,
  }) {
    // print(j);
    // 奇数

    // 确定内外神煞的分界点
    // final int halfCount =
    // isOdd ? shenShaList.length ~/ 2 + 1 : shenShaList.length ~/ 2;

    bool isInner = j >= halfCount;
    final _outerRadius = isInner ? middleRadius : outerRadius;
    final _innerRadius = isInner ? innerRadius : middleRadius;

    final angleOffset = isInner ? innerAngleOffset : outerAngleOffset;
    final sweepRadians = isInner ? innerSweepRadians : outerSweepRadians;
    final eachAngleOffset =
        isInner ? (j - halfCount) * angleOffset : j * angleOffset;
    final index = isInner ? j - halfCount + 1 : j;

    return LayoutId(
      id: shenShaIdRange.item1 + j,
      child: _ShenShaItem(
        shenSha: shenShaList[j],
        index: index,
        angleOffset: angleOffset,
        totalCount: shenShaList.length,
        outerRadius: _outerRadius,
        innerRadius: _innerRadius,
        itemSize: itemSize,
        textDirection: RingTextDirection.gravity,
        startAngle: (gongAngleOffset + eachAngleOffset) * math.pi / 180,
        sweepRadian: sweepRadians,
        // gongOffset: gongAngleOffset * math.pi / 180,
        gongOffset: textGongAngleOffset * math.pi / 180,
      ),
    );
  }

  /// 构建每个宫位的神煞列表
  List<Widget> buildEachGongShenSha({
    required EnumTwelveGong gong,
    // required double sweepRadian,
    required double itemSize,
    required List<ShenSha> shenShaList,
    required double gongAngleOffset,
    required Tuple2<int, int> shenShaIdRange,
  }) {
    // 奇数
    bool isOdd = shenShaList.length % 2 != 0;

    int totalShenShaForOuterRadius =
        isOdd ? shenShaList.length ~/ 2 + 1 : shenShaList.length ~/ 2;
    double outerAngleOffset = 30 / totalShenShaForOuterRadius;

    // angleOffset = 3;
    double outerSweepRadians = outerAngleOffset * math.pi / 180;

    int totalShenShaForInnerRadius =
        shenShaList.length - totalShenShaForOuterRadius;
    double innerAngleOffset = 30 / totalShenShaForInnerRadius;
    double innerSweepRadians = innerAngleOffset * math.pi / 180;

    final result = <Widget>[];
    double eachAngleOffset = 0;
    // 确定内外神煞的分界点
    final int halfCount =
        isOdd ? shenShaList.length ~/ 2 : shenShaList.length ~/ 2 - 1;

    for (var j = 0; j < shenShaList.length; j++) {
      // 确定神煞是在内圈还是外圈
      bool isInner = j > halfCount;
      final _outerRadius = isInner ? middleRadius : outerRadius;
      final _innerRadius = isInner ? innerRadius : middleRadius;

      final angleOffset = isInner ? innerAngleOffset : outerAngleOffset;
      final sweepRadians = isInner ? innerSweepRadians : outerSweepRadians;

      result.add(LayoutId(
        id: shenShaIdRange.item1 + j,
        child: _ShenShaItem(
          shenSha: shenShaList[j],
          index: isInner ? j - halfCount - 1 : j,
          angleOffset: angleOffset,
          totalCount: shenShaList.length,
          outerRadius: _outerRadius,
          innerRadius: _innerRadius,
          itemSize: itemSize,
          textDirection: RingTextDirection.gravity,
          startAngle: (gongAngleOffset + eachAngleOffset) * math.pi / 180,
          sweepRadian: sweepRadians,
          gongOffset: gongAngleOffset * math.pi / 180,
        ),
      ));

      // 计算下一个神煞的角度偏移
      if ((j + 1) > halfCount) {
        eachAngleOffset = (j - halfCount) * angleOffset;
      } else {
        eachAngleOffset = (j + 1) * angleOffset;
      }
    }
    return result;
  }

  double calculateInscribedCircleRadius(
      double outerRadius, int numberOfCircles) {
    // 参数校验
    assert(numberOfCircles > 0, "内切圆数量必须大于0");
    assert(outerRadius > 0, "外半径必须大于0");

    // 将角度转换为弧度
    final theta = 15.0 / numberOfCircles; // 半角分割
    final thetaRadians = theta * (math.pi / 180); // 角度转弧度

    // 应用公式计算半径[6,7](@ref)
    final numerator = outerRadius * math.sin(thetaRadians);
    final denominator = 1 + math.sin(thetaRadians);

    return numerator / denominator;
  }

  double calculateAngleOffset({
    required double outerRadius,
    required double middleRadius,
    required double innerRadius,
    required List<String> shenShaList,
  }) {
    int maxShenShaCount = shenShaList.length;

    // 计算内外圈的平均厚度
    double outerThickness = outerRadius - middleRadius;
    double innerThickness = middleRadius - innerRadius;
    double avgThickness = (outerThickness + innerThickness) / 2;

    // 计算每个宫位的扇区角度（度数）
    double sectorAngle = 30.0; // 12个宫位，每个30度

    // 计算文字所需的最小角度（根据文字大小和半径）
    // 假设每个汉字宽度约为14像素，高度约为16像素
    double charWidth = 14.0;
    double charHeight = 16.0;

    // 计算在平均半径处，一个汉字占据的角度
    double avgRadius = (outerRadius + innerRadius) / 2;
    double charAngle = math.atan2(charWidth, avgRadius) * 180 / math.pi;

    // 考虑到神煞名称的平均长度（假设为2个字）
    double avgNameLength = 2.0;
    double nameAngle = charAngle * avgNameLength;

    // 计算每半边（内圈或外圈）的最大神煞数
    int halfMaxCount = (maxShenShaCount / 2).ceil();

    // 计算合适的角度偏移
    // 我们希望所有神煞能在扇区内均匀分布，同时保持足够间距
    double idealOffset = sectorAngle / (halfMaxCount + 1);

    // 确保角度偏移不小于文字所需的最小角度
    double minOffset = nameAngle * 1.2; // 添加20%的间距

    // 返回合适的角度偏移，但不小于2度且不大于10度
    return math.max(2.0, math.min(10.0, math.max(idealOffset, minOffset)));
  }
}

/// 神煞项组件
class _ShenShaItem extends StatelessWidget {
  /// 神煞名称
  final ShenSha shenSha;

  /// 神煞在当前宫位中的索引
  final int index;

  /// 当前宫位中神煞的总数
  final int totalCount;

  /// 扇环的外半径
  final double outerRadius;

  /// 扇环的内半径
  final double innerRadius;

  /// 整个组件的尺寸
  final double itemSize;

  /// 文字朝向
  final RingTextDirection textDirection;

  /// 自定义起始角度（弧度）
  final double? startAngle;

  /// 自定义扫描角度（弧度）
  final double? sweepRadian;

  /// 每个神煞的角度偏移（度数）
  final double angleOffset;

  /// 宫位的角度偏移（弧度）
  final double gongOffset;

  const _ShenShaItem({
    required this.shenSha,
    required this.index,
    required this.totalCount,
    required this.outerRadius,
    required this.innerRadius,
    required this.itemSize,
    required this.textDirection,
    required this.angleOffset,
    required this.gongOffset,
    this.startAngle,
    this.sweepRadian,
  });

  /// 获取文字样式
  TextStyle getTextStyle() {
    return const TextStyle(
        fontSize: 16,
        height: 1.1,
        color: Colors.black87,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    // 使用自定义扫描角度，如果没有提供则使用默认计算方式
    final double actualSweepRadian = sweepRadian ?? (2 * math.pi / totalCount);
    final textStyle = getTextStyle();

    // 使用TextPainter来准确测量文字宽度和高度
    final textPainter = TextPainter(
      text: TextSpan(text: shenSha.name, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textBlockWidth = textPainter.width;
    final double textBlockHeight = textPainter.height;
    final double ringThickness = outerRadius - innerRadius;

    // 计算扇区的中心角度
    final double sectorCenterAngle = actualSweepRadian / 2;

    // 文字中心点到圆心的径向距离，取内外半径的中间
    final double radialPosition = innerRadius + ringThickness / 2;

    // 计算文字在扇区中心的位置
    final double offsetX = radialPosition * math.cos(sectorCenterAngle);
    final double offsetY = radialPosition * math.sin(sectorCenterAngle);

    // 扇区的整体旋转
    final double baseItemRotation =
        startAngle ?? (2 * math.pi * index / totalCount);

    // 文字自身的旋转
    final double textOrientationRotation = 0; // 文字朝向外侧
    final double finalAngleForText =
        -baseItemRotation + textOrientationRotation;

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: Transform.rotate(
        angle: baseItemRotation, // 每个扇环的整体旋转
        child: CustomPaint(
          size: Size(itemSize, itemSize),
          painter: SectorPainter(
            startAngle: 0,
            sweepRadian: actualSweepRadian,
            // color: Colors.blue[500]!.withAlpha(20 * (index + 1)),
            color: Colors.transparent,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            borderColor: Colors.transparent,
          ),
          child: _buildShenShaContent(offsetX, offsetY, textStyle),
        ),
      ),
    );
  }

  /// 构建神煞内容
  Widget _buildShenShaContent(
      double offsetX, double offsetY, TextStyle textStyle) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY), // 定位文字容器的中心
      child: Transform.rotate(
        // 文字容器旋转，使其垂直于径向方向
        angle: math.pi / 2 + math.atan2(offsetY, offsetX),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景指示条
            // Container(
            //   width: 4,
            //   height: 28,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(3),
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.redAccent.withOpacity(0.5),
            //         Colors.redAccent.withOpacity(0.4),
            //         Colors.redAccent.withOpacity(0.2),
            //         Colors.redAccent.withOpacity(0.1),
            //       ],
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //     ),
            //   ),
            // ),
            // // 文字容器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: shenSha.name
                    .split("")
                    .map((t) => Transform.rotate(
                          angle: _getTextRotationAngle(),
                          child: Text(
                            t,
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取文字旋转角度
  double _getTextRotationAngle() {
    switch (textDirection) {
      case RingTextDirection.center:
        return 0; // 文字指向圆环中心
      case RingTextDirection.outer:
        return math.pi; // 文字指向圆环外侧
      case RingTextDirection.gravity:
        // 文字垂直于半径，考虑宫位偏移
        return -(index * angleOffset + 90) * (math.pi / 180) - gongOffset;
    }
  }
}

/// 神煞布局代理
class _ShenShaLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _ShenShaLayoutDelegate({
    required this.itemCount,
    required this.radius,
    required this.itemSize,
  });

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (!hasChild(i)) continue;

      final childSize =
          layoutChild(i, BoxConstraints.tight(Size(itemSize, itemSize)));
      // 所有子项都放置在中心点
      positionChild(
        i,
        Offset(
            center.dx - childSize.width / 2, center.dy - childSize.height / 2),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _ShenShaLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}

/// 神煞布局代理
class _ShenShaGongLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _ShenShaGongLayoutDelegate({
    required this.itemCount,
    required this.radius,
    required this.itemSize,
  });

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (!hasChild(i)) continue;

      final childSize =
          layoutChild(i, BoxConstraints.tight(Size(itemSize, itemSize)));
      // 所有子项都放置在中心点
      positionChild(
        i,
        Offset(
            center.dx - childSize.width / 2, center.dy - childSize.height / 2),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _ShenShaGongLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}

class GongLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  GongLayoutDelegate({
    required this.itemCount,
    required this.radius,
    required this.itemSize,
  });

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (!hasChild(i)) continue;

      final childSize =
          layoutChild(i, BoxConstraints.tight(Size(itemSize, itemSize)));
      // 所有子项都放置在中心点
      positionChild(
        i,
        Offset(
            center.dx - childSize.width / 2, center.dy - childSize.height / 2),
      );
    }
  }

  @override
  bool shouldRelayout(covariant GongLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}
