import 'package:metaphysics_core/enums.dart';
import 'si_yu_group_algorithm.dart';

class PiecewiseSegment {
  final double fromJulianDay;
  final SiYuGroupAlgorithm algorithm;
  const PiecewiseSegment({required this.fromJulianDay, required this.algorithm});
}

/// 分段多模型：硬切换，取 fromJulianDay ≤ jd 的最后一段。
class PiecewiseGroupAlgorithm implements SiYuGroupAlgorithm {
  final List<PiecewiseSegment> _segments;
  PiecewiseGroupAlgorithm(List<PiecewiseSegment> segments)
      : assert(segments.isNotEmpty),
        _segments = List.of(segments)
          ..sort((a, b) => a.fromJulianDay.compareTo(b.fromJulianDay));

  @override
  String get id => 'piecewise';
  @override
  Set<EnumStars> get bodies => _segments.first.algorithm.bodies;

  @override
  Map<EnumStars, double> computePositions(
      {required double julianDay, required DateTime datetime}) {
    var seg = _segments.first;
    for (final s in _segments) {
      if (s.fromJulianDay <= julianDay) seg = s; else break;
    }
    return seg.algorithm.computePositions(julianDay: julianDay, datetime: datetime);
  }
}
