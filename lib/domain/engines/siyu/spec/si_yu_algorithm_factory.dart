import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/luo_ji_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/yue_bo_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/zi_qi_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/piecewise_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/solar_term_julian_day.dart';
import 'si_yu_group_spec.dart';

class CoordinateContext {
  final double totalDegree;
  final ISiYuEphemerisSource? ephemerisSource;
  const CoordinateContext({required this.totalDegree, this.ephemerisSource});
}

typedef SiYuBuilder = SiYuGroupAlgorithm Function(SiYuGroupSpec, CoordinateContext);

class SiYuAlgorithmFactory {
  final Map<String, SiYuBuilder> _builders;
  SiYuAlgorithmFactory(this._builders);

  void register(String kind, SiYuBuilder b) => _builders[kind] = b;

  SiYuGroupAlgorithm build(SiYuGroupSpec spec, CoordinateContext ctx) {
    if (spec.segments != null && spec.segments!.isNotEmpty) {
      return PiecewiseGroupAlgorithm([
        PiecewiseSegment(
            fromJulianDay: double.negativeInfinity,
            algorithm: _buildBase(spec, ctx)),
        ...spec.segments!.map((s) => PiecewiseSegment(
            fromJulianDay: s.fromJulianDay, algorithm: build(s.spec, ctx))),
      ]);
    }
    return _buildBase(spec, ctx);
  }

  SiYuGroupAlgorithm _buildBase(SiYuGroupSpec s, CoordinateContext ctx) {
    final b = _builders[s.kind];
    if (b == null) throw ArgumentError('未知紫气/四余算法 kind: ${s.kind}');
    return b(s, ctx);
  }

  LinearParallelCore _core(SiYuGroupSpec s) => LinearParallelCore(
        totalDegree: s.params['totalDegree'] ?? 360,
        dailyMotion: s.params['dailyMotion'] ?? 0,
        direction: (s.params['direction'] ?? 1).toInt(),
        epochJulianDay: s.params['epochJulianDay'] ?? 0,
        epochPosition: s.params['epochPosition'] ?? 0,
      );

  static SiYuAlgorithmFactory withDefaults() {
    final f = SiYuAlgorithmFactory({});
    f.register('linear_ziqi', (s, ctx) => ZiQiGroupAlgorithm(
        GuoLaoZiQiAlgorithm(
          totalDegree: s.params['totalDegree'] ?? ctx.totalDegree,
          periodDays: (s.params['totalDegree'] ?? 360) / (s.params['dailyMotion'] ?? 0.0352),
          epochJulianDay: s.params['epochJulianDay'] ?? 0,
          epochLongitude: s.params['epochPosition'] ?? 0,
        )));
    f.register('shixian_ziqi', (s, ctx) => ZiQiGroupAlgorithm(
        ShixianZiQiAlgorithm(
          dailyMotionDegrees: 126.720777 / 3600,
          epochJulianDay: winterSolsticeJulianDay(1744, julianCalendar: false),
          epochLongitude: 197.833333,
        )));
    f.register('yelv_tianguan_ziqi', (s, ctx) => ZiQiGroupAlgorithm(
        const TianguanZiQiAlgorithm(
          epochYear: 1281,
          epochLongitude: 6.0,
          yearlyIncrementDegrees: 13 + 5 / 60,
        )));
    f.register('linear_apogee', (s, ctx) => LinearApogeeAlgorithm(core: f._core(s)));
    f.register('ephemeris_apogee', (s, ctx) =>
        EphemerisApogeeAlgorithm(source: ctx.ephemerisSource!));
    f.register('linear_node', (s, ctx) => LinearNodePairAlgorithm(
        nodeCore: f._core(s),
        convention: EnumRahuKetuConvention.values[s.rahuKetuConventionIndex ?? 0]));
    f.register('ephemeris_node', (s, ctx) => EphemerisNodePairAlgorithm(
        source: ctx.ephemerisSource!,
        convention: EnumRahuKetuConvention.values[s.rahuKetuConventionIndex ?? 0]));
    return f;
  }
}
