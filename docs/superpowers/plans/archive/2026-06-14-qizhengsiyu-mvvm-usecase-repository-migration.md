# QiZhengSiYu MVVM UseCase Repository Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Separate QiZhengSiYu UI, ViewModel, UseCase, repository-interface, and storage responsibilities while preserving all current business behavior.

**Architecture:** The migration keeps GeJu management as the reference clean path and moves the main pan flow in phases. Official assets move behind `repository-interface-qizhengsiyu` ports, concrete Flutter asset loading moves to storage/assets or host adapters, and UI code becomes ViewModel-state driven.

**Tech Stack:** Flutter, Provider, Dart, OpenSpec, `repository_interface_qizhengsiyu`, `persistence_assets`, `persistence_drift`, `flutter_test`.

---

## Reference Documents

- OpenSpec proposal: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/proposal.md`
- OpenSpec design: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/design.md`
- OpenSpec tasks: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/tasks.md`
- Spec delta: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/specs/qizhengsiyu-ui-mvvm-usecase-repository/spec.md`

## File Structure

OpenSpec and evidence:

- Create: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/baseline-manifest.md`
- Create per phase: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/evidence/Q0.md` through `Q5.md`

Architecture tests:

- Create: `test/architecture/import_boundary_test.dart`
- Create: `test/architecture/provider_bootstrap_test.dart`

UseCase tests:

- Create: `test/domain/usecases/save_calculated_panel_usecase_test.dart`
- Create: `test/domain/usecases/initialize_qizheng_official_data_usecase_test.dart`
- Create: `test/domain/usecases/calculate_qizheng_base_panel_usecase_test.dart`
- Create: `test/domain/usecases/evaluate_qizheng_ge_ju_usecase_test.dart`
- Create: `test/domain/usecases/build_qizheng_timeline_usecase_test.dart`

Presentation tests:

- Create: `test/presentation/qizheng_main_pan_viewmodel_characterization_test.dart`
- Create: `test/presentation/ge_ju_viewmodel_characterization_test.dart`

Product files to migrate:

- Modify: `lib/main.dart`
- Modify: `lib/navigator.dart`
- Modify: `lib/di.dart`
- Modify: `lib/qizhengsiyu_storage_dependencies.dart`
- Modify: `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart`
- Modify: `lib/presentation/pages/beauty_page_viewmodel.dart`
- Modify: `lib/domain/usecases/save_calculated_panel_usecase.dart`
- Create: `lib/domain/usecases/initialize_qizheng_official_data_usecase.dart`
- Create: `lib/domain/usecases/calculate_qizheng_base_panel_usecase.dart`
- Create: `lib/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart`
- Create: `lib/domain/usecases/build_qizheng_timeline_usecase.dart`

Interface/storage files to migrate:

- Modify: `../repository-interface-qizhengsiyu/pubspec.yaml`
- Modify: `../repository-interface-qizhengsiyu/lib/repository_interface_qizhengsiyu.dart`
- Create: `../repository-interface-qizhengsiyu/lib/src/contracts/qizhengsiyu_official_asset_contracts.dart`
- Create: `../repository-interface-qizhengsiyu/lib/src/repositories/qizhengsiyu_official_asset_ports.dart`
- Modify: `../xuan-storage/assets/pubspec.yaml`
- Create: `../xuan-storage/assets/lib/qizhengsiyu/assets_qizheng_official_data_repositories.dart`

## Task 0: Branch And Baseline

**Files:**

