# Metaphysics Chart UI Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable Flutter chart-board UI package with four renderers, shared geometry, shared interaction, Theme/YAML support, and safe module adapter boundaries.

**Architecture:** Module adapters convert domain models into neutral `ChartBoard` data. Layout engines resolve deterministic `BoardGeometry`; renderers consume geometry and interaction state. Canvas and Widget renderers share ids, hit regions, theme tokens, and controller semantics.

**Tech Stack:** Flutter, Dart, `flutter_test`, golden tests, YAML parsing, ThemeExtension, OpenSpec, SuperPowers, gStack/browser QA.

**Revision 2026-06-20:** Package circular APIs accept normalized integer
display millidegrees only. QiZhengSiYu owns the fixed-point `365.25 -> 360`
mapping. Circular coverage is explicitly full-circle or sparse partial-arc;
overlapping Zhu-Luo-San-Xian ranges use ordered overlays sharing one radial
band.

---

## File Structure

Create a sibling package:

- Create: `../metaphysics-chart-ui/pubspec.yaml`
- Create: `../metaphysics-chart-ui/analysis_options.yaml`
- Create: `../metaphysics-chart-ui/lib/metaphysics_chart_ui.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_data.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/board_layer.dart`
- Create: `../metaphysics-chart-ui/lib/src/core/circular_coverage.dart`
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
- Create: `../metaphysics-chart-ui/test/layouts/sparse_arc_coverage_test.dart`
- Create: `../metaphysics-chart-ui/test/layouts/rect_grid_layout_engine_test.dart`
- Create: `../metaphysics-chart-ui/test/layouts/rect_perimeter_layout_engine_test.dart`
- Create: `../metaphysics-chart-ui/test/interaction/board_interaction_test.dart`
- Create: `../metaphysics-chart-ui/test/theme/board_yaml_loader_test.dart`
- Create: `../metaphysics-chart-ui/test/renderers/renderer_conformance_test.dart`
- Create: `../metaphysics-chart-ui/test/renderers/sparse_arc_renderer_conformance_test.dart`
- Create: `test/presentation/chart_adapters/qizheng_angle_normalization_test.dart`
- Create: `../metaphysics-chart-ui/example/lib/main.dart`

Do not modify production QiZhengSiYu renderer files until the package examples and tests pass.

## Task 1: Complete P0 Baseline And Go/No-Go Before Code

**Files:**

- Read: `openspec/changes/create-metaphysics-chart-ui-package/proposal.md`
- Read: `openspec/changes/create-metaphysics-chart-ui-package/design.md`
- Read: `openspec/changes/create-metaphysics-chart-ui-package/tasks.md`
- Modify: `openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-risk-review.md`
- Create: `openspec/changes/create-metaphysics-chart-ui-package/evidence/P0-go-no-go.md`

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

- [ ] **Step 4: Complete baseline discovery**

Record the real QiZhengSiYu painter/ring inventory, QiMen and DaLiuRen widget
grids, ZiWei circular/perimeter layouts, and TaiYi 16-sector layout. Exercise
the neutral model against real read-only data shapes for all five modules, or
formally mark the API experimental and enforce the second-migration gate.

- [ ] **Step 5: Lock migration and contract boundaries**

Record the surviving Theme/YAML owner and sequencing against the in-flight
token migration. Verify that `BoardCenterSpec`, optional zero-width skip
semantics, independent track/body transforms, adapter-owned `365.25 -> 360`
normalization, and sparse overlap fixtures appear in OpenSpec, this plan, and
acceptance cases.

- [ ] **Step 6: Run P0 documentation gates**

```bash
openspec validate create-metaphysics-chart-ui-package --strict --no-interactive
```

Expected: pass with no unresolved P0/P1 documentation blocker.

- [ ] **Step 7: Publish P0 go/no-go**

Create `evidence/P0-go-no-go.md` mapping P0.1-P0.14 to concrete artifacts and
record either `GO` or `NO-GO`. Do not mark OpenSpec checkboxes complete without
the referenced evidence. Task 2 is blocked unless this result is `GO`.

## Task 2: Create Package Skeleton

**Entry Criteria:** `evidence/P0-go-no-go.md` records `GO` and P0.1-P0.14 have
evidence-backed completion.

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

