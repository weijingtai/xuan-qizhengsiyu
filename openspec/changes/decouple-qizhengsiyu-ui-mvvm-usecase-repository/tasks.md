# Tasks: Decouple QiZhengSiYu UI From MVVM, UseCase, And Repository Internals

> 测试方案: `docs/superpowers/plans/2026-06-14-qizhengsiyu-decouple-test-plan.md`
> 验收标准: `docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-acceptance-criteria.md`
> 设计蓝图: `docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-test-acceptance-design.md`

## Q0 · Baseline And Characterization Freeze

**Entry Criteria**

- Current branch is not `main` or `master`.
- No production migration code has been edited.

- [ ] Q0.1 Create `baseline-manifest.md` in this OpenSpec change directory.
- [ ] Q0.2 Record current branch, git status, route list, provider scopes, and legacy/main-pan files.
- [ ] Q0.3 Record line counts for `beauty_view_page.dart`, `beauty_page_viewmodel.dart`, `qi_zheng_si_yu_viewmodel.dart`, `main.dart`, `navigator.dart`, and `di.dart`.
- [ ] Q0.4 Run and record current `flutter analyze`.
- [ ] Q0.5 Run and record current `flutter test`.
- [ ] Q0.6 Run all boundary scans from `design.md` and copy existing matches into the baseline allow-list.
- [ ] Q0.6a Record all seven `navigator.dart` route-level `createProviders(...)` call sites and decide for each route whether it should use app-scope providers or intentionally isolated route-scope providers.
- [ ] Q0.6b Record `ZhouTianModelManager.instance`, `CalculationEngineFactory.create`, and `HistoricalEngine -> SystemDefinitionLocalDataSource/rootBundle` as Q3 blockers.
- [ ] Q0.7 Add architecture tests that fail on new UI -> data/repository/rootBundle imports.
- [ ] Q0.8 Add fake implementations of all existing `QiZhengSiYuStorageDependencies` ports.
- [ ] Q0.9 Add provider bootstrap test proving `createProviders(fakeDeps)` constructs without concrete storage.
- [ ] Q0.10 Add SaveCalculatedPanelUseCase tests with a fake `IQiZhengSiYuPanRepository`.
- [ ] Q0.11 Add GeJu ViewModel characterization tests for list load, refresh, create/edit init, and school load.
- [ ] Q0.12 Add main pan characterization tests for initial state, calculate failure path, disposal, and official-data load error handling.
- [ ] Q0.13 Produce Q0 evidence with go/no-go.

**Exit Criteria**

- Existing violations are frozen.
- New tests protect provider bootstrap, repository-interface fake ports, SaveCalculatedPanelUseCase, GeJu ViewModels, and main pan ViewModel behavior.
- No production behavior has been migrated.

**Stop-The-Line**

- Tests cannot instantiate fake dependency bundles.
- Current provider scoping cannot be described.
- Analyzer/test baseline is not recorded.

## Q1 · Single Composition Root

**Entry Criteria**

- Q0 evidence is complete.
- Provider bootstrap tests pass.

- [ ] Q1.1 Extract concrete dependency construction from `main.dart` into a bootstrap/composition-root helper.
- [ ] Q1.2 Ensure concrete storage dependencies are constructed exactly once per app process.
- [ ] Q1.3 Remove duplicate route-level `createProviders(...)` calls where providers already exist above `MaterialApp`.
- [ ] Q1.4 Keep route-local providers only when a route intentionally needs isolated state; document each exception.
- [ ] Q1.5 Add a widget/provider test proving `/qizhengsiyu/panel` and GeJu routes read the same storage dependency bundle.
- [ ] Q1.6 Run provider bootstrap tests, GeJu route tests, `flutter test`, `flutter analyze`, and boundary scans.
- [ ] Q1.7 Produce Q1 evidence with go/no-go.

**Exit Criteria**

- `QiZhengSiYuStorageDependencies` has one composition root.
- Route navigation no longer creates accidental duplicate business/service graphs.
- Existing GeJu and panel routes still build.

**Stop-The-Line**

- Any route loses access to required ViewModel providers.
- State changes become route-local when they were previously app-scoped.

## Q2 · Repository Interface And Official Assets Boundary

**Entry Criteria**

- Q1 evidence passes.
- `repository-interface-qizhengsiyu` is available locally.

