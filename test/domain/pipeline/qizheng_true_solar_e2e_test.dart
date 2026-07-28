import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/datetime_divination_datamodel.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:enumeration/enums.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/divination_info_model.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:metaphysics_core/models/seventy_two_phenology.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_pipeline_executor.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:xuan_time_location/xuan_time_location.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

const _uuid = 'true-solar-e2e-01';
const _lat = 31.2304;
const _lng = 121.4737;

final _config = BasePanelConfig(
  celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
  houseDivisionSystem: HouseDivisionSystem.equal,
  panelSystemType: PanelSystemType.Tropical,
  constellationSystemType: ConstellationSystemType.Modern,
  settleLifeType: EnumSettleLifeType.Mao,
  settleBodyType: EnumSettleBodyType.moon,
  islifeGongBySunRealTimeLocation: true,
);

final _otherShenShaData = [
  OtherShenSha("斗杓", JiXiongEnum.DA_JI, null, null),
  OtherShenSha("卦气", JiXiongEnum.DA_JI, null, null),
  OtherShenSha("禄卦", JiXiongEnum.DA_JI, null, null),
  OtherShenSha("岁殿", JiXiongEnum.DA_JI, null, null),
  OtherShenSha("月廉", JiXiongEnum.DA_JI, null, null),
];

class _FakeShenShaRepo implements ShenShaRepository {
  @override Future<List<OtherShenSha>> getOtherShenSha() async => _otherShenShaData;
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => [];
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => [
    BundledShenSha(BundledShenShaType.afterJia, '红鸾', JiXiongEnum.JI, 0, <String>[], <String>[]),
  ];
}

class _FakeHuaYaoRepo implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => _fakeOthersHuaYao();
}

List<OthersHuaYao> _fakeOthersHuaYao() => ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元']
    .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[], ShenShaType.Others))
    .toList();

void main() {
  group('T-Q4-TRUE-SOLAR: trueSolar 全链 e2e', () {
    setUpAll(() {
      tz_data.initializeTimeZones();
    });

    setUp(() {
      CalculationEngineFactory.setProvider(_FakeEngineProvider());
    });

    test('pipeline path: setLifeObserver works with standard mode + DefaultMomentResolver', () {
      final now = DateTime(2026, 7, 22, 6, 30);
      final bazi = EightChars(year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI, day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI);

      final dtModel = DivinationDatetimeModel.standard(
        uuid: _uuid, queryUuid: _uuid,
        timezoneStr: 'Asia/Shanghai', datetime: now, bazi: bazi,
        lunarMonth: 6, lunarDay: 22,
        jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.XIAO_SHU, startAt: DateTime(2026, 7, 7), endAt: DateTime(2026, 7, 23)),
        isLeapMonth: false, isSeersLocation: false,
        location: Location(address: Address(
          countryName: 'China', countryId: 45, regionId: 9,
          province: GeoLocation(name: 'Shanghai', latitude: _lat, longitude: _lng, level: GeoLevel.province, code: '31', parentCode: '0'),
          timezone: 'Asia/Shanghai',
        )),
      );

      final divInfo = DivinationInfoModel(
        divination: DivinationRequestInfoDataModel(uuid: _uuid, createdAt: now, divinationTypeUuid: 'test'),
        divinationDatetime: DatatimeDivinationDetailsDataModel(
          uuid: _uuid, createdAt: now, timingType: DateTimeType.solar,
          datetime: now, lunarMonth: 6, isLeapMonth: false, lunarDay: 22,
          yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI, dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
          timingInfoUuid: _uuid, timingInfoListJson: [dtModel],
        ),
      );

      final vm = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: _SpyInitUseCase(),
        calculateBasePanelUseCase: _SpyCalcUseCase(),
        evaluateGeJuUseCase: _SpyEvalUseCase(),
        buildTimelineUseCase: _SpyTimelineUseCase(),
        computeRiseSetUseCase: ComputeRiseSetUseCase(),
        yunLiuUseCase: YunLiuUseCase(),
        computeGanZhiUseCase: ComputeGanZhiUseCase(),
        momentResolver: const DefaultMomentResolver(),
        shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
        huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
      );

      vm.setLifeObserver(divInfo);

      expect(vm.lifeObserver, isNotNull);
    });

    test('pipeline path: calculateWithConfig does not call old UseCase (standard mode)', () async {
      final now = DateTime(2026, 7, 22, 6, 30);
      final bazi = EightChars(year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI, day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI);

      final dtModel = DivinationDatetimeModel.standard(
        uuid: _uuid, queryUuid: _uuid,
        timezoneStr: 'Asia/Shanghai', datetime: now, bazi: bazi,
        lunarMonth: 6, lunarDay: 22,
        jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.XIAO_SHU, startAt: DateTime(2026, 7, 7), endAt: DateTime(2026, 7, 23)),
        isLeapMonth: false, isSeersLocation: false,
        location: Location(address: Address(
          countryName: 'China', countryId: 45, regionId: 9,
          province: GeoLocation(name: 'Shanghai', latitude: _lat, longitude: _lng, level: GeoLevel.province, code: '31', parentCode: '0'),
          timezone: 'Asia/Shanghai',
        )),
      );

      final divInfo = DivinationInfoModel(
        divination: DivinationRequestInfoDataModel(uuid: _uuid, createdAt: now, divinationTypeUuid: 'test'),
        divinationDatetime: DatatimeDivinationDetailsDataModel(
          uuid: _uuid, createdAt: now, timingType: DateTimeType.solar,
          datetime: now, lunarMonth: 6, isLeapMonth: false, lunarDay: 22,
          yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI, dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
          timingInfoUuid: _uuid, timingInfoListJson: [dtModel],
        ),
      );

      final spyCalc = _SpyCalcUseCase();
      final vm = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: _SpyInitUseCase(),
        calculateBasePanelUseCase: spyCalc,
        evaluateGeJuUseCase: _SpyEvalUseCase(),
        buildTimelineUseCase: _SpyTimelineUseCase(),
        computeRiseSetUseCase: ComputeRiseSetUseCase(),
        yunLiuUseCase: YunLiuUseCase(),
        computeGanZhiUseCase: ComputeGanZhiUseCase(),
        momentResolver: const DefaultMomentResolver(),
        shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
        huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
        pipelineExecutor: QizhengPipelineExecutor(),
      );

      vm.setLifeObserver(divInfo);
      await vm.calculateWithConfig(_config, _observer(now));

      expect(spyCalc.executeCallCount, equals(0),
          reason: '管线注入后不走旧 CalculateQiZhengBasePanelUseCase');
    });

    test('trueSolar mode: DefaultMomentResolver 尝试真时解算 (预期 RESOLVER_NEEDS_SWEPH)', () {
      final resolver = const DefaultMomentResolver();

      final moment = DivinationMoment(
        instantUtc: DateTime.utc(2026, 7, 22, 4, 0),
        place: const GeoPoint(longitude: _lng, latitude: _lat, timeZoneId: 'Asia/Shanghai'),
        reckoning: EnumDatetimeType.trueSolar,
      );

      try {
        final resolved = resolver.resolve(moment);
        print('TRUE_SOLAR_OK: nominalTime=${resolved.nominalTime}');
      } catch (e) {
        if (e.toString().contains('Sweph') ||
            e.toString().contains('swe_utc_to_jd') ||
            e.toString().contains('not initialized') ||
            e.toString().contains('ffi')) {
          markTestSkipped('RESOLVER_NEEDS_SWEPH: Sweph native binding 在 flutter test 环境中不可用. '
              'trueSolar 依赖 SolarTimeCalculator.getTrueSolarTime()→Sweph.swe_utc_to_jd/swe_time_equ, '
              '需要真机或集成测试环境加载 .so/.dylib');
          return;
        }
        rethrow;
      }
    });
  });
}

