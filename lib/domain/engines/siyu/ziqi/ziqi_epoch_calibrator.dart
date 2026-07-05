/// 紫气历元经度校准器（对应规格书 §5.3 两种方式）。
class ZiqiEpochCalibrator {
  const ZiqiEpochCalibrator._();

  /// 方式一（自洽）：以宿度管线求得的「箕宿0°」经度作为历元经度。
  static double fromConstellationPipeline({
    required double jiXiuStartLongitude,
    double totalDegree = 360.0,
  }) =>
      _normalize(jiXiuStartLongitude, totalDegree);

  /// 方式二（对标）：由参考盘 (refJulianDay, refLongitude) 反解历元经度。
  static double fromReferenceChart({
    required double refLongitude,
    required double refJulianDay,
    required double epochJulianDay,
    required double dailyMotionDegrees,
    double totalDegree = 360.0,
  }) =>
      _normalize(
          refLongitude - dailyMotionDegrees * (refJulianDay - epochJulianDay), totalDegree);

  static double _normalize(double d, double total) {
    var r = d % total;
    if (r < 0) r += total;
    return r;
  }
}
