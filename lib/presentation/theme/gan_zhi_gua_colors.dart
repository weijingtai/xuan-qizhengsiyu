import 'package:flutter/material.dart';
import 'package:metaphysics_core/enums/enum_di_zhi.dart';
import 'package:metaphysics_core/enums/enum_tian_gan.dart';

/// Local color maps for the lunar card widget.
///
/// Contains only `zodiacGanColors` and `zodiacZhiColors` as required
/// by the card and theme helpers.
class GanZhiGuaColors {
  static final Map<TianGan, Color> zodiacGanColors = {
    TianGan.JIA: const Color.fromRGBO(84, 150, 136, 1),
    TianGan.YI: const Color.fromRGBO(84, 150, 136, 1),
    TianGan.BING: const Color.fromRGBO(233, 84, 100, 1),
    TianGan.DING: const Color.fromRGBO(233, 84, 100, 1),
    TianGan.WU: const Color.fromRGBO(168, 132, 98, 1),
    TianGan.JI: const Color.fromRGBO(168, 132, 98, 1),
    TianGan.GENG: const Color.fromRGBO(240, 167, 46, 1),
    TianGan.XIN: const Color.fromRGBO(238, 166, 61, 1),
    TianGan.REN: const Color.fromRGBO(39, 117, 182, 1),
    TianGan.GUI: const Color.fromRGBO(39, 117, 182, 1),
  };

  static final Map<DiZhi, Color> zodiacZhiColors = {
    DiZhi.HAI: const Color.fromRGBO(61, 89, 171, 1),
    DiZhi.CHOU: const Color.fromRGBO(210, 180, 140, 1),
    DiZhi.YIN: const Color.fromRGBO(120, 146, 98, 1),
    DiZhi.MAO: const Color.fromRGBO(120, 146, 98, 1),
    DiZhi.CHEN: const Color.fromRGBO(225, 169, 95, 1),
    DiZhi.SI: const Color.fromRGBO(205, 92, 92, 1),
    DiZhi.WU: const Color.fromRGBO(205, 92, 92, 1),
    DiZhi.WEI: const Color.fromRGBO(244, 164, 96, 1),
    DiZhi.SHEN: const Color.fromRGBO(242, 190, 69, 1),
    DiZhi.YOU: const Color.fromRGBO(234, 205, 118, 1),
    DiZhi.XU: const Color.fromRGBO(160, 82, 45, 1),
    DiZhi.ZI: const Color.fromRGBO(61, 89, 171, 1),
  };
}

abstract class Light {
  static const Color background = Color.fromRGBO(249, 246, 238, 1);
  static const Color surface = Color.fromRGBO(255, 255, 255, 1);
  static const Color primaryText = Color.fromRGBO(51, 51, 51, 1);
  static const Color secondaryText = Color.fromRGBO(136, 136, 136, 1);
  static const Color divider = Color.fromRGBO(238, 238, 238, 1);
}

abstract class Dark {
  static const Color background = Color.fromRGBO(20, 24, 31, 1);
  static const Color surface = Color.fromRGBO(35, 41, 51, 1);
  static const Color primaryText = Color.fromRGBO(222, 222, 222, 1);
  static const Color secondaryText = Color.fromRGBO(158, 158, 158, 1);
  static const Color divider = Color.fromRGBO(60, 68, 82, 1);
}