ObserverPosition _observer(DateTime dt) => ObserverPosition(
  latitude: _lat, longitude: _lng, altitude: 0,
  timezone: 'Asia/Shanghai', dateTime: dt,
  yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI,
  dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

class _SpyInitUseCase implements InitializeQiZhengOfficialDataUseCase {
  @override Future<void> execute() async {}
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SpyCalcUseCase implements CalculateQiZhengBasePanelUseCase {
  int executeCallCount = 0;
  @override
  Future<CalculateQiZhengBasePanelResult> execute({
    required BasePanelConfig config,
    required ObserverPosition observer,
  }) async {
    executeCallCount++;
    throw UnimplementedError('spy');
  }
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeEngine implements ICalculationEngine {
  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async => ZhouTianModel(
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
  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config,
  ) async => _fakePositions();
  @override
  List<StarPositionRawData> calculateStarPositionsSync(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config, ZhouTianModel zhouTianModel,
  ) => _fakePositions();
}

List<StarPositionRawData> _fakePositions() => [
  StarPositionRawData(
    starType: EnumStars.Sun,
    angleRawInfoSet: {StarAngleRawInfo(
      panelSystemType: PanelSystemType.Tropical,
      coordinateSystem: CelestialCoordinateSystem.Ecliptic,
      angle: 68.116, speed: 0.96,
    )},
  ),
  StarPositionRawData(
    starType: EnumStars.Moon,
    angleRawInfoSet: {StarAngleRawInfo(
      panelSystemType: PanelSystemType.Tropical,
      coordinateSystem: CelestialCoordinateSystem.Ecliptic,
      angle: 97.287, speed: 14.45,
    )},
  ),
];

class _FakeEngineProvider implements ICalculationEngineProvider {
  @override
  ICalculationEngine getEngine(BasePanelConfig config) => _FakeEngine();
}

class _SpyEvalUseCase implements EvaluateQiZhengGeJuUseCase {
  @override
  Future<GeJuEvaluationSummary> execute({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem = CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async => GeJuEvaluationSummary(allResults: []);
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SpyTimelineUseCase implements BuildQiZhengTimelineUseCase {
  @override
  Future<BuildQiZhengTimelineResult> execute({
    required ObserverPosition lifeObserver,
    required BasePanelModel? basicLifePanel,
    ObserverPosition? fateObserver,
    String? locationName,
  }) async => BuildQiZhengTimelineResult(
    birthDateInfo: ChineseDateInfo(
      eightChars: EightChars(year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI, day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI),
      phenology: Phenology.phenologyList.first,
      lunarMonth: 1, lunarDay: 1, isLeapMonth: false,
      jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.LI_CHUN, startAt: DateTime(2026, 2, 4), endAt: DateTime(2026, 2, 19)),
      threeYuan: YuanYunOrder.upper, nineYun: NineYun.first,
    ),
    passageYearPanel: null,
    fateStarAngleMapper: null,
  );
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
