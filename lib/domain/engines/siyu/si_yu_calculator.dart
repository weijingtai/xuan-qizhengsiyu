import 'ziqi/zi_qi_algorithm.dart';

/// 四余星历源抽象（升交点 / 远地点）。生产实现见 SwephSiYuEphemerisSource。
abstract interface class ISiYuEphemerisSource {
  double meanNodeLongitude(double julianDay);   // SE_MEAN_NODE
  double meanApogeeLongitude(double julianDay); // SE_MEAN_APOG
}

/// 四余的中性天文量（尚未套用罗计流派）。
class SiYuRawResult {
  final double northNode; // 升交点
  final double southNode; // 降交点 = northNode + 180
  final double lilith;    // 月孛（月球远地点）
  final double qi;        // 紫气
  const SiYuRawResult({
    required this.northNode,
    required this.southNode,
    required this.lilith,
    required this.qi,
  });
}

/// 四余（紫气/月孛/罗睺/计都）天文计算模块。
///
/// 说明：本模块只产出「中性天文量」——不决定罗/计谁属升/降交点。
/// 罗计流派归属由 RahuKetuDefinition 在 StarsAngle.toMap 边界套用。
class SiYuCalculator {
  final ISiYuEphemerisSource _source;
  final ZiQiAlgorithm _ziQiAlgorithm;

  const SiYuCalculator({
    required ISiYuEphemerisSource source,
    required ZiQiAlgorithm ziQiAlgorithm,
  })  : _source = source,
        _ziQiAlgorithm = ziQiAlgorithm;

  SiYuRawResult compute({
    required double julianDay,
    required DateTime birthDate,
  }) {
    final n = _normalize360(_source.meanNodeLongitude(julianDay));
    final south = _normalize360(n + 180);
    final apogee = _normalize360(_source.meanApogeeLongitude(julianDay));
    return SiYuRawResult(
      northNode: n,
      southNode: south,
      lilith: apogee,
      qi: _ziQiAlgorithm.computeLongitude(julianDay: julianDay, datetime: birthDate),
    );
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
