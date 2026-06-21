# P0 Risk Review

- Change id: `create-metaphysics-chart-ui-package`
- Reviewer: external AI architecture/risk review (Claude, Opus 4.8)
- Review date: 2026-06-18
- Branch under review: `codex/metaphysics-chart-ui-openspec`
- Artifacts reviewed: `proposal.md`, `design.md`, `tasks.md`, `specs/metaphysics-chart-ui/spec.md`, `acceptance.md`, `evidence/doc-validation.md`, SuperPowers plan `docs/superpowers/plans/2026-06-19-metaphysics-chart-ui-package.md`
- Code grounded against: live QiZhengSiYu painter/style/model source and sibling-package layout (see Method).
- **Current verdict: P0 risk review closed for controlled P1 reconciliation.** The original NO-GO and supplemental blockers are preserved below as historical review evidence. `P0-go-no-go.md` records the current decision and pins the experimental gate commit; runtime evidence still gates public API stabilization and any user-facing board replacement.

## Original Verdict Summary

| Risk area | Blockers | Verdict |
|-----------|----------|---------|
| 1. Public API lock-in | A1, A2, A3 | Originally blocked; resolved or gated in the Resolution Log |
| 2. Four-renderer behavior divergence | B1, B2 | Originally blocked; resolved or gated in the Resolution Log |
| 3. Canvas hit-test performance & correctness | C1, C2 | Originally blocked; resolved or gated in the Resolution Log |
| 4. Theme/YAML ownership | D1, D2 | Originally blocked; resolved or gated in the Resolution Log |
| 5. Module boundary leakage | E1 | Originally blocked; resolved or gated in the Resolution Log |
| 6. Accessibility | F1 | Originally blocked; resolved or gated in the Resolution Log |
| 7. QiZheng migration irreversibility | G1, G2 | Originally blocked; resolved or gated in the Resolution Log |

P0-BLOCKER = must be resolved in the spec before code (changes public types or migration plan). P1 = must be resolved before public API is declared stable (P7). P2 = track.

## Reviewer Scope

In scope: the public contract surface (`ChartBoard`/`ChartLayer`/`ChartSector`/`ChartItem`/`BoardGeometry`/`BoardHitRegion`/`BoardTheme`/adapter contracts), the four-renderer model, Canvas interaction/hit-testing, theme & YAML ownership and precedence, the package↔module boundary, accessibility of Canvas output, and the reversibility of the QiZhengSiYu migration.

Out of scope: astronomy/排盘 correctness (sweph/tyme), the GeJu/ShenSha/HuaYao subsystems, and product visual taste. This review does not re-audit the unfinished-marker / OpenSpec-strict gates already recorded in `evidence/doc-validation.md`.

## Method & Evidence Base

Findings are grounded in live source, not only the proposal text:

- Painters: [star_body_ring_painter.dart](lib/painter/star_body_ring_painter.dart), [star_xiu_ring_painter.dart](lib/painter/star_xiu_ring_painter.dart), [painters.dart](lib/painter/painters.dart)
- Star model & collision state: [ui_star_model.dart](lib/presentation/models/ui_star_model.dart)
- Existing chart theme system: [qi_zheng_chart_style.dart](lib/painter/chart_style/qi_zheng_chart_style.dart), [token_loader.dart](lib/painter/chart_style/token_loader.dart), [theme_chart_style_resolver.dart](lib/painter/chart_style/theme_chart_style_resolver.dart), [chart_tokens.yaml](assets/theme/chart_tokens.yaml)
- Org theme package: `../theme` (pubspec name `theme`), `ChartThemeTokens` at `../theme/lib/src/tokens/chart_theme_tokens.dart`
- Shared enums package: `../xuan-metaphysics-core` (pubspec name `metaphysics_core`), imported as `package:metaphysics_core/enums.dart` by every painter and by `UIStarModel`
- Sibling consumer modules confirmed present: `../xuan-qimendunjia`, `../xuan-daliuren`, `../xuan-ziweidoushu`, `../xuan-taiyishenshu`
- In-flight theme migration evidence: recent commits `feat(yaml-token): P3 unified theme pipeline integration`, `refactor(yaml-token): P4 …`; painters already accept `QiZhengChartStyle? style`; goldens exist under `test/painter/chart_style/goldens/`
- Confirmed absence of Canvas hit-testing today: no `GestureDetector`/`hitTest`/`onTapDown` in `lib/painter/**` (interaction lives in widgets such as `StarBody`)

