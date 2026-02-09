# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**qizhengsiyu (七政四余)** — A Flutter module implementing a Chinese astrology/horology system. The module is embedded into a native host app (not a standalone Flutter app). It depends on a sibling package `common` at `../xuan-common`.

The core domain involves celestial body positioning, palace (宫) mapping, and pattern (格局/GeJu) evaluation for astrological chart analysis.

## Build & Development Commands

```bash
# Install dependencies (must also have ../xuan-common available)
flutter pub get

# Code generation (json_serializable, drift)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch

# Run all tests
flutter test

# Run a specific test file
flutter test test/managers/star_position_manager_test.dart

# Run the example app
cd example && flutter run
```

Generated files use `.g.dart` suffix. Never edit these manually — modify the source and re-run `build_runner`.

## Architecture

Clean Architecture with three layers, wired together via Provider in `lib/di.dart`:

```
Presentation (ViewModels + Pages/Widgets)
    ↓ depends on
Domain (Entities, Services, Managers, Repository interfaces)
    ↓ implemented by
Data (Repository implementations, Local data sources, JSON assets)
```

**State management:** Provider with `ChangeNotifier`-based ViewModels.

### Layer responsibilities

- **Data sources** (`lib/data/datasources/local/`): Read JSON assets and local storage. Each feature has its own data source (e.g., `GeJuLocalDataSource`, `ShenShaLocalDataSource`).
- **Repositories** (`lib/data/repositories/`): Implement interfaces from `lib/domain/repositories/`. Handle data merging (built-in + user data), caching, and format migration.
- **Services** (`lib/domain/services/`): CRUD operations and business queries (e.g., `GeJuCrudService` for filtering, validation, import/export of rules).
- **Managers** (`lib/domain/managers/`): Complex business logic — `GeJuEvaluator` (pattern matching engine), `StarPositionManager`, `ZhouTianModelManager`, `ShenShaManager`, `HuaYaoManager`.
- **ViewModels** (`lib/presentation/viewmodels/`): Extend `ChangeNotifier`. Expose state via getters, call `notifyListeners()` on mutation.

### Key domain subsystems

| Subsystem | Purpose | Key files |
|-----------|---------|-----------|
| **GeJu (格局)** | Astrological pattern matching with rule-based conditions | `lib/domain/entities/models/ge_ju/`, `lib/domain/managers/ge_ju/` |
| **ShenSha (神煞)** | Spirit energy calculations per palace | `shen_sha_manager.dart`, `shen_sha_service.dart` |
| **HuaYao (化曜)** | Star transformation mappings (禄暗福耗) | `hua_yao_manager.dart`, `hua_yao_service.dart` |
| **ZhouTian (周天)** | Celestial coordinate/position modeling | `zhou_tian_model_manager.dart`, `zhou_tian_calculator.dart` |
| **Fate (命理)** | Destiny palace computation | `lib/domain/managers/fate/` |

## GeJu System (actively developed)

The GeJu pattern-matching system is the most complex subsystem:

- **GeJuRule** → contains multiple **GeJuVariant** (one per school/source)
- Each variant has **conditions** (logical tree of AND/OR/NOT combinators)
- **GeJuCondition** is the base class; 8 concrete condition categories live in `lib/domain/entities/models/ge_ju/conditions/`:
  - `position_conditions` (star in gong/constellation)
  - `relationship_conditions` (same/opposite/trine/square gong)
  - `structure_conditions` (life palace, star guards)
  - `yong_shen_conditions` (star four-type relationships)
  - `time_conditions` (season, day/night, moon phase)
  - `gong_status_conditions` (temple/exalted/fallen status)
  - `shen_sha_conditions` (spirit energies)
  - `xian_conditions` (running year/大限)
- **GeJuInput** is the unified evaluation context passed to all conditions
- **GeJuEvaluator** orchestrates matching rules against input

Built-in rule JSON assets are in `example/assets/qizhengsiyu/ge_ju/` split into `rules/` (condition logic) and `content/` (display text). User-created rules are stored locally with `user_`-prefixed UUIDs.

## Enums

Domain enums live in `lib/enums/` with `enum_` prefix. Key enums: `EnumQiZheng` (celestial bodies), `EnumTwelveGong` (12 palaces), `EnumStarsFourType` (恩/难/仇/用), `EnumHuaYao` (禄/暗/福/耗), `EnumSchool` (astrological schools).

## Testing

- Unit tests: `test/*_test.dart`
- Dev/exploration tests: `test/dev_*.dart` — these are development scratch files, not CI tests
- Mock data: `test/mock/`
- Test fixtures: `test/resources/`

## Key Dependencies

- `sweph` — Swiss Ephemeris for astronomical calculations
- `tyme` — Chinese lunar calendar/time
- `drift` — SQLite ORM with code generation
- `common` (local path) — shared utilities from `../xuan-common`

## Conventions

- Domain concept names use pinyin (e.g., GeJu, ShenSha, HuaYao, ZhouTian)
- Comments mix Chinese (for domain concepts) and English (for code logic)
- Repository interfaces use `I` prefix (e.g., `IGeJuRepository`) or no prefix (e.g., `ShenShaRepository`)
- Models use `@JsonSerializable()` with factory `fromJson` constructors
- New GeJu condition types must: extend `GeJuCondition`, implement `evaluate()` and `describe()`, register in `GeJuCondition.fromJson()` type dispatch
