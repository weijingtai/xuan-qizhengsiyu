# Tasks: Create Metaphysics Chart UI Package

> SuperPowers implementation plan: `docs/superpowers/plans/2026-06-19-metaphysics-chart-ui-package.md`
> Acceptance package: `openspec/changes/create-metaphysics-chart-ui-package/acceptance.md`

## P0 · Spec Review And Baseline Discovery

**Entry Criteria**

- Current branch is not `main` or `master`.
- No production package code has been created.
- OpenSpec proposal/design/tasks/spec exist.

- [ ] P0.1 Review this OpenSpec change with at least one external AI agent focused on architecture risks.
- [ ] P0.2 Record current QiZhengSiYu Canvas painter inventory and mark which layers are equal-sector, custom-arc, tick, point, or widget-composed.
- [ ] P0.3 Record QiMenDunJia `SmartQiMenGrid` rectangular widget-grid behavior and theme usage.
- [ ] P0.4 Record DaLiuRen rectangular/table/grid UI examples that should migrate to `RectGridWidgetBoard`.
- [ ] P0.5 Record candidate ZiWei and TaiYi board layouts: circular 12, circular 16, and 12-cell perimeter.
- [ ] P0.6 Validate that the neutral model can represent all recorded examples without module-specific renderer branches, including a composite star (`ItemGroup`), dual-angle stars (`AngularPoint`), and the inner/outer mirror rings expressed as `behavior` data.
- [ ] P0.7 Decide final sibling package location and package name. Default: `../metaphysics-chart-ui` directory with pubspec name `metaphysics_chart_ui`.
- [ ] P0.8 Run documentation unfinished-marker scan and fix any incomplete marker terms or incomplete acceptance statements.
- [ ] P0.9 Produce P0 go/no-go note in this change directory.
- [ ] P0.10 Sequence against the in-flight `QiZhengChartStyle` / YAML-token migration (`docs/superpowers/specs/2026-06-17-qizhengsiyu-chart-theme-token-migration-plan.md`); record which theme system survives end-state and confirm the same painters are not re-migrated in parallel.
- [ ] P0.11 Build read-only `buildBoard()` + geometry snapshots against the real data models of all five modules (QiZhengSiYu, TaiYiShenShu, ZiWeiDouShu, DaLiuRen, QiMenDunJia), OR mark the public API experimental and add a gate forbidding a second production migration until a multi-module conformance suite passes.
- [ ] P0.12 Record non-360 coordinate ownership: QiZhengSiYu adapter owns the versioned `365.25 -> 360` cumulative-boundary mapping; package core accepts normalized millidegrees only.
- [ ] P0.13 Record Zhu-Luo-San-Xian sparse fixtures, including disjoint, adjacent, overlapping-overlay, and split wrap-around ranges.

**Exit Criteria**

- All target board families are represented in examples or fixtures, with composite/dual-angle/mirror cases proven on the real module data shapes.
- The theme end-state owner is recorded and does not collide with the in-flight token migration.
- No implementation starts until external risk review and baseline discovery are complete.

**Stop-The-Line**

- Any required board family cannot be modeled by `ChartBoard` + layers, or a star cannot be modeled as one `ItemGroup`.
- Package name would violate `xuan_`/`xuan-` governance.
- External risk review finds a boundary flaw that would require changing public core data types.
- The public API would be frozen on QiZhengSiYu plus synthetic demos only, with no real adapter proof for the other four modules.

## P1 · Package Skeleton And Core Contracts

**Entry Criteria**

- P0 go/no-go is approved.

