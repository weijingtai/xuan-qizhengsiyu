import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';
import 'package:tuple/tuple.dart';

import '../../../domain/entities/models/body_life_model.dart';
import 'circle_text_painter.dart';

/// 身命圆环显示组件
class BodyLifeCircleWidget extends StatelessWidget {
  /// 组件尺寸
  final double itemSize;

  /// 身命模型数据
  final BodyLifeModel bodyLifeModel;

  /// 文本样式
  final TextStyle? textStyle;

  /// 星体文本样式
  final TextStyle? starTextStyle;

  /// 圆环颜色
  final Color? ringColor;

  /// 外半径
  final double? outerRadius;

  /// 内半径
  final double? innerRadius;

  /// 边框颜色
  final Color? borderColor;

  /// 起始角度
  final double? startAngle;

  /// 扫描弧度
  final double? sweepRadian;

  const BodyLifeCircleWidget({
    Key? key,
    this.itemSize = 80,
    required this.bodyLifeModel,
    this.textStyle,
    this.starTextStyle,
    this.ringColor,
    this.outerRadius,
    this.innerRadius,
    this.borderColor,
    this.startAngle,
    this.sweepRadian,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = textStyle ??
        const TextStyle(
            fontSize: 14,
            height: 1,
            color: Colors.black54,
            fontWeight: FontWeight.w400);

    final defaultStarTextStyle = starTextStyle ??
        defaultTextStyle.copyWith(fontWeight: FontWeight.bold, shadows: const [
          Shadow(
            color: Colors.grey,
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
        ]);

    Tuple2<String, String?> lifeGongTuple =
        _toStringDegree(bodyLifeModel.lifeGongInfo.degree);
    Tuple2<String, String?> lifeConstellationTuple =
        _toStringDegree(bodyLifeModel.lifeConstellationInfo.degree);
    Tuple2<String, String?> bodyConstellationTuple =
        _toStringDegree(bodyLifeModel.bodyConstellationInfo.degree);
    Tuple2<String, String?> bodyGongTuple =
        _toStringDegree(bodyLifeModel.bodyGongInfo.degree);

    return SizedBox(
        width: itemSize,
        height: itemSize,
        child: CustomMultiChildLayout(
          delegate: _BodyLifeLayoutDelegate(
            itemCount: 1,
            radius: 0, // 所有子项都从中心开始布局
            itemSize: itemSize,
          ),
          children: [
            LayoutId(
                id: 0,
                child: SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: Transform.rotate(
                      angle: 0,
                      child: CustomPaint(
                        size: Size(itemSize, itemSize),
                        painter: CircleTextPainter(
                            startAngle: startAngle ?? (30 + 30 + 30),
                            sweepRadian:
                                sweepRadian ?? ((3 * 30) * math.pi / 180),
                            color: ringColor ?? Colors.blue,
                            outerRadius: outerRadius ?? itemSize,
                            innerRadius: innerRadius ?? (itemSize - 20),
                            borderColor: borderColor ?? Colors.black12,
                            gongYearsMapper: {
                              EnumTwelveGong.Yin: [
                                Text("身", style: defaultTextStyle),
                                Text("主", style: defaultTextStyle),
                                Text(
                                    bodyLifeModel
                                        .bodyGong.sevenZheng.singleName,
                                    style: defaultStarTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .bodyGong.sevenZheng])),
                                Text(bodyLifeModel.bodyGong.name,
                                    style: defaultTextStyle),
                                Text(bodyGongTuple.item1,
                                    style: defaultTextStyle),
                                if (bodyGongTuple.item2 != null)
                                  Text(bodyGongTuple.item2!,
                                      style: defaultTextStyle),
                              ],
                              EnumTwelveGong.Si: [
                                Text("命", style: defaultTextStyle),
                                Text("主", style: defaultTextStyle),
                                Text(
                                    bodyLifeModel
                                        .lifeGong.sevenZheng.singleName,
                                    style: defaultStarTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .lifeGong.sevenZheng])),
                                Text(bodyLifeModel.lifeGong.name,
                                    style: defaultTextStyle),
                                Text(lifeGongTuple.item1,
                                    style: defaultTextStyle),
                                if (lifeGongTuple.item2 != null)
                                  Text(lifeGongTuple.item2!,
                                      style: defaultTextStyle),
                              ],
                              EnumTwelveGong.Shen: [
                                Text("命", style: defaultTextStyle),
                                Text("度", style: defaultTextStyle),
                                Text(
                                    bodyLifeModel.lifeConstellatioin.sevenZheng
                                        .singleName,
                                    style: defaultStarTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.lifeConstellatioin
                                                .sevenZheng])),
                                Text(bodyLifeModel.lifeConstellatioin.name,
                                    style: defaultTextStyle),
                                Text(lifeConstellationTuple.item1,
                                    style: defaultTextStyle),
                                if (lifeConstellationTuple.item2 != null)
                                  Text(lifeConstellationTuple.item2!,
                                      style: defaultTextStyle),
                              ],
                              EnumTwelveGong.Hai: [
                                Text("身", style: defaultTextStyle),
                                Text("度", style: defaultTextStyle),
                                Text(
                                    bodyLifeModel.bodyConstellation.sevenZheng
                                        .singleName,
                                    style: defaultStarTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.bodyConstellation
                                                .sevenZheng])),
                                Text(bodyLifeModel.bodyConstellation.name,
                                    style: defaultTextStyle),
                                Text(bodyConstellationTuple.item1,
                                    style: defaultTextStyle),
                                if (bodyConstellationTuple.item2 != null)
                                  Text(bodyConstellationTuple.item2!,
                                      style: defaultTextStyle),
                              ],
                            },
                            textStyle: const TextStyle(
                                height: 1, color: Colors.black87, fontSize: 16),
                            gongOrderedSeq: [
                              EnumTwelveGong.Yin,
                              EnumTwelveGong.Si,
                              EnumTwelveGong.Shen,
                              EnumTwelveGong.Hai,
                            ]),
                      )),
                )),
          ],
        ));
  }

  /// 将度数转换为字符串格式
  Tuple2<String, String?> _toStringDegree(double degree) {
    var degreeString = degree.toString();
    List<String> parts = degreeString.split(".");
    var firstPart = parts[0];
    String? secondPart;

    if (parts.length > 1) {
      firstPart = parts[0] + ".";
      secondPart = parts[1] + "°";
      return Tuple2(firstPart, secondPart);
    } else {
      firstPart = parts[0] + "°";
      return Tuple2(firstPart, null);
    }
  }
}

/// 身命圆环布局代理
class _BodyLifeLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _BodyLifeLayoutDelegate({
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
  bool shouldRelayout(covariant _BodyLifeLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}