Create immutable data classes for `ChartBoard`, `ChartLayer`, `ChartSector`,
`BoardCenterSpec`, `ChartItem`, `ItemGroup`, fragmented logical targets, `AngularPoint`,
`CircularCoverage`, `FullCircleCoverage`, `SparseArcCoverage`,
`SparseArcRange`, `OverlayLayer`, `RingOverlaySpec`, `SkippedRingGeometry`, `ChartBoardAdapter`, and
`ChartBoardAdapterContext`. Circular boundaries are integer millidegrees.
`SparseArcRange` includes stable ID, start/end, local partition, caps, and
logical target. Overlay data includes ring reference, z/hit priority, disabled
block/pass-through, declaration order, and semantics ownership.

- [ ] **Step 2: Export public contracts**

Export core contracts from `metaphysics_chart_ui.dart`.

- [ ] **Step 3: Add import boundary test**

Implement an exhaustive import allow-list for package core/layouts/renderers:

```text
Flutter, dart:ui, dart:math, yaml, and explicitly approved pure-Dart utilities
```

Explicitly assert `qizhengsiyu`, other consuming modules,
`metaphysics_core`, `theme`, and `xuan_config` are rejected. Add an API scan
asserting core exposes no `sourceDomainSpan`, `365.25`, mapping table, or
projection callback. Also assert geometry/layer/ring-border/item-style contracts
accept semantic style roles only and reject concrete `Color`, ARGB, or hex
values; renderers may not interpret metadata as styling. Expected: all
allow-list and API-boundary tests pass.

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
- Test: `../metaphysics-chart-ui/test/layouts/sparse_arc_coverage_test.dart`
- Test: `../metaphysics-chart-ui/test/layouts/rect_grid_layout_engine_test.dart`
- Test: `../metaphysics-chart-ui/test/layouts/rect_perimeter_layout_engine_test.dart`

- [ ] **Step 1: Write circular tests first**

Tests must assert:

- 12 equal sectors cover 360 degrees.
- 16 equal sectors cover 360 degrees.
- 360 tick layer produces 360 minor ticks and configured major ticks.
- 28 custom arcs preserve provided start/sweep values.
- point layer produces stable anchors and hit regions.
- full coverage rejects any gap, overlap, underflow, or overflow from `360000`.
- sparse coverage accepts single, disjoint, adjacent, and explicitly split
  wrap-around ranges without requiring full-circle closure.
- sparse coverage rejects zero sweep, out-of-range, implicit wrap-around, and
  same-layer overlap; `[0,60000)` plus `[58000,72000)` succeeds only as two
  ordered overlays sharing one radial band.
- validation runs in canonical clockwise space before direction/offset/rotation;
  point `360000` aliases `0`, and boundary probes at `b-1/b/b+1` satisfy
  half-open ownership.
- one logical target may own multiple hit fragments but at most one semantics
  node; blank angles and round-cap protrusions have no interaction/semantics.
- duplicate IDs and invalid radial allocation are board-fatal; malformed
  coverage with valid radial allocation is ring-local.
- absent/Canvas/Widget/hybrid centers establish the first ring boundary and do
  not participate in angular validation.
- optional zero-width rings retain source identity/order as skipped entries,
  emit nothing, and return at the same position when enabled; required zero is
  board-fatal because no error annulus can be allocated.
- track and body overlays share one ring but resolve independent rotations,
  inverse hit transforms, and paint outsets.

- [ ] **Step 2: Implement circular layout**

Implement only enough geometry to satisfy the tests. Use shared resolved paths,
filled closed annular hit wedges, deterministic IDs, bounds-first hit regions,
single-owner adjacent seams, paint order `(zIndex, declarationOrder)`, and hit
order `(hitPriority, zIndex, declarationOrder)`. Minimum touch expansion is
clipped to declared sparse coverage.

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

Run the documented deterministic benchmark: 5 x 1,000 warm-ups, 10 x 10,000
measured seeded lookups, p95 below 2 ms on the registered target, and fitted
log-log slope below `0.85` for 128/256/512/1024 regions. Record hardware, OS,
Flutter/Dart versions, build mode, seed, and p50/p95/max.

Add a versioned `BenchmarkTargetProfile` fixture. Only an exact profile match
may emit passing evidence; unregistered runs are informational. Re-registration
requires review and a full protocol/baseline rerun. Treat 64 regions as the
non-overridable maximum indexing threshold: implementations may index earlier,
but consumers may not raise or disable it.

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

Tests must assert hover, clear hover, tap selection, multi-selection mode, focus
next/previous, fragmented logical-target identity, overlay hit priority,
disabled `block`/`passThrough`, deterministic semantics order, and isolated
state between two controllers.

Semantics tests require exactly one `owner(targetId, semanticsOrder)` per
logical target. The owner exclusively supplies role, primary label, state, and
activate. `merge(targetId)` appends declaration-ordered description fragments
and uniquely keyed non-activate actions without creating a node. Reject missing/
duplicate owners, duplicate action IDs, and owner-field overrides.

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

