import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/widgets/star_body.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';

/// Inner star body rotating widget.
class InnerStarBodyRotatingWidget extends StatelessWidget {
  const InnerStarBodyRotatingWidget({
    super.key,
    required this.stars,
    required this.outerSize,
    required this.trackSize,
    required this.starBodySize,
    required this.allStarsShowNotifier,
  });

  final List<UIStarModel> stars;
  final double outerSize;
  final double trackSize;
  final double starBodySize;
  final ValueNotifier<bool> allStarsShowNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: stars
            .map((s) => _StarBodyRotatingItem(
                  star: s,
                  ringOuterSize: outerSize,
                  trackSize: trackSize,
                  starBodySize: starBodySize,
                  allStarsShowNotifier: allStarsShowNotifier,
                ))
            .toList(),
      ),
    );
  }
}

/// Outer star body rotating widget.
class OuterStarBodyRotatingWidget extends StatelessWidget {
  const OuterStarBodyRotatingWidget({
    super.key,
    required this.stars,
    required this.outerSize,
    required this.trackSize,
    required this.starBodySize,
    required this.allStarsShowNotifier,
  });

  final List<UIStarModel> stars;
  final double outerSize;
  final double trackSize;
  final double starBodySize;
  final ValueNotifier<bool> allStarsShowNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: stars
            .map((s) => _StarBodyRotatingItem(
                  star: s,
                  ringOuterSize: outerSize,
                  trackSize: trackSize,
                  starBodySize: starBodySize,
                  allStarsShowNotifier: allStarsShowNotifier,
                ))
            .toList(),
      ),
    );
  }
}

class _StarBodyRotatingItem extends StatelessWidget {
  const _StarBodyRotatingItem({
    required this.star,
    required this.ringOuterSize,
    required this.trackSize,
    required this.starBodySize,
    required this.allStarsShowNotifier,
  });

  final UIStarModel star;
  final double ringOuterSize;
  final double trackSize;
  final double starBodySize;
  final ValueNotifier<bool> allStarsShowNotifier;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.notoSans(
      fontSize: 24.0,
      height: 1,
      color: QiZhengSiYuUIConstantResources.starsColorMap[star.star]!,
      fontWeight: FontWeight.normal,
      shadows: [
        BoxShadow(
          color: Colors.black38.withOpacity(.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1),
        )
      ],
    );

    return AnimatedRotation(
      turns: -star.angle / 360,
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: ringOuterSize,
        width: starBodySize,
        padding: EdgeInsets.symmetric(
          vertical: (ringOuterSize - trackSize - starBodySize) * .4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 400),
              turns: (star.angle - 120) / 360,
              child: StarBody(
                starSize: starBodySize,
                starBody: star,
                textStyle: textStyle,
                allStarsShowNotifier: allStarsShowNotifier,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
