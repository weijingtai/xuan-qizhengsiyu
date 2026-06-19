# Metaphysics Chart UI Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable Flutter chart-board UI package with four renderers, shared geometry, shared interaction, Theme/YAML support, and safe module adapter boundaries.

**Architecture:** Module adapters convert domain models into neutral `ChartBoard` data. Layout engines resolve deterministic `BoardGeometry`; renderers consume geometry and interaction state. Canvas and Widget renderers share ids, hit regions, theme tokens, and controller semantics.

**Tech Stack:** Flutter, Dart, `flutter_test`, golden tests, YAML parsing, ThemeExtension, OpenSpec, SuperPowers, gStack/browser QA.

---

## File Structure

Create a sibling package:

- Create: `../metaphysics-chart-ui/pubspec.yaml`
- Create: `../metaphysics-chart-ui/analysis_options.yaml`
- Create: `../metaphysics-chart-ui/lib/metaphysics_chart_ui.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_data.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_layer.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_item.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_geometry.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_interaction.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_theme.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_yaml_loader.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/circular_ring_layout_engine.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/rect_grid_layout_engine.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/rect_perimeter_layout_engine.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/circular_canvas_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/circular_widget_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/rect_grid_canvas_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/rect_grid_widget_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/adapters/adapter_contracts.dart`
- Create: `../metaphysics-chart-ui/lib/src/testing/board_golden_harness.dart`
- Create: `../metaphysics-chart-ui/lib/src/testing/board_hit_test_harness.dart`
- Create: `../metaphysics-chart-ui/test/architecture/import_boundary_test.dart`
- Create: `../metaphysics-chart-ui/test/architecture/no_xuan_identifier_test.dart`
- Create: `../metaphysics-chart-ui/test/layouts/circular_ring_layout_engine_test.dart`
- Create: `../metaphysics-chart-ui/test/layouts/rect_grid_layout_engine_test.dart`
- Create: `../metaphysics-chart-ui/test/layouts/rect_perimeter_layout_engine_test.dart`
- Create: `../metaphysics-chart-ui/test/interaction/board_interaction_test.dart`
- Create: `../metaphysics-chart-ui/test/theme/board_yaml_loader_test.dart`
- Create: `../metaphysics-chart-ui/test/renderers/renderer_conformance_test.dart`
- Create: `../metaphysics-chart-ui/example/lib/main.dart`

Do not modify production QiZhengSiYu renderer files until the package examples and tests pass.

## Task 1: External Risk Review Before Code

**Files:**

- Read: `openspec/changes/create-metaphysics-chart-ui-package/proposal.md`
- Read: `openspec/changes/create-metaphysics-chart-ui-package/design.md`
- Read: `openspec/changes/create-metaphysics-chart-ui-package/tasks.md`
- Create: `openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-risk-review.md`

- [ ] **Step 1: Dispatch or request an external AI architecture review**

Ask the reviewing agent to inspect API lock-in, geometry expressiveness, renderer divergence, Canvas interaction, Theme/YAML ownership, accessibility, and module boundary risks.

- [ ] **Step 2: Record review findings**

Create `openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-risk-review.md` with this structure:

```markdown
# P0 Risk Review

## Reviewer Scope

## Findings

## Accepted Changes

## Rejected Changes

## Stop-The-Line Items

## Approval
```

- [ ] **Step 3: Update OpenSpec if the review finds blocking flaws**

Only proceed when blocking public API or migration risks are resolved in `design.md` and `tasks.md`.

## Task 2: Create Package Skeleton

**Files:**

- Create: `../metaphysics-chart-ui/pubspec.yaml`
- Create: `../metaphysics-chart-ui/analysis_options.yaml`
- Create: `../metaphysics-chart-ui/lib/metaphysics_chart_ui.dart`
- Test: `../metaphysics-chart-ui/test/architecture/no_xuan_identifier_test.dart`

- [ ] **Step 1: Create Flutter package**

Run from `xuan-migration` root:

```bash
flutter create --template=package metaphysics-chart-ui
```

Expected: package directory is created with pubspec name adjusted in the next step.

- [ ] **Step 2: Set package name**

Ensure `../metaphysics-chart-ui/pubspec.yaml` has:

```yaml
name: metaphysics_chart_ui
description: Reusable Flutter chart-board renderers for metaphysics modules.
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  yaml: ^3.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] **Step 3: Add identifier guard test**

Add a test that scans `pubspec.yaml`, `lib`, and `test` for `xuan_` or `xuan-` program identifiers and fails unless the match is an allowed directory/Git URL reference.

- [ ] **Step 4: Run skeleton verification**

Run:

```bash
cd ../metaphysics-chart-ui
flutter analyze
flutter test
```

Expected: both pass.

- [ ] **Step 5: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: scaffold metaphysics chart ui package"
```

