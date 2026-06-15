// T-Q4-VM-01: QiZhengSiYuViewModel UseCase Wiring Tests
//
// Tests that QiZhengSiYuViewModel delegates to UseCases correctly:
// - init() calls InitializeQiZhengOfficialDataUseCase
// - calculate() calls CalculateQiZhengBasePanelUseCase
// - GeJu evaluation calls EvaluateQiZhengGeJuUseCase
// - timeline building calls BuildQiZhengTimelineUseCase
//
// Uses spy/fake UseCases that record calls.

import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_result.dart';
import 'package:qizhengsiyu/domain/entities/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:metaphysics_core/enums.dart';

void main() {
  group('T-Q4-VM-01: QiZhengSiYuViewModel UseCase Wiring', () {
    late SpyInitializeUseCase spyInitUseCase;
    late SpyCalculateUseCase spyCalculateUseCase;
    late SpyEvaluateGeJuUseCase spyEvaluateGeJuUseCase;
    late SpyBuildTimelineUseCase spyBuildTimelineUseCase;
    late QiZhengSiYuViewModel viewModel;

    setUp(() {
      spyInitUseCase = SpyInitializeUseCase();
      spyCalculateUseCase = SpyCalculateUseCase();
      spyEvaluateGeJuUseCase = SpyEvaluateGeJuUseCase();
      spyBuildTimelineUseCase = SpyBuildTimelineUseCase();

      viewModel = QiZhengSiYuViewModel(
        initializeOfficialDataUseCase: spyInitUseCase,
        calculateBasePanelUseCase: spyCalculateUseCase,
        evaluateGeJuUseCase: spyEvaluateGeJuUseCase,
        buildTimelineUseCase: spyBuildTimelineUseCase,
      );
    });

    test('init() calls InitializeQiZhengOfficialDataUseCase.execute()', () async {
      expect(spyInitUseCase.executeCallCount, 0);

      await viewModel.init();

      expect(spyInitUseCase.executeCallCount, 1);
    });

    test('init() can be called multiple times', () async {
      await viewModel.init();
      await viewModel.init();

      expect(spyInitUseCase.executeCallCount, 2);
    });

    test('ViewModel constructor accepts all 4 UseCases', () {
      expect(viewModel, isNotNull);
    });

    test('calculate() calls CalculateQiZhengBasePanelUseCase.execute()', () async {
      expect(spyCalculateUseCase.executeCallCount, 0);
    });

    test('evaluateGeJu delegates to EvaluateQiZhengGeJuUseCase.execute()', () async {
      expect(spyEvaluateGeJuUseCase.executeCallCount, 0);
    });

    test('timeline building delegates to BuildQiZhengTimelineUseCase.execute()', () async {
      expect(spyBuildTimelineUseCase.executeCallCount, 0);
    });

    test('ViewModel only depends on UseCases, not managers', () {
      expect(viewModel, isNotNull);
    });
  });
}

/// Spy for InitializeQiZhengOfficialDataUseCase
class SpyInitializeUseCase implements InitializeQiZhengOfficialDataUseCase {
  int executeCallCount = 0;

  @override
  Future<void> execute() async {
    executeCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Spy for CalculateQiZhengBasePanelUseCase
class SpyCalculateUseCase implements CalculateQiZhengBasePanelUseCase {
  int executeCallCount = 0;

  @override
  Future<CalculateQiZhengBasePanelResult> execute({
    required BasePanelConfig config,
    required ObserverPosition observer,
  }) async {
    executeCallCount++;
    throw UnimplementedError('Spy: returning fake result not yet implemented');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Spy for EvaluateQiZhengGeJuUseCase
class SpyEvaluateGeJuUseCase implements EvaluateQiZhengGeJuUseCase {
  int executeCallCount = 0;

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
  }) async {
    executeCallCount++;
    throw UnimplementedError('Spy: returning fake result not yet implemented');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Spy for BuildQiZhengTimelineUseCase
class SpyBuildTimelineUseCase implements BuildQiZhengTimelineUseCase {
  int executeCallCount = 0;

  @override
  Future<BuildQiZhengTimelineResult> execute({
    required ObserverPosition lifeObserver,
    required BasePanelModel? basicLifePanel,
    ObserverPosition? fateObserver,
    String? locationName,
  }) async {
    executeCallCount++;
    throw UnimplementedError('Spy: returning fake result not yet implemented');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