---

## Findings

### 1. Public API lock-in

**A1 — API is frozen on one real adapter plus synthetic demos. (P0-BLOCKER)**

`tasks.md` freezes the public core at P1 and declares it "stable enough for module adapters" at P7 (`tasks.md:194`), but the only real adapter built before that point is QiZhengSiYu (P6). The other four families appear only as `*-like` demo boards in the package example (`tasks.md:141-144`, `design.md:390-394`). Yet `proposal.md:7` justifies the whole abstraction on QiMen/DaLiuRen being *counterexamples* that "prevent the abstraction from becoming circular-only." All four counterexample modules already exist on disk (`../xuan-qimendunjia`, `../xuan-daliuren`, `../xuan-ziweidoushu`, `../xuan-taiyishenshu`) — so the API is being locked without ever touching the real data shapes it claims to generalize. A model gap found after a second module adopts `ChartBoard` becomes a cross-package breaking change.

Required resolution: before declaring the public API stable, build read-only `buildBoard()` + geometry-snapshot adapters against the **real** domain models of all five modules (not `*-like` demos), **or** ship the public types annotated as explicitly unstable/experimental and add a task gate forbidding a *second* production module migration until a multi-module conformance suite passes. Maps to `tasks.md` P0 stop-the-line "boundary flaw that would require changing public core data types."

**A2 — `ChartItem` cannot express a composite "star" as one addressable entity. (P0-BLOCKER)**

A single QiZheng star is a composite primitive: an inner guide dot at the *original* angle, a leader line, a semi-transparent holder dot at the *adjusted* angle, the star name, a "荫" annotation whose side flips on `star.angle < 180`, and a conditional "速" annotation gated by a business string match (`star_body_ring_painter.dart:81-106`, `:126-182`, `:164`). `design.md:99-113` lists flat item variants (`text`/`marker`/`line`/`connector`/…) with no grouping or composite identity. Hit-testing, selection, and semantics would therefore target sub-primitives (a dot, a line), not "the star." `BoardHitRegion` carries a single `itemId` (`design.md:247-256`), which cannot represent "this hit region belongs to logical star X composed of 6 draw ops."

Required resolution: add a composite/group item to the core model — one logical id owning N draw primitives, exactly one hit region, and one semantics node — before the P1 freeze.

**A3 — `PointLayer` must carry dual angles + leader-line linkage as data, not just an "optional adjusted angle." (P0-BLOCKER)**

`design.md:124` describes point layers with "`angle`, `radiusBand`, and optional collision-adjusted angle." The real renderer needs **both** angles simultaneously and the relationship between them: the guide dot is drawn at `originalAngle` on one radius and the holder at the adjusted `angle` on another, connected by a line (`star_body_ring_painter.dart:86-94`). "Optional adjusted angle" understates this to a single nudged position and drops the leader-line geometry that is the visually defining feature.

Required resolution: specify the point/angle item with `originalAngle`, `displayAngle`, two radius bands, and an explicit leader-line element, in the core model.

### 2. Four-renderer behavior divergence

**B1 — The real QiZheng board is a Canvas+Widget hybrid; the four renderers are modeled as mutually exclusive. (P0-BLOCKER)**

`design.md:160-210` presents `CircularCanvasBoard` and `CircularWidgetBoard` as alternatives. The production board is neither-or — it is both at once: Canvas paints rings/28-arcs/360-ticks/star dots/names, while interactivity, rotation, and accessibility live in **widgets layered over the Canvas** (`StarBody` Stateful badge, `Inner/OuterStarBodyRotatingWidget` `AnimatedRotation`, ShenSha `Transform`+`Text`; see migration plan §1.1 and the confirmed absence of any Canvas `GestureDetector`). `CircularCanvasBoard` alone loses the interactive/animated/semantic widgets; `CircularWidgetBoard` alone cannot feasibly render 360 ticks + 28 arcs as widgets.

Required resolution: define a hybrid composition contract — Widget items positioned over a Canvas board through shared `BoardGeometry` anchors (a documented overlay layer), so one board can mix Canvas-painted layers and Widget-hosted interactive items. Without it, QiZheng has no valid target renderer and the migration premise fails.

**B2 — "Same data → same hit ids across renderers" is contradicted by mirror-image per-ring behavior that is not modeled as data. (P0-BLOCKER)**

