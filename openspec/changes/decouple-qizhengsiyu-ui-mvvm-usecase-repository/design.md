# Design: Decouple QiZhengSiYu UI From MVVM, UseCase, And Repository Internals

## Target Architecture

```text
Flutter UI pages/widgets
  -> ViewModel state + intent methods
  -> UseCases
  -> repository_interface_qizhengsiyu ports/contracts
  -> storage implementations
       - xuan-storage/assets for official read-only JSON/package assets
       - xuan-storage/drift for user-created persistence
       - preferences adapter for UI/user preferences when required
  -> DataSource / rootBundle / Drift / SharedPreferences
```

Domain algorithms may remain inside `xuan-qizhengsiyu` during this change, but they must not depend on Flutter asset loading. Flutter-specific asset loading belongs to concrete adapters.

## Current Architecture Map

### Cleaner Path: GeJu Management

`lib/di.dart` creates adapters from injected `QiZhengSiYuStorageDependencies`:

- `GeJuRepositoryAdapter`
- `GeJuSchoolServiceAdapter`
- `ShenShaRepositoryAdapter`
- `HuaYaoRepositoryAdapter`

GeJu pages use ViewModels under `lib/presentation/viewmodels/ge_ju_*`, and those ViewModels depend on `GeJuCrudService` or school service abstractions. This is the reference path for the rest of the migration.

### Legacy/Mixed Path: Main Pan UI

The main pan route uses:

- `lib/presentation/pages/beauty_view_page.dart`
- `lib/presentation/pages/beauty_page_viewmodel.dart`
- `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart`
- `lib/controllers/panel_controller.dart`

This path mixes UI display state, legacy compatibility notifiers, calculation orchestration, direct asset reads, and partial UseCase access.

### Q3 Testability Blocker Chain

The main-pan UseCase migration cannot be considered executable until these three coupled blockers are resolved:

- `ZhouTianModelManager` currently exposes `ZhouTianModelManager.instance`, has a private constructor, and loads built-in presets through `rootBundle`.
- `CalculationEngineFactory.create(config)` is static and directly constructs `HistoricalEngine()` or `SwephEngine()`.
- `HistoricalEngine` constructs `SystemDefinitionLocalDataSource` from `lib/data/**` and loads historical ephemeris data through `rootBundle`.

Q3 therefore starts with injection seams for ZhouTian models, calculation engines, and historical system/ephemeris data. These are not optional cleanup tasks; they are prerequisites for a testable `CalculateQiZhengBasePanelUseCase`.

## Layer Rules

### UI Layer

Scope:

- `lib/presentation/pages/**`
- `lib/presentation/widgets/**`
- `lib/controllers/**`

MUST:

- Render ViewModel state.
- Call ViewModel intent methods.
- Own Flutter-only visual concerns.

MUST NOT:

- Import `lib/data/**`.
- Import repository implementation classes.
- Read `rootBundle` for business data.
- Construct UseCases directly.
- Construct repository implementations directly.
- Construct storage dependencies directly.

Temporary exception:

- Q0 may record existing violations in `baseline-manifest.md`.
- Q1-Q4 may keep allow-listed legacy compatibility files while they are actively migrated.
- Q5 requires no unapproved UI-layer business dependency violations.

### ViewModel Layer

Scope:

- `lib/presentation/viewmodels/**`
- approved temporary compatibility ViewModels under `lib/presentation/pages/**`

MUST:

- Own UI state transitions.
- Expose stable state and intent APIs.
- Delegate business operations to UseCases or domain services injected through UseCases.

MUST NOT:

- Import `lib/data/**`.
- Construct repositories or data sources.
- Call `rootBundle`.
- Call Drift or persistence adapters.
- Reimplement calculation rules already owned by domain managers/services.

### UseCase Layer

Scope:

- `lib/domain/usecases/**`

MUST:

- Express application actions: calculate pan, load official data, evaluate GeJu, save/update/delete pan, build display-ready result packages.
- Depend on repository-interface ports or pure domain services.
- Return domain/application results that ViewModels can map to UI state.

MUST NOT:

- Import Flutter UI packages.
- Import pages, widgets, controllers, or ViewModels.
- Access `rootBundle`, Drift, SharedPreferences, or service locators directly.

### Domain Layer

Scope:

- `lib/domain/**`

MUST:

- Stay pure Dart for business logic.
- Receive official data through typed ports or constructor-injected data providers.

MUST NOT:

