# Zhu Luo San Xian Ring UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render selected Zhu Luo annual results as sparse initial/middle/final stage groups with annual palace cells, dynamic repeat-visit tracks, jump/bridge/transition semantics, and configurable age labels.

**Architecture:** Keep calculation unchanged. A pure QiZheng presentation projector converts `ZhuLuoYearResult` into an immutable ring plan. Existing chart-ui `ArcLayer` renders annual cells; a QiZheng foreground painter renders only jump and inter-stage connectors.

**Tech Stack:** Flutter 3.38.6, Dart 3.10.7, `flutter_test`, `metaphysics_chart_ui` public ArcLayer API, golden tests, gStack visual QA.

---

## Source Of Truth

- OpenSpec: `openspec/changes/render-zhu-luo-san-xian-rings/`
- Human design: `docs/superpowers/specs/2026-06-24-zhu-luo-san-xian-ring-ui-design.md`
- Existing calculator: `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart`
- Existing generic ring evidence: `docs/superpowers/specs/da-xian-ring-ui-drawing.md`

## File Structure

Create:

- `lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart` — immutable visit, annual-cell, transition, track, and plan types.
- `lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart` — pure annual-result projection.
- `lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart` — ring-plan to chart-ui ArcLayer conversion.
- `lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart` — widget composition, label mode, hit lookup.
- `lib/presentation/widgets/rings/zhu_luo_transition_painter.dart` — jump and inter-stage connector painting only.
- Matching tests under `test/presentation/models/`, `test/presentation/chart_adapters/`, and `test/presentation/widgets/rings/`.

Modify only after standalone evidence passes:

- `lib/presentation/adapters/legacy/qizheng_legacy_board.dart` — additive feature-flagged host composition.
- `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` — selected algorithm, label mode, and annual result exposure.
- `lib/painter/chart_style/qi_zheng_chart_style.dart` — QiZheng-local semantic style role fields and defaults.
- `lib/painter/chart_style/theme_chart_style_resolver.dart` — parser/resolver support for QiZheng-local Zhu Luo roles.
- Existing QiZheng-local theme token files selected by the repository's current chart theme convention.

Do not modify:

- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart`
- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart`
- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart`
- `lib/presentation/widgets/rings/da_xian_ring_painter.dart`
- `lib/utils/da_xian_calculate_helper.dart`
- `../metaphysics-chart-ui/`

### Task 1: Characterize Projection Inputs

**Files:**
- Create: `test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart`
- Read: `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart`

- [ ] **Step 1: Add fixtures produced by the real calculator**

Cover A inverse jumps, Frederick B bridge years, a repeated palace visit, and a shared transition age. Tests must call `calculateZhuLuoSanXian`; do not hand-author fake presentation results except for malformed-input validation.

- [ ] **Step 2: Run the test and confirm failure**

```bash
flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart
```

Expected: FAIL because projector/model files do not exist.

- [ ] **Step 3: Record unchanged calculator baseline**

```bash
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected: all existing tests PASS with no skips.

### Task 2: Add Immutable Ring Plan

**Files:**
- Create: `lib/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan.dart`
- Create: `test/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan_test.dart`

- [ ] **Step 1: Define the types**

Required public shape:

```dart
enum ZhuLuoAgeLabelMode { rangeOnly, allCells, auto }

class ZhuLuoVisitSegment {
  final LimitStage stage;
  final ZhuLuoRuler ruler;
  final EnumTwelveGong palace;
  final int startAge;
  final int endAge;
  final String phase;
  final bool usedBridge;
  final int visitOrdinal;
}

class ZhuLuoAnnualCell {
  final String id;
  final int age;
  final double startAngle;
  final double sweepAngle;
  final int trackIndex;
  final ZhuLuoVisitSegment visit;
  final bool isTransitionYear;
}

class ZhuLuoTransitionEdge {
  final String id;
  final int age;
  final ZhuLuoTransitionKind kind;
  final String sourceCellId;
  final String targetCellId;
}

class ZhuLuoRingPlan {
  final List<ZhuLuoAnnualCell> cells;
  final List<ZhuLuoTransitionEdge> transitions;
  final Map<LimitStage, int> trackCounts;
}
```

