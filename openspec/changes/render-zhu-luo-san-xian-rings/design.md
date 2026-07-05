## Context

Zhu Luo San Xian is a chronological annual path, not a complete duration ring. It has three semantic stages, sparse palace occupancy, multi-year holds, A-style non-adjacent jumps, B-style bridges, repeated palace visits, and shared transition ages.

The legacy DaXian painter allocates a full 360-degree ring and carries fractional years across palace boundaries. That model must not be reused. The existing `metaphysics_chart_ui` dependency can render arc cells, soft dividers, labels, and hit regions, but its circular `OverlayLayer` is currently a no-op.

## Goals / Non-Goals

**Goals:**

- Convert annual results into immutable visit segments, annual cells, stage tracks, and transition edges.
- Render stage groups from inside to outside: initial, middle, final.
- Insert repeat-visit tracks directly outside their owning stage's first track.
- Leave unvisited palace areas transparent and non-interactive.
- Default to one age-range label while retaining all-cell labels as a user option.
- Reuse chart-ui arc geometry, theming, hit testing, and Canvas rendering.
- Keep jump connectors local to QiZhengSiYu for the first implementation.

**Non-Goals:**

- Change Zhu Luo calculation or historical interpretation.
- Draw several algorithms simultaneously.
- Persist display preferences.
- Add a shared chart-ui connector type in this change.
- Refactor unrelated rings.

## Decisions

### 1. Pure projection before rendering

```text
List<ZhuLuoYearResult>
  -> ZhuLuoRingPlan
     -> stage groups
     -> visit tracks
     -> annual cells
     -> transition edges
```

A new visit starts when stage, ruler, palace, phase, bridge state, or age continuity changes. Rendering code receives only the immutable plan and never groups raw records itself.

### 2. Dynamic physical tracks inside three semantic stage groups

Radial order is deterministic:

```text
initial visit 1
initial visit 2 ... N
middle visit 1
middle visit 2 ... N
final visit 1
final visit 2 ... N
```

Visits are numbered independently per `(stage, palace)`. A stage allocates the maximum visit count required by any palace. Repeat tracks paint only palaces that actually have that ordinal.

### 3. Each contiguous visit owns one 30-degree palace sector

For a visit containing `N` annual records:

```text
cellSweep = 30 degrees / N
cellStart = palaceStart + cellIndex * cellSweep
```

The final cell ends exactly at the palace boundary. A one-year visit occupies the full 30 degrees. Angular width expresses subdivision within that visit, not the stage's global elapsed time.

### 4. Label mode does not alter geometry

`ZhuLuoAgeLabelMode` supports:

- `rangeOnly`: one inclusive range on the segment's central cell; default.
- `allCells`: one age on every cell when it fits.
- `auto`: range labels normally, all-cell labels after a zoom or sweep threshold.

Suppressed labels do not remove annual cells, hit regions, or semantics.

### 5. Arc cells reuse chart-ui; connectors remain QiZheng-owned

Each physical visit track maps to one `ArcLayer`; each annual cell maps to one `ArcSegment`. Stable ID:

```text
zhu-luo:<algorithm>:<stage>:visit-<ordinal>:<palace>:age-<age>
```

A foreground `ZhuLuoTransitionPainter` consumes transition edges and paints inverse jumps and inter-stage markers only. It does not paint cells, labels, or hit regions.

A generic chart-ui connector layer is a possible later capability, but it requires its own cross-package semantics, hit testing, and Canvas/Widget parity work.

### 6. Movement semantics remain explicit

- `hold`: annual cells subdivide one palace sector.
- `inverse`: a jump connector links non-adjacent source and destination; skipped palaces stay blank.
- `direct`: adjacent palace visits use normal sequence styling.
- `bridge`: real annual cells in real palaces, using a bridge style role.
- `transition`: one annual cell plus an inter-stage marker; never duplicate the age.

### 7. Theme-driven styling

Required semantic roles:

- `zhuLuoInitial`
- `zhuLuoMiddle`
- `zhuLuoFinal`
- `zhuLuoBridge`
- `zhuLuoCellDivider`
- `zhuLuoJumpConnector`
- `zhuLuoTransitionMarker`

The first implementation may add these roles only inside the QiZheng project theme/style boundary:

- `lib/painter/chart_style/qi_zheng_chart_style.dart`
- `lib/painter/chart_style/theme_chart_style_resolver.dart`
- Existing QiZheng-local theme token files discovered by the current chart theme convention

No black borders or raw ARGB values are allowed in Zhu Luo presentation files. Repeat tracks retain their stage hue with controlled opacity or luminance, but color must not be the only channel: repeat tracks, bridges, jumps, and transition markers need non-color affordances such as dashed strokes, dotted edge ticks, hatching, boundary ticks, or marker shape differences. Stage-group gaps are larger than repeat-track gaps.

Rendering tests must prove semantic roles are actually consumed. At least one focused test or golden pair must differ only by stage/bridge semantic role and assert that the resolved `ArcSegment`/paint output changes.