- [ ] P1.1 Create sibling Flutter package `metaphysics_chart_ui`.
- [ ] P1.2 Add public barrel `lib/metaphysics_chart_ui.dart`.
- [ ] P1.3 Add immutable core contracts: `ChartBoard`, `ChartLayer` (with `semanticsMode` and a `behavior` block), `ChartSector`, `ChartItem`, `ItemGroup`, `AngularPoint`, `ChartBoardAdapter`, `BoardSemantics`.
- [ ] P1.4 Add layout spec contracts: `CircularLayerSpec`, `FullCircleCoverage`, `SparseArcCoverage`, `SparseArcRange` (stable id, integer start/end, local partition, caps, logical target), overlay ring reference, z/hit priority, disabled block/pass-through, `owner(targetId, semanticsOrder)` / `merge(targetId)` / `none` semantics policy, `RectGridLayoutSpec`, and `RectPerimeterLayoutSpec`.
- [ ] P1.5 Add `BoardInteractionController`, `BoardInteractionState`, and callback contracts; resolve a child hit up to its owning `ItemGroup` id.
- [ ] P1.6 Add `BoardTheme`, renderer token groups, module palette contracts, and fallback values; include the role-mapping destinations for the existing chart-style roles.
- [ ] P1.7 Add architecture tests enforcing the import allow-list (core/layouts/renderers may import only Flutter, `dart:ui`, `dart:math`, `yaml`, and named utilities) and explicitly failing on `package:metaphysics_core`, `package:theme`, and `package:xuan_config`.
- [ ] P1.8 Add no-`xuan_`/`xuan-` identifier scan for package pubspec, library declarations, import keys, and public identifiers.
- [ ] P1.9 Run `flutter analyze` and package tests.
- [ ] P1.10 Add an API/identifier test proving core exposes no source-domain span, `365.25`, mapping table, or projection callback.

**Exit Criteria**

- Package compiles with no renderer implementation yet.
- Core contracts are pure UI/data contracts and do not depend on consuming modules.
- A star is representable as a single `ItemGroup` with a dual-angle `AngularPoint`.

**Stop-The-Line**

- Core contracts require any module enum/model, or any import outside the allow-list (including `package:metaphysics_core`).
- Public data model cannot express opaque module metadata without leaking domain objects.
- A composite mark cannot be expressed without exposing its sub-primitives as separate addressable entities.

## P2 · Layout Engines And Geometry

**Entry Criteria**

- P1 tests pass.

- [ ] P2.1 Implement `CircularRingLayoutEngine` for equal sectors.
- [ ] P2.2 Implement circular full and sparse custom arc geometry for non-uniform layers such as 28 constellations and partial Zhu-Luo-San-Xian ranges.
- [ ] P2.3 Implement tick geometry for 360-degree and configurable major/minor ticks.
- [ ] P2.4 Implement point/angle geometry for stars/items with two radius bands and dual `originalAngle`/`displayAngle` plus leader line.
- [ ] P2.5 Implement `RectGridLayoutEngine` for matrix grids.
- [ ] P2.6 Implement `RectPerimeterLayoutEngine` for rounded-rectangle perimeter layouts.
- [ ] P2.7 Implement `BoardGeometry` and `BoardHitRegion` generation. Hit regions are filled, closed geometry (annular wedge polygons for sectors/arcs), authored independently of the stroked draw path; tick scales default to non-interactive.
- [ ] P2.8 Add snapshot tests for all geometry types.
- [ ] P2.9 Add hit-test tests for circular sector, custom arc band, point item, grid cell, and perimeter cell; assert an arc-band hit uses the wedge area (not the stroke path) and that an interactive tick scale resolves by angular bucket.
- [ ] P2.10 Implement a mandatory spatial/angular index for layers above 64 regions and the documented deterministic benchmark: 5 x 1,000 warm-ups, 10 x 10,000 measured seeded lookups, p95 below 2 ms on the registered target, and fitted log-log slope below `0.85` for 128/256/512/1024 regions; record complete environment metadata.
- [ ] P2.11 Add sparse coverage tests: single/disjoint/adjacent ranges; reject same-layer overlap, zero sweep, out-of-range and implicit wrap-around; accept explicit split wrap-around; assert full radial reservation, blank-angle hit/semantics exclusion, and deterministic overlay z-order.
- [ ] P2.12 Add Canvas/Widget geometry conformance fixtures for sparse inner/outer borders, radial start/end borders, and `butt`/`round` caps.
- [ ] P2.13 Add canonical-transform and boundary tests: validate before direction/offset/rotation, normalize point `360000` to `0`, probe `b-1/b/b+1`, and map split fragments to one logical target/semantics node.
- [ ] P2.14 Add deterministic overlay tests for paint order, hit order, equal-priority declaration tie-break, disabled block/pass-through, paint-only round-cap protrusion, and single-owner adjacent seams.
- [ ] P2.15 Add semantics policy tests: one owner per target; owner-only role/primary label/state/activate; declaration-ordered merged descriptions; unique non-activate action IDs; reject missing/duplicate owners, duplicate actions, and owner-field overrides.