Tests must assert fallback-only theme completeness, YAML load, optional-token
fallback, strict production failure for each missing/malformed required
`invalidRing*` role, light/dark fixtures, module palette separation, host base
tokens, renderer override, and instance override precedence.
They must also prove concrete colors appear only in `ResolvedBoardTheme` and
module palettes cannot bypass resolution through geometry metadata.

- [ ] **Step 2: Implement theme contracts**

Implement semantic tokens, typography tokens, geometry tokens, circular tokens,
rectangular tokens, module palette, and resolved theme. Add exactly one ownership
destination for `invalidRingFill`, `invalidRingBorder`, `invalidRingLabel`, and
`invalidRingBorderWidth`.

- [ ] **Step 3: Implement YAML loader**

Use `yaml`. Optional invalid values fall back with diagnostics; required
invalid-ring roles fail strict production validation before painting.

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
- Test: `../metaphysics-chart-ui/test/renderers/sparse_arc_renderer_conformance_test.dart`

- [ ] **Step 1: Write renderer conformance tests**

Tests must assert all four renderers consume `ChartBoard`, resolve geometry,
expose the same logical IDs, and update shared interaction state. Circular
Canvas/Widget must match exactly on integer geometry, transforms, sparse paths,
boundary ownership, hit results, overlay ordering, fragmented identities, and
semantics structure. Raster goldens use declared pixel/text-baseline tolerances.
Circular renderer tests also assert center parity and independent track/body
rotation parity without changing shared ring radii.

- [ ] **Step 2: Implement Canvas wrappers**

Canvas renderers must wrap `CustomPaint` with `MouseRegion`, `GestureDetector`, and focus/semantics support.

- [ ] **Step 3: Implement Widget renderers**

Widget renderers must use shared geometry and normal Flutter widgets for content slots.

- [ ] **Step 4: Implement hybrid composition**

Position Widget overlays over Canvas layers through shared geometry anchors,
controller, hit IDs, and instance ownership. Verify one Canvas ring plus Widget
star badges produces one consistent selection.

- [ ] **Step 5: Add golden tests**

Add deterministic goldens for four simple boards.

- [ ] **Step 6: Run renderer tests**

```bash
cd ../metaphysics-chart-ui
flutter test test/renderers
```

Expected: pass.

- [ ] **Step 7: Commit**

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
- Zhu-Luo-San-Xian-like sparse circular board: blank angles, butt/round caps,
  split wrap-around, and overlapping `0..60` / `58..72` ordered overlays.

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

Collect desktop/mobile screenshots, hover/tap/theme evidence, plus sparse blank
angles, cap styles, overlay priority, disabled pass-through, semantics, and
responsive clipping evidence in both circular renderers.

- [ ] **Step 6: Commit**

```bash
git add ../metaphysics-chart-ui
git commit -m "test: add chart board example validation surface"
```

## Task 9: QiZhengSiYu Adapter Prototype

**Files:**

- Create: `lib/presentation/chart_adapters/qizheng_chart_board_adapter.dart`
- Create: `lib/presentation/chart_adapters/qizheng_angle_normalizer.dart`
- Test: `test/presentation/chart_adapters/qizheng_chart_board_adapter_test.dart`
- Test: `test/presentation/chart_adapters/qizheng_angle_normalization_test.dart`

- [ ] **Step 1: Write adapter tests**

Tests must assert adapter creates:

- 12-sector palace layer.
- 360 tick layer.
- 28 custom arc layer.
- star point layer.
- `moduleId == 'qizhengsiyu'`.
- stable `instanceId`.
- complete source-derived center/ring/overlay inventory from the geometry spec.
- package output contains integer display millidegrees only.
- `centerSize` maps to `BoardCenterSpec`, not a ring.
- zero-width `star-sequence` maps to a skipped optional entry with stable order.
- Legacy track/body rotations map to independent `RingOverlaySpec` transforms.

- [ ] **Step 2: Write projection-math tests**

Projection tests must assert:

- source fixed-point `0/182625/365250` maps to display
  `0/180000/360000` using integer rational round-half-up;
- cumulative boundaries are mapped once and sweeps are derived by subtraction;
- exact-half behavior and monotonic property fixtures are deterministic;

- [ ] **Step 3: Write rejection and sparse-preservation tests**

Rejection tests must assert:

- non-finite, non-monotonic, out-of-range, invalid full-coverage closure, and collapsed
  positive segments fail before package construction;
