import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/datetime_divination_datamodel.dart';
import 'package:metaphysics_core/datamodel/divination_request_info_datamodel.dart';
import 'package:metaphysics_core/datamodel/geo_location.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:metaphysics_core/models/divination_info_model.dart';
import 'package:metaphysics_core/models/eight_chars.dart';
import 'package:metaphysics_core/models/jie_qi_info.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/chinese_date_info.dart';
import 'package:metaphysics_core/models/seventy_two_phenology.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_pipeline_executor.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

// ── Shared fixture ──────────────────────────────────────────────
const _uuid = 'equiv-test-uuid-01';
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

ObserverPosition _observer() => ObserverPosition(
  latitude: _lat, longitude: _lng, altitude: 0,
  timezone: 'Asia/Shanghai',
  dateTime: DateTime(1990, 1, 1, 12),
  yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI,
  dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
  isDayBirth: true,
);

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

List<BundledShenSha> _bundled() => [
  BundledShenSha(BundledShenShaType.afterJia, '红鸾', JiXiongEnum.JI, 0, <String>[], <String>[]),
];

List<OtherShenSha> _other() => ['斗杓', '卦气', '禄卦', '岁殿', '月廉']
    .map((n) => OtherShenSha(n, JiXiongEnum.JI, <String>[], <String>[]))
    .toList();

List<OthersHuaYao> _othersHuaYao() => ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元']
    .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[], ShenShaType.Others))
    .toList();

// ── Fake engine ─────────────────────────────────────────────────
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

// ── Fake repos ──────────────────────────────────────────────────
class _FakeShenShaRepo implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => _bundled();
  @override Future<List<OtherShenSha>> getOtherShenSha() async => _other();
}

class _FakeHuaYaoRepo implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => _othersHuaYao();
}

// ── Fake moment resolver ────────────────────────────────────────
class _FakeMomentResolver implements MomentResolver {
  @override
  ResolvedMoment resolve(DivinationMoment moment) => ResolvedMoment(
    source: moment,
    nominalTime: DateTime(1990, 1, 1, 12),
    eightChars: EightChars(
      year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
      day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
    ),
    lunar: LunarDate(month: 1, day: 1, isLeapMonth: false),
    jieQi: JieQiInfo(
      jieQi: TwentyFourJieQi.CHUN_FEN,
      startAt: DateTime(1990, 3, 20), endAt: DateTime(1990, 4, 4),
    ),
  );
  @override
  List<ResolvedMoment> resolveCandidates(DivinationMoment moment, CandidateSpec spec) => [];
}

