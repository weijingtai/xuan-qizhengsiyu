import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:common/painter/text_circle_ring_painter.dart';

/// Text-only ring for twelve-gong layout using TextCircleRingPainter.
class TwelveGongTextRingWidget extends StatelessWidget {
  const TwelveGongTextRingWidget({
    super.key,
    required this.innerSize,
    required this.outerSize,
    required this.contentList,
    this.innerPadding = 0,
  });

  final double innerSize;
  final double outerSize;
  final List<Text> contentList;
  final double innerPadding;

  @override
  Widget build(BuildContext context) {
    final outerRadius = outerSize * .5;
    final innerRadius = innerSize * .5;

    return Container(
      alignment: Alignment.center,
      height: outerSize,
      width: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Transform.rotate(
        angle: 75 * math.pi / 180,
        origin: Offset.zero,
        child: CustomPaint(
          size: Size(outerSize, outerSize),
          painter: TextCircleRingPainter(
            innerRadius: innerRadius,
            outerRadius: outerRadius,
            textList: contentList,
            isAntiClockwise: true,
            innerPadding: innerPadding,
            isReverseText: false,
            isHorizontalText: true,
          ),
        ),
      ),
    );
  }
}

/// Builder function compatible with RingLayer.bodyBuilder style.
Widget twelveGongTextRingBuilder(
  double innerSize,
  double outerSize,
  List<Text> contentList, {
  double innerPadding = 0,
}) =>
    TwelveGongTextRingWidget(
      innerSize: innerSize,
      outerSize: outerSize,
      contentList: contentList,
      innerPadding: innerPadding,
    );