R4 (`design.md:410`) and the spec scenario (`spec.md:62-66`) require renderers to agree given identical board data. But the two existing star painters are mirror images driven by hidden logic, not data: `OuterLifeStarRangePainter` draws the inner guide dot at `innerRadius` (`:87`) while `InnerLifeStarRangePainter` uses `outerRadius` (`:305`), and the "荫" annotation side is inverted between them for the same `star.angle < 180` test (`:156-162` vs `:370-376`). The constellation-name label carries a fixed `-30°` counter-rotation (`star_xiu_ring_painter.dart:167`) and the star-name counter-rotation uses a `360 - 30 + angle` term (`star_body_ring_painter.dart:117-119`) tied to the chart's start offset.

Required resolution: enumerate every per-instance behavioral parameter (radius source, annotation-side rule, start-angle/`-30` offset, rotation mode) as explicit fields on the layer spec, and add them to the renderer conformance matrix (`tasks.md:96`). Otherwise a single layer spec cannot reproduce both rings, and "shared behavior" is unverifiable.

### 3. Canvas hit-test performance & correctness

**C1 — `path.contains()` on stroked arcs and 1px ticks is geometrically unsound. (P0-BLOCKER)**

`design.md:258` specifies hit-testing as `bounds.contains` then `path.contains(position)`. The 28 constellation bands are **stroked open arcs** (`Path()..addArc(...)`, stroke width `ringWidth - 10`; `star_xiu_ring_painter.dart:66-71`) and ticks are 1px lines (`:106-122`). `Path.contains` ignores stroke width and treats an open path as implicitly closed — so arc hit regions test the wrong region (a pie chord, not the band) and zero-area tick/line paths are never hit. The hit geometry must be authored independently of the draw path.

Required resolution: `BoardGeometry` must generate **filled, closed** hit geometry — annular wedge polygons for sectors/arcs, angular buckets (not line paths) for ticks — specified before P2 (`tasks.md:73`). Add a hit-test correctness test for a thick arc band and for a tick ring.

**C2 — No mandatory spatial index; tick/degree layers' interactivity is unspecified. (P0-BLOCKER)**

A single QiZheng board emits ~720 tick draws + 28 arcs + ~11 star composites + 12 sectors. R3 leaves spatial bucketing "optional" and states the stop-the-line as "hover frame time exceeds target" with no number (`design.md:409`). If degree/tick layers are interactive, every pointer-move does a linear scan over hundreds of regions with per-region path math.

Required resolution: (a) state that tick/degree-scale layers default to `hitTestMode: none`; (b) make an angular/spatial index **mandatory** (not optional) for any layer above a stated region count; (c) replace "exceeds target" with a concrete hover frame-time budget as a hard gate in `acceptance.md`.

### 4. Theme/YAML ownership

**D1 — A third, conflicting theme/YAML system. (P0-BLOCKER — highest impact)**

`design.md:276-325` invents a new `BoardTheme` + YAML schema (`themes.<name>.board/circular/rect/modules`) + a five-level precedence. The workspace already has two layers the proposal never mentions:

1. An org-wide unified theme pipeline in `package:theme`: `XuanThemeData.chartTokens` → `ChartThemeTokens` (defined at `../theme/lib/src/tokens/chart_theme_tokens.dart`), consumed via `XuanThemeScope` (`theme_chart_style_resolver.dart:1-53`). This package already owns chart theme tokens for the whole repo.
2. An existing YAML asset `assets/theme/chart_tokens.yaml` with a **different schema** — top-level `colors`/`typography`/`geometry`/`starPalette` (`token_loader.dart:96-187,236-254`) — versus the proposal's nested `themes.classic_ink.board…`.

Three overlapping owners (org `package:theme`, module `QiZhengChartStyle`, new `BoardTheme`) with no defined relationship. Theme token shape is part of the public API, so this must be resolved before freeze.

Required resolution: `design.md` must state how `metaphysics_chart_ui` theming relates to `package:theme`/`XuanThemeData`/`ChartThemeTokens` — consume it as the source, or own a disjoint, explicitly-scoped surface — and reconcile (or supersede) the existing `chart_tokens.yaml` schema. The five-level precedence must place `XuanThemeData` explicitly.

**D2 — The new `BoardSemanticColors` cannot express roles the real painters already require. (P0-BLOCKER)**