- Import `package:flutter/services.dart`.
- Import `package:flutter/rendering.dart`.
- Import Flutter UI packages.
- Use `rootBundle`.
- Import `lib/data/**`, `SystemDefinitionLocalDataSource`, repository implementations, or data source implementations.

Allowed transitional exceptions are recorded in Q0 and must trend to zero.

### Repository Interface Package

Scope:

- `../repository-interface-qizhengsiyu/**`

MUST:

- Define pure Dart ports and contracts for all storage/data boundaries.
- Include ports for current official assets: GeJu built-in data, ShenSha, HuaYao, star position status, historical ephemeris, Sweph/qizhengsiyu resource data, and ZhouTian model files.
- Depend only on genuinely pure-Dart packages such as `equatable`.
  - **Correction (verified):** `metaphysics_core` is NOT pure Dart — it directly imports `package:flutter/foundation.dart` and `package:flutter/material.dart` (`template_preset.dart:1`, `five_elements_colors.dart:1`, `day_pillar_strategy.dart:1`) and declares `flutter_timezone`/`google_fonts`. The interface package currently declares a `metaphysics_core` dependency but imports it **0 times** in `lib`. Q2.0 removes that unused dependency so the package can run under pure `dart test`. Purifying `metaphysics_core` itself is OUT of scope (~15 sibling packages depend on it; it is a separate upstream refactor).

MUST NOT:

- Depend on Flutter SDK.
- Import product package internals.
- Define generic path-based asset loaders as the long-term API.

## Official Asset Port Design

Existing ports stay:

- `GeJuBuiltInDataSource`
- `QiZhengShenShaRepository`
- `QiZhengHuaYaoRepository`

New ports required by this change:

- `QiZhengStarPositionStatusRepository`
  - Loads star position status data currently read from `assets/qizhengsiyu/star_position_status.json`.
- `QiZhengHistoricalEphemerisRepository`
  - Loads historical ephemeris data currently read from `assets/historical_ephemeris/sun_speeds.json`.
- `QiZhengEphemerisResourceRepository`
  - Loads Sweph/qizhengsiyu resource content currently read by `SwephEngine`.
- `QiZhengZhouTianModelRepository`
  - Loads ZhouTian model definitions currently read by `ZhouTianModelManager`.

These ports should return typed contracts where practical. A raw `Map<String, dynamic>` contract is acceptable only when the current domain parser already owns the type interpretation and the OpenSpec task records the mapping boundary.

## UseCase Design

New or revised UseCases:

- `InitializeQiZhengOfficialDataUseCase`
  - Loads official assets through repository-interface ports and initializes managers/services.
- `CalculateQiZhengBasePanelUseCase`
  - Coordinates calculation engine selection, ZhouTian model lookup, star position calculation, and base panel generation.
  - Must receive an injectable calculation-engine provider or explicit `ICalculationEngine` instances for tests.
- `EvaluateQiZhengGeJuUseCase`
  - Evaluates a calculated panel through `GeJuEvaluationService` without UI-level service access.
- `BuildQiZhengTimelineUseCase`
  - Builds lunar date info, YunLiu, DaXian, and rise/set display data from domain inputs.
- `SaveCalculatedPanelUseCase`
  - Keep existing behavior, remove Flutter import, fix update success return, and keep repository-interface dependency.

ViewModels should compose these UseCases instead of composing repositories/data sources directly.

## Composition Root

The host/application layer is the only place allowed to construct concrete storage implementations:

- `AppDatabase`
- `GeJuBuiltInDatabase`
- `GeJuSQLiteDataSource`
- `GeJuDao`
- `QiZhengSiYuPanRepository`
- `AssetsQiZhengShenShaRepository`
- `AssetsQiZhengHuaYaoRepository`
- future assets repositories for star status, historical ephemeris, Sweph resources, and ZhouTian models

`main.dart` or an extracted bootstrap file should create `QiZhengSiYuStorageDependencies` once. Routes should not call `createProviders` again if the provider scope already exists above `MaterialApp`.

## Boundary Scans

Run these scans in every migration round and record output.

UI deny-list:

```bash
rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|QiZhengSiYuPanRepository|ShenShaRepositoryImpl|HuaYaoRepositoryImpl|LocalDataSourceImpl|SaveCalculatedPanelUseCase\\(|CalculateFateDongWeiUseCase\\(" \
  lib/presentation lib/controllers lib/navigator.dart
```

ViewModel deny-list:

```bash
rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|RepositoryImpl|LocalDataSourceImpl|package:flutter/services.dart" \
  lib/presentation/viewmodels lib/presentation/pages/beauty_page_viewmodel.dart
```

