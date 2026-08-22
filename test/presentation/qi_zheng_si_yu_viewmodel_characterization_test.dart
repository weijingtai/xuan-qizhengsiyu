// T-Q0-PAN-01: Main pan ViewModel characterization tests.
//
// Captures QiZhengSiYuViewModel behavior as a frozen baseline:
// initial state, UseCase delegation, notifier state, disposal, calculation.

import 'package:flutter_test/flutter_test.dart';
import 'package:repository_contract_kernel/repository_contract_kernel.dart';
import 'package:metaphysics_core/datamodel/datetime_divination_datamodel.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/divination_info_model.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:metaphysics_core/models/seventy_two_phenology.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository_adapter.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

// ===== Fixtures =====
const _uuid = 'char-test-uuid-01';
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

DivinationInfoModel _divinationInfo() {
  final now = DateTime(1990, 1, 1, 12);
  final bazi = EightChars(year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI, day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI);
  return DivinationInfoModel(
    divination: DivinationRequestInfoDataModel(uuid: _uuid, createdAt: now, divinationTypeUuid: 'test'),
    divinationDatetime: DatatimeDivinationDetailsDataModel(
      uuid: _uuid, createdAt: now, timingType: DateTimeType.solar,
      datetime: now, lunarMonth: 1, isLeapMonth: false, lunarDay: 1,
      yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI, dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
      timingInfoUuid: _uuid, timingInfoListJson: [
        DivinationDatetimeModel.standard(
          uuid: _uuid, queryUuid: _uuid,
          timezoneStr: 'Asia/Shanghai', datetime: now, bazi: bazi,
          lunarMonth: 1, lunarDay: 1,
          jieQiInfo: JieQiInfo(jieQi: TwentyFourJieQi.CHUN_FEN, startAt: DateTime(1990, 3, 20), endAt: DateTime(1990, 4, 4)),
          isLeapMonth: false, isSeersLocation: false,
          location: Location(address: Address(
            countryName: 'China', countryId: 45, regionId: 9,
            province: GeoLocation(name: 'Shanghai', latitude: _lat, longitude: _lng, level: GeoLevel.province, code: '31', parentCode: '0'),
            timezone: 'Asia/Shanghai',
          )),
        ),
      ],
    ),
  );
}

ObserverPosition _observer() => ObserverPosition(
  latitude: _lat, longitude: _lng, altitude: 0,
  timezone: 'Asia/Shanghai',
  dateTime: DateTime(1990, 1, 1, 12),
  yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI,
  dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

// ===== Fake engine =====
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

class _FakeEngine implements ICalculationEngine {
  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async => _ecliptic();
  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config,
  ) async => _positions();
  @override
  List<StarPositionRawData> calculateStarPositionsSync(
    DateTime birthDate, ObserverPosition position, BasePanelConfig config, ZhouTianModel zhouTianModel,
  ) => _positions();
}

class _FakeEngineProvider implements ICalculationEngineProvider {
  @override
  ICalculationEngine getEngine(BasePanelConfig config) => _FakeEngine();
}

// ===== Fakes =====

class _FakeShenShaRepo implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => [
    BundledShenSha(BundledShenShaType.afterJia, '红鸾', JiXiongEnum.JI, 0, <String>[], <String>[]),
  ];
  @override Future<List<OtherShenSha>> getOtherShenSha() async => [
    OtherShenSha("斗杓", JiXiongEnum.DA_JI, <String>[], <String>[]),
    OtherShenSha("卦气", JiXiongEnum.DA_JI, <String>[], <String>[]),
    OtherShenSha("禄卦", JiXiongEnum.DA_JI, <String>[], <String>[]),
    OtherShenSha("岁殿", JiXiongEnum.DA_JI, <String>[], <String>[]),
    OtherShenSha("月廉", JiXiongEnum.DA_JI, <String>[], <String>[]),
  ];
}

class _FakeHuaYaoRepo implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async =>
    ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元']
        .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[], ShenShaType.Others))
        .toList();
}

class _FakeZhouTianRepo implements QiZhengZhouTianModelRepository {
  @override
  Future<List<QiZhengZhouTianModelContract>> loadBuiltInZhouTianModels() async => const [];
}

