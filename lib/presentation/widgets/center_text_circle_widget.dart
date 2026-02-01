import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/circle_text_painter.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';
import 'package:tuple/tuple.dart';

/// 命盘中心文本环组件
/// 用于显示安身立命、身度主命度主信息的圆形布局
class CenterTextCircleWidget extends StatelessWidget {
  final BodyLifeModel bodyLifeModel;
  final double size;
  double get _size => size * 0.5;

  const CenterTextCircleWidget({
    super.key,
    required this.bodyLifeModel,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
        fontSize: 14,
        height: 1,
        color: Colors.black54,
        fontWeight: FontWeight.w400);
    TextStyle starTextStyle =
        textStyle.copyWith(fontWeight: FontWeight.bold, shadows: const [
      Shadow(
        color: Colors.grey,
        offset: Offset(1, 1),
        blurRadius: 1,
      ),
    ]);

    Tuple2<String, String?> lifeGongTuple =
        _toStringDegree(bodyLifeModel.lifeDegree);
    Tuple2<String, String?> lifeConstellationTuple =
        _toStringDegree(bodyLifeModel.lifeConstellationDegree);

    Tuple2<String, String?> bodyConstellationTuple =
        _toStringDegree(bodyLifeModel.bodyConstellationDegree);
    Tuple2<String, String?> bodyGongTuple =
        _toStringDegree(bodyLifeModel.bodyGongDegree);

    return SizedBox(
        width: _size,
        height: _size,
        child: CustomMultiChildLayout(
          delegate: _CenterTextLayoutDelegate(
            itemCount: 1,
            radius: 0, // 所有子项都从中心开始布局
            itemSize: _size,
          ),
          children: [
            LayoutId(
                id: 0,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: Transform.rotate(
                      angle: 0,
                      child: CustomPaint(
                        size: Size(_size, _size),
                        painter: CircleTextPainter(
                            startAngle: 30 + 30 + 30,
                            // sweepRadian: 2 * math.pi,
                            sweepRadian: (3 * 30) * math.pi / 180,
                            color: Colors.blue,
                            outerRadius: _size,
                            innerRadius: _size - 20,
                            borderColor: Colors.black12,
                            gongYearsMapper: {
                              // 身主信息 - 寅宫
                              EnumTwelveGong.Yin: [
                                Text("身", style: textStyle),
                                Text("主", style: textStyle),
                                Text(
                                    bodyLifeModel
                                        .bodyGong.sevenZheng.singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .bodyGong.sevenZheng])),
                                Text(bodyLifeModel.bodyGong.name,
                                    style: textStyle),
                                Text(bodyGongTuple.item1, style: textStyle),
                                if (bodyGongTuple.item2 != null)
                                  Text(bodyGongTuple.item2!, style: textStyle),
                              ],
                              // 命主信息 - 巳宫
                              EnumTwelveGong.Si: [
                                Text("命", style: textStyle),
                                Text("主", style: textStyle),
                                Text(
                                    bodyLifeModel
                                        .lifeGong.sevenZheng.singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .lifeGong.sevenZheng])),
                                Text(bodyLifeModel.lifeGong.name,
                                    style: textStyle),
                                Text(lifeGongTuple.item1, style: textStyle),
                                if (lifeGongTuple.item2 != null)
                                  Text(lifeGongTuple.item2!, style: textStyle),
                              ],
                              // 命度信息 - 申宫
                              EnumTwelveGong.Shen: [
                                Text("命", style: textStyle),
                                Text("度", style: textStyle),
                                Text(
                                    bodyLifeModel.lifeConstellatioin.sevenZheng
                                        .singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.lifeConstellatioin
                                                .sevenZheng])),
                                Text(bodyLifeModel.lifeConstellatioin.name,
                                    style: textStyle),
                                Text(lifeConstellationTuple.item1,
                                    style: textStyle),
                                if (lifeConstellationTuple.item2 != null)
                                  Text(lifeConstellationTuple.item2!,
                                      style: textStyle),
                              ],
                              // 身度信息 - 亥宫
                              EnumTwelveGong.Hai: [
                                Text("身", style: textStyle),
                                Text("度", style: textStyle),
                                Text(
                                    bodyLifeModel.bodyConstellation.sevenZheng
                                        .singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.bodyConstellation
                                                .sevenZheng])),
                                Text(bodyLifeModel.bodyConstellation.name,
                                    style: textStyle),
                                Text(bodyConstellationTuple.item1,
                                    style: textStyle),
                                if (bodyConstellationTuple.item2 != null)
                                  Text(bodyConstellationTuple.item2!,
                                      style: textStyle),
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
    var mingGongDegree = degree.toString();
    List<String> _tmpList = mingGongDegree.split(".");
    var mingGongDegreeFirstPart = _tmpList[0];
    String? mingGongDegreeSecondPar;
    if (_tmpList.length > 1) {
      mingGongDegreeFirstPart = _tmpList[0] + ".";
      mingGongDegreeSecondPar = _tmpList[1] + "°";
      return Tuple2(mingGongDegreeFirstPart, mingGongDegreeSecondPar);
    } else {
      mingGongDegreeFirstPart = _tmpList[0] + "°";
      return Tuple2(mingGongDegreeFirstPart, null);
    }
  }
}

/// 中心文本环布局代理
class _CenterTextLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _CenterTextLayoutDelegate({
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
  bool shouldRelayout(covariant _CenterTextLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}
