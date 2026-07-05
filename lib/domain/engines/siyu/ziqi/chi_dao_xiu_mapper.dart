import 'package:metaphysics_core/enums.dart';
import '../../../entities/models/zhou_tian_model.dart';
import '../../../managers/zhou_tian_calculator.dart';

class ChiDaoXiuMapper {
  final ZhouTianModel _model;
  final Map<Enum28Constellations, _XiuRange> _ranges;

  ChiDaoXiuMapper(ZhouTianModel model)
      : _model = model,
        _ranges = _buildRanges(model);

  static Map<Enum28Constellations, _XiuRange> _buildRanges(ZhouTianModel model) {
    final calc = ZhouTianCalculator(zhouTianModel: model);
    final angles = calc.calculateConstellationAngles();
    final total = model.totalDegree;

    final Map<Enum28Constellations, _XiuRange> map = {};
    angles.forEach((xiu, obj) {
      final start = obj.absStartContinuous % total;
      final startNorm = start < 0 ? start + total : start;
      final end = (startNorm + obj.width) % total;
      map[xiu] = _XiuRange(
        xiu: xiu,
        start: startNorm,
        end: end,
        width: obj.width,
      );
    });
    return map;
  }

  double xiuStartLongitude(Enum28Constellations xiu) {
    final r = _ranges[xiu];
    if (r == null) {
      throw ArgumentError("星宿 ${xiu.name} 不在周天模型中");
    }
    return r.start;
  }

  ({Enum28Constellations xiu, double deg}) toXiuDegree(double chiDaoLongitude) {
    final total = _model.totalDegree;
    var lon = chiDaoLongitude % total;
    if (lon < 0) lon += total;

    for (final r in _ranges.values) {
      bool contains = false;
      if (r.start <= r.end) {
        if (lon >= r.start && lon < r.end) {
          contains = true;
        }
      } else {
        // wrap-around
        if (lon >= r.start || lon < r.end) {
          contains = true;
        }
      }

      if (contains) {
        var deg = lon - r.start;
        if (deg < 0) deg += total;
        return (xiu: r.xiu, deg: deg);
      }
    }

    // Fallback/boundary case: if not found due to floating point precision, return first matching or closest.
    final first = _ranges.values.first;
    return (xiu: first.xiu, deg: 0.0);
  }
}

class _XiuRange {
  final Enum28Constellations xiu;
  final double start;
  final double end;
  final double width;

  _XiuRange({
    required this.xiu,
    required this.start,
    required this.end,
    required this.width,
  });
}