- [ ] Q2.0 Make `repository-interface-qizhengsiyu` runnable under pure `dart test` (A2 prerequisite). Remove the **unused** `metaphysics_core` dependency from its `pubspec.yaml` (verified: imported 0 times in `lib`), drop `flutter: sdk: flutter`, and replace `flutter_test` with `test`. Do NOT modify `metaphysics_core` itself — purifying it is out of scope (~15 sibling packages depend on it; it has direct `package:flutter` imports). Gate: `cd ../repository-interface-qizhengsiyu && dart pub get && dart test` passes.
- [ ] Q2.1 Confirm `repository-interface-qizhengsiyu` source is pure Dart, then verify no Flutter SDK dependency remains in its pubspec.
- [ ] Q2.2 Add `QiZhengStarPositionStatusRepository` port and contract.
- [ ] Q2.3 Add `QiZhengHistoricalEphemerisRepository` port and contract.
- [ ] Q2.4 Add `QiZhengEphemerisResourceRepository` port and contract.
- [ ] Q2.5 Add `QiZhengZhouTianModelRepository` port and contract.
- [ ] Q2.6 Export new ports/contracts from `repository_interface_qizhengsiyu.dart`.
- [ ] Q2.7 Add interface package tests proving no Flutter/product imports.
- [ ] Q2.8 Implement Flutter asset adapters in `xuan-storage/assets` for the new official-data ports.
- [ ] Q2.9 Extend `QiZhengSiYuStorageDependencies` with the new official-data ports.
- [ ] Q2.10 Update composition root to pass concrete assets adapters.
- [ ] Q2.11 Keep old domain `rootBundle` paths untouched until UseCases consume new ports.
- [ ] Q2.12 Run interface purity scan, storage reverse dependency scan, package tests, and product tests.
- [ ] Q2.13 Produce Q2 evidence with go/no-go.

**Exit Criteria**

- Q2.0 gate passes: `repository-interface-qizhengsiyu` runs under pure `dart test` (no Flutter).
- Official asset concepts are represented as repository-interface ports.
- Concrete Flutter asset loading lives outside product domain/presentation logic.
- No generic long-term `AssetLoader.loadString(path)` API is introduced as the business contract.

**Stop-The-Line**

- Q2.0 cannot pass without modifying `metaphysics_core` (means the interface package still has a real metaphysics_core usage — re-scope before proceeding).
- Interface package must depend on Flutter or `qizhengsiyu`.
- New storage adapters need product UI imports.
- Typed contracts cannot represent current official data without loss.

## Q3 · UseCase Layer For Main Pan Flow

**Entry Criteria**

- Q2 evidence passes.
- Fake official-data ports exist for tests.

- [ ] Q3.0a Refactor `ZhouTianModelManager` so tests can construct an instance with injected built-in models or `QiZhengZhouTianModelRepository`; keep `ZhouTianModelManager.instance` only as a transitional compatibility facade.
- [ ] Q3.0b Refactor `CalculationEngineFactory` into an injectable engine provider or make `CalculateQiZhengBasePanelUseCase` accept explicit `ICalculationEngine` instances for historical and Sweph paths.
- [ ] Q3.0c Refactor `HistoricalEngine` so `SystemDefinitionLocalDataSource` and historical ephemeris data are injected; no constructor path may hard-code `lib/data/**` or `rootBundle`.
- [ ] Q3.0d Add tests proving `ZhouTianModelManager`, engine provider, `HistoricalEngine`, and `CalculateQiZhengBasePanelUseCase` can run with fake in-memory data and no Flutter bindings.
- [ ] Q3.1 Add `InitializeQiZhengOfficialDataUseCase` using ShenSha, HuaYao, ZhouTian, star status, ephemeris, and resource ports.
- [ ] Q3.2 Add `CalculateQiZhengBasePanelUseCase` to coordinate injected engine selection, ZhouTian model lookup, star position calculation, and base panel generation.
- [ ] Q3.3 Add `EvaluateQiZhengGeJuUseCase` around `GeJuEvaluationService`.
- [ ] Q3.4 Add `BuildQiZhengTimelineUseCase` for lunar date info, YunLiu, DaXian, and rise/set display data.
- [ ] Q3.5 Refactor `SaveCalculatedPanelUseCase` to remove Flutter import and return true after successful update.
- [ ] Q3.6 Add focused tests for each UseCase with fake ports and deterministic domain inputs.
- [ ] Q3.7 Add negative tests proving UseCases do not import Flutter, UI, rootBundle, data sources, or repository implementations.
- [ ] Q3.8 Wire new UseCases into `createProviders(deps)` without changing UI behavior.
- [ ] Q3.9 Run UseCase tests, architecture scans including domain-to-data scan, `flutter test`, and `flutter analyze`.
- [ ] Q3.10 Produce Q3 evidence with go/no-go.

**Exit Criteria**

- Main pan business operations have UseCase entry points.
- ViewModels can receive UseCases without knowing concrete repositories.
- Existing behavior remains available through compatibility ViewModel APIs.

**Stop-The-Line**

- UseCases import Flutter UI or concrete storage.
- `ZhouTianModelManager`, `CalculationEngineFactory`, or `HistoricalEngine` still block fake-data tests.
- `HistoricalEngine` still imports `SystemDefinitionLocalDataSource` directly.
- Domain-to-data scan has new or unresolved matches.
- Any business calculation result differs from Q0 characterization without approval.

## Q4 · Main Pan ViewModel Migration

**Entry Criteria**

- Q3 evidence passes.
- Main pan UseCases are injected.

