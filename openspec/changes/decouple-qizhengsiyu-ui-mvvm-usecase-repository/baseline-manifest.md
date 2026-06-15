# Baseline Manifest: QiZhengSiYu Decouple

- Date: 2026-06-14
- Branch: `refactor/qizhengsiyu-decouple-mvvm-usecase-repository`
- Scope: Q0 baseline freeze before production migration code changes.

## Git Status

Current working tree at Q0 baseline capture:

```text
 M example/pubspec.lock
 D flutter_01.log
?? .codegraph/daemon.pid
?? docs/superpowers/plans/2026-06-14-qizhengsiyu-decouple-test-plan.md
?? docs/superpowers/plans/2026-06-14-qizhengsiyu-mvvm-usecase-repository-migration.md
?? docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-acceptance-criteria.md
?? docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-test-acceptance-design.md
?? openspec/
?? test/domain/fixtures/
?? test/fixtures/
?? test/resources/golden_base_star_positions.json
?? test/resources/qizhengsiyu_all_in_one_panel_cases.json
?? test/resources/qizhengsiyu_all_in_one_panel_manifest.json
?? test/resources/qizhengsiyu_decoupling_contract_fixture.json
?? test/resources/qizhengsiyu_time_calculation_cases.json
?? test/scripts/
```

## Route List

`lib/navigator.dart` currently defines these routes:

- `/`
- `/qizhengsiyu/panel`
- `/qizhengsiyu/home`
- `/qizhengsiyu/ge_ju/list`
- `/qizhengsiyu/ge_ju/detail`
- `/qizhengsiyu/ge_ju/create`
- `/qizhengsiyu/ge_ju/edit`
- `/qizhengsiyu/ge_ju/school/list`
- `/qizhengsiyu/ge_ju/school/edit`

## Provider Scopes

`createProviders(...)` call sites:

```text
lib/main.dart:45 app-scope providers from `deps`
lib/navigator.dart:27 /qizhengsiyu/panel route-level providers
lib/navigator.dart:36 /qizhengsiyu/ge_ju/list route-level providers
lib/navigator.dart:44 /qizhengsiyu/ge_ju/detail route-level providers
lib/navigator.dart:59 /qizhengsiyu/ge_ju/create route-level providers
lib/navigator.dart:70 /qizhengsiyu/ge_ju/edit route-level providers
lib/navigator.dart:77 /qizhengsiyu/ge_ju/school/list route-level providers
lib/navigator.dart:84 /qizhengsiyu/ge_ju/school/edit route-level providers
```

Q1 decision required: decide which route-level provider scopes can collapse to app-scope and document any intentional route-local exceptions.

## Key File Sizes

```text
2459 lib/presentation/pages/beauty_view_page.dart
 954 lib/presentation/pages/beauty_page_viewmodel.dart
 897 lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart
 517 lib/main.dart
 153 lib/navigator.dart
 131 lib/di.dart
5111 total
```

## Flutter Analyze Baseline

Command:

```bash
flutter analyze
```

Result: failed with `1634 issues found`.

Dominant existing buckets:

- `companion_system/**` missing package imports and undefined generated/database/provider types.
- Existing dev/test files with stale enum names, deprecated members, duplicate imports, unused locals/imports, and print lints.
- Known examples include `test/dev_zhou_tian_manager.dart`, `test/engines/calculation_engine_factory_test.dart`, `test/test_shen_sha.dart`, and `test/dev_stars_test.dart`.

Q1+ rule: touched files must introduce zero new analyzer issues relative to this baseline.

## Flutter Test Baseline

Command:

```bash
flutter test
```

Result: failed. Observed terminal summary near completion: approximately `+190 ~11 -13`.

Dominant existing failures:

- `test/domain/engines/projection/linear_projector_test.dart`: expected `0.0`, actual `365.25` for the 360-degree boundary case.
- `test/domain/entities/models/ge_ju/parser_conversion_test.dart`: compile failures around `DiZhiShenSha`, generated `di_zhi_shen_sha.g.dart`, and stale `CelestialCoordinateSystem` enum constants.
- Several existing dev tests still compile against stale enum names such as `PanelSystemType.tropical` and `ConstellationSystemType.modern`.