The proposal's `BoardSemanticColors` is `surface/divider/border/label/mutedLabel/hover/selected/focus/disabled` (`design.md:279`). The shipped `ChartSemanticColors` already needs `ringStroke`, `northLine`, `annotationYin`, `annotationSu`, `scaleTickAccent`, `sectorBorder` (`qi_zheng_chart_style.dart:3-30`, mirrored in `chart_tokens.yaml:18-30`). These have no home in the new token model. Either the package forces QiZheng to keep `QiZhengChartStyle` *alongside* `BoardTheme` (two theme systems inside one module), or these roles must be classified.

Required resolution: produce a mapping table assigning every existing `ChartSemanticColors`/typography/geometry role to a destination — core semantic token, renderer token, or module palette — before P1. `northLine`/`annotationYin`/`annotationSu` in particular blur the "semantic vs business" line the migration plan §0.4 fought to keep separate.

### 5. Module boundary leakage

**E1 — The boundary scan omits `package:metaphysics_core`, where the business enums actually live. (P0-BLOCKER)**

Both the design's "MUST NOT import" list (`design.md:422-429`) and the acceptance import scan (`acceptance.md:67-71`) enumerate only `package:(qizhengsiyu|qimendunjia|daliuren|ziwei|taiyishenshu)`. The business enums (`EnumStars`, `Enum28Constellations`, `EnumTwelveGong`, …) do not live in those packages — they live in `package:metaphysics_core` (`../xuan-metaphysics-core`), imported by every painter and by `UIStarModel` (`star_body_ring_painter.dart:3`, `star_xiu_ring_painter.dart:1`, `ui_star_model.dart:3`). A core file could `import 'package:metaphysics_core/enums.dart'` and the scan would **pass** while the "neutral" core silently gains business semantics. This is exactly the leak the package exists to prevent.

Required resolution: convert the boundary check from a deny-list of five names to an **allow-list** (core/layouts/renderers may import only `flutter/*`, `dart:ui`, `yaml`, and named pure utilities). Explicitly add `package:metaphysics_core`, `package:theme` business tokens, and `package:xuan_config` to the forbidden-in-core set. Adapters may still import `metaphysics_core` — restrict the scan to `lib/src/core`, `lib/src/layouts`, `lib/src/renderers`.

### 6. Accessibility

**F1 — Semantics-from-every-hit-region is screen-reader hostile, and current widget a11y would regress. (P0-BLOCKER)**

`design.md:43,170` says Canvas renderers "expose semantics nodes from geometry / hit regions." For a real board that yields hundreds of regions (360 ticks, 28 arcs) — a screen reader would enumerate 360 ticks. The model has no notion of semantic eligibility (separate from hit eligibility), grouping/merge, or traversal order. Worse, today's actual a11y comes from widgets (`StarBody`, `DestinyTwelveGongRingWidget`); a Canvas-only board drops them, so migration can *reduce* accessibility (the R7 risk), while the migration plan's Tier C deliberately keeps those as widgets.

Required resolution: define in the core model (a) `semanticsMode` independent from `hitTestMode`, (b) grouping/merge so one composite = one node, (c) traversal order, and (d) per-region labels. Strengthen `acceptance.md` from "accessibility smoke evidence" to a real screen-reader traversal assertion on the QiZheng-like board (node count bounded, every interactive sector labeled, ticks excluded).

### 7. QiZhengSiYu migration irreversibility

**G1 — Double migration on the same painter files; the new theme system orphans the just-built one. (P0-BLOCKER)**

The module is mid-flight on the 2026-06-17 token migration: painters were just refactored to accept `QiZhengChartStyle? style` (`star_body_ring_painter.dart:23,37`), and `ChartThemeTokens`/resolvers/palette/goldens already exist (recent `yaml-token` P2–P4 commits; `test/painter/chart_style/goldens/`). This change proposes to migrate the *same* painters again into neutral package types and replace that theme system. Two overlapping migrations on the same files is a merge/ordering hazard, and the new `BoardTheme` would strand the completed `ChartThemeTokens` integration.

Required resolution: sequence explicitly in `tasks.md` — land/freeze the token migration first (or fold it into this change), and state which theme system survives end-state — so the two migrations do not collide and no completed work is orphaned.

**G2 — Collision-avoidance state is mutable; the adapter contract is "pure / must not mutate." (P0-BLOCKER)**