All collections must be immutable defensive copies.

- [ ] **Step 2: Test equality-relevant fields, defensive copying, and stable IDs**

- [ ] **Step 3: Run model tests**

```bash
flutter test test/presentation/models/zhu_luo_san_xian/zhu_luo_ring_plan_test.dart
```

Expected: PASS.

### Task 3: Implement Pure Projection

**Files:**
- Create: `lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart`
- Modify: `test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart`

- [ ] **Step 1: Add the pure signature**

```dart
ZhuLuoRingPlan projectZhuLuoRing({
  required List<ZhuLuoYearResult> years,
  required List<EnumTwelveGong> palaceOrder,
  required double startAngleOffset,
});
```

- [ ] **Step 2: Group contiguous visits**

Split when stage, ruler, palace, phase, bridge state, or age continuity changes.

- [ ] **Step 3: Assign repeat visit ordinals**

Count visits independently per `(stage, palace)`; compute each stage's maximum required track count.

- [ ] **Step 4: Generate annual-cell geometry**

For a visit of `N` years, generate `N` cells across exactly 30 degrees. Force the final boundary to the palace end.

Do not re-deduplicate, synthesize missing ages, or call Zhu Luo rule helpers from presentation code. The projector must preserve one annual cell per calculator record.

- [ ] **Step 5: Generate transition edges**

Create inverse jump edges only for non-adjacent jump semantics. Create inter-stage edges from transition metadata without duplicating annual cells. Bridges remain cells, not jumps.

- [ ] **Step 6: Run projection tests**

Expected assertions include:

```dart
expect(fourYearCells.map((e) => e.sweepAngle), everyElement(7.5));
expect(fourYearCells.fold<double>(0, (sum, e) => sum + e.sweepAngle), closeTo(30, 1e-9));
expect(fourYearCells.last.startAngle + fourYearCells.last.sweepAngle, closeTo(palaceStart + 30, 1e-9));
expect(plan.cells, hasLength(years.length));
expect(repeatCells.map((e) => e.trackIndex).toSet(), {0, 1});
expect(skippedPalaceCells, isEmpty);
expect(cells.where((e) => e.age == transitionAge), hasLength(1));
```

### Task 4: Convert Plan To ArcLayers

**Files:**
- Create: `lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart`
- Create: `test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart`

- [ ] **Step 1: Add adapter result and signature**

```dart
class ZhuLuoRingLayers {
  final List<ArcLayer> layers;
  final Map<String, ZhuLuoAnnualCell> cellByHitId;
}

ZhuLuoRingLayers buildZhuLuoRingLayers({
  required ZhuLuoRingPlan plan,
  required double innerRadius,
  required double trackWidth,
  required double repeatGap,
  required double stageGap,
  required ZhuLuoAgeLabelMode labelMode,
  required double zoomScale,
});
```

- [ ] **Step 2: Build one ArcLayer per physical visit track**

Blank palace sectors must emit no `ArcSegment`. Use semantic palette/style roles only.

Style roles may be added only in QiZheng-local theme/style files named in the file structure section. Do not change `../metaphysics-chart-ui/`.

- [ ] **Step 3: Implement labels**

`rangeOnly` labels one central cell per visit. `allCells` labels cells that fit. `auto` switches policy by zoom/available sweep without changing IDs or geometry.

- [ ] **Step 4: Test style role consumption**

Add a discriminating assertion: two otherwise identical cells/plans that differ only by stage or bridge semantic role must resolve to different `ArcSegment` style or different painted/golden output. This test must fail if the adapter ignores semantic roles.

- [ ] **Step 5: Test layer order, sparse arcs, labels, and hit lookup**

Run:

```bash
flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart
```

Expected: PASS; geometry IDs identical across all label modes; semantic role changes are observable in resolved output.

### Task 5: Add Connector Painter And Widget

**Files:**
- Create: `lib/presentation/widgets/rings/zhu_luo_transition_painter.dart`
- Create: `lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart`
- Create: `test/presentation/widgets/rings/zhu_luo_transition_painter_test.dart`
- Create: `test/presentation/widgets/rings/zhu_luo_san_xian_ring_test.dart`

- [ ] **Step 1: Write failing geometry and widget tests**

