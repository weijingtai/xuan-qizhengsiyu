/// 周天制枚举：360 度制（现代）与古度 365.2575。
enum EnumZhouTianModel {
  /// 现代 360 度制
  degree360(360.0),

  /// 古周天 365.2575 度制
  degree36525(365.2575);

  const EnumZhouTianModel(this.totalDegree);

  /// 对应周天总度
  final double totalDegree;
}
