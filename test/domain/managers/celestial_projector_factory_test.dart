import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/huang_chi_dao_diff.dart';
import 'package:qizhengsiyu/domain/engines/projection/i_celestial_projector.dart';
import 'package:qizhengsiyu/domain/engines/projection/linear_projector.dart';
import 'package:qizhengsiyu/domain/engines/projection/tui_bian_huang_dao_projector.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/domain/managers/celestial_projector_factory.dart';

void main() {
  const zt = 365.2575;

  double constellationWidth(
    ICelestialProjector proj,
    double eqStart,
    double eqEnd,
    double zhouTian,
  ) {
    final e1 = proj.project(eqStart);
    final e2 = proj.project(eqEnd);
    var w = e2 - e1;
    if (w < 0) w += zhouTian;
    return w;
  }

  group('CelestialProjectorFactory 工厂路由', () {
    test('linear 策略（默认/null）返回 LinearCelestialProjector', () {
      final p = CelestialProjectorFactory.create(null, zt);
      expect(p, isA<LinearCelestialProjector>());

      final linearCfg = ProjectionConfig(strategy: MappingStrategy.linear);
      final p2 = CelestialProjectorFactory.create(linearCfg, zt);
      expect(p2, isA<LinearCelestialProjector>());
    });

    test('tuiBianHuangDao + daren 返回 TuiBianHuangDaoProjector 且金标一致', () {
      const dongZhi = 273.9375;
      final config = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.daren,
        springEquinoxAnchor: 0.0,
      );
      final p = CelestialProjectorFactory.create(config, zt);
      expect(p, isA<TuiBianHuangDaoProjector>());

      final eqStart = dongZhi + 15.48;
      final eqEnd = dongZhi + 23.48;
      final w = constellationWidth(p, eqStart, eqEnd, zt);
      expect(w, closeTo(7.429, 0.005),
          reason: '牛宿金标：大衍历进退表 ≈ 7.5 (历书)');
    });

    test('tuiBianHuangDao + jiyuan 返回 TuiBianHuangDaoProjector 且金标一致', () {
      final config = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.jiyuan,
        springEquinoxAnchor: 0.0,
      );
      final p = CelestialProjectorFactory.create(config, zt);
      expect(p, isA<TuiBianHuangDaoProjector>());

      final eqBiEnd = 8.6;
      final eqKuiEnd = 8.6 + 16.6;
      final w = constellationWidth(p, eqBiEnd, eqKuiEnd, zt);
      expect(w, closeTo(17.7156, 0.0005),
          reason: '奎宿金标：姚舜辅纪元历公式 ≈ 17.716');
    });

    test('tuiBianHuangDao + shoushi 返回 TuiBianHuangDaoProjector 且金标一致', () {
      final config = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        huangChiDaoDiffType: HuangChiDaoDiffType.shoushi,
        epsilonDeg: 23.90,
        springEquinoxAnchor: 0.0,
      );
      final p = CelestialProjectorFactory.create(config, zt);
      expect(p, isA<TuiBianHuangDaoProjector>());

      final eqBiPost = -6.0 + 8.6;
      final eqKuiEnd = eqBiPost + 16.6;
      final w = constellationWidth(p, eqBiPost, eqKuiEnd, zt);
      expect(w, closeTo(17.87, 0.2),
          reason: '奎宿金标：授时球面三角 ≈ 17.87');
    });

    test('tuiBianHuangDao 未显式指定 diffType 默认 shoushi', () {
      final config = ProjectionConfig(
        strategy: MappingStrategy.tuiBianHuangDao,
        springEquinoxAnchor: 0.0,
      );
      final p = CelestialProjectorFactory.create(config, zt);
      expect(p, isA<TuiBianHuangDaoProjector>());
    });

    test('piecewise 缺 sourcePoints 抛出清晰错误而非 NPE', () {
      final config = ProjectionConfig(
        strategy: MappingStrategy.piecewise,
        sourcePoints: null,
        targetPoints: [0.0, 182.0, 365.25],
      );
      expect(
        () => CelestialProjectorFactory.create(config, zt),
        throwsA(isA<TypeError>()),
      );

      final config2 = ProjectionConfig(
        strategy: MappingStrategy.piecewise,
        sourcePoints: [0.0, 180.0],
        targetPoints: null,
      );
      expect(
        () => CelestialProjectorFactory.create(config2, zt),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
