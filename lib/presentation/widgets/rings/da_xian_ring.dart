import 'dart:io';
import 'dart:math' as math;

import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:tuple/tuple.dart';

import 'enum_ring_text_direction.dart';
import 'sector_painter.dart';
import 'da_xian_ring_painter.dart';

class DaXianRing extends StatelessWidget {
  // final Map<EnumTwelveGong, double> gongYearsMapper;
  final double outerRadius;
  final double innerRadius;
  final RingTextDirection shaTextDirection;
  final double baseGongOffsetAngle;

  final List<EnumTwelveGong> gongOrderSeq;
  Map<EnumTwelveGong, YearMonth> gongYearsMapper;
  DaXianRing({
    super.key,
    required this.gongYearsMapper,
    required this.outerRadius,
    required this.innerRadius,
    required this.baseGongOffsetAngle,
    this.shaTextDirection = RingTextDirection.gravity,
    this.gongOrderSeq = EnumTwelveGong.values,
  });

  @override
  Widget build(BuildContext context) {
    // 收集所有神煞

    // 每个item占据的空间是外半径的两倍
    final double itemSize = outerRadius * 2;

    // double totalSlot = gongYearsMapper.values.reduce((a, b) => a + b);
    // double eachSlotAngle = 360 / totalSlot;
    // double sweepRadians = eachSlotAngle * math.pi / 180;
    double middelRadius = innerRadius + (outerRadius - innerRadius) / 2;

    // 将角度转换为弧度
    Border gongBorder = const Border(
        left: BorderSide(color: Colors.black, width: 1),
        top: BorderSide.none,
        bottom: BorderSide(color: Colors.black, width: 1),
        right: BorderSide.none);
    Border slotBorder = const Border(
        left: BorderSide(color: Colors.black12, width: 1),
        top: BorderSide.none,
        bottom: BorderSide.none,
        right: BorderSide.none);

    TextStyle textStyle =
        const TextStyle(height: 1, color: Colors.black54, fontSize: 10);

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: CustomMultiChildLayout(
        delegate: _DongWeiLayoutDelegate(
          itemCount: 3,
          radius: 0, // 所有子项都从中心开始布局
          itemSize: itemSize,
        ),
        children: [
          // for (int i = 0; i < 1; i++)
          LayoutId(
              id: 0,
              child: SizedBox(
                width: itemSize,
                height: itemSize,
                child: Transform.rotate(
                    angle: 0,
                    child: CustomPaint(
                      size: Size(itemSize, itemSize),
                      painter: DaXianRingPainter(
                          startAngle: 30 + 30,
                          // sweepRadian: 2 * math.pi,
                          sweepRadian: (3 * 30) * math.pi / 180,
                          color: Colors.blue,
                          outerRadius: outerRadius,
                          innerRadius: outerRadius - 16,
                          gongYearsMapper: gongYearsMapper,
                          startFromYear: YearMonth(0, 0),
                          gongBorder: const Border(
                              left: BorderSide(color: Colors.black, width: 1),
                              top: BorderSide.none,
                              bottom: BorderSide(color: Colors.black, width: 1),
                              right: BorderSide.none),
                          slotBorder: const Border(
                              left: BorderSide(color: Colors.black12, width: 1),
                              top: BorderSide.none,
                              bottom: BorderSide.none,
                              right: BorderSide.none),
                          textStyle: const TextStyle(
                              height: 1, color: Colors.black54, fontSize: 10),
                          gongOrderedSeq: EnumTwelveGong.listAll),
                    )),
              )),

          LayoutId(
              id: 1,
              child: SizedBox(
                width: itemSize,
                height: itemSize,
                child: Transform.rotate(
                    angle: 0,
                    child: CustomPaint(
                      size: Size(itemSize, itemSize),
                      painter: DaXianRingPainter(
                          startAngle: 30 + 30,
                          // sweepRadian: 2 * math.pi,
                          sweepRadian: (3 * 30) * math.pi / 180,
                          color: Colors.blue,
                          outerRadius: outerRadius - 16,
                          innerRadius: outerRadius - 16 - 16,
                          gongYearsMapper: daXian106,
                          startFromYear: YearMonth(0, 0),
                          gongBorder: gongBorder,
                          slotBorder: slotBorder,
                          textStyle: textStyle,
                          gongOrderedSeq: EnumTwelveGong.listAll),
                    )),
              )),
          // LayoutId(
          //     id: 2,
          //     child: SizedBox(
          //         width: itemSize,
          //         height: itemSize,
          //         child: Transform.rotate(
          //             angle: 0,
          //             child: Stack(
          //               alignment: Alignment.center,
          //               children: [
          //                 _InteractiveDot(
          //                     angle: 0,
          //                     itemSize: 6,
          //                     dotIndex: 0,
          //                     radius: itemSize

          //                     // width: 12,
          //                     // height: 12,
          //                     // decoration: BoxDecoration(
          //                     //   color: Colors.red,
          //                     //   borderRadius: BorderRadius.circular(12),
          //                     //   // border: Border.all(color: Colors.black, width: 1),
          //                     // ),
          //                     )
          //               ],
          //             ))
          //             )
          //             )
        ],
      ),
    );
  }

  // static Map<EnumTwelveGong, YearMonth> daXianDongWei = {
  //   // EnumTwelveGong.Zi: YearMonth(10, 2),
  //   // EnumTwelveGong.Chou: YearMonth(4, 0),
  //   EnumTwelveGong.Zi: YearMonth(10, 2),
  //   EnumTwelveGong.Chou: YearMonth(10, 0),
  //   EnumTwelveGong.Yin: YearMonth(11, 0),
  //   EnumTwelveGong.Mao: YearMonth.fromYear(15),
  //   EnumTwelveGong.Chen: YearMonth.fromYear(8),
  //   EnumTwelveGong.Si: YearMonth.fromYear(7),
  //   EnumTwelveGong.Wu: YearMonth.fromYear(11),
  //   EnumTwelveGong.Wei: YearMonth(4, 6),
  //   EnumTwelveGong.Shen: YearMonth(4, 6),
  //   EnumTwelveGong.You: YearMonth(4, 6),
  //   EnumTwelveGong.Xu: YearMonth.fromYear(5),
  //   EnumTwelveGong.Hai: YearMonth.fromYear(5),
  // };

  static Map<EnumTwelveGong, YearMonth> daXian106 = {
    EnumTwelveGong.Zi: YearMonth.fromYear(15),
    EnumTwelveGong.Chou: YearMonth.fromYear(10),
    EnumTwelveGong.Yin: YearMonth.fromYear(11),
    EnumTwelveGong.Mao: YearMonth.fromYear(15),
    EnumTwelveGong.Chen: YearMonth.fromYear(8),
    EnumTwelveGong.Si: YearMonth.fromYear(7),
    EnumTwelveGong.Wu: YearMonth.fromYear(11),
    EnumTwelveGong.Wei: YearMonth(4, 6),
    EnumTwelveGong.Shen: YearMonth(4, 6),
    EnumTwelveGong.You: YearMonth(4, 6),
    EnumTwelveGong.Xu: YearMonth.fromYear(5),
    EnumTwelveGong.Hai: YearMonth.fromYear(5),
  };

  Widget eachShenNumber(
      {required int i,
      required double itemSize,
      required double eachSlotAngle,
      required double sweepRadian}) {
    // 计算扇形的中心角度（相对于当前扇形的起始角度）
    final double sectorCenterAngle = sweepRadian / 2;

    // 扇环的中间半径位置
    final double middleRadius = innerRadius + (outerRadius - innerRadius) / 2;

    // Canvas的中心点
    final double canvasCenter = itemSize / 2;

    // 计算文字在扇环中心的位置
    final double offsetX = middleRadius * math.cos(sectorCenterAngle);
    final double offsetY = middleRadius * math.sin(sectorCenterAngle);

    return Transform.translate(
      offset: Offset(
        offsetX,
        offsetY,
      ),
      child: Transform.rotate(
        // angle: -(i * eachSlotAngle + baseGongOffsetAngle) * math.pi / 180,
        angle: 0,
        child: Text(
          i.toString(),
          style: TextStyle(height: 1, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// 宫位神煞环组件
/// 用于显示十二宫位中的神煞信息
//
/// 神煞项组件
/// 神煞布局代理
class _DongWeiLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _DongWeiLayoutDelegate({
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
  bool shouldRelayout(covariant _DongWeiLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}

/// 神煞布局代理
class _InteractiveDot extends StatefulWidget {
  final double angle; // 角度（度数）
  final double radius; // 距离中心的半径
  final double itemSize; // 容器大小
  final int dotIndex; // 点的索引

  const _InteractiveDot({
    required this.angle,
    required this.radius,
    required this.itemSize,
    required this.dotIndex,
  });

  @override
  State<_InteractiveDot> createState() => _InteractiveDotState();
}

class _InteractiveDotState extends State<_InteractiveDot>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算点的位置
    final double angleInRadians = widget.angle * math.pi / 180;
    final double centerX = widget.itemSize / 2;
    final double centerY = widget.itemSize / 2;
    final double dotX = centerX + widget.radius * math.cos(angleInRadians);
    final double dotY = centerY + widget.radius * math.sin(angleInRadians);

    return Positioned(
      // left: dotX - 6, // 点的半径为6，所以偏移6像素使其居中
      top: dotY + 8,
      // top: 0,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
          _animationController.forward();
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
          _animationController.reverse();
        },
        child: GestureDetector(
          onTap: () {
            // 点击事件处理
            logger.d('点击了第 ${widget.dotIndex + 1} 个点，角度: ${widget.angle}°');
            // 这里可以添加更多的点击处理逻辑
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isHovered ? Colors.red : Colors.blue,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isHovered
                      ? Icon(
                          Icons.star,
                          size: 8,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
