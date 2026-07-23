import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/engines/historical_engine.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';

ZhouTianModel _buildEclipticTropicalModel() {
  return ZhouTianModel(
    systemType: CelestialCoordinateSystem.Ecliptic,
    constellationSystemType: ConstellationSystemType.Modern,
    panelSystemType: PanelSystemType.Tropical,
    epochCorrection: 'default',
    totalDegree: 360.0,
    gongDegreeSeq: List.generate(
      12,
      (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0),
    ),
    starInnDegreeSeq: [
      ConstellationDegree(constellation: Enum28Constellations.Jiao_Mu_Jiao, degree: 12.0),
      ConstellationDegree(constellation: Enum28Constellations.Kang_Jin_Long, degree: 10.0),
    ],
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
    starInnOrder: [Enum28Constellations.Jiao_Mu_Jiao, Enum28Constellations.Kang_Jin_Long],
  );
}

class FakeSystemDefinitionSource implements ISystemDefinitionSource {
  final ZhouTianModel model;

  FakeSystemDefinitionSource(this.model);

  @override
  Future<ZhouTianModel> getSystemDefinition(String fileName) async => model;
}

class FakeHistoricalEphemerisRepository implements QiZhengHistoricalEphemerisRepository {
  final Map<String, dynamic> data;

  FakeHistoricalEphemerisRepository(this.data);

  @override
  Future<Map<String, dynamic>> loadHistoricalEphemeris() async => data;
}

class FakeEngine implements ICalculationEngine {
  final ZhouTianModel systemDefinition;
  final List<StarPositionRawData> starPositions;

  FakeEngine({required this.systemDefinition, required this.starPositions});

  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async => systemDefinition;

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate,
    ObserverPosition position,
    BasePanelConfig config,
  ) async => starPositions;

  @override
  List<StarPositionRawData> calculateStarPositionsSync(
    DateTime birthDate,
    ObserverPosition position,
    BasePanelConfig config,
    ZhouTianModel zhouTianModel,
  ) => starPositions;
}

class FakeEngineProvider implements ICalculationEngineProvider {
  final ICalculationEngine engine;

  FakeEngineProvider(this.engine);

  @override
  ICalculationEngine getEngine(BasePanelConfig config) => engine;
}

BasePanelConfig _defaultConfig() => BasePanelConfig(
  celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
  houseDivisionSystem: HouseDivisionSystem.equal,
  panelSystemType: PanelSystemType.Tropical,
  constellationSystemType: ConstellationSystemType.Modern,
  settleLifeType: EnumSettleLifeType.Mao,
  settleBodyType: EnumSettleBodyType.moon,
  islifeGongBySunRealTimeLocation: true,
);

ObserverPosition _defaultObserver() => ObserverPosition(
  latitude: 31.2304,
  longitude: 121.4737,
  altitude: 0,
  timezone: 'Asia/Shanghai',
  dateTime: DateTime(1990, 1, 1, 12), yearGanZhi: JiaZi.JIA_ZI,
  monthGanZhi: JiaZi.JIA_ZI, dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

void main() {
  group('HistoricalEngine injection', () {
    test('constructs with ISystemDefinitionSource + ephemeris repository, no Flutter bindings', () {
      final model = _buildEclipticTropicalModel();
      final sysDef = FakeSystemDefinitionSource(model);
      final ephemeris = FakeHistoricalEphemerisRepository({
        'dongZhi': 1.0,
      });
      final engine = HistoricalEngine(
        systemDefinitionSource: sysDef,
        ephemerisRepository: ephemeris,
      );
      expect(engine, isNotNull);
    });

    test('constructs without requiring SystemDefinitionLocalDataSource or rootBundle', () {
      final model = _buildEclipticTropicalModel();
      final engine = HistoricalEngine(
        systemDefinitionSource: FakeSystemDefinitionSource(model),
        ephemerisRepository: FakeHistoricalEphemerisRepository({'dongZhi': 1.0}),
      );
      expect(engine, isA<ICalculationEngine>());
    });
  });

}

class _ConfigRoutingProvider implements ICalculationEngineProvider {
  final ICalculationEngine ecliptic;
  final ICalculationEngine skyEquatorial;

  _ConfigRoutingProvider({required this.ecliptic, required this.skyEquatorial});

  @override
  ICalculationEngine getEngine(BasePanelConfig config) {
    return config.celestialCoordinateSystem == CelestialCoordinateSystem.SkyEquatorial
        ? skyEquatorial
        : ecliptic;
  }
}
