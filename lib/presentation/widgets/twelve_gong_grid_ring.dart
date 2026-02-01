import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/painter/star_body_ring_painter.dart';

/// Grid-only ring for twelve-gong layout using RingSheetPainter.
class TwelveGongGridRingWidget extends StatelessWidget {
  const TwelveGongGridRingWidget({
    super.key,
    required this.innerSize,
    required this.outerSize,
  });

  final double innerSize;
  final double outerSize;

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
        angle: 75 * pi / 180,
        origin: Offset.zero,
        child: CustomPaint(
          size: Size(outerSize, outerSize),
          painter: RingSheetPainter(
            innerRadius: innerRadius,
            outerRadius: outerRadius,
          ),
        ),
      ),
    );
  }
}

/// Builder function compatible with StarRingLayer.gridBuilder signature.
Widget twelveGongGridBuilder(double innerSize, double outerSize) =>
    TwelveGongGridRingWidget(innerSize: innerSize, outerSize: outerSize);