## Task 3: Core Data Contracts

**Files:**

- Create: `../metaphysics-chart-ui/lib/src/core/board_data.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_layer.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_item.dart`
- Create: `../metaphysics-chart-ui/lib/src/adapters/adapter_contracts.dart`
- Modify: `../metaphysics-chart-ui/lib/metaphysics_chart_ui.dart`
- Test: `../metaphysics-chart-ui/test/architecture/import_boundary_test.dart`

- [ ] **Step 1: Define immutable board data**

Create data classes for `ChartBoard`, `ChartLayer`, `ChartSector`, `ChartItem`, `ChartBoardAdapter`, and `ChartBoardAdapterContext`. Use only Flutter/Dart primitives and opaque metadata maps.

- [ ] **Step 2: Export public contracts**

Export core contracts from `metaphysics_chart_ui.dart`.

- [ ] **Step 3: Add import boundary test**

Scan package core/layouts/renderers for:

```text
package:qizhengsiyu
package:qimendunjia
package:daliuren
package:ziwei
package:taiyishenshu
```

Expected: no matches.

- [ ] **Step 4: Run tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/architecture
flutter analyze
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: add chart board core contracts"
```

## Task 4: Geometry And Hit Regions

**Files:**

- Create: `../metaphysics-chart-ui/lib/src/core/board_geometry.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/circular_ring_layout_engine.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/rect_grid_layout_engine.dart`
- Create: `../metaphysics-chart-ui/lib/src/layouts/rect_perimeter_layout_engine.dart`
- Test: `../metaphysics-chart-ui/test/layouts/circular_ring_layout_engine_test.dart`
- Test: `../metaphysics-chart-ui/test/layouts/rect_grid_layout_engine_test.dart`
- Test: `../metaphysics-chart-ui/test/layouts/rect_perimeter_layout_engine_test.dart`

- [ ] **Step 1: Write circular tests first**

Tests must assert:

- 12 equal sectors cover 360 degrees.
- 16 equal sectors cover 360 degrees.
- 360 tick layer produces 360 minor ticks and configured major ticks.
- 28 custom arcs preserve provided start/sweep values.
- point layer produces stable anchors and hit regions.

- [ ] **Step 2: Implement circular layout**

Implement only enough geometry to satisfy the tests. Use deterministic ids and bounds-first hit regions.

- [ ] **Step 3: Write rectangular tests**

Tests must assert:

- 3x3 matrix cells produce nine regions.
- 12 perimeter cells produce twelve stable slots.
- corner radius affects perimeter corner paths.

- [ ] **Step 4: Implement rectangular layouts**

Implement `RectGridLayoutEngine` and `RectPerimeterLayoutEngine`.

- [ ] **Step 5: Run geometry tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/layouts
```

Expected: pass.

- [ ] **Step 6: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: add board layout geometry engines"
```

## Task 5: Interaction Controller

**Files:**

- Create: `../metaphysics-chart-ui/lib/src/core/board_interaction.dart`
- Test: `../metaphysics-chart-ui/test/interaction/board_interaction_test.dart`

- [ ] **Step 1: Write interaction tests**

Tests must assert hover, clear hover, tap selection, multi-selection mode, focus next/previous, disabled region behavior, and isolated state between two controllers.

- [ ] **Step 2: Implement controller**

Implement `BoardInteractionController` and immutable `BoardInteractionState`.

- [ ] **Step 3: Run interaction tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/interaction
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: add board interaction controller"
```

## Task 6: Theme And YAML

**Files:**

- Create: `../metaphysics-chart-ui/lib/src/core/board_theme.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_yaml_loader.dart`
- Test: `../metaphysics-chart-ui/test/theme/board_yaml_loader_test.dart`

- [ ] **Step 1: Write theme tests**

Tests must assert fallback, YAML load, per-token fallback, module palette separation, renderer override, and instance override precedence.

- [ ] **Step 2: Implement theme contracts**

Implement semantic tokens, typography tokens, geometry tokens, circular tokens, rectangular tokens, module palette, and resolved theme.

- [ ] **Step 3: Implement YAML loader**

Use `yaml` package. Invalid values should fall back per token and expose diagnostics.

