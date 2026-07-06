/// 周天缩放 —— 古度 365.2575 ↔ 今度 360 独立、可逆的一级换算。
///
/// 本类只做纯比率缩放，不做任何隐式取模。调用方必须显式标注坐标系。
/// 见 docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md。
class ZhouTianScale {
  ZhouTianScale._();

  static const double ancientTotal = 365.2575;
  static const double modernTotal = 360.0;

  static const double _toModern = modernTotal / ancientTotal;
  static const double _toAncient = ancientTotal / modernTotal;

  static double toModern(double ancientDegree) => ancientDegree * _toModern;

  static double toAncient(double modernDegree) => modernDegree * _toAncient;
}
