import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/painter/star_body_ring_painter.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';

/// Inner star track ring widget using InnerLifeStarRangePainter.
class InnerStarTrackRingWidget extends StatelessWidget {
  const InnerStarTrackRingWidget({
    super.key,
    required this.stars,
    required this.outerSize,
    required this.innerSize,
    required this.trackSize,
    this.showText = false,
    this.showStarTrackLine = false,
  });

  final List<UIStarModel> stars;
  final double outerSize;
  final double innerSize;
  final double trackSize;
  final bool showText;
  final bool showStarTrackLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        size: Size(outerSize, outerSize),
        painter: InnerLifeStarRangePainter(
          stars: stars,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: outerSize,
          innerSize: innerSize,
          trackSize: trackSize,
          showText: showText,
          showStarTrackLine: showStarTrackLine,
          textStyle: GoogleFonts.notoSans(
            fontSize: 24.0,
            height: 1,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
            shadows: [
              BoxShadow(
                color: Colors.black38.withOpacity(.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Outer star track ring widget using OuterLifeStarRangePainter.
class OuterStarTrackRingWidget extends StatelessWidget {
  const OuterStarTrackRingWidget({
    super.key,
    required this.stars,
    required this.outerSize,
    required this.innerSize,
    required this.trackSize,
    this.showText = false,
    this.showStarTrackLine = false,
  });

  final List<UIStarModel> stars;
  final double outerSize;
  final double innerSize;
  final double trackSize;
  final bool showText;
  final bool showStarTrackLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        size: Size(outerSize, outerSize),
        painter: OuterLifeStarRangePainter(
          stars: stars,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: outerSize,
          innerSize: innerSize,
          trackSize: trackSize,
          showText: showText,
          showStarTrackLine: showStarTrackLine,
          textStyle: GoogleFonts.notoSans(
            fontSize: 24.0,
            height: 1,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
            shadows: [
              BoxShadow(
                color: Colors.black38.withOpacity(.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1),
              )
            ],
          ),
        ),
      ),
    );
  }
}
