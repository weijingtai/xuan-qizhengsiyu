import '../engines/projection/i_celestial_projector.dart';
import '../engines/projection/linear_projector.dart';
import '../engines/projection/piecewise_projector.dart';
import '../engines/projection/tui_bian_huang_dao_projector.dart';
import '../engines/projection/huang_chi_dao_diff.dart';
import '../entities/models/projection_config.dart';

class CelestialProjectorFactory {
  /// 春分锚点默认值：0.0（春分点不动契约）。
  /// 文档 002 §10 指出元时春分点约在壁宿 6–8°（待定 O1），
  /// 0.0 表示不施加全局平移，仅依赖 diff 算法的进退规则。
  static const double _defaultAnchor = 0.0;

  static ICelestialProjector create(
      ProjectionConfig? config, double targetTotal) {
    final strategy = config?.strategy ?? MappingStrategy.linear;
    switch (strategy) {
      case MappingStrategy.linear:
        return LinearCelestialProjector(
          sourceTotal: 360.0,
          targetTotal: targetTotal,
          offset: config?.offset ?? 0.0,
        );
      case MappingStrategy.piecewise:
        return PiecewiseCelestialProjector(
          sourcePoints: config!.sourcePoints!,
          targetPoints: config.targetPoints!,
          sourceTotal: 360.0,
          targetTotal: targetTotal,
        );
      case MappingStrategy.tuiBianHuangDao:
        return TuiBianHuangDaoProjector(
          diff: _buildDiff(config!, targetTotal),
          zhouTian: targetTotal,
          springEquinoxAnchor: config.springEquinoxAnchor ?? _defaultAnchor,
        );
    }
  }

  static HuangChiDaoDiff _buildDiff(ProjectionConfig c, double zhouTian) {
    switch (c.huangChiDaoDiffType ?? HuangChiDaoDiffType.shoushi) {
      case HuangChiDaoDiffType.daren:
        return const DarenJinTuiDiff();
      case HuangChiDaoDiffType.jiyuan:
        return const JiyuanFormulaDiff();
      case HuangChiDaoDiffType.shoushi:
        return ShoushiSphericalDiff(
          epsilonDeg: c.epsilonDeg ?? 23.90,
          zhouTian: zhouTian,
        );
      case HuangChiDaoDiffType.hushi:
        return HushiGeyuanDiff(
            epsilonDeg: c.epsilonDeg ?? 23.9030, zhouTian: zhouTian);
    }
  }
}
