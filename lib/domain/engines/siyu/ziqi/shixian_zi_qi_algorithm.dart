import 'zi_qi_algorithm.dart';

/// 清时宪：乾隆甲子元新平行法（历元+日行，与果老同形态，仅锚点不同）。
class ShixianZiQiAlgorithm implements ZiQiAlgorithm {
  final double dailyMotionDegrees; // 126.720777″/3600 ≈ 0.0352002°/日
  final double epochJulianDay;     // 乾隆九年甲子(1744)冬至
  final double epochLongitude;     // 起七宫17°50′（西洋黄道回归天秤宫，整分版为绝对经度 197.8333°）

  const ShixianZiQiAlgorithm({
    required this.dailyMotionDegrees,
    required this.epochJulianDay,
    required this.epochLongitude,
  });

  @override
  String get id => 'shixian';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) =>
      _normalize360(
          epochLongitude + dailyMotionDegrees * (julianDay - epochJulianDay));

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
