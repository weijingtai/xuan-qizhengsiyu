// T-Q7-PERSIST: 七政 Pipeline 落库测试
//
// 验收范围：
//   T-Q7-P1: setLifeObserver → calculateWithConfig → 落库恰好一次，panelModel 为同一对象
//   T-Q7-P2: 跳过 setLifeObserver，直接走 calculate → 不崩、不落库、排盘结果照常产出

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
import 'package:metaphysics_core/models/twelve_zhang_sheng.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/pan_entity.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/star_position_raw_data.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_pipeline_executor.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/save_calculated_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';
import 'package:xuan_time_location/xuan_time_location.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

// ============================================================
// 测试常量
// ============================================================
const _uuid = 'persist-test-01';
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

// ============================================================
// 辅助函数
// ============================================================

ObserverPosition _observer(DateTime dt) => ObserverPosition(
      latitude: _lat,
      longitude: _lng,
      altitude: 0,
      timezone: 'Asia/Shanghai',
      dateTime: dt,
      yearGanZhi: JiaZi.JIA_ZI,
      monthGanZhi: JiaZi.JIA_ZI,
      dayGanZhi: JiaZi.JIA_ZI,
      timeGanZhi: JiaZi.JIA_ZI,
      isDayBirth: true,
    );

DivinationInfoModel _buildDivInfo(DateTime now) {
  final bazi = EightChars(
    year: JiaZi.JIA_ZI,
    month: JiaZi.JIA_ZI,
    day: JiaZi.JIA_ZI,
    time: JiaZi.JIA_ZI,
  );
  final dtModel = DivinationDatetimeModel.standard(
    uuid: _uuid,
    queryUuid: _uuid,
    timezoneStr: 'Asia/Shanghai',
    datetime: now,
    bazi: bazi,
    lunarMonth: 6,
    lunarDay: 22,
    jieQiInfo: JieQiInfo(
      jieQi: TwentyFourJieQi.XIAO_SHU,
      startAt: DateTime(2026, 7, 7),
      endAt: DateTime(2026, 7, 23),
    ),
    isLeapMonth: false,
    isSeersLocation: false,
    location: Location(
      address: Address(
        countryName: 'China',
        countryId: 45,
        regionId: 9,
        province: GeoLocation(
          name: 'Shanghai',
          latitude: _lat,
          longitude: _lng,
          level: GeoLevel.province,
          code: '31',
          parentCode: '0',
        ),
        timezone: 'Asia/Shanghai',
      ),
    ),
  );

  return DivinationInfoModel(
    divination: DivinationRequestInfoDataModel(
      uuid: _uuid,
      createdAt: now,
      divinationTypeUuid: 'test',
    ),
    divinationDatetime: DatatimeDivinationDetailsDataModel(
      uuid: _uuid,
      createdAt: now,
      timingType: DateTimeType.solar,
      datetime: now,
      lunarMonth: 6,
      isLeapMonth: false,
      lunarDay: 22,
      yearGanZhi: JiaZi.JIA_ZI,
      monthGanZhi: JiaZi.JIA_ZI,
      dayGanZhi: JiaZi.JIA_ZI,
      timeGanZhi: JiaZi.JIA_ZI,
      timingInfoUuid: _uuid,
      timingInfoListJson: [dtModel],
    ),
  );
}

/// 构造最小化的合法 ZhouTianModel（供 calculateUIStars 使用）
ZhouTianModel _fakeZhouTianModel() => ZhouTianModel(
      systemType: CelestialCoordinateSystem.Ecliptic,
      constellationSystemType: ConstellationSystemType.Modern,
      panelSystemType: PanelSystemType.Tropical,
      epochCorrection: 'default',
      totalDegree: 360.0,
      gongDegreeSeq: List.generate(
        12,
        (i) => GongDegree(gong: EnumTwelveGong.listAll[i], degree: 30.0),
      ),
      starInnDegreeSeq: List.generate(
        28,
        (i) => ConstellationDegree(
          constellation: Enum28Constellations.values[i],
          degree: i < 27 ? 12.86 : 12.78,
        ),
      ),
      alignmentPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Xu_Ri_Shu,
        degree: 6.0,
      ),
      alignmentPointAtGong:
          GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
      zeroPointJieQi: TwentyFourJieQi.CHUN_FEN,
      zeroPointAtConstellation: ConstellationDegree(
        constellation: Enum28Constellations.Shi_Huo_Zhu,
        degree: 6.5,
      ),
      zeroPointAtGong: GongDegree(gong: EnumTwelveGong.Xu, degree: 0.0),
      celestialLongitude: 0.0,
      zeroPointOffsetToNow: 0.0,
      rightAscension: 0.0,
      specificationList: const ['baseline'],
      gongOrder: EnumTwelveGong.listAll,
      starInnOrder: Enum28Constellations.values,
    );

