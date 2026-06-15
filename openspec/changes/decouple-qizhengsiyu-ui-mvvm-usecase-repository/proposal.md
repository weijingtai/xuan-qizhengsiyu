# Decouple QiZhengSiYu UI From MVVM, UseCase, And Repository Internals

## Summary

This change migrates `xuan-qizhengsiyu` toward a stable UI -> ViewModel -> UseCase -> Repository Interface -> Repository Implementation/DataSource architecture while preserving current business behavior. The work starts from the current mixed state: GeJu management already follows a cleaner injected-provider path, while the main pan UI still relies on large compatibility ViewModels, direct asset loading, and direct data/repository construction in presentation code.

## Problem

The package currently has two partially overlapping UI architecture paths:

- A newer path around `QiZhengSiYuStorageDependencies`, `createProviders(deps)`, GeJu ViewModels, service adapters, and `repository_interface_qizhengsiyu`.
- A legacy main-pan path around `BeautyViewPage`, `BeautyPageViewModel`, and compatibility APIs in `QiZhengSiYuViewModel`, where UI/presentation code still directly loads assets, constructs data repositories, and owns calculation orchestration.

This creates high migration risk:

- UI routes can receive duplicated Provider instances because `main.dart` and `navigator.dart` both call `createProviders(deps)`.
- ViewModels still import data sources or repository implementations.
- Domain code still imports Flutter services and `rootBundle`.
- UseCase coverage is too thin for the main pan flow.
- Current tests do not directly protect `QiZhengSiYuViewModel`, `BeautyPageViewModel`, `createProviders`, or the repository-interface injection chain.

## Goals

- Freeze current behavior before migration with route, state, and field-level characterization tests.
- Establish a single composition root for storage dependencies and ViewModels.
- Move all official asset access behind `repository-interface-qizhengsiyu` ports and concrete storage/assets implementations.
- Break the Q3 calculation testability blocker chain: `ZhouTianModelManager` singleton, static `CalculationEngineFactory`, and `HistoricalEngine` hard-coded data source/asset access.
- Introduce UseCases for main-pan calculation, official data loading, GeJu evaluation, and panel persistence orchestration.
- Make UI widgets/pages depend on ViewModel state and intent methods only.
- Keep GeJu management behavior working while using it as the clean architecture reference path.
- Remove or quarantine legacy compatibility ViewModels only after equivalence is proven.
- Enforce machine-checkable boundary scans for UI, ViewModel, UseCase, domain, repository-interface, and storage packages.

## Non-Goals

- Redesigning the visual appearance of the pan UI.
- Rewriting astronomy, fate, GeJu, ShenSha, HuaYao, or ZhouTian algorithms.
- Changing official JSON or SQLite data semantics.
- Removing legacy UI in the first migration round.
- Moving all domain models into another package unless a boundary scan proves it is required.
- Treating route smoke tests as sufficient evidence without state and field-level assertions.

## Current Evidence

- `lib/main.dart` constructs `QiZhengSiYuStorageDependencies` and also provides `...createProviders(deps)`.
- `lib/navigator.dart` wraps each route in another `createProviders(context.read<QiZhengSiYuStorageDependencies>())`.
- `lib/di.dart` already adapts `repository_interface_qizhengsiyu` ports to product services and ViewModels.
- `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` still imports `data/datasources` and `data/repositories`.
- `lib/presentation/pages/beauty_page_viewmodel.dart` directly calls `rootBundle.loadString` and constructs ShenSha/HuaYao repository implementations.
- `lib/domain/managers/zhou_tian_model_manager.dart` uses a singleton and loads built-in data through `rootBundle`.
- `lib/domain/engines/calculation_engine_factory.dart` statically constructs concrete engines.
- `lib/domain/engines/historical_engine.dart` constructs `SystemDefinitionLocalDataSource` from the data layer and reads historical ephemeris assets directly.
- `repository-interface-qizhengsiyu/lib` contains pure Dart-looking ports, but its `pubspec.yaml` still declares Flutter SDK dependencies.

## Required Review Revisions

External feasibility review returned `DONE_WITH_CONCERNS`. This change incorporates the accepted revisions:

- D1: Q3 must first make `ZhouTianModelManager` injectable/testable.
- D2: Q3 must refactor `CalculationEngineFactory` or use an injected engine provider.
- D5: Q3 must remove `HistoricalEngine` hard dependency on `SystemDefinitionLocalDataSource`.
- D6: Boundary scans must include domain-to-data violations.
- D7: Q4 must define legacy notifier/getter equivalence with explicit field and consumer coverage.

## Approval State

This proposal is ready for review as a migration/refactor plan. It is not approval to change production code until Q0 baseline gates are complete.
