# qizhengsiyu-ui-mvvm-usecase-repository Specification

## ADDED Requirements

### Requirement: UI depends only on ViewModel state and intents

QiZhengSiYu UI pages, widgets, and controllers SHALL render ViewModel state and call ViewModel intent methods rather than constructing repositories, UseCases, data sources, storage adapters, or official-data readers.

#### Scenario: Main pan page uses ViewModel intent

- **GIVEN** the `/qizhengsiyu/panel` route is built
- **WHEN** the user requests a pan calculation
- **THEN** the page calls a ViewModel intent method
- **AND** the page does not import `lib/data/**`, `persistence_drift`, `persistence_assets`, or repository implementation classes

#### Scenario: GeJu page remains service-backed

- **GIVEN** a GeJu management page is built
- **WHEN** the user loads, edits, or refreshes GeJu rules
- **THEN** the page calls its GeJu ViewModel
- **AND** the ViewModel delegates to injected service/usecase abstractions

### Requirement: ViewModels delegate business work to UseCases

QiZhengSiYu ViewModels SHALL own UI state transitions and SHALL delegate calculation, official-data loading, GeJu evaluation, timeline building, and persistence operations to injected UseCases.

#### Scenario: ViewModel has no direct data implementation imports

- **GIVEN** `lib/presentation/viewmodels/**` and approved compatibility ViewModels are scanned
- **WHEN** the migration is complete
- **THEN** no ViewModel imports any `lib/data/**` path, `rootBundle`, `persistence_drift`, or `persistence_assets`

### Requirement: UseCases depend on repository-interface ports or pure domain services

UseCases SHALL expose application actions and SHALL NOT import Flutter UI, pages, widgets, ViewModels, concrete storage adapters, or asset loaders.

#### Scenario: Save panel usecase persists through repository interface

- **GIVEN** `SaveCalculatedPanelUseCase` receives an `IQiZhengSiYuPanRepository`
- **WHEN** it saves, updates, reads, or deletes a pan
- **THEN** it calls the repository-interface port
- **AND** it does not import Flutter rendering, UI, Drift, or data source implementations

### Requirement: Official assets are modeled as repository-interface ports

Official read-only QiZhengSiYu datasets SHALL be exposed through explicit repository-interface ports and SHALL be implemented by storage/assets adapters or host-provided adapters.

#### Scenario: Star status data is loaded through a port

- **GIVEN** YuanLe calculation needs star position status data
- **WHEN** the migrated path runs
- **THEN** it receives data through `QiZhengStarPositionStatusRepository`
- **AND** domain code does not call `rootBundle.loadString`

#### Scenario: Historical ephemeris data is loaded through a port

- **GIVEN** historical ephemeris calculation needs `sun_speeds.json`
- **WHEN** the migrated path runs
- **THEN** it receives data through `QiZhengHistoricalEphemerisRepository`
- **AND** domain code remains pure Dart

#### Scenario: ZhouTian models are loaded through a port

- **GIVEN** ZhouTian model definitions are needed
- **WHEN** the model manager initializes
- **THEN** model content is supplied through `QiZhengZhouTianModelRepository`
- **AND** no domain manager uses Flutter asset APIs

### Requirement: Repository-interface package remains pure Dart

`repository-interface-qizhengsiyu` SHALL NOT depend on Flutter SDK or the product package.

#### Scenario: Interface package purity scan passes

- **GIVEN** `repository-interface-qizhengsiyu` source and pubspec are scanned
- **WHEN** migration completion is claimed
- **THEN** there are no matches for Flutter SDK dependencies, `package:flutter`, or `package:qizhengsiyu`

### Requirement: Composition root constructs concrete storage once

The application/host composition root SHALL construct concrete storage and assets adapters once and SHALL pass them into `QiZhengSiYuStorageDependencies`.

#### Scenario: Route provider graph is stable

- **GIVEN** the app starts at `/qizhengsiyu/panel`
- **WHEN** navigation moves between panel and GeJu routes
- **THEN** routes use the same storage dependency bundle
- **AND** routes do not accidentally create duplicate business/storage graphs

### Requirement: Migration preserves business behavior

Every migration phase SHALL preserve existing calculated outputs and UI-observable state unless an approved spec change explicitly changes behavior.

#### Scenario: Characterization fixtures remain equivalent

- **GIVEN** Q0 characterization fixtures and expected outputs exist
- **WHEN** any migration phase completes
- **THEN** focused tests compare migrated outputs against Q0 expected results
- **AND** mismatches block the phase unless approved as intentional behavior changes

### Requirement: Domain does not depend on data-layer implementations

QiZhengSiYu domain code SHALL NOT import data-layer sources, repository implementations, local data sources, or `SystemDefinitionLocalDataSource`.

#### Scenario: Domain-to-data boundary scan passes

- **GIVEN** `lib/domain` is scanned for data-layer implementation dependencies
- **WHEN** migration completion is claimed
- **THEN** there are no matches for broad `(^|/)data/`, `LocalDataSource`, `RepositoryImpl`, or `SystemDefinitionLocalDataSource`

### Requirement: Main-pan legacy compatibility fields remain equivalent

The Q4 main-pan ViewModel migration SHALL preserve every public legacy notifier/getter still consumed by UI until that consumer is migrated or explicitly retired.

#### Scenario: Legacy notifier equivalence is proven

- **GIVEN** the Q4 equivalence manifest marks a legacy field as `must-sync` or `derived-compatible`
- **WHEN** the same Q0 fixture is run through the migrated ViewModel path
- **THEN** the legacy field/getter value matches the new `QiZhengPanUiState` or `QiZhengPanDisplayState` value according to its recorded policy
- **AND** fields marked `retire-after-Q4` have no remaining UI consumer before Q5 cleanup