### 8. Annual-cell interaction

Every cell remains independently hit-testable. A stable-ID lookup exposes age, stage, ruler, palace, phase, algorithm, bridge state, and transition state. Algorithm radio selection only replaces the annual input; the renderer never branches on A, B, or a custom algorithm ID.

Small angular cells must not require pixel-perfect touch. The UI must provide a forgiving selection path such as hit slop, visit-first selection with year disambiguation, or zoom-on-touch. A linear annual-path fallback/list must expose the same sequence as the ring for accessibility and debugging: age -> stage -> palace -> phase -> bridge/jump/transition.

## Feasibility Analysis

**Available now through chart-ui public APIs:**

- Dynamic radial tracks through per-layer radii.
- Sparse palace occupancy through arbitrary `ArcSegment` lists.
- Annual cells, soft seams, labels, and per-arc hit regions.
- Stage and bridge colors through semantic palette keys.

**QiZheng-specific work required:**

- Annual-result projection and visit numbering.
- Dynamic radial allocation in board composition.
- Stable interaction lookup and label-mode wiring.
- Jump and stage-transition drawing because circular `OverlayLayer` is a no-op.

**Verdict:** GO for a QiZheng-owned implementation using chart-ui `ArcLayer` cells plus a QiZheng foreground connector painter. A shared connector abstraction is deferred to a separate OpenSpec change.

## Risks / Trade-offs

- Dynamic tracks may exceed radial budget -> calculate required width first; enforce minimum track width and fail visibly rather than dropping visits.
- All-cell labels may collide -> text-fit suppression; interaction and semantics stay available.
- Connector and arc geometry may drift -> derive both from one immutable plan and shared angle/radius transform.
- Transition ages may duplicate -> project from the calculator's deduplicated annual list and represent transition as metadata/edge.
- Existing board composition may lack a host seam -> add a narrow additive seam; do not route through legacy DaXian painter APIs.
- The shared package has unrelated dirty work -> do not modify it in this change.
- The projector may accidentally smuggle calculation rules into presentation -> preserve calculator annual record count one-to-one when generating cells; do not re-deduplicate, fill missing ages, or call Zhu Luo rule helpers.
- Mobile and accessibility may fail before production enablement -> require forgiving touch, non-color encodings, dark/light theme evidence, and a linear annual-path fallback before default enablement.
- Connector clutter may obscure cells -> connector routing remains a production-quality risk; first implementation must keep connectors lower emphasis than cells and verify they do not cover annual labels or hit regions.

## Migration Plan

1. Add projection models and pure tests.
2. Add ArcLayer conversion and geometry snapshots without production wiring.
3. Add connector painter and standalone golden fixtures.
4. Add algorithm and label controls on a diagnostic surface.
5. Integrate behind a default-off feature flag.
6. Run focused tests, analyzer, goldens, and gStack visual QA.
7. Delete no legacy behavior.

Rollback: disable the feature flag. All new projection and renderer files are additive.

## Boundary Scans

```bash
rg -n "calculateZhuLuoSanXian|rulerDuration|rulerNumber" lib/presentation
```

Expected: no calculation-rule implementation in presentation files.

```bash
rg -n "DaXianRingPainter|DaXianCalculateHelper" lib/presentation/widgets/rings/zhu_luo* lib/presentation/chart_adapters/zhu_luo* 2>/dev/null
```

Expected: no legacy DaXian painter/helper reuse.

```bash
rg -n "Colors\.black|Color\(0x" lib/presentation/widgets/rings/zhu_luo* lib/presentation/chart_adapters/zhu_luo* 2>/dev/null
```

Expected: no hard-coded black or ARGB styling.

```bash
git diff --name-only -- ../metaphysics-chart-ui
```

Expected: no shared-package changes caused by this implementation.

```bash
rg -n "skip:|skip\(|\.only|, skip|solo" test/presentation
```

Expected: no new skipped, focused, or solo presentation tests caused by this implementation.

## Behavior Preservation And Rollback Gates

- Calculator fixtures remain unchanged at the annual-result level.
- Algorithm selection changes input only, not renderer behavior.
- DaXian, Hundred-Six, FeiXian, XiaoXian, and existing board goldens remain unchanged.
- Production wiring stays default-off until geometry, golden, interaction, and gStack evidence pass.
- Insufficient radial budget must not silently drop repeat visits.
- Production wiring must not be attempted until projection, adapter, painter, widget, style-consumption, accessibility, and no-skip gates have evidence.

## Open Questions

No blocking product questions remain. Exact token names and production host insertion point may follow existing theme and board-composition conventions without changing specified behavior.

Deferred production-quality decisions:

- Whether dense repeat tracks collapse into badges, zoom/pan, or a dedicated detail mode when radial budget is insufficient.
- Whether jump connectors route as straight chords, track-hugging arcs, or an adaptive mixed strategy.
- Whether the linear annual-path fallback ships in the same screen or as a linked/details surface.