// ── Spy use cases ──────────────────────────────────────────────
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
      eightChars: EightChars(
        year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
      ),
      phenology: Phenology.phenologyList.first,
      lunarMonth: 1,
      lunarDay: 1,
      isLeapMonth: false,
      jieQiInfo: JieQiInfo(
        jieQi: TwentyFourJieQi.LI_CHUN,
        startAt: DateTime(2026, 2, 4),
        endAt: DateTime(2026, 2, 19),
      ),
      threeYuan: YuanYunOrder.upper,
      nineYun: NineYun.first,
    ),
    passageYearPanel: null,
    fateStarAngleMapper: null,
  );
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ── Tests ──────────────────────────────────────────────────────
void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  setUp(() {
    CalculationEngineFactory.setProvider(_FakeEngineProvider());
  });

  group('T-Q4-EQUIV: 新旧排盘路径等价', () {
    test('管线注入后 calculateWithConfig 不走旧 UseCase', () async {
      final spyCalc = _SpyCalcUseCase();
      final vm = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: _SpyInitUseCase(),
        calculateBasePanelUseCase: spyCalc,
        evaluateGeJuUseCase: _SpyEvalUseCase(),
        buildTimelineUseCase: _SpyTimelineUseCase(),
        computeRiseSetUseCase: ComputeRiseSetUseCase(),
        yunLiuUseCase: YunLiuUseCase(),
        computeGanZhiUseCase: ComputeGanZhiUseCase(),
        momentResolver: _FakeMomentResolver(),
        shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
        huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
        pipelineExecutor: QizhengPipelineExecutor(),
      );

      vm.setLifeObserver(_divinationInfo());
      await vm.calculateWithConfig(_config, _observer());

      expect(spyCalc.executeCallCount, equals(0),
          reason: '管线注入后不走旧 CalculateQiZhengBasePanelUseCase');
    });

    test('新旧路径产出等值 panelModel (T-Q4-EQUIV-02)', () async {
      final shenShaService = ShenShaService(repository: _FakeShenShaRepo());
      final huaYaoService = HuaYaoService(repository: _FakeHuaYaoRepo());
      final shenShaManager = ShenShaManager(shenShaService: shenShaService);
      final huaYaoManager = HuaYaoManager(huaYaoService: huaYaoService);

      // 旧路径: ShenShaManager + HuaYaoManager + CalculateQiZhengBasePanelUseCase
      final oldVm = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: _SpyInitUseCase(),
        calculateBasePanelUseCase: CalculateQiZhengBasePanelUseCase(
          shenShaManager: shenShaManager,
          huaYaoManager: huaYaoManager,
        ),
        evaluateGeJuUseCase: _SpyEvalUseCase(),
        buildTimelineUseCase: _SpyTimelineUseCase(),
        computeRiseSetUseCase: ComputeRiseSetUseCase(),
        yunLiuUseCase: YunLiuUseCase(),
        computeGanZhiUseCase: ComputeGanZhiUseCase(),
      );

      // 新路径: MomentResolver + ShenShaService + HuaYaoService + QizhengPipelineExecutor
      final newVm = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: _SpyInitUseCase(),
        calculateBasePanelUseCase: _SpyCalcUseCase(),
        evaluateGeJuUseCase: _SpyEvalUseCase(),
        buildTimelineUseCase: _SpyTimelineUseCase(),
        computeRiseSetUseCase: ComputeRiseSetUseCase(),
        yunLiuUseCase: YunLiuUseCase(),
        computeGanZhiUseCase: ComputeGanZhiUseCase(),
        momentResolver: _FakeMomentResolver(),
        shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
        huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
        pipelineExecutor: QizhengPipelineExecutor(),
      );

      oldVm.setLifeObserver(_divinationInfo());
      newVm.setLifeObserver(_divinationInfo());

      await oldVm.calculateWithConfig(_config, _observer());
      await newVm.calculateWithConfig(_config, _observer());

      final oldModel = oldVm.basicLifePanel;
      final newModel = newVm.basicLifePanel;

      expect(oldModel, isNotNull, reason: '旧路径应产出 non-null panel');
      expect(newModel, isNotNull, reason: '新路径应产出 non-null panel');

      expect(newModel!.twelveGongMapper, equals(oldModel!.twelveGongMapper),
          reason: '十二宫映射一致');
      expect(newModel.twelveZhangShengGongMapper, equals(oldModel.twelveZhangShengGongMapper),
          reason: '十二长生映射一致');
      expect(newModel.bodyLifeModel.lifeGongInfo.gong, equals(oldModel.bodyLifeModel.lifeGongInfo.gong),
          reason: '命宫一致');
      expect(newModel.bodyLifeModel.bodyGongInfo.gong, equals(oldModel.bodyLifeModel.bodyGongInfo.gong),
          reason: '身宫一致');

      final oldStars = oldModel.starAngleMapper.map((k, v) => MapEntry(k, [v.angle, v.speed]));
      final newStars = newModel.starAngleMapper.map((k, v) => MapEntry(k, [v.angle, v.speed]));
      expect(newStars, equals(oldStars),
          reason: '星体位置(angle/speed)一致');
    });
  });
}

DivinationInfoModel _divinationInfo() {
  final now = DateTime(1990, 1, 1, 12);
  final bazi = EightChars(
    year: JiaZi.JIA_ZI, month: JiaZi.JIA_ZI,
    day: JiaZi.JIA_ZI, time: JiaZi.JIA_ZI,
  );
  return DivinationInfoModel(
    divination: DivinationRequestInfoDataModel(
      uuid: _uuid, createdAt: now, divinationTypeUuid: 'test',
    ),
    divinationDatetime: DatatimeDivinationDetailsDataModel(
      uuid: _uuid, createdAt: now,
      timingType: DateTimeType.solar,
      datetime: now, lunarMonth: 1, isLeapMonth: false, lunarDay: 1,
      yearGanZhi: JiaZi.JIA_ZI, monthGanZhi: JiaZi.JIA_ZI,
      dayGanZhi: JiaZi.JIA_ZI, timeGanZhi: JiaZi.JIA_ZI,
      timingInfoUuid: _uuid,
      timingInfoListJson: [
        DivinationDatetimeModel.standard(
          uuid: _uuid, queryUuid: _uuid,
          timezoneStr: 'Asia/Shanghai', datetime: now, bazi: bazi,
          lunarMonth: 1, lunarDay: 1,
          jieQiInfo: JieQiInfo(
            jieQi: TwentyFourJieQi.CHUN_FEN,
            startAt: DateTime(1990, 3, 20), endAt: DateTime(1990, 4, 4),
          ),
          isLeapMonth: false, isSeersLocation: false,
          location: Location(
            address: Address(
              countryName: 'China', countryId: 45, regionId: 9,
              province: GeoLocation(
                name: 'Shanghai',
                latitude: _lat, longitude: _lng,
                level: GeoLevel.province, code: '31', parentCode: '0',
              ),
              timezone: 'Asia/Shanghai',
            ),
          ),
        ),
      ],
    ),
  );
}
