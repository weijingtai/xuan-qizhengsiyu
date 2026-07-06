import '../engines/projection/i_celestial_projector.dart';
import '../engines/projection/linear_projector.dart';
import '../engines/projection/piecewise_projector.dart';
import '../engines/projection/tui_bian_huang_dao_projector.dart';
import '../engines/projection/huang_chi_dao_diff.dart';
import '../entities/models/projection_config.dart';

class CelestialProjectorFactory {
  static ICelestialProjector create(
      ProjectionConfig? config, double targetTotal) {
    final srcTotal = config?.sourceTotal ?? 360.0;
    if (config == null || config.strategy == MappingStrategy.linear) {
      return LinearCelestialProjector(
        sourceTotal: srcTotal,
        targetTotal: targetTotal,
        offset: config?.offset ?? 0.0,
      );
    } else if (config.strategy == MappingStrategy.tuiBianHuangDao) {
      final diffType = config.huangChiDaoDiffType ?? HuangChiDaoDiffType.jiyuan;
      final HuangChiDaoDiff diff = switch (diffType) {
        HuangChiDaoDiffType.daren => const DarenJinTuiDiff(),
        HuangChiDaoDiffType.jiyuan => const JiyuanFormulaDiff(),
        HuangChiDaoDiffType.shoushi => ShoushiSphericalDiff(
            epsilonDeg: config.epsilonDeg ?? 23.90,
            zhouTian: targetTotal,
          ),
      };
      return TuiBianHuangDaoProjector(
        diff: diff,
        zhouTian: targetTotal,
        springEquinoxAnchor: config.springEquinoxAnchor ?? 6.0,
      );
    } else {
      return PiecewiseCelestialProjector(
        sourcePoints: config.sourcePoints!,
        targetPoints: config.targetPoints!,
        sourceTotal: srcTotal,
        targetTotal: targetTotal,
      );
    }
  }
}
