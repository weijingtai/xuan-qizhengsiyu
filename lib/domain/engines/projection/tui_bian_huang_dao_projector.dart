import 'i_celestial_projector.dart';
import 'huang_chi_dao_diff.dart';

/// 推变黄道投影器 —— 四象限进退框架。
///
/// 在赤道周天内做畸变（进退），绝不做跨周天操作。
/// 三种算法（大衍进退表/姚舜辅公式/授时球面三角）共享同一框架，
/// 唯一不同是 [diff] 策略计算黄赤道差的方式。
///
/// 进退规则（§3）：
/// - 春分→夏至、秋分→冬至：黄道增度（+d）
/// - 夏至→秋分、冬至→春分：黄道减度（−d）
///
/// 见 docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md。
class TuiBianHuangDaoProjector implements ICelestialProjector {
  final HuangChiDaoDiff _diff;
  final double _zhouTian;
  final double _quadrant;
  final double _springEquinoxAnchor;

  TuiBianHuangDaoProjector({
    required HuangChiDaoDiff diff,
    required double zhouTian,
    required double springEquinoxAnchor,
  })  : _diff = diff,
        _zhouTian = zhouTian,
        _quadrant = zhouTian / 4.0,
        _springEquinoxAnchor = _norm(springEquinoxAnchor, zhouTian);

  static double _norm(double x, double total) {
    var r = x % total;
    return r < 0 ? r + total : r;
  }

  double _normalize(double x) => _norm(x, _zhouTian);

  @override
  double project(double equatorialDegree) {
    final offset = _normalize(equatorialDegree - _springEquinoxAnchor);
    final qi = (offset / _quadrant).floor();
    final c = offset - qi * _quadrant;
    final d = _diff.diff(c);
    final sign = (qi % 2 == 0) ? 1.0 : -1.0;
    return equatorialDegree + sign * d;
  }

  @override
  double reverse(double eclipticDegree) {
    var c = eclipticDegree;
    for (var i = 0; i < 20; i++) {
      final p = project(c);
      final error = p - eclipticDegree;
      if (error.abs() < 1e-12) break;
      c -= error;
    }
    return c;
  }
}