Assert connector endpoints use the same plan radii/angles as cells; painter paints no cells or labels.

- [ ] **Step 2: Implement connector painter**

Use resolved semantic colors. Paint inverse jumps and inter-stage markers only. Bridge emphasis belongs to ArcLayer styling.

- [ ] **Step 3: Add non-color affordances**

Do not distinguish states by color alone. Use non-color channels:

- Repeat tracks: dotted edge tick or equivalent boundary marker.
- Bridge cells: hatch, seam, or patterned stroke.
- Jump connectors: dashed or patterned stroke.
- Transition markers: shape or tick distinct from normal cells.

- [ ] **Step 4: Implement the ring widget**

Compose circular ArcLayers and foreground painter in one stable-size `Stack`. Expose selected-cell callback and label mode.

- [ ] **Step 5: Add golden fixtures**

Cover A jump, B bridge, repeated visit ring, shared transition, range-only normal scale, all-cell enlarged scale, light theme, and dark theme.

### Task 6: Wire Controls Behind A Feature Flag

**Files:**
- Modify: `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart`
- Modify: `lib/presentation/adapters/legacy/qizheng_legacy_board.dart`
- Test: focused ViewModel and legacy-board widget tests

- [ ] **Step 1: Add ViewModel state**

Expose selected algorithm config, selected label mode, and calculated annual results. The renderer receives annual results only.

- [ ] **Step 2: Add the algorithm Radio control**

Options come from configured algorithms, including user extensions. Selecting one recalculates/reprojects one displayed result set.

- [ ] **Step 3: Add label-density control**

Default `rangeOnly`; allow `allCells` and `auto`.

- [ ] **Step 4: Add forgiving selection and linear fallback**

Small angular cells must not require pixel-perfect tapping. Implement hit slop, visit-first disambiguation, zoom-on-touch, or an equivalent selection path.

Expose a linear annual-path list/fallback derived from the same immutable ring plan. Each row must include age, stage, palace, phase, algorithm, bridge state, jump state, and transition state.

- [ ] **Step 5: Integrate default-off**

Additive host wiring must leave the existing production board unchanged when disabled.

- [ ] **Step 6: Test both flag states and control changes**

No control change may alter calculation rules, cell IDs for the same annual input, linear fallback payloads, or unrelated board layers.

### Task 7: Verification Gates

- [ ] **Step 1: Focused tests**

```bash
flutter test test/presentation/models/zhu_luo_san_xian
flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_projector_test.dart
flutter test test/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter_test.dart
flutter test test/presentation/widgets/rings/zhu_luo_san_xian_ring_test.dart
flutter test test/xing_xian/zhu_luo_san_xian
```

Expected: PASS, no skipped tests.

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/presentation/models/zhu_luo_san_xian lib/presentation/chart_adapters/zhu_luo_san_xian_ring_projector.dart lib/presentation/chart_adapters/zhu_luo_san_xian_ring_adapter.dart lib/presentation/widgets/rings/zhu_luo_san_xian_ring.dart lib/presentation/widgets/rings/zhu_luo_transition_painter.dart
```

Expected: no issues.

- [ ] **Step 3: Boundary scans**

Run the boundary scans in OpenSpec `design.md`. Expected: no calculation leakage, legacy DaXian reuse, hard-coded black/ARGB styling, new shared-package changes, or new skipped/focused tests.

Also run:

```bash
rg -n "skip:|skip\(|\.only|, skip|solo" test/presentation
```

Expected: no new skipped, focused, or solo presentation tests caused by this implementation.

- [ ] **Step 4: Impact scan before production host edits**

Before modifying `qizheng_legacy_board.dart` or `qi_zheng_si_yu_viewmodel.dart`, run the repo's available impact/dependency scan for those symbols. Stop and report if the scan reveals unexpected high-blast-radius dependencies.

- [ ] **Step 5: gStack QA**

Verify radial stage order, sparse sectors, repeat tracks, light annual dividers, A jumps, B bridges, non-duplicated transitions, zoom label behavior, forgiving small-cell selection, non-color affordances, dark theme, and linear fallback.

- [ ] **Step 6: Evidence and enablement gate**

Record commands, outputs, goldens, and screenshots. Keep feature default-off until user approval.
