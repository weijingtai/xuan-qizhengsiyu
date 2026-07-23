import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/divination_datetime.dart' show EnumDatetimeType;
import 'package:timezone/data/latest_all.dart' as tz_data;
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
import 'package:qizhengsiyu/domain/entities/models/star_angle_speed.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_calculator.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_calculation_context.dart';
import 'package:qizhengsiyu/domain/pipeline/qizheng_chart_params.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';

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

Map<EnumStars, StarAngleSpeed> _angleMapper() {
  final m = <EnumStars, StarAngleSpeed>{};
  for (final p in _positions()) {
    final i = p.angleRawInfoSet.first;
    m[p.starType] = StarAngleSpeed(angle: i.angle, speed: i.speed);
  }
  return m;
}

final _config = BasePanelConfig(
  celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
  houseDivisionSystem: HouseDivisionSystem.equal,
  panelSystemType: PanelSystemType.Tropical,
  constellationSystemType: ConstellationSystemType.Modern,
  settleLifeType: EnumSettleLifeType.Mao,
  settleBodyType: EnumSettleBodyType.moon,
  islifeGongBySunRealTimeLocation: true,
);

QizhengChartParams _params() => QizhengChartParams(
  uuid: _uuid,
  createdAt: _now,
  lastUpdatedAt: _now,
  divinationRequestInfoUuid: _uuid,
  panelConfig: _config,
  observerPosition: _observer(),
);

void main() {
  late QizhengCalculationContext ctx;
  late QizhengChartCalculator calculator;
  late ResolvedMoment moment;

  setUp(() {
    tz_data.initializeTimeZones();
    ctx = QizhengCalculationContext(
      zhouTianModel: _ecliptic(),
      starAngleMapper: _angleMapper(),
      otherShenSha: _other(),
      ganZhiShenSha: const [],
      tianGanShenSha: const [],
      yearDiZhiShenSha: const [],
      monthDiZhiShenSha: const [],
      bundledShenSha: _bundled(),
      tianGanHuaYao: const [],
      diZhiHuaYao: const [],
      othersHuaYao: _othersHuaYao(),
    );
    calculator = QizhengChartCalculator(context: ctx);
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

  test('red: calculator constructs and returns contract', () {
    expect(calculator.module, equals('qizhengsiyu'));
    final contract = calculator.calculate(moment, _params());
    expect(contract, isA<QiZhengSiYuPanContract>());
    expect(contract.uuid, equals(_uuid));
  });

  test('is deterministic — same input twice produces equal contract', () {
    final a = calculator.calculate(moment, _params());
    final b = calculator.calculate(moment, _params());
    expect(a, equals(b));
  });
}
