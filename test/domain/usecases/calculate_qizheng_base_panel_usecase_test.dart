import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_di_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class FakeShenShaRepository implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => const [];
  @override Future<List<OtherShenSha>> getOtherShenSha() async => const [];
}

class FakeHuaYaoRepository implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => const [];
}

ZhouTianModel _eclipticModel() {
  return ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Modern,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'default',
    totalDegree: 360.0,
    gongDegreeSeq: List.generate(12, (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0)),
    starInnDegreeSeq: List.generate(28, (i) => ConstellationDegree(
      constellation: Enum28Constellations.values[i],
      degree: i < 27 ? 12.86 : 12.78, // 27*12.86 + 12.78 ≈ 360
    )),
    alignmentPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Xu_Ri_Shu, degree: 6.0),
    alignmentPointAtGong: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
    zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
    zeroPointAtConstellation: ConstellationDegree(constellation: Enum28Constellations.Shi_Huo_Zhu, degree: 6.5),
    zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
    celestialLongitude: 0.0,
    zeroPointOffsetToNow: 0.0,
    rightAscension: 0.0,
    specificationList: const ['baseline'],
    gongOrder: EnumTwelveGong.listAll,
    starInnOrder: Enum28Constellations.values,
  );
}

ObserverPosition _observer() => ObserverPosition(
  latitude: 31.2304,
  longitude: 121.4737,
  altitude: 0,
  timezone: 'Asia/Shanghai',
  dateTime: DateTime(1990, 1, 1, 12),
  yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI, dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

BasePanelConfig _defaultConfig() => BasePanelConfig(
  celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
  houseDivisionSystem: HouseDivisionSystem.equal,
  panelSystemType: PanelSystemType.Tropical,
  constellationSystemType: ConstellationSystemType.Modern,
  settleLifeType: EnumSettleLifeType.Mao,
  settleBodyType: EnumSettleBodyType.moon,
  islifeGongBySunRealTimeLocation: true,
);

List<StarPositionRawData> _samplePosition(EnumStars star, double angle, double speed) {
  return [
    StarPositionRawData(
      starType: star,
      angleRawInfoSet: {
        StarAngleRawInfo(
          panelSystemType: PanelSystemType.Tropical,
          coordinateSystem: CelestialCoordinateSystem.Ecliptic,
          angle: angle,
          speed: speed,
        ),
      },
    ),
  ];
}

List<StarPositionRawData> _samplePositions() {
  return [
    ..._samplePosition(EnumStars.Sun, 68.116, 0.96),
    ..._samplePosition(EnumStars.Moon, 97.287, 14.45),
    ..._samplePosition(EnumStars.Mercury, 66.947, 2.20),
    ..._samplePosition(EnumStars.Venus, 22.297, 0.94),
    ..._samplePosition(EnumStars.Mars, 139.59, 0.53),
    ..._samplePosition(EnumStars.Jupiter, 87.381, 0.22),
    ..._samplePosition(EnumStars.Saturn, 0.297, 0.07),
  ];
}

class FakeEngine implements ICalculationEngine {
  final ZhouTianModel model;
  final List<StarPositionRawData> positions;
  FakeEngine(this.model, this.positions);

  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async => model;

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config,
  ) async => positions;
}

class FakeEngineProvider implements ICalculationEngineProvider {
  final ICalculationEngine engine;
  FakeEngineProvider(this.engine);

  @override
  ICalculationEngine getEngine(BasePanelConfig config) => engine;
}

void main() {
  group('CalculateQiZhengBasePanelUseCase', () {
    late ShenShaManager shenShaManager;
    late HuaYaoManager huaYaoManager;

    setUp(() {
      tz_data.initializeTimeZones();
      shenShaManager = ShenShaManager(
        shenShaService: ShenShaService(repository: FakeShenShaRepository()),
      );
      huaYaoManager = HuaYaoManager(
        huaYaoService: HuaYaoService(repository: FakeHuaYaoRepository()),
      );
      CalculationEngineFactory.setProvider(
        FakeEngineProvider(FakeEngine(_eclipticModel(), _samplePositions())),
      );
    });

    test('constructs without Flutter bindings', () {
      final useCase = CalculateQiZhengBasePanelUseCase(
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );
      expect(useCase, isNotNull);
    });

    test('execute returns result with basicLifePanel, zhouTianModel, starAngleMapper', () async {
      final useCase = CalculateQiZhengBasePanelUseCase(
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );
      final result = await useCase.execute(
        config: _defaultConfig(),
        observer: _observer(),
      );

      expect(result.basicLifePanel, isNotNull);
      expect(result.zhouTianModel, isNotNull);
      expect(result.starAngleMapper, isNotEmpty);
    });
  });
}