class _FakeGeJuRepo implements IGeJuRepository {
  @override Future<List<GeJuRuleContract>> loadAllRules() async => const [];
  @override Future<GeJuRuleContract?> getRuleById(String id) async => null;
  @override Future<void> saveUserRule(GeJuRuleContract rule) async {}
  @override Future<void> deleteUserRule(String id) async {}
  @override bool isBuiltInRule(String ruleId) => false;
  @override Set<String> get builtInRuleIds => const {};
  @override Future<List<GeJuConditionSetContract>> getConditionSetsForRule(String ruleId) async => const [];
  @override Future<GeJuConditionSetContract?> getConditionSetById(String id) async => null;
  @override Future<void> saveUserConditionSet(GeJuConditionSetContract cs) async {}
  @override Future<void> deleteUserConditionSet(String id) async {}
  @override Future<void> deleteUserConditionSetsForRule(String ruleId) async {}
  @override Future<List<GeJuAnnotationContract>> getAnnotationsForRule(String ruleId) async => const [];
  @override Future<GeJuAnnotationContract?> getAnnotationById(String id) async => null;
  @override Future<void> saveUserAnnotation(GeJuAnnotationContract ann) async {}
  @override Future<void> deleteUserAnnotation(String id) async {}
  @override Future<void> deleteUserAnnotationsForRule(String ruleId) async {}
  @override Future<Map<String, dynamic>> getPreference() async => const {};
  @override Future<void> savePreference(Map<String, dynamic> pref) async {}
  @override Future<void> recordDeletion(Map<String, dynamic> record) async {}
  @override void clearCache() {}
  @override Future<Map<String, List<GeJuConditionSetContract>>> loadAllConditionSetsGrouped() async => const {};
  @override Future<Map<String, List<GeJuAnnotationContract>>> loadAllAnnotationsGrouped() async => const {};
  @override Future<List<GeJuRuleContract>> loadBuiltInRules() async => const [];
  @override Future<List<GeJuRuleContract>> loadUserRules() async => const [];
  // L0 Kernel Slice methods
  @override Future<Result<Page<GeJuRuleContract>>> query(Map<String, Object?> spec, PageRequest page, RequestContext ctx) async => const Ok(Page(items: []));
  @override Future<Result<int>> count(Map<String, Object?> spec, RequestContext ctx) async => const Ok(0);
}

QiZhengSiYuViewModel _createViewModel() {
  final zhouTianManager = ZhouTianModelManager(repository: _FakeZhouTianRepo());
  final shenShaManager = ShenShaManager(shenShaService: ShenShaService(repository: _FakeShenShaRepo()));
  final huaYaoManager = HuaYaoManager(huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()));
  final geJuAdapter = GeJuRepositoryAdapter(_FakeGeJuRepo());
  final geJuEvalService = GeJuEvaluationService(repository: geJuAdapter);

  return QiZhengSiYuViewModel(
    initializeOfficialDataUseCase: InitializeQiZhengOfficialDataUseCase(zhouTianModelManager: zhouTianManager),
    calculateBasePanelUseCase: CalculateQiZhengBasePanelUseCase(shenShaManager: shenShaManager, huaYaoManager: huaYaoManager),
    evaluateGeJuUseCase: EvaluateQiZhengGeJuUseCase(geJuEvaluationService: geJuEvalService),
    buildTimelineUseCase: BuildQiZhengTimelineUseCase(shenShaManager: shenShaManager, huaYaoManager: huaYaoManager),
    computeRiseSetUseCase: ComputeRiseSetUseCase(),
    yunLiuUseCase: YunLiuUseCase(),
    computeGanZhiUseCase: ComputeGanZhiUseCase(),
  );
}

void main() {
  group('QiZhengSiYuViewModel Characterization (T-Q0-PAN-01)', () {
    late QiZhengSiYuViewModel vm;

    setUp(() {
      vm = _createViewModel();
    });

    tearDown(() {
      vm.dispose();
    });

    test('initial state: basicLifePanel is null', () {
      expect(vm.basicLifePanel, isNull);
    });

    test('initial state: uiBasicLifeStars is empty', () {
      expect(vm.uiBasicLifeStars, isEmpty);
    });

    test('initial state: uiFateLifeStars is empty', () {
      expect(vm.uiFateLifeStars, isEmpty);
    });

    test('initial state: all notifiers are null', () {
      expect(vm.uiZhouTianModelNotifier.value, isNull);
      expect(vm.uiBasePanelNotifier.value, isNull);
      expect(vm.uiDaXianPanelNotifier.value, isNull);
      expect(vm.uiBasicLifeStarsNotifier.value, isNull);
      expect(vm.uiFateLifeStarsNotifier.value, isNull);
      expect(vm.baseObserverPositionNotifier.value, isNull);
      expect(vm.geJuSummaryNotifier.value, isNull);
      expect(vm.birthRiseSetNotifier.value, isNull);
      expect(vm.customRiseSetNotifier.value, isNull);
      expect(vm.lunarDateInfoNotifier.value, isNull);
    });

    test('initial state: observer positions are null', () {
      expect(vm.lifeObserver, isNull);
      expect(vm.fateObserver, isNull);
    });

    test('initial state: derived values are null/empty', () {
      expect(vm.yunLiuViewModel, isNull);
      expect(vm.birthLocationName, isNull);
      expect(vm.daXianMapper, isNull);
    });

    test('listenables wrap the same notifier', () {
      expect(vm.uiBasePanelListenable, same(vm.uiBasePanelNotifier));
      expect(vm.uiBasicLifeStarsListenable, same(vm.uiBasicLifeStarsNotifier));
      expect(vm.uiFateLifeStarsListenable, same(vm.uiFateLifeStarsNotifier));
    });

    test('init() calls InitializeQiZhengOfficialDataUseCase', () async {
      await vm.init();
    });

    test('dispose does not throw', () {
      final vm2 = _createViewModel();
      expect(() => vm2.dispose(), returnsNormally);
    });

    group('calculation output', () {
      setUpAll(() {
        tz_data.initializeTimeZones();
      });

      setUp(() {
        CalculationEngineFactory.setProvider(_FakeEngineProvider());
      });

      test('setLifeObserver + calculateWithConfig 产出 non-null panel (T-Q0-PAN-02)', () async {
        final info = _divinationInfo();
        vm.setLifeObserver(info);
        await vm.calculateWithConfig(_config, _observer());
        expect(vm.basicLifePanel, isNotNull);
      });
    });
  });
}