/// 构造最小化合法 BasePanelModel（所有 Map 为空）
BasePanelModel _makeMinimalPanel() => BasePanelModel(
      starAngleMapper: {},
      enteredGongMapper: {},
      fiveStarWalkingTypeMapper: {},
      bodyLifeModel: BodyLifeModel(
        lifeGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
        lifeConstellationInfo: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu,
          degree: 0.0,
        ),
        bodyGongInfo: GongDegree(gong: EnumTwelveGong.Zi, degree: 0.0),
        bodyConstellationInfo: ConstellationDegree(
          constellation: Enum28Constellations.Xu_Ri_Shu,
          degree: 0.0,
        ),
      ),
      twelveGongMapper: {},
      shenShaItemMapper: {},
      huaYaoItemMapper: {},
      twelveZhangShengGongMapper: {},
    );

// ============================================================
// Fake 神煞 / 化曜 仓储
// ============================================================

final _otherShenShaData = [
  OtherShenSha('斗杓', JiXiongEnum.DA_JI, null, null),
  OtherShenSha('卦气', JiXiongEnum.DA_JI, null, null),
  OtherShenSha('禄卦', JiXiongEnum.DA_JI, null, null),
  OtherShenSha('岁殿', JiXiongEnum.DA_JI, null, null),
  OtherShenSha('月廉', JiXiongEnum.DA_JI, null, null),
];

class _FakeShenShaRepo implements ShenShaRepository {
  @override
  Future<List<OtherShenSha>> getOtherShenSha() async => _otherShenShaData;
  @override
  Future<List<GanZhiShenSha>> getGanZhiShenSha() async => [];
  @override
  Future<List<TianGanShenSha>> getTianGanShenSha() async => [];
  @override
  Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => [];
  @override
  Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => [];
  @override
  Future<List<BundledShenSha>> getBundledShenSha() async => [
        BundledShenSha(
          BundledShenShaType.afterJia,
          '红鸾',
          JiXiongEnum.JI,
          0,
          <String>[],
          <String>[],
        ),
      ];
}

class _FakeHuaYaoRepo implements HuaYaoRepository {
  @override
  Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override
  Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override
  Future<List<OthersHuaYao>> getOthersHuaYao() async =>
      ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元']
          .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[],
              ShenShaType.Others))
          .toList();
}

// ============================================================
// Fake 计算引擎（给 CalculationEngineFactory 用）
// ============================================================

class _FakeEngine implements ICalculationEngine {
  @override
  Future<ZhouTianModel> getSystemDefinition(BasePanelConfig config) async =>
      _fakeZhouTianModel();

  @override
  Future<List<StarPositionRawData>> calculateStarPositions(
    DateTime birthDate,
    ObserverPosition position,
    BasePanelConfig config,
  ) async =>
      _fakePositions();

  @override
  List<StarPositionRawData> calculateStarPositionsSync(
    DateTime birthDate,
    ObserverPosition position,
    BasePanelConfig config,
    ZhouTianModel zhouTianModel,
  ) =>
      _fakePositions();
}