`design.md:337-343` requires adapters to be pure and to "not mutate `ChartBoard`." But the data the QiZheng adapter must read is a mutable, stateful graph: `UIStarModel.adjustedAngle/adjustedEdges/inRangeStar/adjustCount/previousAdjustedDirection`, mutated in place by the collision solver, with `UIConstellationModel` grouping (`ui_star_model.dart:27-31,212-241,268-308,347-372`). `angle` itself is `adjustedAngle ?? originalAngle` (`:31`). Non-Goals correctly keep the *algorithm* out of the package, but the contract does not say the adapter must consume a **resolved immutable snapshot**, nor define that snapshot's shape — risking the adapter triggering or depending on layout-solver mutation.

Required resolution: specify that the adapter consumes a post-collision **immutable** snapshot (resolved display angles + original angles + leader-line pairs + group membership), define that snapshot type, and add a parity fixture asserting both `originalAngle` and resolved `angle` survive the adapter byte-identical (the R9 calculation stop-the-line, `design.md:415`).

### 8. Cross-cutting (sequencing & duplication) — P1

- The package re-creates golden infrastructure (`board_golden_harness.dart`) that already exists in the module (`test/painter/chart_style/chart_golden_harness_test.dart`); decide reuse vs duplication before P3.
- `proposal.md` "Current Evidence" cites `QiZhengStarPalette` still depending on `EnumStars` as proof palettes belong in an adapter — consistent and correct, but the same reasoning (E1) must be applied to the scan, which it currently is not.

---

## What the proposal already gets right

To keep this review balanced — these are genuine strengths and should be preserved:

- Explicit, well-chosen Non-Goals (`proposal.md:44-52`): no algorithm movement, no forced-Canvas, no forced-12-sectors, business palettes kept out of semantic tokens.
- A real risk register with stop-the-line conditions (`design.md:403-419`); this review sharpens several of those from "soft" to "hard."
- Instance-scoped interaction controller with `moduleId`+`instanceId` (R6) — the right call for multi-board leakage.
- "Golden parity before replacing painters," migrate one layer at a time, keep old painters (`design.md:397-401`, `tasks.md:163-169`) — the correct irreversibility guard.
- Separate `RectPerimeterLayoutEngine` vs `RectGridLayoutEngine` (R10) — correct; do not collapse them.

## Accepted Changes

Edits to `design.md`/`tasks.md`/`spec.md`/`acceptance.md` I endorse and that should be made before code:

1. Add a composite/group item type and dual-angle point item to the core model (A2, A3).
2. Add a hybrid Canvas-base + Widget-overlay composition contract keyed on shared geometry (B1).
3. Promote per-ring behavioral parameters (radius source, annotation side, start offset, rotation mode) to data on the layer spec; add to conformance tests (B2).
4. Author hit geometry as filled/closed regions + angular buckets, independent of draw paths; mandate a spatial index and a numeric hover-frame budget (C1, C2).
5. Reconcile theming with `package:theme`/`ChartThemeTokens` and the existing `chart_tokens.yaml`; produce a full role-mapping table (D1, D2).
6. Make the import boundary an allow-list and add `metaphysics_core`/`theme`/`xuan_config` to forbidden-in-core (E1).
7. Add `semanticsMode`, grouping, traversal order, labels; upgrade a11y acceptance to a real traversal assertion (F1).
8. Sequence vs the in-flight token migration; define the surviving theme end-state (G1).
9. Define the resolved immutable star snapshot the adapter consumes; add original+adjusted angle parity fixture (G2).
10. Build real read-only adapters for all five modules (or mark API experimental + gate a second migration) before P7 stability (A1).

## Rejected Changes

Considered and explicitly **not** recommended, to avoid over-engineering:

- Do not merge the two rectangular engines into one configurable engine — the perimeter/grid split is correct (R10).
- Do not pull `metaphysics_core` enums into core "because they are just enums" — that is precisely the leak (E1); keep enums adapter-side.
- Do not mandate a generic plugin/registry for arbitrary item types now; a fixed composite item plus a Widget-overlay escape hatch covers the known five modules without speculative generality.
- Do not block on dark-mode parity for this change — the existing system already defers business dark colors to domain owners; carry that as a known residual, not a P0.

## Stop-The-Line Items

