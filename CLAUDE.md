# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **架构方向 · 盘面渲染统一到 `metaphysics-chart-ui`（Chart-UI）**
>
> 本模块的「排盘 / 盘面」渲染将迁移到共享的专用排盘包 `metaphysics-chart-ui`（4 个通用渲染器 + 自带 5 级优先级 token 主题系统），**替换当前模块内自有的盘面实现**。本模块是该包的**首个迁移消费者**。
> - 不要再扩展或重写模块自有的盘面 Canvas painter / 盘面级主题；新的盘面工作一律经 Chart-UI 的中性模型 + 渲染器 + 模块适配器接入。
> - 盘面样式**不走** `XuanThemeData.component()` / `ComponentStyle` 通用主题迁移；那条通路只负责非盘面的 card / 组件（这些组件不退役，照常迁移）。
> - 已退役模块自有的 YAML 图表 loader（`ChartTokenLoader`/`ChartStarPaletteLoader`/`YamlChartStyleResolver`），统一到 `ThemeChartStyleResolver`；后者原地待命，作为 Chart-UI 主题契约的参考锚。
> - 背景见 `openspec/changes/create-metaphysics-chart-ui-package`。

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

## docs/ — Upstream subtree (pull-only)

`docs/` 是从 `https://github.com/weijingtai/docs.git`（分支 `master`）通过 `git subtree` 引入的 AI 协同文档框架。所有文件由本仓库的 git 管理（与普通源文件等同）。

**铁律**：
- **MUST NOT** 向 `weijingtai/docs` 推送任何修改；该仓库对本项目而言是只读上游。
- 本项目对 `docs/` 的本地适配（如 `Plans.md`、`ai/code-style.md` 等）随本仓库 commit 即可。
- 拉取上游更新（仅在需要时执行）：
  ```bash
  git subtree pull --prefix=docs https://github.com/weijingtai/docs.git master --squash
  ```
- 严禁运行 `git subtree push --prefix=docs ...`。本仓库未配置任何指向 `weijingtai/docs` 的 git remote，正常 `git push` 不会触及上游。

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **xuan-qizhengsiyu** (19055 symbols, 47036 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/xuan-qizhengsiyu/context` | Codebase overview, check index freshness |
| `gitnexus://repo/xuan-qizhengsiyu/clusters` | All functional areas |
| `gitnexus://repo/xuan-qizhengsiyu/processes` | All execution flows |
| `gitnexus://repo/xuan-qizhengsiyu/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