- Create: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/baseline-manifest.md`

- [x] **Step 0.1: Confirm branch**

Run:

```bash
git branch --show-current
```

Expected: branch is not `main` or `master`.

- [x] **Step 0.2: Record status**

Run:

```bash
git status --short
```

Expected: record all existing dirty files before migration. Do not clean unrelated work.

- [x] **Step 0.3: Record current architecture facts**

Run:

```bash
wc -l lib/presentation/pages/beauty_view_page.dart lib/presentation/pages/beauty_page_viewmodel.dart lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart lib/main.dart lib/navigator.dart lib/di.dart
rg -n "QiZhengSiYuStorageDependencies|createProviders\\(|BeautyPageViewModel|QiZhengSiYuViewModel" lib/main.dart lib/navigator.dart lib/di.dart lib/presentation
```

Expected: copy output into `baseline-manifest.md`.

- [x] **Step 0.4: Record analyzer and tests**

Run:

```bash
flutter analyze
flutter test
```

Expected: record exact pass/fail status, issue counts, and representative failures.

- [x] **Step 0.5: Run boundary scans**

Run every scan listed in `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/design.md`.

Expected: copy all existing matches into the baseline allow-list.

- [x] **Step 0.6: Commit baseline artifacts**

Run:

```bash
git add openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/baseline-manifest.md
git commit -m "docs(qizhengsiyu): record mvvm migration baseline"
```

Expected: baseline commit succeeds.

## Task 1: Add Architecture Test Harness

**Files:**

- Create: `test/architecture/import_boundary_test.dart`
- Create: `test/architecture/provider_bootstrap_test.dart`

- [x] **Step 1.1: Write import boundary tests**

Create tests that scan source text for forbidden patterns in UI, ViewModel, UseCase, domain, interface, and storage scopes. The test must include a local sample string with a forbidden import to prove the matcher fails when expected.

- [x] **Step 1.2: Run boundary tests and verify failure against current baseline**

Run:

```bash
flutter test test/architecture/import_boundary_test.dart
```

Expected: initial test either fails with current known violations or passes only when baseline allow-list is encoded.

- [x] **Step 1.3: Write provider bootstrap test**

Create fake implementations for all current `QiZhengSiYuStorageDependencies` ports and assert `createProviders(fakeDeps)` returns providers without constructing Drift, assets, or rootBundle-backed adapters.

- [x] **Step 1.4: Run provider bootstrap test**

Run:

```bash
flutter test test/architecture/provider_bootstrap_test.dart
```

Expected: PASS.

- [x] **Step 1.5: Commit architecture tests**

Run:

```bash
git add test/architecture/import_boundary_test.dart test/architecture/provider_bootstrap_test.dart
git commit -m "test(qizhengsiyu): add architecture boundary harness"
```

Expected: commit succeeds.

## Task 2: Stabilize Composition Root

**Files:**

- Modify: `lib/main.dart`
- Modify: `lib/navigator.dart`
- Modify: `lib/di.dart`
- Test: `test/architecture/provider_bootstrap_test.dart`

- [x] **Step 2.1: Write failing provider scope test**

Extend provider bootstrap tests to build `MyApp` with fake deps and navigate to `/qizhengsiyu/panel` and one GeJu route. Assert the same `QiZhengSiYuStorageDependencies` instance is visible.

- [x] **Step 2.2: Run test to verify current failure or duplicate-provider risk**

Run:

```bash
flutter test test/architecture/provider_bootstrap_test.dart
```

Expected: FAIL if duplicate route providers create unexpected ViewModel/service graphs, otherwise PASS with explicit evidence.

- [x] **Step 2.3: Extract bootstrap construction**

Move concrete dependency construction from `main()` into a helper such as `createQiZhengSiYuStorageDependencies()`. Keep concrete imports only in the composition root.

- [x] **Step 2.4: Remove accidental route-level duplicate providers**

Update `navigator.dart` so routes use the provider scope established above `MaterialApp`. Keep route-local providers only when tests prove isolation is required and document the exception in Q1 evidence.

- [x] **Step 2.5: Run tests**

Run:

```bash
flutter test test/architecture/provider_bootstrap_test.dart
flutter test
flutter analyze
```

Expected: no new failures in touched files.

- [x] **Step 2.6: Commit**

Run:

```bash
git add lib/main.dart lib/navigator.dart lib/di.dart test/architecture/provider_bootstrap_test.dart
git commit -m "refactor(qizhengsiyu): stabilize provider composition root"
```

Expected: commit succeeds.

## Task 3: Move Official Asset Contracts Into Repository Interface

**Files:**

- Modify: `../repository-interface-qizhengsiyu/pubspec.yaml`
- Modify: `../repository-interface-qizhengsiyu/lib/repository_interface_qizhengsiyu.dart`
- Create: `../repository-interface-qizhengsiyu/lib/src/contracts/qizhengsiyu_official_asset_contracts.dart`
- Create: `../repository-interface-qizhengsiyu/lib/src/repositories/qizhengsiyu_official_asset_ports.dart`
- Test: `../repository-interface-qizhengsiyu/test/import_boundary_test.dart`

- [x] **Step 3.1: Write interface purity test**

Create a test that scans `pubspec.yaml` and `lib/**` for `flutter:`, `sdk: flutter`, `package:flutter`, and `package:qizhengsiyu/`.

- [x] **Step 3.2: Run purity test and verify it fails**

Run:

```bash
cd ../repository-interface-qizhengsiyu && dart test test/import_boundary_test.dart
```

Expected: FAIL because current pubspec still declares Flutter.

- [x] **Step 3.3: Add official asset ports and contracts**

Add pure Dart contracts and ports named in OpenSpec Q2: star position status, historical ephemeris, ephemeris resources, and ZhouTian models.

- [x] **Step 3.4: Remove Flutter SDK dependency from interface package**

Change `repository-interface-qizhengsiyu` to pure Dart dependencies. Replace `flutter_test` with `test` if the package tests no longer require Flutter.

- [x] **Step 3.5: Export new ports**

Update the interface barrel to export the new contracts and ports.

- [x] **Step 3.6: Run interface tests**

Run:

```bash
cd ../repository-interface-qizhengsiyu && dart test && dart analyze
```

Expected: PASS, or record pre-existing analyzer debt unrelated to touched files.

- [x] **Step 3.7: Commit interface package**

Run from `../repository-interface-qizhengsiyu`:

```bash
git add pubspec.yaml lib test
git commit -m "feat(qizhengsiyu): add official asset repository ports"
```

Expected: commit succeeds in the interface repository.

## Task 4: Implement Assets Adapters

**Files:**

- Modify: `../xuan-storage/assets/pubspec.yaml`
- Create: `../xuan-storage/assets/lib/qizhengsiyu/assets_qizheng_official_data_repositories.dart`
- Modify: `../xuan-storage/assets/lib/persistence_assets.dart`
- Test: `../xuan-storage/assets/test/qizhengsiyu/assets_qizheng_official_data_repositories_test.dart`

- [x] **Step 4.1: Write failing adapter tests**

Create tests for valid JSON, missing asset error, malformed JSON error, and empty data behavior using fake bundle access where possible.

- [x] **Step 4.2: Run tests and verify failure**

Run:

```bash
cd ../xuan-storage/assets && flutter test test/qizhengsiyu/assets_qizheng_official_data_repositories_test.dart
```

Expected: FAIL because adapters do not exist yet.

- [x] **Step 4.3: Implement concrete adapters**

Implement classes satisfying the new repository-interface ports. Keep `rootBundle` and Flutter imports inside `xuan-storage/assets`.

- [x] **Step 4.4: Export adapters**

Export the adapters from `persistence_assets.dart`.

- [x] **Step 4.5: Run tests and scans**

Run:

```bash
cd ../xuan-storage/assets && flutter test test/qizhengsiyu/assets_qizheng_official_data_repositories_test.dart && flutter analyze
```

Expected: PASS, or record pre-existing debt unrelated to touched files.

- [x] **Step 4.6: Commit assets adapters**

Run from `../xuan-storage/assets`:

```bash
git add pubspec.yaml lib test
git commit -m "feat(qizhengsiyu): add official asset repository adapters"
```

Expected: commit succeeds in the storage repository.

## Task 5: Add Main Pan UseCases

**Files:**

- Modify: `lib/domain/managers/zhou_tian_model_manager.dart`
- Modify: `lib/domain/engines/calculation_engine_factory.dart`
- Modify: `lib/domain/engines/historical_engine.dart`
- Create: `lib/domain/usecases/initialize_qizheng_official_data_usecase.dart`
- Create: `lib/domain/usecases/calculate_qizheng_base_panel_usecase.dart`
- Create: `lib/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart`
- Create: `lib/domain/usecases/build_qizheng_timeline_usecase.dart`
- Modify: `lib/domain/usecases/save_calculated_panel_usecase.dart`
- Test: `test/domain/usecases/*_test.dart`
- Test: `test/domain/engines/historical_engine_injection_test.dart`
- Test: `test/domain/managers/zhou_tian_model_manager_injection_test.dart`

- [x] **Step 5.1: Write failing tests for each UseCase**

Use fake repository-interface ports and deterministic domain objects. Tests must assert that UseCases can be constructed and run without Flutter bindings or concrete storage.

- [x] **Step 5.1a: Write failing ZhouTian injection test**

Create `test/domain/managers/zhou_tian_model_manager_injection_test.dart`. It must instantiate a non-singleton `ZhouTianModelManager` with in-memory `ZhouTianModel` data or a fake `QiZhengZhouTianModelRepository`, call `load()`, and assert `getZhouTianModelBy(config)` returns the injected model without Flutter bindings.

- [x] **Step 5.1b: Write failing engine injection test**

Create `test/domain/engines/historical_engine_injection_test.dart`. It must instantiate `HistoricalEngine` with fake system-definition data and fake historical ephemeris data, call `getSystemDefinition` and `calculateStarPositions`, and assert no `SystemDefinitionLocalDataSource` or `rootBundle` path is used.

- [x] **Step 5.2: Run tests and verify failure**

Run:

```bash
flutter test test/domain/usecases
```

Expected: FAIL because new UseCases do not exist.

- [x] **Step 5.3: Break the Q3 testability blocker chain**

Refactor `ZhouTianModelManager` so a test can construct an instance with injected built-in models or `QiZhengZhouTianModelRepository`. Keep `ZhouTianModelManager.instance` only as a transitional compatibility facade. Refactor `CalculationEngineFactory` into an injectable provider or let `CalculateQiZhengBasePanelUseCase` receive explicit `ICalculationEngine` instances. Refactor `HistoricalEngine` so `SystemDefinitionLocalDataSource` and historical ephemeris data are constructor-injected.

- [x] **Step 5.4: Implement minimal UseCases**

Add UseCases that delegate to existing domain managers/services without changing algorithm behavior.

- [x] **Step 5.5: Fix SaveCalculatedPanelUseCase**

Remove `package:flutter/rendering.dart`, replace `debugPrint` with a pure Dart or injected logging approach, and return `true` after successful update.

- [x] **Step 5.6: Run tests**

Run:

```bash
flutter test test/domain/usecases
flutter test test/domain/engines/historical_engine_injection_test.dart
flutter test test/domain/managers/zhou_tian_model_manager_injection_test.dart
flutter test test/architecture/import_boundary_test.dart
flutter analyze
```

Expected: PASS for focused tests; no new analyzer issues in touched files. The architecture test must include a domain-to-data deny-list for `data/datasources|data/repositories|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource`.

- [x] **Step 5.7: Commit UseCases**

Run:

```bash
git add lib/domain/engines lib/domain/managers/zhou_tian_model_manager.dart lib/domain/usecases test/domain test/architecture/import_boundary_test.dart
git commit -m "feat(qizhengsiyu): introduce main pan usecase boundary"
```

Expected: commit succeeds.

## Task 6: Migrate Main Pan ViewModel Behind UseCases

**Files:**

- Modify: `lib/di.dart`
- Modify: `lib/qizhengsiyu_storage_dependencies.dart`
- Modify: `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart`
- Modify: `lib/presentation/pages/beauty_page_viewmodel.dart`
- Test: `test/presentation/qizheng_main_pan_viewmodel_characterization_test.dart`

- [x] **Step 6.1: Write failing ViewModel characterization tests**

Assert initial state, calculate intent calls, error state, legacy notifier synchronization, and disposal behavior.

- [x] **Step 6.1a: Write Q4 equivalence manifest test**

Create a test fixture or manifest in `test/presentation/fixtures/qizheng_pan_legacy_equivalence_manifest.dart` that lists every public `QiZhengSiYuViewModel` legacy-facing getter/notifier consumed by UI and marks each as `must-sync`, `derived-compatible`, or `retire-after-Q4`.

Required fields:

```text
basicLifePanel
uiBasicLifeStars
uiFateLifeStars
uiZhouTianModelNotifier
uiBasePanelNotifier
uiBasePanelListenable
uiDaXianPanelNotifier
uiBasicLifeStarsNotifier
uiBasicLifeStarsListenable
uiFateLifeStarsNotifier
uiFateLifeStarsListenable
baseObserverPositionNotifier
geJuSummaryNotifier
birthRiseSetNotifier
customRiseSetNotifier
lunarDateInfoNotifier
yunLiuViewModel
birthLocationName
daXianMapper
lifeObserver
fateObserver
```

For each field, record the UI consumer file(s), expected source in `QiZhengPanUiState` or `QiZhengPanDisplayState`, and equivalence policy.

- [x] **Step 6.2: Run tests and verify current gaps**

Run:

```bash
flutter test test/presentation/qizheng_main_pan_viewmodel_characterization_test.dart
```

Expected: FAIL for missing new state/intent APIs, or PASS only for legacy behavior captured before migration.

- [x] **Step 6.3: Add ViewModel state classes**

Define `QiZhengPanInputState`, `QiZhengPanUiState`, and `QiZhengPanDisplayState` in focused presentation model files.

- [x] **Step 6.4: Add field-level equivalence tests**

For every manifest entry marked `must-sync` or `derived-compatible`, assert the legacy getter/notifier value equals the corresponding state-backed value for the same Q0 fixture. Fields marked `retire-after-Q4` must assert no remaining UI consumer before Q5 cleanup.

- [x] **Step 6.5: Inject UseCases into ViewModel**

Update `createProviders(deps)` so `QiZhengSiYuViewModel` receives UseCases instead of constructing or reaching into data/repository paths.

- [x] **Step 6.6: Back legacy ValueNotifiers with new state**

Keep old notifier getters for existing widgets, but set them from the new UI state after UseCase execution.

- [x] **Step 6.7: Remove presentation data imports**

Remove `data/datasources` and `data/repositories` imports from `QiZhengSiYuViewModel` and `BeautyPageViewModel`.

- [x] **Step 6.8: Run tests and scans**

Run:

```bash
flutter test test/presentation/qizheng_main_pan_viewmodel_characterization_test.dart
flutter test test/architecture/import_boundary_test.dart
flutter test
flutter analyze
```

Expected: no behavior regressions and no new boundary violations. Every `must-sync` and `derived-compatible` field in the Q4 manifest has an assertion.

- [x] **Step 6.9: Commit ViewModel migration**

Run:

```bash
git add lib/di.dart lib/qizhengsiyu_storage_dependencies.dart lib/presentation test/presentation test/architecture
git commit -m "refactor(qizhengsiyu): move main pan viewmodel behind usecases"
```

Expected: commit succeeds.

## Task 7: Remove Domain Flutter Asset Dependencies

**Files:**

- Modify: `lib/domain/engines/sweph_engine.dart`
- Modify: `lib/domain/engines/historical_engine.dart`
- Modify: `lib/domain/services/yuan_le_panel_builder.dart`
- Modify: `lib/domain/managers/zhou_tian_model_manager.dart`
- Modify: `lib/domain/managers/ge_ju/ge_ju_manager.dart`
- Modify: domain files with unused `foundation.dart` or `rendering.dart`
- Test: existing domain tests plus new official-data fake tests

- [x] **Step 7.1: Write failing pure-domain boundary test**

Extend architecture tests so `rg`-equivalent scans fail on `package:flutter/services.dart`, `package:flutter/rendering.dart`, `rootBundle`, `data/datasources`, `data/repositories`, `LocalDataSource`, `RepositoryImpl`, and `SystemDefinitionLocalDataSource` under `lib/domain`.

- [x] **Step 7.2: Run boundary test and verify failure**

Run:

```bash
flutter test test/architecture/import_boundary_test.dart
```

Expected: FAIL because current domain files still use Flutter asset APIs and may still contain domain-to-data dependencies.

- [x] **Step 7.3: Refactor domain classes to receive data**

Change engines/managers/builders to receive typed official-data providers or parsed data from UseCases. Keep public behavior unchanged.

- [x] **Step 7.4: Remove unused Flutter imports**

Remove unused `foundation.dart` and `rendering.dart` imports from domain files.

- [x] **Step 7.5: Run domain tests and scans**

Run:

```bash
flutter test test/domain test/engines test/managers
flutter test test/architecture/import_boundary_test.dart
flutter analyze
```

Expected: pure-domain and domain-to-data boundary scans pass.

- [x] **Step 7.6: Commit domain cleanup**

Run:

```bash
git add lib/domain test
git commit -m "refactor(qizhengsiyu): remove flutter asset access from domain"
```

Expected: commit succeeds.

## Task 8: Final Verification And Review

**Files:**

- Create: `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/evidence/final.md`

- [x] **Step 8.1: Run full verification**

Run:

```bash
flutter analyze
flutter test
flutter test test/architecture
flutter test test/domain/usecases
flutter test test/presentation
```

Expected: PASS, or final evidence records pre-existing failures and proves no touched-file regression.

- [x] **Step 8.2: Run boundary scans**

Run every scan in OpenSpec `design.md`.

Expected: zero unapproved matches.

- [x] **Step 8.3: Request code review**

Use the required review workflow. Review focus: boundary leaks, behavior drift, weak tests, provider duplication, and accidental storage construction in UI.

- [x] **Step 8.4: Commit final evidence**

Run:

```bash
git add openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/evidence/final.md
git commit -m "docs(qizhengsiyu): record mvvm migration verification"
```

Expected: commit succeeds.