- [ ] Q4.1 Define `QiZhengPanInputState`.
- [ ] Q4.2 Define `QiZhengPanUiState` with idle, loading, success, and error variants.
- [ ] Q4.3 Define `QiZhengPanDisplayState` for UI-rendered panel, stars, rise/set, GeJu summary, YuanLe, HuaYao, and timeline data.
- [ ] Q4.3a On top of Q0 `baseline-manifest.md`, list every public `QiZhengSiYuViewModel` ValueNotifier/getter and every UI consumer; mark each as `must-sync`, `derived-compatible`, or `retire-after-Q4`.
- [ ] Q4.3b Add equivalence tests **only** for fields Q4.3a marked `must-sync` or `derived-compatible` (incl. panel model, basic/fate stars, ZhouTian model, DaXian panel, observer position, GeJu summary, rise/set data, lunar date info, YunLiu, birth location, DaXian mapper, life observer, fate observer when so classified). For `*Notifier`/`*Listenable` fields, also assert notification/rebuild semantics, not only value equality.
- [ ] Q4.3c For fields Q4.3a marked `retire-after-Q4` or `internal-only`, do NOT add equivalence tests; instead add a consumer-scan/evidence assertion proving the field name has no remaining UI consumer in `lib/presentation`+`lib/controllers` (must be empty before Q5 cleanup).
- [ ] Q4.4 Refactor `QiZhengSiYuViewModel` to call UseCases for official data initialization, calculation, GeJu evaluation, and timeline building.
- [ ] Q4.5 Remove all `lib/data/**` imports from `QiZhengSiYuViewModel` — verified by the broad `(^|/)data/` scan, not only `data/datasources` / `data/repositories` (A1: e.g. `data/contract_mappers` must also be caught).
- [ ] Q4.6 Keep legacy ValueNotifiers as a compatibility facade backed by the new UI state.
- [ ] Q4.7 Refactor `BeautyPageViewModel` to delegate to `QiZhengSiYuViewModel` or a temporary compatibility facade instead of loading assets and constructing repositories.
- [ ] Q4.8 Remove `rootBundle.loadString` calls from `BeautyPageViewModel`.
- [ ] Q4.9 Add migration tests proving legacy notifier/getter values and new UI state stay synchronized according to the Q4 equivalence manifest.
- [ ] Q4.10 Run main pan characterization tests, route smoke tests, boundary scans, `flutter test`, and `flutter analyze`.
- [ ] Q4.11 Produce Q4 evidence with go/no-go.

**Exit Criteria**

- Main pan UI state is ViewModel-owned and UseCase-backed.
- Presentation code no longer constructs repositories/data sources.
- Legacy UI can still render through compatibility notifiers.

**Stop-The-Line**

- Main pan route cannot calculate a known Q0 fixture.
- Notifier compatibility breaks existing widgets.
- Any Q4 `must-sync` or `derived-compatible` field lacks an equivalence assertion.
- Any `retire-after-Q4`/`internal-only` field lacks a no-consumer evidence assertion, or still has a live UI consumer.
- ViewModel still imports data/repository implementations outside baseline exceptions.

## Q5 · Pure Domain And Legacy Cleanup

**Entry Criteria**

- Q4 evidence passes.
- UI and ViewModel boundary scans show only approved cleanup targets.

- [ ] Q5.1 Refactor `SwephEngine` to receive `QiZhengEphemerisResourceRepository` data through a UseCase or injected domain provider.
- [ ] Q5.2 Refactor `HistoricalEngine` to receive `QiZhengHistoricalEphemerisRepository` data.
- [ ] Q5.3 Refactor `YuanLePanelBuilder` to receive `QiZhengStarPositionStatusRepository` data.
- [ ] Q5.4 Refactor `ZhouTianModelManager` to receive `QiZhengZhouTianModelRepository` data.
- [ ] Q5.5 Refactor or retire `GeJuManager` asset reads in favor of `GeJuBuiltInDataSource`.
- [ ] Q5.6 Remove unused `foundation.dart` and `rendering.dart` imports from domain files.
- [ ] Q5.7 Delete or quarantine obsolete compatibility paths only after Q4 tests pass without them.
- [ ] Q5.8 Run domain Flutter deny-list scan and require zero matches except documented UI-only files.
- [ ] Q5.9 Run domain-to-data deny-list scan and require zero matches except explicitly approved transitional adapters outside `lib/domain`.
- [ ] Q5.10 Run full test/analyze suite and all architecture scans.
- [ ] Q5.11 Produce final evidence with go/no-go.

**Exit Criteria**

- Domain layer has no Flutter dependency for business logic.
- Official asset loading is behind repository-interface ports and storage adapters.
- UI, ViewModel, UseCase, domain, repository-interface, and storage boundaries are machine-verified.

**Stop-The-Line**

- Domain still needs rootBundle for production behavior.
- Any legacy cleanup changes calculated output.
- Tests or scans cannot prove boundary separation.

## Q6 · Delivery Gate And Archive

- [ ] Q6.1 Collect Q0-Q5 evidence paths.
- [ ] Q6.2 Confirm every boundary scan is clean or has an approved remaining baseline item.
- [ ] Q6.3 Confirm no touched file introduces analyzer issues.
- [ ] Q6.4 Confirm business fixture outputs match Q0.
- [ ] Q6.5 Run code review focused on boundary leaks, behavior drift, and weak tests.
- [ ] Q6.6 Archive this OpenSpec change only after implementation, verification, and review evidence pass.