UseCase deny-list:

```bash
rg -n "package:flutter/(material|widgets|services|rendering)\\.dart|presentation/|pages/|widgets/|BuildContext|rootBundle|AppDatabase|RepositoryImpl|LocalDataSourceImpl|(^|/)data/" \
  lib/domain/usecases
```

Domain Flutter deny-list:

```bash
rg -n "package:flutter/(services|foundation|rendering|material|widgets)\\.dart|rootBundle" \
  lib/domain
```

Domain data-layer deny-list:

```bash
rg -n "(^|/)data/|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource" \
  lib/domain
```

> A1 (boundary-scan hardening): the data term is the broad `(^|/)data/`, not the
> narrow `data/datasources|data/repositories`. The narrow form misses other
> `lib/data/**` subdirs — verified: `lib/domain/usecases/save_calculated_panel_usecase.dart`
> imports `../../data/contract_mappers/qizhengsiyu_contract_mappers.dart`, which the
> narrow scan passes silently. The UseCase deny-list previously had no data term at all.

Repository-interface purity scan:

```bash
rg -n "flutter:|sdk: flutter|package:flutter|package:qizhengsiyu/" \
  ../repository-interface-qizhengsiyu/pubspec.yaml ../repository-interface-qizhengsiyu/lib
```

> A2 (runnable purity gate): the source scan above can pass while the package is
> still Flutter-bound transitively. The acceptance gate therefore also requires a
> pure-Dart run: `cd ../repository-interface-qizhengsiyu && dart pub get && dart test`
> must pass (NOT `flutter test`). See Q2.0 in tasks.md.

Storage reverse dependency scan:

```bash
rg -n "presentation/|pages/|widgets/|ViewModel|BuildContext" \
  ../xuan-storage/assets/lib ../xuan-storage/drift/lib
```

## Behavior Preservation Gates

Q0 must create characterization tests before production migration:

- Provider bootstrap test: `createProviders(fakeDeps)` builds without touching assets/DB.
- Main pan ViewModel smoke: initial state, calculate intent, error state, notifier disposal.
- Assets repository fake test: official-data UseCases work with fake ports.
- Save panel UseCase test: save/update/delete call fake `IQiZhengSiYuPanRepository`.
- GeJu route/ViewModel regression tests: load/list/edit state remains stable through adapter.

Q4 must add explicit legacy notifier/getter equivalence tests. The Q4 equivalence manifest must list every public `QiZhengSiYuViewModel` legacy-facing field/getter/notifier consumed by UI and mark it as one of:

- `must-sync`: new `QiZhengPanUiState` / `QiZhengPanDisplayState` must keep this value exactly equivalent.
- `derived-compatible`: value may be derived from new state but must match Q0 behavior for fixtures.
- `retire-after-Q4`: UI consumer must be migrated before Q5 deletes or stops updating it.

Minimum Q4 equivalence fields:

- `basicLifePanel`
- `uiBasicLifeStars`
- `uiFateLifeStars`
- `uiZhouTianModelNotifier`
- `uiBasePanelNotifier`
- `uiBasePanelListenable`
- `uiDaXianPanelNotifier`
- `uiBasicLifeStarsNotifier`
- `uiBasicLifeStarsListenable`
- `uiFateLifeStarsNotifier`
- `uiFateLifeStarsListenable`
- `baseObserverPositionNotifier`
- `geJuSummaryNotifier`
- `birthRiseSetNotifier`
- `customRiseSetNotifier`
- `lunarDateInfoNotifier`
- `yunLiuViewModel`
- `birthLocationName`
- `daXianMapper`
- `lifeObserver`
- `fateObserver`

Each `must-sync` and `derived-compatible` field must have at least one characterization assertion that compares pre-migration legacy output and post-migration state-backed output for the same input fixture.

Each later phase must run:

```bash
flutter analyze
flutter test
flutter test test/architecture
flutter test test/domain/usecases
flutter test test/presentation
```

If full `flutter analyze` has pre-existing debt, Q0 must record the exact baseline and every later phase must prove no new issue in touched files.

## Rollback Strategy

Every phase must keep the app runnable. Rollback is phase-local:

- Q1 rollback restores route provider scoping.
- Q2 rollback keeps new ports unused while old asset paths remain.
- Q3 rollback leaves new UseCases unused behind existing ViewModel behavior.
- Q4 rollback points legacy UI back to compatibility ViewModel state.
- Q5 only deletes legacy paths after all prior evidence passes.

No phase may delete legacy behavior before the replacement path has passing characterization tests.
