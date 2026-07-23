import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/shen_sha.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
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
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_calculator.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_calculation_context.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_params.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/pan_entity.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

final _uuid = '00000000-0000-0000-0000-000000000001';
final _now = DateTime(2026, 7, 22);

List<BundledShenSha> _bundled() => [
  BundledShenSha(BundledShenShaType.afterJia, '红鸾', JiXiongEnum.JI, 0, <String>[], <String>[]),
];

List<OtherShenSha> _other() => ['斗杓', '卦气', '禄卦', '岁殿', '月廉']
    .map((n) => OtherShenSha(n, JiXiongEnum.JI, <String>[], <String>[]))
    .toList();

List<OthersHuaYao> _othersHuaYao() => ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元']
    .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[], ShenShaType.Others))
    .toList();

ZhouTianModel _ecliptic() => ZhouTianModel(
  systemType: CelestialCoordinateSystem.Ecliptic,
  constellationSystemType: ConstellationSystemType.Modern,
  panelSystemType: PanelSystemType.Tropical,
  epochCorrection: 'default',
  totalDegree: 360.0,
  gongDegreeSeq: List.generate(12, (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0)),
  starInnDegreeSeq: List.generate(28, (i) => ConstellationDegree(
    constellation: Enum28Constellations.values[i],
    degree: i < 27 ? 12.86 : 12.78,
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

ObserverPosition _observer() => ObserverPosition(
  latitude: 31.2304,
  longitude: 121.4737,
  altitude: 0,
  timezone: 'Asia/Shanghai',
  dateTime: DateTime(1990, 1, 1, 12),
  yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI,
  dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

List<StarPositionRawData> _positions() => [
  for (final e in [
    (EnumStars.Sun, 68.116, 0.96),
    (EnumStars.Moon, 97.287, 14.45),
    (EnumStars.Mercury, 66.947, 2.20),
    (EnumStars.Venus, 22.297, 0.94),
    (EnumStars.Mars, 139.59, 0.53),
    (EnumStars.Jupiter, 87.381, 0.22),
    (EnumStars.Saturn, 0.297, 0.07),
  ])
    StarPositionRawData(
      starType: e.$1,
      angleRawInfoSet: {StarAngleRawInfo(
        panelSystemType: PanelSystemType.Tropical,
        coordinateSystem: CelestialCoordinateSystem.Ecliptic,
        angle: e.$2,
        speed: e.$3,
      )},
    ),
];

final _config = BasePanelConfig(
  celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
  houseDivisionSystem: HouseDivisionSystem.equal,
  panelSystemType: PanelSystemType.Tropical,
  constellationSystemType: ConstellationSystemType.Modern,
  settleLifeType: EnumSettleLifeType.Mao,
  settleBodyType: EnumSettleBodyType.moon,
  islifeGongBySunRealTimeLocation: true,
);

class _FakeShenShaRepository implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => _bundled();
  @override Future<List<OtherShenSha>> getOtherShenSha() async => _other();
}

class _FakeHuaYaoRepository implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => _othersHuaYao();
}

class _FakeEngine implements ICalculationEngine {
  final ZhouTianModel model;
  final List<StarPositionRawData> positions;
  _FakeEngine(this.model, this.positions);

  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async => model;

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config,
  ) async => positions;

  @override
  List<StarPositionRawData> calculateStarPositionsSync(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config, ZhouTianModel zhouTianModel,
  ) => positions;
}

class _FakeEngineProvider implements ICalculationEngineProvider {
  final ICalculationEngine engine;
  _FakeEngineProvider(this.engine);

  @override
  ICalculationEngine getEngine(BasePanelConfig config) => engine;
}

void main() {
  late _FakeEngine engine;
  late ShenShaManager shenShaManager;
  late HuaYaoManager huaYaoManager;
  late QizhengCalculationContext ctx;
  late QizhengChartCalculator calculator;
  late ResolvedMoment moment;

  setUp(() async {
    tz_data.initializeTimeZones();

    engine = _FakeEngine(_ecliptic(), _positions());
    shenShaManager = ShenShaManager(
      shenShaService: ShenShaService(repository: _FakeShenShaRepository()),
    );
    huaYaoManager = HuaYaoManager(
      huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepository()),
    );

    ctx = await QizhengCalculationContext.load(
      config: _config,
      engine: engine,
      shenShaService: ShenShaService(repository: _FakeShenShaRepository()),
      huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepository()),
    );
    calculator = QizhengChartCalculator(context: ctx, engine: engine);

    moment = ResolvedMoment(
      source: DivinationMoment(
        instantUtc: DateTime.utc(1990, 1, 1, 4),
        place: GeoPoint(longitude: 121.4737, latitude: 31.2304),
        reckoning: EnumDatetimeType.standard,
      ),
      nominalTime: DateTime(1990, 1, 1, 12),
      eightChars: EightChars(
        year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
      ),
      lunar: LunarDate(month: 1, day: 1, isLeapMonth: false),
      jieQi: JieQiInfo(
        jieQi: TwentyFourJieQi.CHUN_FEN,
        startAt: DateTime(1990, 3, 20),
        endAt: DateTime(1990, 4, 4),
      ),
    );
  });

  test(
    'red: panelModelJson matches legacy async calculation chain',
    () async {
      CalculationEngineFactory.setProvider(_FakeEngineProvider(engine));

      final useCase = CalculateQiZhengBasePanelUseCase(
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );

      final legacyResult = await useCase.execute(
        config: _config,
        observer: _observer(),
      );

      final divinationDatetimeModel = DivinationDatetimeModel.standard(
        uuid: _uuid,
        queryUuid: _uuid,
        timezoneStr: 'Asia/Shanghai',
        datetime: DateTime(1990, 1, 1, 12),
        bazi: EightChars(
          year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
          day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
        ),
        lunarMonth: 1,
        isLeapMonth: false,
        lunarDay: 1,
        jieQiInfo: JieQiInfo(
          jieQi: TwentyFourJieQi.CHUN_FEN,
          startAt: DateTime(1990, 3, 20),
          endAt: DateTime(1990, 4, 4),
        ),
        isSeersLocation: false,
        location: null,
      );

      final params = QizhengChartParams(
        uuid: _uuid,
        createdAt: _now,
        lastUpdatedAt: _now,
        divinationRequestInfoUuid: _uuid,
        divinationDatetimeJson: jsonEncode(divinationDatetimeModel.toJson()),
        panelConfig: _config,
        observerPosition: _observer(),
      );

      final contract = calculator.calculate(moment, params);

      final legacyEntity = QiZhengSiYuPanEntity(
        uuid: _uuid,
        createdAt: _now,
        lastUpdatedAt: _now,
        deletedAt: null,
        divinationRequestInfoUuid: _uuid,
        divinationDatetimeModel: divinationDatetimeModel,
        panelConfig: _config,
        panelModel: legacyResult.basicLifePanel,
      );
      final legacyContract = legacyEntity.toContract();

      expect(calculator.module, equals('qizhengsiyu'));
      expect(contract.uuid, equals(_uuid));
      expect(contract.panelModelJson, equals(legacyContract.panelModelJson));
      expect(contract.panelConfigJson, equals(legacyContract.panelConfigJson));
      expect(contract.divinationDatetimeJson, equals(legacyContract.divinationDatetimeJson));
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );

  test('is deterministic — same input twice produces equal contract', () {
    final params = QizhengChartParams(
      uuid: _uuid,
      createdAt: _now,
      lastUpdatedAt: _now,
      divinationRequestInfoUuid: _uuid,
      divinationDatetimeJson: '{}',
      panelConfig: _config,
      observerPosition: _observer(),
    );

    final a = calculator.calculate(moment, params);
    final b = calculator.calculate(moment, params);
    expect(a, equals(b));
  });
}