**Exit Criteria**

- All target layouts produce deterministic geometry and hit regions.
- Hit geometry is sound for stroked arcs and tick scales, and dense-board hit-test meets the budget.

**Stop-The-Line**

- Hit-test regions differ across renderers for the same board data.
- Geometry cannot represent a 360 tick layer and an equal-sector layer on the same circular board.
- Any hit region is derived from a stroked/open draw path, or a dense layer has no spatial index.

## P3 · Four Renderers

**Entry Criteria**

- P2 geometry and hit-test tests pass.

- [ ] P3.1 Implement `CircularCanvasBoard`.
- [ ] P3.2 Implement `CircularWidgetBoard`.
- [ ] P3.3 Implement `RectGridCanvasBoard`.
- [ ] P3.4 Implement `RectGridWidgetBoard`.
- [ ] P3.5 Add renderer conformance tests proving all renderers use shared interaction state, including two mirror-image rings that differ only by `behavior` parameters yet yield identical hit-region ids.
- [ ] P3.6 Add hover, selected, pressed, focus, and disabled visual-state tests.
- [ ] P3.7 Add semantics tests for interactive regions, asserting bounded node count and `ItemGroup` collapsing (no node for tick scales).
- [ ] P3.8 Add golden tests for all four renderers with deterministic fixtures.
- [ ] P3.9 Implement the hybrid Canvas+Widget composition (widget overlay items positioned on shared geometry anchors, sharing the controller and hit ids) and test that a Canvas ring plus widget star badges resolve one consistent selection.

**Exit Criteria**

- Four renderers plus the hybrid composition exist and consume the same `ChartBoard` model.
- Canvas renderers provide hover/click/focus through shared controller and hit regions.

**Stop-The-Line**

- A renderer introduces private data requirements not represented in `ChartBoard`.
- A per-ring difference is implemented as renderer logic instead of `behavior` data.
- Canvas hover cannot be verified by tests.
- Widget and Canvas renderers disagree on selected region ids.

## P4 · ThemeExtension And YAML

**Entry Criteria**

- P3 renderer tests pass.

- [ ] P4.1 Implement standalone `BoardTheme`/ThemeExtension support for the package example and tests, without core importing `package:theme`.
- [ ] P4.2 Implement YAML loader with schema version and package fallback; reconcile field names with the existing `assets/theme/chart_tokens.yaml` schema (`colors`/`typography`/`geometry`/`starPalette`).
- [ ] P4.3 Implement module palette loading without adding module enum dependencies.
- [ ] P4.4 Add theme precedence tests: fallback, base tokens (host `XuanThemeData.chartTokens` or standalone YAML), module, renderer, instance override.
- [ ] P4.5 Add invalid YAML tests proving optional per-token fallback, plus strict production failure and clear diagnostics for missing `invalidRingFill`, `invalidRingBorder`, `invalidRingLabel`, or `invalidRingBorderWidth`.
- [ ] P4.6 Add light/dark theme fixture tests.
- [ ] P4.7 Implement the host bridge in the adapter/host layer that feeds `XuanThemeData.chartTokens` to a board as base tokens, and add the role-mapping table test asserting each existing chart-style role lands in its single destination (core semantic / renderer token / module palette).

**Exit Criteria**

- Themes can be loaded from YAML and resolved for each board instance.
- Module palettes remain separate from semantic UI tokens.
- Host theme tokens drive a board without core importing `package:theme`, and no third parallel theme system is introduced.

**Stop-The-Line**

- YAML parser requires module-specific classes.
- An optional YAML key crashes instead of falling back, or a required
  `invalidRing*` key silently falls back in strict production mode.
- Package core imports `package:theme`, or a chart-style role has no mapped destination.

## P5 · Example App And gStack Validation Surface

**Entry Criteria**

- P4 theme tests pass.

- [ ] P5.1 Add example board: QiZheng-like circular board with 12 sectors, 360 ticks, 28 custom arcs, and angle-positioned star items.
- [ ] P5.2 Add example board: TaiYi-like circular 16-sector board.
- [ ] P5.3 Add example board: ZiWei-like rounded-rectangle 12-cell perimeter board.
- [ ] P5.4 Add example board: QiMen/DaLiuRen-like rectangular widget grid.
- [ ] P5.5 Add theme switch or YAML-loaded theme control.
- [ ] P5.6 Add visible hover/selected interaction demo for Canvas and Widget renderers.
- [ ] P5.7 Run browser/manual QA and collect gStack evidence after implementation.
- [ ] P5.8 Add a sparse circular demo with blank angles and two overlapping Zhu-Luo-San-Xian overlays, exposing cap styles and hover/selection for gStack verification.

