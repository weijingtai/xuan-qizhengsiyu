import 'zi_qi_algorithm.dart';

/// 耶律天官：中气闰余逐年加 13°05′，粗算宫度（只到十二宫，舍二十八宿细度）。
///
/// 说明：耶律天官以「上古上元甲子岁首」为先天历元，起算元度为「子宫虚六度」（赤道绝对经度 6.0°，地支十二次以冬至子宫起算）。
/// 实际计算时，通过传入参考年份 [epochYear] 和在该参考年份的赤道参考度数 [epochLongitude]
/// 进行相对年份差的增量推算，从而规避硬编码上古甲子纪年的公元年份。
class TianguanZiQiAlgorithm implements ZiQiAlgorithm {
  final int epochYear;
  final double epochLongitude;
  final double yearlyIncrementDegrees; // 13 + 5/60

  const TianguanZiQiAlgorithm({
    required this.epochYear,
    required this.epochLongitude,
    required this.yearlyIncrementDegrees,
  });

  @override
  String get id => 'yelv_tianguan';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) {
    final years = datetime.year - epochYear;
    final raw = _normalize360(
        epochLongitude + yearlyIncrementDegrees * years);
    // 粗算：截断到所在宫起点（30° 整数倍）
    return (raw / 30.0).floorToDouble() * 30.0;
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