Implementation MUST NOT start until each is resolved in the spec (all change public types or the migration plan, matching the `tasks.md` P0 stop-the-line "boundary flaw that would require changing public core data types"):

1. A2 — composite item identity in core model.
2. A3 — dual-angle + leader-line point item.
3. B1 — hybrid Canvas+Widget overlay composition.
4. B2 — per-ring behavior promoted to data.
5. C1 — sound (filled/closed) hit geometry, not draw-path `contains`.
6. C2 — mandatory spatial index + numeric hover budget; ticks non-interactive by default.
7. D1 — theme ownership reconciled with `package:theme`/`ChartThemeTokens` and `chart_tokens.yaml`.
8. D2 — every existing chart-style role mapped to a destination token.
9. E1 — allow-list boundary scan including `metaphysics_core`.
10. F1 — semantic eligibility/grouping/traversal in the model.
11. G1 — sequencing vs the in-flight token migration; surviving theme end-state.
12. G2 — resolved immutable star snapshot + angle parity fixture.

## Approval

**Approved to continue P0 baseline work and implementation planning only.** This is not approval to start P1 package implementation or replace production boards.

The original conditional GO criteria have been addressed at the documentation level:

- All twelve Stop-The-Line items above are addressed in the spec text, with the public core data types updated for A2/A3/B1/B2/C1/F1/G2 and the boundary scan updated for E1.
- D1/D2 contain an explicit ownership decision against `package:theme`/`ChartThemeTokens`, not a new parallel theme.
- A1 is satisfied either by real five-module read-only adapters before P7, or by an explicit experimental-API label plus a task gate forbidding a second production migration until a multi-module conformance suite passes.

The P0 exit criterion "external risk review finds no boundary flaw requiring public-core-type changes" is met for documentation. Runtime evidence remains mandatory at the phase gates named in the Resolution Log.

## Resolution Log

Update 2026-06-18: the spec package was revised to address all twelve stop-the-line items. The findings above are preserved as the original review record; this log maps each item to where it is now resolved in the spec. Items A1, C2, F1, G2 are resolved at the **specification** level (the gate is now written into tasks/acceptance); their **runtime evidence** is produced during implementation, not by this documentation change.

| Item | Resolved in |
|------|-------------|
| A1 — API frozen on one adapter | `design.md` R13; `tasks.md` P0.11, P0 stop-the-line, P7 exit criteria (real five-module adapters or experimental API + second-migration gate) |
| A2 — composite item identity | `design.md` "ItemGroup"; `spec.md` "Composite marks are single addressable entities"; `tasks.md` P1.3 |
| A3 — dual-angle point + leader line | `design.md` "AngularPoint"; `spec.md` circular scenario "original and display angle"; `tasks.md` P2.4 |
| B1 — hybrid Canvas+Widget composition | `design.md` "Hybrid Canvas+Widget Composition"; `spec.md` "Package supports hybrid…"; `tasks.md` P3.9 |
| B2 — per-ring behavior as data | `design.md` "Layer Behavior Parameters" + R4; `spec.md` "Mirror-image rings differ only by behavior data"; `tasks.md` P3.5 |
| C1 — sound filled/closed hit geometry | `design.md` "Canvas Hit Testing"; `spec.md` "Arc and tick hit regions use filled closed geometry"; `tasks.md` P2.7, P2.9; `acceptance.md` geometry tests |
| C2 — spatial index + numeric budget + ticks none | `design.md` "Canvas Hit Testing" (under 2 ms) + R3; `spec.md` "Dense board hit-test stays within budget"; `tasks.md` P2.10; `acceptance.md` gStack budget evidence |
| D1 — theme ownership vs `package:theme` | `design.md` "Theme Ownership" + precedence + R16; `spec.md` "Host theme tokens supply base tokens…"; `tasks.md` P4.1/P4.7; `acceptance.md` theme tests |
| D2 — role mapping table | `design.md` "Token Group Ownership Map"; `tasks.md` P4.7 |
| E1 — allow-list boundary incl `metaphysics_core` | `design.md` "Boundary Rules" + R17; `spec.md` "Package boundary…" allow-list scenarios; `tasks.md` P1.7, P7.2; `acceptance.md` import scan |
| F1 — bounded/grouped semantics | `design.md` "Accessibility" + R7; `spec.md` "Canvas accessibility is bounded and grouped"; `tasks.md` P3.7; `acceptance.md` accessibility tests |
| G1 — sequencing vs token migration | `design.md` M0 + R18; `tasks.md` P0.10 |
| G2 — resolved immutable snapshot + parity | `design.md` Adapter Contracts; `tasks.md` P6.2, P6.7 |