- [ ] **Step 4: Run theme tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/theme
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: add board theme and yaml loader"
```

## Task 7: Four Renderers

**Files:**

- Create: `../metaphysics-chart-ui/lib/src/renderers/circular_canvas_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/circular_widget_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/rect_grid_canvas_board.dart`
- Create: `../metaphysics-chart-ui/lib/src/renderers/rect_grid_widget_board.dart`
- Test: `../metaphysics-chart-ui/test/renderers/renderer_conformance_test.dart`

- [ ] **Step 1: Write renderer conformance tests**

Tests must assert all four renderers consume `ChartBoard`, resolve geometry, expose same region ids, and update hover/selected state through shared controller semantics.

- [ ] **Step 2: Implement Canvas wrappers**

Canvas renderers must wrap `CustomPaint` with `MouseRegion`, `GestureDetector`, and focus/semantics support.

- [ ] **Step 3: Implement Widget renderers**

Widget renderers must use shared geometry and normal Flutter widgets for content slots.

- [ ] **Step 4: Add golden tests**

Add deterministic goldens for four simple boards.

- [ ] **Step 5: Run renderer tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/renderers
```

Expected: pass.

- [ ] **Step 6: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "feat: add four chart board renderers"
```

## Task 8: Example App And gStack Surface

**Files:**

- Create/Modify: `../metaphysics-chart-ui/example/lib/main.dart`

- [ ] **Step 1: Add four example boards**

Examples:

- QiZheng-like circular: 12 sectors, 360 ticks, 28 arcs, star points.
- TaiYi-like circular: 16 sectors.
- ZiWei-like perimeter: 12 rounded rectangle slots.
- QiMen/DaLiuRen-like: 3x3 rich widget grid.

- [ ] **Step 2: Add theme/YAML switch**

Expose one control to switch between fallback and YAML-loaded theme.

- [ ] **Step 3: Add visible interaction state**

Every example must show selected state. Canvas examples must show hover state.

- [ ] **Step 4: Run local example**

```bash
cd ../metaphysics-chart-ui/example
flutter run -d chrome
```

Expected: all four examples visible.

- [ ] **Step 5: Run gStack/browser QA**

Collect desktop/mobile screenshots, hover evidence, tap evidence, and theme switch evidence.

- [ ] **Step 6: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "test: add chart board example validation surface"
```

## Task 9: QiZhengSiYu Adapter Prototype

**Files:**

- Create: `lib/presentation/chart_adapters/qizheng_chart_board_adapter.dart`
- Test: `test/presentation/chart_adapters/qizheng_chart_board_adapter_test.dart`

- [ ] **Step 1: Write adapter tests**

Tests must assert adapter creates:

- 12-sector palace layer.
- 360 tick layer.
- 28 custom arc layer.
- star point layer.
- `moduleId == 'qizhengsiyu'`.
- stable `instanceId`.

- [ ] **Step 2: Implement adapter without deleting old painters**

Use existing QiZhengSiYu data models only in adapter file. Return neutral `ChartBoard`.

- [ ] **Step 3: Add parity fixture**

Use one stable panel fixture to compare old painter geometry assumptions against new `ChartBoard` geometry.

- [ ] **Step 4: Run adapter tests**

```bash
flutter test test/presentation/chart_adapters/qizheng_chart_board_adapter_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/chart_adapters test/presentation/chart_adapters
git commit -m "feat: prototype qizheng chart board adapter"
```

## Task 10: Production Readiness Gate

**Files:**

- Create: `openspec/changes/create-metaphysics-chart-ui-package/evidence/P7-production-readiness.md`

- [ ] **Step 1: Run package gates**

```bash
cd ../metaphysics-chart-ui
flutter analyze
flutter test
```

- [ ] **Step 2: Run product adapter gates**

```bash
cd ../xuan-qizhengsiyu
flutter analyze
flutter test test/presentation/chart_adapters/qizheng_chart_board_adapter_test.dart
```

- [ ] **Step 3: Run boundary scans**

Use commands in `openspec/changes/create-metaphysics-chart-ui-package/acceptance.md`.

- [ ] **Step 4: Attach gStack evidence**

Record paths to screenshots and QA notes.

- [ ] **Step 5: Decide go/no-go**

Only proceed to production replacement when all evidence exists.

## Self-Review Checklist

- [ ] Every OpenSpec requirement maps to at least one task.
- [ ] No task requires modifying production QiZhengSiYu painters before package validation.
- [ ] No package core file imports module packages.
- [ ] Four renderers are implemented before production readiness.
- [ ] Canvas interaction has hit-test tests before visual demos.
- [ ] Theme/YAML fallback is tested before module migration.
- [ ] gStack evidence is required before production replacement.
