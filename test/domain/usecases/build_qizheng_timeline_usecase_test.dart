import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao_shen_sha.dart';

List<OtherShenSha> _fakeOtherShenSha() {
  final names = ['斗杓', '卦气', '禄卦', '岁殿', '月廉'];
  return names
      .map((n) => OtherShenSha(n, JiXiongEnum.JI, <String>[], <String>[]))
      .toList();
}

List<BundledShenSha> _fakeBundledShenSha() {
  return [
    BundledShenSha(BundledShenShaType.afterJia, '红鸾', JiXiongEnum.JI, 0, <String>[], <String>[]),
  ];
}

List<OthersHuaYao> _fakeOthersHuaYao() {
  final names = ['科甲', '天经', '地纬', '天元禄', '人元禄', '地元禄', '职元', '局主', '马元', '寿元'];
  return names
      .map((n) => OthersHuaYao(n, JiXiongEnum.JI, <String>[], <String>[], ShenShaType.Others))
      .toList();
}

class FakeShenShaRepository implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => _fakeBundledShenSha();
  @override Future<List<OtherShenSha>> getOtherShenSha() async => _fakeOtherShenSha();
}

class FakeHuaYaoRepository implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => _fakeOthersHuaYao();
}

ObserverPosition _testObserver() {
  return ObserverPosition(
    latitude: 31.2,
    longitude: 121.5,
    altitude: 0,
    timezone: 'Asia/Shanghai',
    dateTime: DateTime(2000, 1, 1, 12, 0),
    isDayBirth: true,
    yearGanZhi: JiaZi.JIA_ZI,
    monthGanZhi: JiaZi.JIA_ZI,
    dayGanZhi: JiaZi.JIA_ZI,
    timeGanZhi: JiaZi.JIA_ZI,
  );
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('BuildQiZhengTimelineUseCase', () {
    late BuildQiZhengTimelineUseCase useCase;

    setUp(() {
      final shenShaRepo = FakeShenShaRepository();
      final huaYaoRepo = FakeHuaYaoRepository();
      final shenShaService = ShenShaService(repository: shenShaRepo);
      final huaYaoService = HuaYaoService(repository: huaYaoRepo);
      final shenShaManager = ShenShaManager(shenShaService: shenShaService);
      final huaYaoManager = HuaYaoManager(huaYaoService: huaYaoService);

      useCase = BuildQiZhengTimelineUseCase(
        shenShaManager: shenShaManager,
        huaYaoManager: huaYaoManager,
      );
    });

    test('constructs without Flutter bindings', () {
      expect(useCase, isNotNull);
    });

    test('returns result with birthDateInfo for life observer only', () async {
      final observer = _testObserver();
      final result = await useCase.execute(
        lifeObserver: observer,
        fateObserver: null,
        basicLifePanel: null,
      );
      expect(result.birthDateInfo, isNotNull);
      expect(result.riseSetData, isNull);
    });

    test('execute skips DaXian when fateObserver is null', () async {
      final observer = _testObserver();
      final result = await useCase.execute(
        lifeObserver: observer,
        fateObserver: null,
        basicLifePanel: null,
      );
      expect(result.birthDateInfo, isNotNull);
    });

    test('execute with basicLifePanel still returns birthDateInfo', () async {
      final observer = _testObserver();
      final result = await useCase.execute(
        lifeObserver: observer,
        fateObserver: null,
        basicLifePanel: null,
      );
      expect(result.birthDateInfo, isNotNull);
    });

    tearDownAll(() {});
  });
}