Q1+ rule: new focused tests must pass; full-suite failures above remain baseline debt unless a touched file creates a new failure.

## Boundary Scan Baseline

### UI Deny-List

Command:

```bash
rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|QiZhengSiYuPanRepository|ShenShaRepositoryImpl|HuaYaoRepositoryImpl|LocalDataSourceImpl|SaveCalculatedPanelUseCase\(|CalculateFateDongWeiUseCase\(" lib/presentation lib/controllers lib/navigator.dart
```

Current matches:

```text
lib/presentation/pages/beauty_page_viewmodel.dart:16 import data/datasources/local/hua_yao_local_data_source.dart
lib/presentation/pages/beauty_page_viewmodel.dart:17 import data/repositories/hua_yao_repository_impl.dart
lib/presentation/pages/beauty_page_viewmodel.dart:24 import data/datasources/local/shen_sha_local_data_source.dart
lib/presentation/pages/beauty_page_viewmodel.dart:25 import data/repositories/shen_sha_repository_impl.dart
lib/presentation/pages/beauty_page_viewmodel.dart:816-821 rootBundle shen_sha assets
lib/presentation/pages/beauty_page_viewmodel.dart:827-828 ShenShaRepositoryImpl/ShenShaLocalDataSourceImpl construction
lib/presentation/pages/beauty_page_viewmodel.dart:850-852 rootBundle hua_yao assets
lib/presentation/pages/beauty_page_viewmodel.dart:859-860 HuaYaoRepositoryImpl/HuaYaoLocalDataSourceImpl construction
lib/presentation/pages/beauty_page_viewmodel.dart:931 commented SaveCalculatedPanelUseCase reference
lib/presentation/pages/beauty_view_page.dart:1982 rootBundle.load
lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart:20-24 data datasource/repository imports
```

### ViewModel Deny-List

Command:

```bash
rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|RepositoryImpl|LocalDataSourceImpl|package:flutter/services.dart" lib/presentation/viewmodels lib/presentation/pages/beauty_page_viewmodel.dart
```

Current matches:

```text
lib/presentation/pages/beauty_page_viewmodel.dart:15 package:flutter/services.dart
lib/presentation/pages/beauty_page_viewmodel.dart:16-17 data HuaYao imports
lib/presentation/pages/beauty_page_viewmodel.dart:24-25 data ShenSha imports
lib/presentation/pages/beauty_page_viewmodel.dart:816-821 rootBundle shen_sha assets
lib/presentation/pages/beauty_page_viewmodel.dart:827-828 ShenShaRepositoryImpl/ShenShaLocalDataSourceImpl construction
lib/presentation/pages/beauty_page_viewmodel.dart:850-852 rootBundle hua_yao assets
lib/presentation/pages/beauty_page_viewmodel.dart:859-860 HuaYaoRepositoryImpl/HuaYaoLocalDataSourceImpl construction
lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart:20-24 data datasource/repository imports
```

### UseCase Deny-List

Command:

```bash
rg -n "package:flutter/(material|widgets|services|rendering)\.dart|presentation/|pages/|widgets/|BuildContext|rootBundle|AppDatabase|RepositoryImpl|LocalDataSourceImpl|(^|/)data/" lib/domain/usecases
```

Current matches:

```text
lib/domain/usecases/save_calculated_panel_usecase.dart:3 package:flutter/rendering.dart
lib/domain/usecases/save_calculated_panel_usecase.dart:7 ../../data/contract_mappers/qizhengsiyu_contract_mappers.dart
```

A1 self-proof: the broad `(^|/)data/` scan catches `data/contract_mappers`, which the former narrow scan missed.

### Domain Flutter Deny-List

Command:

```bash
rg -n "package:flutter/(services|foundation|rendering|material|widgets)\.dart|rootBundle" lib/domain
```

Current matches:

```text
lib/domain/managers/zhou_tian_model_manager.dart:4 package:flutter/services.dart
lib/domain/managers/zhou_tian_model_manager.dart:71 rootBundle.loadString
lib/domain/engines/historical_engine.dart:3 package:flutter/services.dart
lib/domain/engines/historical_engine.dart:33 rootBundle.loadString
lib/domain/usecases/save_calculated_panel_usecase.dart:3 package:flutter/rendering.dart
lib/domain/engines/sweph_engine.dart:6 package:flutter/services.dart
lib/domain/engines/sweph_engine.dart:47 rootBundle.loadString
lib/domain/managers/ge_ju/ge_ju_input_builder.dart:3 package:flutter/foundation.dart
lib/domain/managers/ge_ju/ge_ju_evaluator.dart:2 package:flutter/foundation.dart
lib/domain/managers/ge_ju/ge_ju_manager.dart:2 package:flutter/services.dart
lib/domain/managers/ge_ju/ge_ju_manager.dart:47,67 rootBundle.loadString
lib/domain/services/generate_base_panel_service.dart:8 package:flutter/services.dart
lib/domain/services/ge_ju_evaluation_service.dart:2 package:flutter/foundation.dart
lib/domain/services/yuan_le_panel_builder.dart:4 package:flutter/foundation.dart
lib/domain/services/yuan_le_panel_builder.dart:5 package:flutter/services.dart
lib/domain/services/yuan_le_panel_builder.dart:32 rootBundle.loadString
lib/domain/entities/models/star_to_star_relationship_model.dart:2 package:flutter/foundation.dart
```

### Domain Data-Layer Deny-List

Command:

```bash
rg -n "(^|/)data/|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource" lib/domain
```

Current matches:

```text
lib/domain/services/ge_ju_crud_service.dart:13 data/contract_mappers
lib/domain/services/ge_ju_evaluation_service.dart:12 data/contract_mappers
lib/domain/usecases/save_calculated_panel_usecase.dart:7 data/contract_mappers
lib/domain/engines/historical_engine.dart:4 SystemDefinitionLocalDataSource import
lib/domain/engines/historical_engine.dart:17 SystemDefinitionLocalDataSource field
lib/domain/engines/historical_engine.dart:19 SystemDefinitionLocalDataSource construction
```

### Repository-Interface Purity Scan

Command:

```bash
rg -n "flutter:|sdk: flutter|package:flutter|package:qizhengsiyu/" ../repository-interface-qizhengsiyu/pubspec.yaml ../repository-interface-qizhengsiyu/lib
```

Current matches:

```text
../repository-interface-qizhengsiyu/pubspec.yaml:6 flutter environment
../repository-interface-qizhengsiyu/pubspec.yaml:9 flutter dependency
../repository-interface-qizhengsiyu/pubspec.yaml:10 sdk: flutter
../repository-interface-qizhengsiyu/pubspec.yaml:17 sdk: flutter
```

Additional Q2.0 fact: `metaphysics_core` appears only in `../repository-interface-qizhengsiyu/pubspec.yaml`, not in `lib` or `test`.

### Storage Reverse Dependency Scan

Command:

```bash
rg -n "presentation/|pages/|widgets/|ViewModel|BuildContext" ../xuan-storage/assets/lib ../xuan-storage/drift/lib
```

Current matches: none.

### Composition Root Count

Command:

```bash
rg -n "createProviders\(" lib/main.dart lib/navigator.dart
```

Current count: 8 call sites, listed under Provider Scopes above.

## Q3 Blockers

Current blocker evidence:

```text
lib/domain/managers/zhou_tian_model_manager.dart: rootBundle model loading
lib/presentation/pages/beauty_page_viewmodel.dart:126,161 ZhouTianModelManager.instance
lib/presentation/pages/beauty_page_viewmodel.dart:265,334,890 CalculationEngineFactory.create
lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart:335,793 CalculationEngineFactory.create
lib/domain/engines/historical_engine.dart: SystemDefinitionLocalDataSource + rootBundle
```

Q3 must create injection seams before fake-data UseCase tests can be credible.
