import 'package:flutter/material.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_ming_li_ring.dart';

/// Default twelve-gong ring builder using Normal12GongRing.
Widget generateDefault12GongRing(
  double innerSize,
  double outerSize,
  Map<EnumTwelveGong, List<String>> mapper,
) {
  return Normal12GongRing(
    outerRadius: outerSize,
    innerRadius: innerSize,
    baseGongOffsetAngle: 2 * 30,
    shenShaMapper: mapper,
    zhouTianModel: null,
  );
}
