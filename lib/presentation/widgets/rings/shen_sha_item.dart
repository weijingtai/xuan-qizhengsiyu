import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/sector_painter.dart';

import 'enum_ring_text_direction.dart';

class ShenShaItem extends StatelessWidget {
  final String name;
  final int index;
  final int totalCount;
  final double outerRadius;
  final double innerRadius;
  final double itemSize;
  final RingTextDirection shaTextDirection;

  const ShenShaItem({
    required this.name,
    required this.index,
    required this.totalCount,
    required this.outerRadius,
    required this.innerRadius,
    required this.itemSize,
    required this.shaTextDirection,
  });

  TextStyle getTextStyle() {
    return TextStyle(
      fontSize: 14,
      height: 1.2,
      color: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool toCenter = false;
    final double sweepRadian = 2 * math.pi / totalCount;
    // final characters = name.split(''); // 如果用单个Text，这个不需要了
    final textStyle = getTextStyle();
    // 使用TextPainter来准确测量文字宽度和高度
    final textPainter = TextPainter(
      text: TextSpan(text: name, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textBlockWidth = textPainter.width; // 文字横向排列的实际宽度
    final double textBlockHeight = textPainter.height; // 文字横向排列的实际高度

    final double ringThickness = outerRadius - innerRadius;

    // --- 修改开始：让文字平行于半径边 ---

    // 1. 文字容器的定位：
    // 我们希望文字“贴在”扇环的起始半径边上。
    // 扇环的起始半径在当前 _ShenShaItem 坐标系中是0度角方向。
    // 文字容器的中心点应该位于这条半径上，并且在内外半径之间。
    // 为了让文字看起来是“靠边”，我们将文字容器的一边（比如左边或右边）对齐到半径。

    // 文字中心点到圆心的径向距离，可以取内外半径的中间，或者根据需要调整
    final double radialPosition = innerRadius + ringThickness / 2;

    // 文字容器沿半径方向的偏移量。
    // 我们希望文字容器的中心位于 (radialPosition * cos(angle), radialPosition * sin(angle))
    // 对于起始半径边，angle = 0。所以中心点在 (radialPosition, 0)。
    // 但是，我们希望文字的一侧贴近这条半径线。
    // 假设文字容器的旋转使得其长边（宽度）平行于半径。
    // 如果文字是横向的 Text('神煞')，我们希望它“躺”在半径旁边。

    // 目标：文字平行于起始半径（x轴），并位于其一侧。
    // 文字容器的中心点，我们先设定在扇环厚度的中间，并且稍微偏离起始半径一点点，以便文字能完整显示。
    // 偏移的距离是文字高度的一半，这样文字的中心线会与半径线有textBlockHeight / 2的间隔。
    final double offsetX = radialPosition; // 文字块的中心 X 坐标
    final double offsetY =
        textBlockHeight / 2 + 2; // 文字块的中心 Y 坐标 (略微偏离半径，给文字留出空间，+2是额外间距)
    // 如果希望文字的下边缘贴近半径，则offsetY应该是 textBlockHeight / 2
    // 如果希望文字的上边缘贴近半径，则offsetY应该是 -textBlockHeight / 2

    // 2. 文字容器的旋转 (Transform.rotate around the text container itself):
    // 由于文字是横向的，并且我们希望它平行于起始半径（x轴），所以文字容器本身不需要旋转。
    final double textContainerItselfRotation = 0; // 容器不旋转

    // 3. 文字自身的旋转 (Transform.rotate for the Text widget):
    // a. 抵消父级 _ShenShaItem 的整体旋转
    final double baseItemRotation = 2 * math.pi * index / totalCount;
    // b. 我们希望文字平行于当前 _ShenShaItem 的起始半径（x轴）。
    //    并且文字是横向的。如果希望文字朝向圆心，则需要旋转 pi 弧度。
    //    如果希望文字朝向外侧，则不需要额外旋转 (0 弧度)。
    //    这里我们让文字朝向外侧（即正常阅读方向，如果观察者在圆心外看）。
    final double textOrientationRotation = 0; // 文字朝向外侧
    // final double textOrientationRotation = math.pi; // 如果想让文字朝向圆心

    final double finalAngleForText =
        -baseItemRotation + textOrientationRotation;
    // --- 修改结束 ---
    debugPrint(
        "offsetX: $offsetX, offsetY: $offsetY, textContainerItselfRotation: $textContainerItselfRotation, textOrientationRotation: $textOrientationRotation, finalAngleForText: $finalAngleForText");

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: Transform.rotate(
        angle: baseItemRotation, // 每个扇环的整体旋转
        child: CustomPaint(
            size: Size(itemSize, itemSize),
            painter: SectorPainter(
              startAngle: 0,
              sweepRadian: sweepRadian,
              color: Colors.blue[500]!.withAlpha(20 * index),
              outerRadius: outerRadius,
              innerRadius: innerRadius,
            ),
            child: eachShenSha(offsetX + 20, offsetY, textStyle)),
      ),
    );
  }

  Widget eachShenSha(double offsetX, double offsetY, TextStyle textStyle) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY), // 定位文字容器的中心
      child: Transform.rotate(
          // angle: textContainerItselfRotation, // 文字容器本身的旋转（这里是0）
          angle: 90 * (math.pi / 180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6,
                height: 36,
                // color: Colors.redAccent.withAlpha(), // Removed solid color
                decoration: BoxDecoration(
                  // Added BoxDecoration for gradient
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(0.8),
                      Colors.redAccent.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 36,
                // width: textBlockWidth,
                // height: textBlockHeight * 2,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), // 文字背景圆角
                    // color: Colors.blue.withOpacity(0.3), // 调试用
                    border: BoxBorder.fromLTRB(
                        bottom: BorderSide(color: Colors.black12, width: 1.0))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: name
                        .split("")
                        .map((t) => Transform.rotate(
                              angle: getTextRotationAngle(shaTextDirection),
                              child: Text(
                                t,
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList()),
              ),
            ],
          )),
    );
  }

  double getTextRotationAngle(RingTextDirection direction) {
    // 计算文字的旋转角度，使其始终垂直于半径
    // 这里我们假设文字是横向的 Text('神煞')，并且我们希望它垂直于半径。
    // 如果文字是纵向的 Text('神\n煞')，则需要调整角度。
    // 这里我们简单地返回0度，即不旋转。
    switch (direction) {
      case RingTextDirection.center:
        return 0; // 文字指向圆环中心
      case RingTextDirection.outer:
        return math.pi; // 文字指向圆环外侧
      case RingTextDirection.gravity:
        return -(index * 30 + 90) * (math.pi / 180); // 文字垂直于半径，旋转180度
    }
  }
}