List<StarPositionRawData> _fakePositions() => [
      StarPositionRawData(
        starType: EnumStars.Sun,
        angleRawInfoSet: {
          StarAngleRawInfo(
            panelSystemType: PanelSystemType.Tropical,
            coordinateSystem: CelestialCoordinateSystem.Ecliptic,
            angle: 68.116,
            speed: 0.96,
          )
        },
      ),
      StarPositionRawData(
        starType: EnumStars.Moon,
        angleRawInfoSet: {
          StarAngleRawInfo(
            panelSystemType: PanelSystemType.Tropical,
            coordinateSystem: CelestialCoordinateSystem.Ecliptic,
            angle: 97.287,
            speed: 14.45,
          )
        },
      ),
    ];

class _FakeEngineProvider implements ICalculationEngineProvider {
  @override
  ICalculationEngine getEngine(BasePanelConfig config) => _FakeEngine();
}

// ============================================================
// Spy/Fake UseCase 存根
// ============================================================

class _SpyInitUseCase implements InitializeQiZhengOfficialDataUseCase {
  @override
  Future<void> execute() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SpyEvalUseCase implements EvaluateQiZhengGeJuUseCase {
  @override
  Future<GeJuEvaluationSummary> execute({
    required BasePanelModel panelModel,
    required Set<ElevenStarsInfo> starsSet,
    required DiZhi monthZhi,
    required JiaZi yearJiaZi,
    CelestialCoordinateSystem coordinateSystem =
        CelestialCoordinateSystem.Ecliptic,
    Set<String> preferredSchools = const {'guo_lao'},
    bool onlyMatched = false,
  }) async =>
      GeJuEvaluationSummary(allResults: []);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SpyTimelineUseCase implements BuildQiZhengTimelineUseCase {
  @override
  Future<BuildQiZhengTimelineResult> execute({
    required ObserverPosition lifeObserver,
    required BasePanelModel? basicLifePanel,
    ObserverPosition? fateObserver,
    String? locationName,
  }) async =>
      BuildQiZhengTimelineResult(
        birthDateInfo: ChineseDateInfo(
          eightChars: EightChars(
            year: JiaZi.JIA_ZI,
            month: JiaZi.JIA_ZI,
            day: JiaZi.JIA_ZI,
            time: JiaZi.JIA_ZI,
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
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// 老路径计算用的 Fake（返回最小合法结果，不调用真实引擎）
class _FakeCalcUseCase extends CalculateQiZhengBasePanelUseCase {
  _FakeCalcUseCase()
      : super(
          shenShaManager: ShenShaManager(
            shenShaService:
                ShenShaService(repository: _FakeShenShaRepo()),
          ),
          huaYaoManager: HuaYaoManager(
            huaYaoService:
                HuaYaoService(repository: _FakeHuaYaoRepo()),
          ),
        );

  @override
  Future<CalculateQiZhengBasePanelResult> execute({
    required BasePanelConfig config,
    required ObserverPosition observer,
  }) async {
    return CalculateQiZhengBasePanelResult(
      basicLifePanel: _makeMinimalPanel(),
      zhouTianModel: _fakeZhouTianModel(),
      starAngleMapper: {},
    );
  }
}

// ============================================================
// Spy SaveCalculatedPanelUseCase
// ============================================================

/// 空实现的盘库仓储（spy 的父类构造需要，execute 已被覆盖不会实际调用）
class _NoOpPanRepo implements IQiZhengSiYuPanRepository {
  @override
  Future<void> save(QiZhengSiYuPanContract contract) async {}
  @override
  Future<QiZhengSiYuPanContract?> findByUuid(String uuid) async => null;
  @override
  Future<void> update(QiZhengSiYuPanContract contract) async {}
  @override
  Future<void> delete(String uuid) async {}
  @override
  Future<void> permanentlyDelete(String uuid) async {}
  @override
  Future<List<QiZhengSiYuPanContract>> findAllActive() async => [];
  @override
  Future<List<QiZhengSiYuPanContract>> findByDivinationUuid(
      String divinationUuid) async =>
      [];
  @override
  Future<List<QiZhengSiYuPanContract>> findByDateRange(
      DateTime startDate, DateTime endDate) async =>
      [];
  @override
  Future<PaginatedResult<QiZhengSiYuPanContract>> findWithPagination(
      {int page = 1, int pageSize = 20}) async =>
      PaginatedResult(
          items: [], totalCount: 0, page: 1, pageSize: 20, totalPages: 0);
  @override
  Future<List<QiZhengSiYuPanContract>> search({
    String? divinationUuid,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async =>
      [];
  @override
  Future<int> getTotalCount() async => 0;
  @override
  Future<int> getTodayCount() async => 0;
  @override
  Future<List<QiZhengSiYuPanContract>> getRecent({int limit = 10}) async => [];
  @override
  Future<bool> existsByUuid(String uuid) async => false;
  @override
  Future<void> saveBatch(List<QiZhengSiYuPanContract> contracts) async {}
  @override
  Future<int> cleanupExpiredData({int daysOld = 30}) async => 0;
}

/// 空实现的 Record 仓储
class _NoOpRecordRepo implements QiZhengRecordRepository {
  @override
  Future<String> saveRecord(QiZhengSiYuPanContract record) async => '';
  @override
  Future<List<QiZhengSiYuPanContract>> getAllRecords() async => [];
  @override
  Future<QiZhengSiYuPanContract?> getRecordByUuid(String uuid) async => null;
  @override
  Future<bool> softDeleteRecord(String uuid) async => false;
  @override
  Stream<List<QiZhengSiYuPanContract>> watchAllRecords() =>
      const Stream.empty();
}

/// 落库 Spy：记录调用次数和最后一次 panelModel
class _SpySaveUseCase extends SaveCalculatedPanelUseCase {
  int executeCallCount = 0;
  BasePanelModel? lastPanelModel;
  BasePanelConfig? lastPanelConfig;
  String? lastUuid;

  _SpySaveUseCase()
      : super(
          qiZhengSiYuPanRepository: _NoOpPanRepo(),
          recordRepository: _NoOpRecordRepo(),
        );

  @override
  Future<QiZhengSiYuPanEntity> execute({
    required BasePanelModel basicPanelModel,
    required BasePanelConfig panelConfig,
    required DivinationDatetimeModel divinationDatetimeModel,
    required DivinationRequestInfoDataModel requestInfo,
    String? uuid,
  }) async {
    executeCallCount++;
    lastPanelModel = basicPanelModel;
    lastPanelConfig = panelConfig;
    lastUuid = uuid;
    return QiZhengSiYuPanEntity(
      uuid: uuid ?? 'spy-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      deletedAt: null,
      divinationRequestInfoUuid: requestInfo.uuid,
      panelConfig: panelConfig,
      panelModel: basicPanelModel,
      divinationDatetimeModel: divinationDatetimeModel,
    );
  }
}

// ============================================================
// 主测试
// ============================================================

void main() {
  group('T-Q7-PERSIST: 七政 Pipeline 落库', () {
    setUpAll(() {
      tz_data.initializeTimeZones();
      // T-Q7-P3 复刻 devInit() 用 'Asia/Beijing' 构造 ObserverPosition，
      // 该字符串不是 IANA 标准时区名，需与生产 di.dart 一样显式注册别名，
      // 否则 ObserverPosition.toUtcTime() 会抛 LocationNotFoundException。
      ensureChinaTimeZoneAlias();
    });

    setUp(() {
      CalculationEngineFactory.setProvider(_FakeEngineProvider());
    });

    // ----------------------------------------------------------
    // T-Q7-P1: 落库成功路径
    // ----------------------------------------------------------
    test(
      'T-Q7-P1: setLifeObserver → calculateWithConfig → '
      '落库恰好一次，panelModel 为同一对象',
      () async {
        final now = DateTime(2026, 7, 22, 6, 30);
        final divInfo = _buildDivInfo(now);
        final spySave = _SpySaveUseCase();

        final vm = QiZhengSiYuViewModel(
          initializeOfficialDataUseCase: _SpyInitUseCase(),
          calculateBasePanelUseCase: _FakeCalcUseCase(),
          evaluateGeJuUseCase: _SpyEvalUseCase(),
          buildTimelineUseCase: _SpyTimelineUseCase(),
          computeRiseSetUseCase: ComputeRiseSetUseCase(),
          yunLiuUseCase: YunLiuUseCase(),
          computeGanZhiUseCase: ComputeGanZhiUseCase(),
          momentResolver: const DefaultMomentResolver(),
          shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
          huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
          pipelineExecutor: QizhengPipelineExecutor(),
          saveCalculatedPanelUseCase: spySave,
        );

        vm.setLifeObserver(divInfo);
        await vm.calculateWithConfig(_config, _observer(now));
        // 等待 fire-and-forget 的落库 Future 完成
        await Future<void>.delayed(Duration.zero);

        expect(
          spySave.executeCallCount,
          equals(1),
          reason: 'pipeline 路径恰好落库一次',
        );
        expect(
          identical(spySave.lastPanelModel, vm.basicLifePanel),
          isTrue,
          reason: '传给落库 UseCase 的 panelModel 与 ViewModel 存储的为同一对象（零拷贝）',
        );
        expect(
          spySave.lastPanelConfig?.panelSystemType,
          equals(_config.panelSystemType),
          reason: 'panelConfig 正确传递',
        );
        // ── 执行证据：executor 真实执行 + 落库 uuid 同源 ──
        final evidence = vm.lastPipelineEvidence;
        expect(evidence, isNotNull, reason: 'pipeline 路径必须产出执行证据');
        expect(evidence!.callCount, 1, reason: 'executor 恰好执行一次');
        expect(evidence.requestId, isNotEmpty, reason: 'requestId 取排盘 uuid');
        expect(evidence.resultUuid, evidence.requestId,
            reason: 'resultUuid 与排盘 uuid 同源');
        expect(evidence.module, 'qizhengsiyu');
        expect(evidence.error, isNull, reason: '成功执行无异常');
        expect(evidence.keyResult, isNotNull, reason: '命宫是页面可观察结果');
        // 落库 Record 的 uuid == 排盘 uuid（证据链锚点）
        expect(
          spySave.lastUuid,
          evidence.requestId,
          reason: '落库 Record uuid 必须与排盘 uuid 同源',
        );
        expect(
          spySave.lastPanelModel,
          same(vm.basicLifePanel),
          reason: '落库对象与展示对象一致（零拷贝）',
        );
      },
    );

    // ----------------------------------------------------------
    // T-Q7-P2: 未初始化（跳过 setLifeObserver）不崩、不落库
    // ----------------------------------------------------------
    test(
      'T-Q7-P2: 跳过 setLifeObserver 直接 calculate → '
      '不抛异常、不触发落库、排盘结果照常产出',
      () async {
        final now = DateTime(2026, 7, 22, 6, 30);
        final spySave = _SpySaveUseCase();

        // 注意：不传 pipelineExecutor，走老路径（_savedDatetimeModel 为 null）
        final vm = QiZhengSiYuViewModel(
          initializeOfficialDataUseCase: _SpyInitUseCase(),
          calculateBasePanelUseCase: _FakeCalcUseCase(),
          evaluateGeJuUseCase: _SpyEvalUseCase(),
          buildTimelineUseCase: _SpyTimelineUseCase(),
          computeRiseSetUseCase: ComputeRiseSetUseCase(),
          yunLiuUseCase: YunLiuUseCase(),
          computeGanZhiUseCase: ComputeGanZhiUseCase(),
          saveCalculatedPanelUseCase: spySave,
          // 有意不传 momentResolver / pipelineExecutor → _resolvedMoment 始终为 null
          // → pipeline 分支不触发 → _savePanelAsync 不被调用
        );

        // 不调用 setLifeObserver
        // 用 calculate() 而非 calculateWithConfig()，以正确设置 _lifeObserver
        await vm.calculate(_observer(now));
        await Future<void>.delayed(Duration.zero);

        expect(
          spySave.executeCallCount,
          equals(0),
          reason: '未经 setLifeObserver 初始化，不应触发任何落库操作',
        );
        expect(
          vm.basicLifePanel,
          isNotNull,
          reason: '排盘结果仍由老路径产出，不为 null',
        );
        // 验证具体字段：空 Map 的 starAngleMapper（FakeCalc 返回 {}）
        expect(
          vm.basicLifePanel!.starAngleMapper,
          isEmpty,
          reason: 'FakeCalcUseCase 返回的 starAngleMapper 应为空 Map',
        );
      },
    );

    // ----------------------------------------------------------
    // T-Q7-P3: BeautyViewPage.devInit() 现有调用序列必须接通 Pipeline
    // ----------------------------------------------------------
    //
    // 背景（ORDER-QIZHENG-BEAUTY-VIEW-WIRING-FIX.md 一）：
    // lib/presentation/pages/beauty_view_page.dart 的 devInit() 构造硬编码
    // testObserver 后直接 await vm.calculate(testObserver)，从未调用
    // vm.setLifeObserver(...)。而 Pipeline 分支的前置条件 _resolvedMoment
    // 只在 setLifeObserver() 内部赋值（见 T-Q7-P2 的注释），导致真实页面
    // 排盘恒不进入 Pipeline 分支，lastPipelineEvidence 恒为 null，也不落
    // Record。
    //
    // 本用例在 ViewModel 层原样复刻 devInit() 现有调用序列的全部字面量
    // （DateTime(1990,1,1,12,0) / 纬度 39.9042 / 经度 116.4074 / 时区
    // Asia/Beijing / 干支 GENG_WU-WU_ZI-JIA_XU-GENG_WU），断言排盘完成后
    // lastPipelineEvidence 不应为 null —— 这是 devInit() 修复后的期望行为。
    //
    // 【红态说明】本提交刻意不调用 setLifeObserver，与 devInit() 现状保持
    // 同步缺失，用以证明接线缺口；修复 devInit() 的同一个提交会同步在此处
    // 补上与生产代码等价的 setLifeObserver 调用（两处 fixture 的时间/经
    // 纬度/时区严格一致，不引入第二套数据）。
    test(
      'T-Q7-P3: 复刻 BeautyViewPage.devInit() 调用序列 → '
      'lastPipelineEvidence 不应为 null（接线缺口修复前必然失败）',
      () async {
        final spySave = _SpySaveUseCase();

        final vm = QiZhengSiYuViewModel(
          initializeOfficialDataUseCase: _SpyInitUseCase(),
          calculateBasePanelUseCase: _FakeCalcUseCase(),
          evaluateGeJuUseCase: _SpyEvalUseCase(),
          buildTimelineUseCase: _SpyTimelineUseCase(),
          computeRiseSetUseCase: ComputeRiseSetUseCase(),
          yunLiuUseCase: YunLiuUseCase(),
          computeGanZhiUseCase: ComputeGanZhiUseCase(),
          momentResolver: const DefaultMomentResolver(),
          shenShaService: ShenShaService(repository: _FakeShenShaRepo()),
          huaYaoService: HuaYaoService(repository: _FakeHuaYaoRepo()),
          pipelineExecutor: QizhengPipelineExecutor(),
          saveCalculatedPanelUseCase: spySave,
        );

        await vm.init();

        // —— 以下与 beauty_view_page.dart devInit() 现有调用序列逐字对应 ——
        final testDateTime = DateTime(1990, 1, 1, 12, 0);
        final testObserver = ObserverPosition(
          dateTime: testDateTime,
          latitude: 39.9042, // 北京纬度
          longitude: 116.4074, // 北京经度
          altitude: 0,
          timezone: 'Asia/Beijing',
          isDayBirth: true,
          yearGanZhi: JiaZi.GENG_WU, // 庚午年 (1990)
          monthGanZhi: JiaZi.WU_ZI, // 戊子月
          dayGanZhi: JiaZi.JIA_XU, // 甲戌日
          timeGanZhi: JiaZi.GENG_WU, // 庚午时
        );

        // 当前 devInit() 现状：不调用 setLifeObserver，直接 calculate。
        await vm.calculate(testObserver);
        await Future<void>.delayed(Duration.zero);

        expect(
          vm.lastPipelineEvidence,
          isNotNull,
          reason:
              'devInit() 必须先 setLifeObserver() 再 calculate()，否则 '
              '_resolvedMoment 恒为 null，Pipeline 分支不会进入',
        );
      },
    );
  });
}