Revised verdict: the original documentation findings are represented in the
design, but P0 execution remains a hard gate. P1 starts only after P0.1-P0.14
have evidence-backed completion and `P0-go-no-go.md` records GO. Runtime items
remain mandatory before API stabilization and user-facing replacement.

---

## Supplemental Review: Coordinate Ownership And Sparse Coverage

- Review date: 2026-06-20
- Reviewers: OpenSpec architecture role, independent gStack-style adversarial
  reviewer, and gStack plan engineering review role
- Trigger: move `365.25 -> 360` normalization to the QiZhengSiYu consuming
  adapter and add sparse partial-arc coverage for Zhu-Luo-San-Xian
- Initial verdict: BLOCKED pending deterministic contracts

### Supplemental Findings And Resolution

| Area | Resolution |
| --- | --- |
| Projection ownership | Package accepts integer display millidegrees only; QiZhengSiYu owns versioned fixed-point cumulative-boundary mapping |
| Numeric reproducibility | Three-decimal source fixed point, integer rational arithmetic, round-half-up, source validation before full-coverage endpoint pinning |
| Sparse coverage | Explicit full/sparse modes, half-open canonical ranges, explicit split wrap-around, preserved radial band and transparent gaps |
| Overlap and ordering | Same-layer overlap invalid; intentional overlap uses overlays with deterministic paint/hit/disabled policies |
| Fragmented identity | Multiple geometry/hit fragments may resolve to one logical target and at most one semantics node |
| Borders and caps | Shared seams have one owner; round-cap protrusion is paint-only and cannot create blank-angle interaction |
| Semantics merge | One owner supplies primary semantics; merges only append ordered descriptions and unique non-activate actions |
| Validation severity | Invalid radial allocation/duplicate IDs/theme schema are board-fatal; valid-band coverage defects are ring-local |
| Theme contradiction | Optional tokens fall back; strict production requires all `invalidRing*` roles with one ownership destination |
| Performance evidence | Seeded warm-up/measured protocol, p95 target, scaling matrix, and recorded environment replace an unrepeatable “under 2 ms” claim |
| Rollback | Normative pre/post-activation failure scenarios atomically retain/restore Legacy and preserve instance state |
| False completion | Closed schema-v1 17-ID manifest catalog including `p0-go-no-go`, exact commit and SHA-256 verifier, CI negative fixture |

The gStack role's final reported contradiction was an example manifest ID
(`package-tests`) not present in the closed catalog; it was corrected to
`package-unit`. A requested final zero-blocker rerun was interrupted by the
external role's usage limit. No CLEAR response is claimed. Final local gates
are OpenSpec strict validation, diff/placeholder/contradiction scans, numeric
fixture checks, and exact catalog/example consistency.

## Adjudication Of External `f41ba82` Readiness Report

The external report's “ENGINEERING IMPLEMENTATION READY” and “machine-verified”
phrasing is rejected. Commit `f41ba82` contains documentation only; the verifier,
manifest, and runtime artifacts are future implementation work. OpenSpec strict
validation proves schema consistency, not runtime evidence.

The report also treated G-5 and G-6 as closed because they existed in the
Superpowers geometry spec, while the OpenSpec public contract and implementation
plan did not require `BoardCenterSpec` or independent track/body transforms.
Those contracts and tests are now propagated across design/spec/tasks/
acceptance/plan. Optional zero-width rings now have one unambiguous rule:
preserved source identity/order, skipped resolved output, and no radial or
interactive allocation.

The subsequent gStack Eng Review was also based on stale commit `f41ba82`. Its
remaining findings were adjudicated as follows: duplicate plan path removed;
P6 projection math and rejection/sparse tests split; `daXian106` documented as
a configuration ID producing 104 slots; literal color bypass prohibited by API
and theme tests; stale-commit verifier negatives added; benchmark target
registration made versioned and exact-match-only; and 64 made a non-overridable
maximum indexing threshold while permitting earlier indexing. These fixes did
not change the P0 NO-GO decision at that review baseline. The later P0 closure
is recorded separately in `P0-go-no-go.md`; it does not retroactively alter
this review's findings.