**Exit Criteria**

- Example app demonstrates all four renderer families and all required layout forms.

**Stop-The-Line**

- gStack/browser QA cannot visually confirm hover/selected states.
- Any renderer has no example route.

## P6 · QiZhengSiYu Adapter Prototype

**Entry Criteria**

- P5 example app passes local and gStack validation.

- [ ] P6.1 Add QiZhengSiYu adapter in the consuming module, not package core.
- [ ] P6.2 Map existing ring sizes, 12 palace layers, 360 tick layer, 28 constellation arcs, and star point layers into `ChartBoard`, consuming a resolved immutable star snapshot (original angle, display angle, leader pairs, group membership), never the live mutable solver model.
- [ ] P6.3 Keep old QiZhengSiYu painters available for parity testing.
- [ ] P6.4 Add side-by-side golden harness comparing old and new output for one stable fixture.
- [ ] P6.5 Migrate one low-risk layer first, such as a divider/tick layer.
- [ ] P6.6 Produce migration evidence before replacing any user-facing board.
- [ ] P6.7 Add an angle-parity fixture asserting both `originalAngle` and resolved `displayAngle` survive the adapter unchanged and that building the board triggers no solver mutation.
- [ ] P6.8 Implement the QiZhengSiYu-owned, versioned cumulative-boundary normalization policy using three-decimal source fixed point, integer rational arithmetic, and round-half-up; test `0/182.625/365.25 -> 0/180000/360000`, exact-half boundaries, monotonic properties, invalid full-coverage source closure/order/range/finiteness, quantization collapse, and sparse ranges without aggregate closure preserving gaps.

**Exit Criteria**

- QiZhengSiYu can generate a `ChartBoard` without moving calculation/domain code.
- At least one migrated layer has parity evidence.
- The adapter reads an immutable snapshot and preserves both angles.

**Stop-The-Line**

- Adapter needs package core changes for module-specific behavior.
- Adapter triggers or depends on collision-solver mutation.
- Migration changes calculated positions or business data.
- Golden drift appears without an approved visual-design change.

## P7 · Production Readiness Review

- [ ] P7.1 Run all package tests and analyzer.
- [ ] P7.2 Run architecture/import allow-list scans (fail on `package:metaphysics_core`/`theme`/`xuan_config` in core).
- [ ] P7.3 Run golden tests.
- [ ] P7.4 Run example app interaction QA.
- [ ] P7.5 Collect gStack screenshots and interaction evidence.
- [ ] P7.6 Run independent code review focused on public API lock-in, irreversible migration risk, accessibility, and renderer divergence.
- [ ] P7.7 Approve or revise OpenSpec before production migration continues.
- [ ] P7.8 Attach hit-test performance-budget evidence and a bounded-node accessibility traversal result for the reference board.
- [ ] P7.9 Attach sparse-arc Canvas/Widget parity evidence covering blank angles, caps, overlay hit priority, semantics, and responsive clipping.
- [ ] P7.10 Run failure injection for geometry, strict-theme, hit-index, and renderer initialization; prove Legacy fallback preserves selection, rotation, and module state.
- [ ] P7.11 Generate a commit-SHA evidence manifest and verify a deliberately missing runtime artifact fails production readiness even when OpenSpec reports artifact completion.
- [ ] P7.12 Implement and test `tool/verify_production_readiness.dart` against `evidence/production-readiness-manifest.yaml`; require schema v1, exact HEAD, the closed 16-ID catalog from `design.md`, `passed` statuses, existing files, and matching SHA-256 hashes in CI; catalog changes require a schema-version change.

**Exit Criteria**

- Public API is stable enough for module adapters, proven by real adapters for all five modules or explicitly labeled experimental with a second-migration gate.
- All four renderers plus the hybrid composition are verified.
- Known risks have mitigation evidence.

**Stop-The-Line**

- Any required gate lacks evidence.
- External review identifies an unresolved irreversible API or migration risk.
