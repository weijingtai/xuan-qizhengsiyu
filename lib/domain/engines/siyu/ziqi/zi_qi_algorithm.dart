/// 紫气行度算法策略。各流派实现之，供 ZiQiAlgorithmRegistry 管理与扩展。
abstract interface class ZiQiAlgorithm {
  /// 算法标识（配置/日志）。
  String get id;

  /// 紫气经度（度，全派顺行）。
  /// [julianDay] 供逐日平行流派；[datetime] 供逐年粗算流派。
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  });
}
