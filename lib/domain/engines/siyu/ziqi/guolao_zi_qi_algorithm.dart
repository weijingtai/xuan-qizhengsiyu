import 'zi_qi_algorithm.dart';

/// 果老/琴堂：授时元积日平行顺推。
/// [totalDegree] 决定坐标框架：黄道 360 或天赤道 365.25（度制铁律，勿混）。
/// 历元位置(epochLongitude，同框架单位)由 ZiqiEpochCalibrator 校准后注入。
class GuoLaoZiQiAlgorithm implements ZiQiAlgorithm {
  final double totalDegree;    // 360(黄道) / 365.25(天赤道古度)
  final double periodDays;     // 10227.1792(28年) / 10592(29年)
  final double epochJulianDay; // 历元冬至 JD
  final double epochLongitude; // 历元位置（与 totalDegree 同框架单位）

  const GuoLaoZiQiAlgorithm({
    required this.totalDegree,
    required this.periodDays,
    required this.epochJulianDay,
    required this.epochLongitude,
  });

  @override
  String get id => 'guolao_qintang';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) {
    final daily = totalDegree / periodDays; // 同框架度/日
    return _normalize(
        epochLongitude + daily * (julianDay - epochJulianDay), totalDegree);
  }

  static double _normalize(double d, double total) {
    var r = d % total;
    if (r < 0) r += total;
    return r;
  }
}
