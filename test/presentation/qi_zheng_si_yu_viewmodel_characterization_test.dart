// T-Q0-PAN-01: Main pan ViewModel characterization tests.
//
// Captures QiZhengSiYuViewModel behavior as a frozen baseline:
// initial state, UseCase delegation, notifier state, disposal.

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/models/shen_sha_tian_gan.dart';
import 'package:metaphysics_core/models/shen_sha_gan_zhi.dart';
import 'package:metaphysics_core/models/shen_sha_bundled.dart';
import 'package:qizhengsiyu/domain/repositories/ge_ju_repository_adapter.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/hua_yao.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/managers/shen_sha_manager.dart';
import 'package:qizhengsiyu/domain/managers/hua_yao_manager.dart';
import 'package:qizhengsiyu/domain/repositories/shen_sha_repository.dart';
import 'package:qizhengsiyu/domain/repositories/hua_yao_repository.dart';
import 'package:qizhengsiyu/domain/services/shen_sha_service.dart';
import 'package:qizhengsiyu/domain/services/hua_yao_service.dart';
import 'package:qizhengsiyu/domain/services/ge_ju_evaluation_service.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_rise_set_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/yun_liu_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/compute_gan_zhi_usecase.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

// ===== Fakes =====

class _FakeShenShaRepo implements ShenShaRepository {
  @override Future<List<TianGanShenSha>> getTianGanShenSha() async => const [];
  @override Future<List<YearDiZhiShenSha>> getYearDiZhiShenSha() async => const [];
  @override Future<List<MonthDiZhiShenSha>> getMonthDiZhiShenSha() async => const [];
  @override Future<List<GanZhiShenSha>> getGanZhiShenSha() async => const [];
  @override Future<List<BundledShenSha>> getBundledShenSha() async => const [];
  @override Future<List<OtherShenSha>> getOtherShenSha() async => const [];
}

class _FakeHuaYaoRepo implements HuaYaoRepository {
  @override Future<List<TianGanHuaYao>> getTianGanHuaYao() async => const [];
  @override Future<List<DiZhiHuaYao>> getDiZhiHuaYao() async => const [];
  @override Future<List<OthersHuaYao>> getOthersHuaYao() async => const [];
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
  });
}