- sparse source ranges preserve gaps and do not expand to a full circle.

- [ ] **Step 4: Implement adapter without deleting old painters**

Use existing QiZhengSiYu data models only in adapter file. Return neutral `ChartBoard`.

Implement the versioned `equatorial-365.25-to-display-360-v1` mapping in the
QiZhengSiYu adapter directory, never in `metaphysics_chart_ui`. Keep source
coordinates and mapping revision in module-owned diagnostics outside package
geometry/equality/cache keys.

- [ ] **Step 5: Add parity fixture**

Use one stable panel fixture to compare old painter geometry assumptions against new `ChartBoard` geometry.

- [ ] **Step 6: Run adapter tests**

```bash
flutter test test/presentation/chart_adapters
```

Expected: pass.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/chart_adapters test/presentation/chart_adapters
git commit -m "feat: prototype qizheng chart board adapter"
```

## Task 10: Production Readiness Gate

**Files:**

- Create: `openspec/changes/create-metaphysics-chart-ui-package/evidence/P7-production-readiness.md`
- Create: `openspec/changes/create-metaphysics-chart-ui-package/evidence/production-readiness-manifest.yaml`
- Create: `tool/verify_production_readiness.dart`
- Test: `test/tool/verify_production_readiness_test.dart`

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
flutter test test/presentation/chart_adapters
```

- [ ] **Step 3: Run boundary scans**

Use commands in `openspec/changes/create-metaphysics-chart-ui-package/acceptance.md`.

- [ ] **Step 4: Attach gStack evidence**

Record paths to screenshots and QA notes.

- [ ] **Step 5: Run rollback failure injection**

Inject geometry, strict-theme, hit-index, and renderer initialization failures.
Assert Legacy remains/restores visible and preserves selection, rotation, and
module state.

- [ ] **Step 6: Generate evidence manifest**

Key all static, unit, golden, adapter, gStack, accessibility, performance, and
rollback evidence to the tested commit SHA. Implement schema v1 fields
`changeId`, `commitSha`, and artifacts with unique `id`, `category`, `path`,
`sha256`, `command`, and `status`. The verifier requires exact HEAD, all required
IDs, `passed` status, existing files, and matching hashes. Negative tests cover
missing/duplicate IDs, stale commit, missing file, hash mismatch, failed status,
and OpenSpec `4/4` with a missing runtime artifact.

The schema-v1 required IDs are the closed 17-ID catalog, including
`p0-go-no-go`, defined in OpenSpec `design.md` and `acceptance.md`; changing the
catalog requires a schema-version change.

- [ ] **Step 7: Decide go/no-go**

Only proceed to production replacement when all evidence exists.

## Self-Review Checklist

- [ ] Every OpenSpec requirement maps to at least one task.
- [ ] No task requires modifying production QiZhengSiYu painters before package validation.
- [ ] No package core file imports module packages.
- [ ] Four renderers are implemented before production readiness.
- [ ] Canvas interaction has hit-test tests before visual demos.
- [ ] Full and sparse coverage, canonical transforms, fragmented identity,
  blank-angle interaction, and overlap ordering are tested before visual demos.
- [ ] QiZhengSiYu, not package core, owns deterministic `365.25 -> 360` mapping.
- [ ] Optional Theme/YAML fallback and strict required-token failure are tested.
- [ ] Board-fatal versus ring-local validation is executable.
- [ ] Hybrid Canvas+Widget composition is implemented and tested.
- [ ] Legacy failure rollback preserves current instance state.
- [ ] Evidence is commit-SHA keyed; document completeness cannot imply runtime completion.
- [ ] gStack evidence is required before production replacement.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | Not run | Scope decisions were user-approved directly |
| Codex/OpenSpec Review | OpenSpec architecture roles | Independent contract challenge | 2 | CLEAR after revision | 10 edge-case groups resolved in normative docs |
| Eng Review | `/plan-eng-review` | Architecture & tests | 4 | P0 REQUIRED | External review exposed missing center/track-body propagation and incomplete P0 execution gate; plan corrected |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | Deferred to runtime demo | No rendered implementation exists yet |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | Not run | Not required for this documentation revision |

- **CROSS-MODEL:** Both architecture and gStack reviewers required adapter-owned fixed-point normalization, canonical sparse coverage, deterministic interaction/semantics, and machine-verifiable evidence.
- **UNRESOLVED:** P0.1-P0.14 require evidence-backed execution and a recorded go/no-go; no P1 implementation may start before `GO`.
- **VERDICT:** Design documents may proceed through P0 only. P1 implementation and production are blocked.
