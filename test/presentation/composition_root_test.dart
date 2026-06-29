// T-Q1-ROOT-01 / T-Q1-ROOT-02: Composition Root Tests
//
// Tests that createProviders(deps) produces consistent providers:
// - The same QiZhengSiYuStorageDependencies instance is shared across all providers
// - createProviders returns a non-empty list
// - MultiProvider widget tree can resolve providers correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/di.dart';
import 'package:qizhengsiyu/qizhengsiyu_storage_dependencies.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_list_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_editor_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/ge_ju_detail_viewmodel.dart';
import 'package:qizhengsiyu/domain/managers/zhou_tian_model_manager.dart';
import 'package:qizhengsiyu/domain/usecases/initialize_qizheng_official_data_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_qizheng_base_panel_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/domain/usecases/build_qizheng_timeline_usecase.dart';
import '../fakes/fake_storage_dependencies.dart';

void main() {
  group('T-Q1-ROOT: Composition Root (createProviders)', () {
    late QiZhengSiYuStorageDependencies fakeDeps;

    setUp(() {
      fakeDeps = _buildFakeDeps();
    });

    // T-Q1-ROOT-01: createProviders returns a non-empty list
    test('T-Q1-ROOT-01: createProviders returns non-empty provider list', () {
      final providers = createProviders(fakeDeps);

      expect(providers, isNotEmpty);
      expect(providers.length, greaterThan(5));
    });

    // T-Q1-ROOT-01: The same deps instance is accessible from the provider tree
    testWidgets(
      'T-Q1-ROOT-01: MultiProvider tree can resolve QiZhengSiYuStorageDependencies',
      (tester) async {
        final providers = createProviders(fakeDeps);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
              ...providers,
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final resolvedDeps =
                      context.read<QiZhengSiYuStorageDependencies>();
                  expect(resolvedDeps, same(fakeDeps));

                  final vm = context.read<QiZhengSiYuViewModel>();
                  expect(vm, isNotNull);

                  return const Scaffold(body: Text('ok'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('ok'), findsOneWidget);
      },
    );

    // T-Q1-ROOT-02: Simulate two route contexts that both read the same deps
    testWidgets(
      'T-Q1-ROOT-02: Two route contexts share the same deps identity',
      (tester) async {
        final providers = createProviders(fakeDeps);

        QiZhengSiYuStorageDependencies? resolvedFromPanel;
        QiZhengSiYuStorageDependencies? resolvedFromGeJu;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
              ...providers,
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  // Simulate /qizhengsiyu/panel route reading deps
                  resolvedFromPanel =
                      context.read<QiZhengSiYuStorageDependencies>();
                  return const Scaffold(body: Text('panel'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('panel'), findsOneWidget);

        // Now rebuild with a GeJu route context
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
              ...providers,
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  // Simulate /qizhengsiyu/ge_ju route reading deps
                  resolvedFromGeJu =
                      context.read<QiZhengSiYuStorageDependencies>();

                  final geJuListVm = context.read<GeJuListViewModel>();
                  expect(geJuListVm, isNotNull);

                  return const Scaffold(body: Text('geju'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('geju'), findsOneWidget);

        // Identity equality: both route contexts got the same instance
        expect(resolvedFromPanel, same(resolvedFromGeJu));
        expect(resolvedFromPanel, same(fakeDeps));
      },
    );

    // T-Q1-ROOT-02: All expected UseCase providers are registered
    testWidgets(
      'T-Q1-ROOT-02: All UseCase providers are resolvable',
      (tester) async {
        final providers = createProviders(fakeDeps);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
              ...providers,
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(
                    context.read<InitializeQiZhengOfficialDataUseCase>(),
                    isNotNull,
                  );
                  expect(
                    context.read<CalculateQiZhengBasePanelUseCase>(),
                    isNotNull,
                  );
                  expect(
                    context.read<EvaluateQiZhengGeJuUseCase>(),
                    isNotNull,
                  );
                  expect(
                    context.read<BuildQiZhengTimelineUseCase>(),
                    isNotNull,
                  );
                  expect(
                    context.read<ZhouTianModelManager>(),
                    isNotNull,
                  );
                  return const Scaffold(body: Text('usecases'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('usecases'), findsOneWidget);
      },
    );

    // T-Q1-ROOT-02: GeJu view models are also resolvable
    testWidgets(
      'T-Q1-ROOT-02: GeJu ViewModels are resolvable from provider tree',
      (tester) async {
        final providers = createProviders(fakeDeps);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<QiZhengSiYuStorageDependencies>.value(value: fakeDeps),
              ...providers,
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(context.read<GeJuListViewModel>(), isNotNull);
                  expect(context.read<GeJuEditorViewModel>(), isNotNull);
                  expect(context.read<GeJuDetailViewModel>(), isNotNull);
                  return const Scaffold(body: Text('geju_vms'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('geju_vms'), findsOneWidget);
      },
    );
  });
}

/// Build a QiZhengSiYuStorageDependencies using shared fakes.
QiZhengSiYuStorageDependencies _buildFakeDeps() {
  return QiZhengSiYuStorageDependencies(
    panRepository: FakeQiZhengSiYuPanRepository(),
    recordRepository: FakeQiZhengRecordRepository(),
    geJuRepository: FakeGeJuRepository(),
    geJuBuiltInDataSource: FakeGeJuBuiltInDataSource(),
    geJuSchoolService: FakeGeJuSchoolServicePort(),
    shenSha: FakeQiZhengShenShaRepository(),
    huaYao: FakeQiZhengHuaYaoRepository(),
    starPositionStatus: FakeQiZhengStarPositionStatusRepository(),
    historicalEphemeris: FakeQiZhengHistoricalEphemerisRepository(),
    ephemerisResource: FakeQiZhengEphemerisResourceRepository(),
    zhouTianModelRepository: FakeQiZhengZhouTianModelRepository(),
  );
}
