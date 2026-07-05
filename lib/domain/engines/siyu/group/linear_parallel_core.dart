/// 通用平行推算内核：顺逆/速率/历元/坐标框架全参数化。
/// 紫气/罗计古法平行/月孛古法平行共用此内核，仅参数不同。
class LinearParallelCore {
  final double totalDegree;    // 360 / 365.25
  final double dailyMotion;    // 日行度(该框架单位，取正)
  final int direction;         // +1 顺 / -1 逆
  final double epochJulianDay;
  final double epochPosition;

  const LinearParallelCore({
    required this.totalDegree,
    required this.dailyMotion,
    required this.direction,
    required this.epochJulianDay,
    required this.epochPosition,
  });

  double positionAt(double julianDay) {
    final raw = epochPosition +
        direction * dailyMotion * (julianDay - epochJulianDay);
    var r = raw % totalDegree;
    if (r < 0) r += totalDegree;
    return r;
  }
}
