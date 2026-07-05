# Design: Metaphysics Chart UI Package

## Architecture Overview

The package separates chart-board UI into five layers:

```text
Module domain model
  -> Module adapter
  -> Neutral ChartBoard data
  -> Layout engine resolves BoardGeometry
  -> Renderer paints/builds UI
  -> Interaction controller updates board state
```

The neutral model is intentionally visual and structural. It contains no astrology-specific calculation rules.

```dart
ChartBoard(
  moduleId: 'qizhengsiyu',
  instanceId: 'pan-2026-06-19T10:00',
  themeId: 'classic_ink',
  layout: BoardLayoutSpec.circular(sizePolicy: ...),
  layers: [...],
  semantics: BoardSemantics(label: '七政四余命盘'),
)
```

The consuming module owns the current pan instance. The package owns rendering, layout geometry, style resolution, interaction state, and test harnesses.

## Existing Problems And Required Solutions

| Problem | Evidence | Risk If Ignored | Required Solution |
|---------|----------|-----------------|-------------------|
| Circular code assumes module models | QiZhengSiYu painters use `UIStarModel`, `EnumStars`, `EnumTwelveGong`, `ZhouTianModel` | New package depends on QiZhengSiYu internals; TaiYi/ZiWei/DaLiuRen cannot reuse cleanly | Define neutral `ChartSector`, `ChartItem`, `AngularPoint`, `BoardPaletteKey`; adapters convert module models |
| Not all rings are equal sectors | QiZhengSiYu has 360 ticks and 28 non-uniform arcs | A 12-sector-only API cannot represent current chart | Layer specs must include equal sectors, custom arcs, ticks, and angle points |
| Widget grids and Canvas boards need different renderers | QiMen uses GridView/Row/Column; QiZheng uses Canvas | A Canvas-only package loses accessibility and complex content ergonomics | Provide four renderers sharing data and geometry |
| Canvas interaction is not centralized | Painter has no native pointer handling | Hover/click behavior is duplicated and hard to test | Wrap Canvas renderers in `MouseRegion`/`GestureDetector`; hit-test against `BoardHitRegion` |
| Theme ownership is unclear | Existing QiZheng style/palette split is local | Module palette and semantic UI colors may be mixed | Separate `BoardTheme`, renderer tokens, and module palettes with explicit precedence |
| Instance ownership is unclear | Multiple modules can show many boards | Theme or static singleton could leak across instances | Every `ChartBoard` has `moduleId`, `instanceId`, and optional instance overrides |
| Migration could silently change visuals | TextPainter measurement, radii, angle math, font fallback | Chart positions drift without compile errors | Golden tests and geometry snapshots before migration |
| Rect perimeter is not the same as matrix grid | ZiWei/DaLiuRen perimeter 12 cells vs QiMen 3x3 | One rectangular abstraction becomes awkward | Separate `RectGridLayoutEngine` and `RectPerimeterLayoutEngine` |
| Accessibility may regress in Canvas | Canvas text/items are not individually semantic by default | Screen readers and keyboard users lose board access | Render semantic nodes from `BoardHitRegion`; Widget renderers use normal focusable widgets |

## Core Data Model

### ChartBoard

`ChartBoard` is immutable and represents one rendered board instance.

Required fields:

- `moduleId`: stable module owner, e.g. `qizhengsiyu`, `taiyishenshu`, `ziwei`, `daliuren`, `qimen`.
- `instanceId`: stable current pan/board instance id.
- `themeId`: resolved theme name.
- `layout`: top-level board layout family and sizing policy.
- `center`: optional `BoardCenterSpec` for circular boards.
- `layers`: ordered list of visual layers.
- `interaction`: optional per-board interaction config.
- `semantics`: board-level accessibility metadata.

No field may contain a module domain object. Use `metadata` maps only for adapter-owned opaque ids needed by callbacks.

Validation distinguishes board-fatal from ring-local failures. Duplicate stable
IDs, negative/non-finite radial allocation, required zero-width rings, and unresolved required theme schema
are board-fatal because reliable geometry cannot be allocated. Partition or
coverage defects are ring-local only when radial allocation is valid: the band
remains reserved and becomes the invalid-ring annulus, neighboring rings remain
interactive, and invalid content emits no hit regions or semantics.

### BoardCenterSpec

Circular center content is an independent `BoardCenterSpec`, never a ring. It
reserves `radius`; the first ordered ring starts at that boundary. It may host
Canvas content, a Widget child, or both through hybrid composition, with its own
clip, fit, semantics, interaction, background/border, and declared paint
outsets. A missing center is valid and reserves radius zero. Center content does
not participate in angular partition or ring-coverage validation.

### ChartLayer

Layer variants:

- `SectorLayer`: equal or custom sector fills/borders.
- `TickLayer`: tick marks, major/minor ticks, labels, degree scales.
- `ArcLayer`: non-uniform arcs such as 28 constellations.
- `PointLayer`: angle/position-based stars, marks, labels, or icons.
- `CellLayer`: rectangular grid/perimeter cells.
- `OverlayLayer`: hover, selected, focus, custom annotations.

Each layer has:

- `id`
- `zIndex`
- `visible`
- `styleRole`
- `hitTestMode`: `none`, `layer`, `sector`, `item`
- `semanticsMode`: `none`, `group`, `perItem` — chosen independently of `hitTestMode` (see Accessibility)
- `items` or geometry source
- `behavior`: explicit per-instance rendering parameters (see Layer Behavior Parameters)

Geometry and layer contracts reference semantic `styleRole`/token keys only.
They do not accept Flutter `Color`, ARGB integers, or hex color strings. Concrete
colors exist only inside `ResolvedBoardTheme` after theme resolution. Opaque
metadata may contain diagnostic strings, but geometry/renderers must never
interpret metadata as styling. Module palettes enter through the theme resolver,
not through ring or item geometry.

Circular layers additionally declare `coverage`: `FullCircleCoverage` or
`SparseArcCoverage`. `FullCircleCoverage` must resolve exactly to integer
display millidegrees `0..360000`. `SparseArcCoverage` contains one or more
half-open ranges `[startMilliDegree, endMilliDegree)` and deliberately leaves
the remaining angles blank while preserving the layer's complete radial band.

An explicitly optional ring may have width zero. It remains in source-plan
ordering and identity but resolves as `SkippedRingGeometry(reason: zeroWidth)`;
it allocates no radius and emits no paint, hit region, or semantics. A required
ring with zero width is invalid. Enabling an optional ring with positive width
restores it at the same source position.

The neutral contracts are:

- `CircularCoverage.fullCircle(partition)`
- `CircularCoverage.sparse(List<SparseArcRange>)`
- `SparseArcRange`: stable `id`, integer `startMilliDegree`, integer
  `endMilliDegree`, range-local `partition`, `startCap`, `endCap`, and logical
  target ID
- `OverlayLayer`: referenced ring/band ID, unique ID, `zIndex`, `hitPriority`,
  disabled-hit policy (`block` or `passThrough`), and semantics ownership
  (`owner(targetId, semanticsOrder)`, `merge(targetId)`, or `none`)
- `RingOverlaySpec`: referenced ring ID, stable ID, role (`track`, `body`, or
  custom), independent `rotationMilliDegrees`, direction, zero-angle offset,
  radial anchor, `zIndex`, hit/semantics policy, and declared paint outset

Exactly one semantics owner may exist per logical target. `merge(targetId)`
creates no node. The owner exclusively supplies role, primary label,
selected/disabled state, and activate action. A merge may append only a
description fragment and uniquely keyed non-activate custom actions;
description fragments concatenate in declaration order. Missing/duplicate
owners, duplicate action IDs, or merge attempts to override owner fields are
invalid. Owner traversal is ordered by `semanticsOrder`, then declaration order,
then stable target ID.

Track and body are overlays on one resolved `ContinuousPartition` ring, not
separate radial bands. Their transforms are resolved independently; neither may
inherit the other's rotation. Hit testing applies each overlay's inverse
transform before lookup. This preserves Legacy `trackRotationAngle` and
`bodyRotationAngle` while keeping shared ring radii stable.

### Layer Behavior Parameters

The two existing QiZhengSiYu star rings (inner-life and outer-life) are mirror images of each other: they differ in which radius the guide dot anchors to and on which side the `荫`/`速` annotations sit for the same `angle < 180` test. These differences MUST be expressed as data on the layer, not as renderer-internal branches, so one layer spec can reproduce either ring and so Canvas and Widget renderers stay in lockstep.

`behavior` carries at least:

- `radiusAnchor`: which band the inner guide dot uses (`inner` vs `outer`).
- `annotationSide`: rule mapping `displayAngle` to label side (`leftWhenUnder180` vs `rightWhenUnder180`).
- `startAngleOffset`: chart zero offset (the existing `-30` term tied to the 子 start position).
- `direction`: `clockwise` / `counterClockwise`.
- `textOrientation`: `horizontal` / `radial` / `tangential` / `counterRotated`.

Two layers that differ only in these parameters MUST produce identical hit-region ids for the same logical sectors/items; only geometry anchors differ. Renderer conformance tests assert this.

### ChartSector

Neutral sector/cell object:

- `id`
- `index`
- `label`
- `startAngle` / `sweepAngle` for circular custom sectors
- `row` / `column` / `perimeterSlot` for rectangular layouts
- `items`
- `paletteKey`
- `semanticsLabel`
- `metadata`

Equal-sector layouts may derive angles from `index` and `count`. Custom arc layouts must provide explicit start/sweep values.

All public circular geometry is already normalized display geometry. Package
types do not expose `sourceDomainSpan` or a domain projection callback. Sparse
ranges require `0 <= start < end <= 360000`; same-layer ranges may be adjacent
but may not overlap. Wrap-around is represented explicitly as two ranges.
Intentional overlap uses distinct `OverlayLayer` instances with deterministic
`zIndex`, hit-test priority, and semantics ownership.

Coverage is authored and validated in canonical clockwise display coordinates
before direction, start-angle offset, or overlay rotation. `360000` is legal
only as an exclusive interval end and aliases `0` for point lookup. At a shared
half-open boundary the range starting there owns the boundary and seam.

### ChartItem

Item variants:

- `text`
- `richText`
- `badge`
- `icon`
- `image`
- `customWidgetRef`
- `marker`
- `line`
- `connector`
- `angularPoint` (see `AngularPoint`)
- `group` (see `ItemGroup`)

Canvas renderers support built-in item variants only. Widget renderers may use `customWidgetBuilder` for complex content. The package must not accept arbitrary module domain widgets inside Canvas renderers.

### ItemGroup (composite identity)

Some board marks are visually a cluster of primitives but logically one addressable thing. A QiZhengSiYu star is one logical entity drawn as: an inner guide dot, a leader line, an outer holder dot, the star name, a side annotation (`荫`), and a conditional second annotation (`速`). Hit-testing, selection, and accessibility must address the star, not its six primitives.

`ItemGroup` provides this:

- `id`: stable logical id (e.g. `star:Sun`).
- `children`: the primitive items that render the group.
- `hitItemId`: which child or logical target owns contiguous or fragmented hit regions.
- `semanticsLabel`: the one label announced for the whole group.

`BoardGeometry` normally emits one `BoardHitRegion` and at most one semantics
node per contiguous `ItemGroup`. One logical target may own multiple geometry
and hit-region fragments, including split wrap-around ranges; every fragment
resolves to the same logical target ID and at most one semantics node. Renderers
MUST resolve a child or fragment hit/selection up to its owning logical id.

### AngularPoint (dual-angle item)

Angle-positioned items such as stars carry two angles and two radius bands, not one nudged angle:

- `originalAngle`: the true (pre-collision) angle; anchors the inner guide dot.
- `displayAngle`: the resolved (post-collision) angle; anchors the outer holder dot and label.
- `innerRadiusBand` / `outerRadiusBand`: the two bands the leader line spans.
- `leader`: whether to draw the guide dot → holder leader line connecting the two angles.

The package consumes both angles as data; it never computes collision adjustment (see Non-Goals and Module Adapter Contracts → resolved snapshot).

## Layout Engines

### CircularRingLayoutEngine

Supports:

- 12 sectors for QiZhengSiYu/ZiWei/DaLiuRen.
- 16 sectors for TaiYiShenShu.
- 360 tick marks for degree scales.
- 28 non-uniform arcs for QiZhengSiYu constellations.
- sparse partial-arc ranges; overlapping Zhu-Luo-San-Xian examples `0..60`
  and `58..72` are separate overlays sharing one radial band.
- point layers with `AngularPoint` dual-angle geometry, radius bands, and leader-line support.
- clockwise and anti-clockwise orientation.
- start-angle offset.
- inner/outer radius per layer.
- text orientation modes:
  - horizontal
  - radial
  - tangential
  - counter-rotated

The engine returns `BoardGeometry` containing paths, arcs, label anchors, item anchors, and hit regions.

For sparse coverage, the engine creates paths, labels, hit regions, and
semantics only inside painted ranges. It paints inner/outer arc borders plus
range start/end radial borders with configured `butt` or `round` caps. It does
not merge adjacent ranges, infer wrap-around, expand sparse input to 360
degrees, or allocate hit regions in blank angles. Every child partition must
close against its containing range, while the ranges collectively need not
close against the full circle.

Round-cap protrusion is paint-only and included in clipping/paint envelopes,
not hit or semantics coverage. Adjacent ranges paint one radial seam owned by
the range starting there. Paint order is `(zIndex, declarationOrder)`; hit order
is `(hitPriority, zIndex, declarationOrder)`, highest/later first. Disabled
overlays obey their declared block/pass-through policy. Canvas and Widget
renderers consume these same resolved paths and orderings.

### RectGridLayoutEngine

Supports:

- fixed rows/columns, e.g. QiMen 3x3.
- optional center cell behavior.
- row/column gaps.
- equal or weighted tracks.
- per-cell rounded corners.
- slot anchors inside each cell: top, left, center, right, bottom, overlays.

### RectPerimeterLayoutEngine

Supports:

- rounded-rectangle perimeter with 12 or configurable slots.
- optional center area.
- corner slot sizing rules.
- clockwise/counter-clockwise ordering.
- edge-specific text alignment.
- ZiWei-style 12 palace perimeter and DaLiuRen perimeter boards.

## Renderers

### CircularCanvasBoard

Responsibilities:

- Build `BoardGeometry` using `CircularRingLayoutEngine`.
- Wrap `CustomPaint` with `MouseRegion`, `GestureDetector`, `FocusableActionDetector` where supported.
- Resolve hit regions on hover/tap/focus.
- Paint layers in deterministic z-order.
- Paint hover/selected/focus overlays from `BoardInteractionState`.
- Expose semantics nodes from geometry.

Canvas interaction is implemented outside the painter:

```dart
MouseRegion(
  onHover: (event) => controller.hoverAt(event.localPosition),
  onExit: (_) => controller.clearHover(),
  child: GestureDetector(
    onTapDown: (details) => controller.tapAt(details.localPosition),
    child: CustomPaint(painter: CircularCanvasBoardPainter(...)),
  ),
)
```

The painter is pure rendering. It reads `ChartBoard`, `BoardGeometry`, resolved theme, and interaction state.

### CircularWidgetBoard

Responsibilities:

- Use the same circular geometry.
- Position normal widgets using `Stack`, `Positioned`, and `Transform`.
- Prefer normal Flutter focus/semantics for complex interactive content.
- Use the same controller events and selected/hover state.

### RectGridCanvasBoard

Responsibilities:

- Paint rectangular matrix grid cells, borders, backgrounds, labels, and built-in items.
- Use `BoardHitRegion` rectangles/paths for hover and click.
- Support fast rendering for dense boards.

### RectGridWidgetBoard

Responsibilities:

- Build matrix or perimeter boards with `GridView`, `Table`, `Row`, `Column`, `Stack`, or custom layout.
- Host rich content and complex module widgets.
- Serve as the migration target for QiMenDunJia and DaLiuRen widget-heavy boards.

### Hybrid Canvas+Widget Composition

The four renderers are not mutually exclusive. The production QiZhengSiYu board is a hybrid: Canvas paints the rings, 360-degree ticks, 28 constellation arcs, star dots, and labels, while interactive, animated, and accessible elements (the `StarBody` badge, rotating star widgets, ShenSha `Transform`+`Text`) live in **widgets layered over the Canvas**. A Canvas-only renderer would drop those widgets; a Widget-only renderer cannot feasibly draw 360 ticks and 28 arcs.

The package therefore provides a composition contract, not just standalone renderers:

- A board may declare some layers as Canvas-painted and some items as Widget-hosted overlay items.
- Overlay widgets are positioned through the **same** `BoardGeometry` anchors used by the painter, so a star badge sits exactly on its painted holder dot.
- The shared `BoardInteractionController` and hit-region ids are used by both the Canvas base and the overlay widgets, so hover/selection is consistent across the boundary.

`CircularCanvasBoard` and `CircularWidgetBoard` remain available for pure cases; the hybrid composition is the supported target for QiZhengSiYu. A board declares its composition explicitly; the renderer does not silently choose.

## Interaction Model

### BoardInteractionController

Controller state:

- `hoveredRegionId`
- `pressedRegionId`
- `selectedRegionIds`
- `focusedRegionId`
- `disabledRegionIds`

Events:

- `hoverAt(Offset position)`
- `tapAt(Offset position)`
- `select(String regionId, SelectionMode mode)`
- `focusNext()`
- `focusPrevious()`
- `clearHover()`
- `clearSelection()`

Callbacks:

- `onRegionHover`
- `onRegionTap`
- `onRegionLongPress`
- `onSelectionChanged`
- `onFocusChanged`

### Canvas Hit Testing

`BoardGeometry` owns hit-test data:

```dart
class BoardHitRegion {
  final String id;
  final String layerId;
  final String? sectorId;
  final String? itemId;
  final String? groupId; // owning ItemGroup, if any
  final Path path;       // filled, closed hit geometry (NOT the draw path)
  final Rect bounds;
  final int zIndex;
}
```

Hit geometry is authored independently of the draw path:

- A hit region's `path` MUST be a **filled, closed** shape. Sector/arc hit regions are annular wedge polygons (inner arc + outer arc + two radial edges), not the stroked open `addArc` path used to paint the band. A stroked arc or a 1px tick line has effectively zero fill area, so `path.contains` on the draw path is unsound and is forbidden for hit geometry.
- Minimum-touch-target expansion for sparse ranges is clipped to declared
  half-open angular coverage. Round-cap paint protrusion never expands hit or
  semantics coverage into a blank angle.
- Degree-scale / tick layers default to `hitTestMode: none`. When a tick scale must be interactive, it is hit-tested by angular bucket (degree → region), never by `path.contains` on tick lines.

Hit-test resolution:

- Hit-test order is the total order `(hitPriority, zIndex, declarationOrder)`,
  highest/later first. Disabled overlays obey their declared `block` or
  `passThrough` policy.
- `bounds.contains(position)` is checked before `path.contains(position)`.
- A spatial index is **mandatory** (not optional) for any layer that produces more than 64 hit regions. The circular engine indexes regions by angular bucket; the rect engines index by cell grid. Per-hover cost MUST be sub-linear in region count.
- A resolved hit returns its `groupId` when the region belongs to an `ItemGroup`, so selection/hover act on the logical entity.

Performance budget (hard gate): run a profile/release benchmark with deterministic
seeded pointer positions, 5 x 1,000 warm-up lookups and 10 x 10,000 measured
lookups. Record hardware model, OS, Flutter/Dart versions, build mode, seed, and
p50/p95/max in the evidence manifest. On the registered gStack target, the
reference QiZheng-like board (12 sectors + 360 ticks + 28 arcs + around 11 star
groups) must remain below 2 ms p95. A second seeded matrix at 64, 128, 256, 512,
and 1024 hit regions must have a fitted log-log lookup-time slope below `0.85`
from 128 through 1024, demonstrating indexed rather than linear growth.
Warm-up samples are excluded; any run with background-throttling warnings is
discarded and rerun. Exceeding either gate is stop-the-line R3.

The registered target is a versioned `BenchmarkTargetProfile` containing
hardware, OS, Flutter/Dart versions, build mode, and benchmark seed. Only an
exact profile match may produce a passing `hit-performance` artifact.
Unregistered-environment results are informational and cannot pass or fail the
production gate. Re-registration requires a reviewed profile-version change and
a complete rerun of the protocol and baseline artifacts.

The 64-region indexing threshold is a package maximum, not a consumer tuning
knob. Implementations may index at a lower count, but adapters, boards, themes,
or runtime configuration may not raise it above 64 or disable indexing where it
is mandatory. The performance budget still applies below the threshold.

### Hover And Selected Painting

Renderer tokens define:

- `hoverFill`
- `hoverStroke`
- `hoverShadow`
- `selectedFill`
- `selectedStroke`
- `selectedShadow`
- `focusRing`
- `pressedOverlay`

Canvas painters render overlays as a separate pass after base layers and before foreground labels unless the layer overrides overlay placement.

## Theme And YAML

### Theme Ownership

This package is not the first theme owner in the workspace. Two systems already exist and the package MUST NOT silently become a third, conflicting one:

1. `package:theme` (the org "unified theme pipeline") already owns chart tokens via `ChartThemeTokens` (`colors`, `typography`, `geometry`, `starPalette` as raw maps), read from `XuanThemeData.chartTokens` through `XuanThemeScope`.
2. QiZhengSiYu already has `QiZhengChartStyle` + `QiZhengStarPalette`, bridged from `ChartThemeTokens` by `ThemeChartStyleResolver`, plus an existing asset `assets/theme/chart_tokens.yaml` whose schema is top-level `colors` / `typography` / `geometry` / `starPalette`.

Ownership decision for this package:

- `package:theme` / `XuanThemeData` remains the host-app source of truth. When a `metaphysics_chart_ui` board runs inside the host, the host adapter feeds resolved tokens from `XuanThemeData.chartTokens` into the board theme; the package does not re-read `XuanThemeScope` itself (that would couple core to `package:theme`).
- The package's own `BoardTheme` + YAML loader is the **standalone / example** path used when no host theme is supplied (package example app, tests). Its YAML schema is the package contract; it must be reconcilable with the existing `chart_tokens.yaml` field names, and any divergence is a documented, versioned schema change, not an accident.
- The package core depends on neither `package:theme` nor module style classes. Bridging happens in adapters / the host integration layer.

### Token Group Ownership Map

Every role the existing chart painters require has exactly one destination, so QiZhengSiYu does not end up maintaining `QiZhengChartStyle` and `BoardTheme` in parallel:

| Existing role (`ChartSemanticColors` / `chart_tokens.yaml`) | Destination in package |
|------------------------------------------------------------|------------------------|
| `divider`, `border`, `shadow`, `labelDefault`→`label`, `labelMuted`→`mutedLabel` | `BoardSemanticColors` (core) |
| `ringStroke`, `sectorBorder`, `scaleTick`, `scaleTickAccent` | `CircularRendererTokens` / `BoardGeometryTokens` (renderer) |
| `invalidRingFill`, `invalidRingBorder`, `invalidRingLabel`, `invalidRingBorderWidth` | required invalid-ring roles in `BoardSemanticColors` / `BoardGeometryTokens` |
| `northLine`, `annotationYin`, `annotationSu` | `ModulePalette` (business/cultural marks, not generic semantic UI) |
| `starPalette.zheng`, `starPalette.stars` | `ModulePalette` (module-defined keys) |
| `typography.*` (constellationName/starName/gongName/degree/yearMonth/shenSha) | `BoardTypography` (core), with module-named roles supplied by the adapter |
| `geometry.*` (ringStrokeWidth/tickLength/…/starHolderRadius) | `BoardGeometryTokens` (core) |

`northLine` / `annotationYin` / `annotationSu` are explicitly business marks, not semantic UI colors, preserving the semantic-vs-business boundary the existing migration established.

### Token Groups

- `BoardSemanticColors`: surface, divider, border, label, mutedLabel, hover, selected, focus, disabled, invalidRingFill, invalidRingBorder, invalidRingLabel.
- `BoardTypography`: palaceTitle, palaceBody, smallLabel, degreeTick, badge.
- `BoardGeometryTokens`: stroke widths, gap, minimum hit target, radius, tick lengths, invalidRingBorderWidth.
- `CircularRendererTokens`: ring padding, default sector divider, tick styles, label orientation defaults.
- `RectRendererTokens`: cell gap, cell radius, perimeter corner radius, grid border.
- `ModulePalette`: business/cultural colors by module-defined palette keys.

Fallback-only themes contain every required token. Optional YAML omissions use
fallback values. Strict production loading rejects any missing or malformed
required invalid-ring role before painting; renderers never invent local
fallback colors.

### YAML Example

```yaml
themes:
  classic_ink:
    board:
      surface: "#FFFDF8"
      divider: "#2E2A24"
      label: "#1F1A16"
      mutedLabel: "#6D6258"
      hoverFill: "#D9B45A22"
      selectedStroke: "#A45D2A"
    circular:
      tickColor: "#4A4036"
      majorTickLength: 10
      minorTickLength: 5
      sectorDividerWidth: 0.5
    rect:
      cellRadius: 8
      cellGap: 0
      perimeterCornerRadius: 16
    modules:
      qizhengsiyu:
        palette:
          sun: "#FFA400"
          moon: "#A1AFC9"
      taiyishenshu:
        palette:
          defaultSector: "#D8C7A1"
```

### Resolution Precedence

1. Package fallback.
2. Supplied base tokens — exactly one source per board: host `XuanThemeData.chartTokens` (fed in by the host adapter) **or** a standalone YAML theme file (example/tests). The integration chooses the source; the package treats both as the same "base tokens" slot.
3. Module tokens under `modules.<moduleId>`.
4. Renderer-specific tokens.
5. `ChartBoard.themeOverrides`.

The resolved theme must be immutable and serializable enough for tests to snapshot important values.

## Accessibility

Canvas boards do not get free semantics. Emitting one semantics node per hit region would announce hundreds of nodes (360 ticks, 28 arcs) and is hostile to screen readers. Today the real accessibility lives in widgets (`StarBody`, `DestinyTwelveGongRingWidget`); a naive Canvas-only migration would regress it.

The model therefore separates semantics from hit-testing:

- `semanticsMode` is per layer and independent of `hitTestMode`. A 360-tick layer is typically `hitTestMode: none, semanticsMode: none`. A palace layer is `semanticsMode: group`.
- `ItemGroup` collapses a composite (e.g. one star) to a single semantics node with one `semanticsLabel`.
- The board defines a deterministic semantics traversal order (e.g. sectors clockwise from the start angle, then star groups by id).
- Interactive regions expose role, label, selected/disabled state, and an activate action.
- For complex interactive content, the hybrid composition hosts real focusable widgets over the Canvas (preferred over synthetic Canvas semantics), preserving current widget accessibility.

Acceptance requires a real screen-reader/semantics traversal assertion on the QiZheng-like board: bounded node count, every interactive sector labeled, tick layers excluded — not a generic "smoke" check.

## Module Adapter Contracts

Adapters are pure mapping code:

```dart
abstract class ChartBoardAdapter<TInput> {
  ChartBoard buildBoard(TInput input, ChartBoardAdapterContext context);
}
```

Adapter rules:

- May import module domain models.
- Must not import package internals outside public adapter contracts.
- Must not mutate `ChartBoard` after creation.
- Must assign stable ids for sectors/items so interactions survive rebuilds.
- Must pass module-specific meaning through `metadata` or callback payloads, not through renderer-specific classes.
- Must consume a **resolved, immutable snapshot** of the source model, never the live solver model. QiZhengSiYu star positions come from a stateful, mutated-in-place collision solver (`UIStarModel.adjustedAngle/adjustedEdges/inRangeStar`, `UIConstellationModel` grouping). The adapter reads a post-collision snapshot exposing `originalAngle`, resolved `displayAngle`, leader-line pairs, and group membership; it must not trigger or depend on solver mutation. A parity fixture asserts both `originalAngle` and resolved `displayAngle` survive the adapter unchanged.
- Must normalize non-360 source coordinates before constructing package data.
  QiZhengSiYu owns a versioned mapping policy such as
  `equatorial-365.25-to-display-360-v1`. It converts non-negative domain
  degrees to three-decimal fixed-point source millidegrees using
  round-half-up, represents `365.25` exactly as `365250`, and projects every
  shared cumulative boundary once with integer rational arithmetic:
  `roundHalfUp(sourceBoundaryMilliDegree * 360000 / 365250)`. It validates
  finite/order/range before projection; full coverage additionally validates
  source closure before endpoint pinning, while sparse coverage validates each
  range without aggregate closure. It derives sweeps by subtraction and rejects
  positive source segments collapsed by projection. Sparse ranges preserve
  gaps. Binary floating-point multiplication does not decide boundaries.
- Original source coordinates, units, span, and mapping revision remain in
  consuming-module state or adapter diagnostics outside package geometry. If
  copied to neutral metadata they are optional scalar/serializable diagnostics
  ignored by layout, paint, interaction, equality, and cache keys.

Initial adapters:

- QiZhengSiYu adapter maps current panel/ring data into circular layers.
- QiMenDunJia adapter maps `PalaceData`/EachGong-style data into `RectGridWidgetBoard`.
- DaLiuRen adapter maps existing rectangular display data into `RectGridWidgetBoard`; circular 12-sector adapter can follow.
- ZiWei adapter maps 12 palace data into circular or perimeter layouts.
- TaiYi adapter maps 16 palace/work-position data into circular sector layouts.

## Migration Strategy

### M0: Specification And Baseline

- Freeze current QiZhengSiYu painter inventory.
- Capture QiMen and DaLiuRen rectangular UI examples.
- Create OpenSpec, SuperPowers plan, acceptance package, and external-agent risk prompt.
- Sequence against the in-flight `QiZhengChartStyle` / YAML-token migration (`docs/superpowers/specs/2026-06-17-qizhengsiyu-chart-theme-token-migration-plan.md`). That migration has already refactored the same painters to accept `QiZhengChartStyle? style` and produced goldens, resolvers, and a `ChartThemeTokens` bridge. This change MUST NOT re-migrate those files in parallel: the token migration lands/freezes first (or is folded into this change), and the end-state theme owner is stated explicitly (host `XuanThemeData.chartTokens` as base tokens, package `BoardTheme` for standalone) so no completed work is orphaned and the two migrations do not collide on the same files.

### M1: Package Skeleton And Core Model

- Create `metaphysics_chart_ui` sibling package.
- Add pure data model, layout specs, theme contracts, and YAML loader.
- Add architecture tests preventing module-domain imports into package core.

### M2: Layout Engines

- Implement circular equal sectors, full/sparse custom arcs, ticks, and angle points.
- Implement rectangular matrix grid.
- Implement rectangular perimeter layout.
- Add geometry snapshot tests.

### M3: Four Renderers

- Implement `CircularCanvasBoard`.
- Implement `CircularWidgetBoard`.
- Implement `RectGridCanvasBoard`.
- Implement `RectGridWidgetBoard`.
- Add hit-test and interaction tests for each renderer.

### M4: Theme/YAML Integration

- Add ThemeExtension integration.
- Add YAML parse/fallback tests.
- Add module palette tests proving semantic colors and business palettes remain separate.

### M5: Demo And gStack Evidence

- Build a package example app with:
  - QiZheng-like 12-sector + 360 ticks + 28 arcs board.
  - TaiYi-like 16-sector board.
  - ZiWei-like 12 perimeter board.
  - QiMen/DaLiuRen-like 3x3 grid board.
- Use gStack/browser QA after implementation to collect screenshots and interaction evidence.

### M6: QiZhengSiYu Adapter Migration

- Create adapter in QiZhengSiYu without deleting old painters.
- Run old and new renderers side by side in golden harness.
- Migrate one ring/layer at a time.
- Keep activation instance-safe and reversible. Geometry, strict-theme,
  hit-index, or renderer initialization failure retains/restores Legacy while
  preserving selection, rotation, and module state.

## Risk Register

| ID | Risk | Impact | Probability | Mitigation | Stop-The-Line |
|----|------|--------|-------------|------------|---------------|
| R1 | Neutral model too generic to express real boards | High | Medium | Prototype with QiZheng 360 ticks, TaiYi 16, ZiWei perimeter, QiMen 3x3 before migration | Any MVP demo requires module-specific renderer forks |
| R2 | Canvas text measurement drifts | High | High | Golden tests, typography fallback parity, geometry snapshots | QiZheng golden differs without approved visual change |
| R3 | Hit-test paths become expensive or unsound | High | Medium | Filled/closed hit geometry (not draw path); bounds-first; **mandatory** spatial/angular index above 64 regions; ticks default non-interactive | Pointer-move hit-test exceeds 2 ms on the reference board, or any hit region is derived from a stroked/open draw path |
| R4 | Widget and Canvas renderers diverge behavior | High | Medium | Shared `BoardGeometry`, shared controller, per-ring behavior promoted to `layer.behavior` data, renderer conformance tests | Same board data produces different hit ids, or a per-ring difference is implemented as renderer logic instead of data |
| R5 | Theme tokens mix semantic UI colors and business palettes | High | Medium | Separate `BoardSemanticColors` and `ModulePalette`; tests assert no palette keys are required by core | Core package imports module enum or palette |
| R6 | Instance state leaks across boards | High | Low | Interaction controller is instance-scoped; `moduleId` + `instanceId` required | Two boards affect each other's selection/hover |
| R7 | Accessibility is sacrificed for or regressed by Canvas | High | Medium | `semanticsMode` independent of hit-testing; `ItemGroup` collapses composites; hybrid hosts focusable widgets; bounded-node traversal assertion | Canvas board emits unbounded semantics nodes, or a migrated board has fewer labeled interactive regions than the current widget board |
| R8 | Package name violates governance | High | Low | Use `metaphysics_chart_ui` or similarly neutral name; architecture test scans pubspec/library/imports | Any program identifier uses `xuan_`/`xuan-` |
| R9 | Migration touches calculation behavior | High | Low | Adapter-only migration; no domain algorithm movement | Any calculation fixture changes |
| R10 | Rect perimeter corner geometry is underestimated | Medium | Medium | Treat perimeter as its own engine, not a grid option | ZiWei/DaLiuRen perimeter cannot align 12 cells cleanly |
| R11 | YAML schema churn breaks modules | Medium | Medium | Version schema and fallback; validate YAML fixtures | Existing fixture cannot parse after schema update |
| R12 | Asset/icon references cannot be generic | Medium | Medium | Use asset resolver callbacks and package asset references; no hard-coded module assets in core | Core package imports module asset constants |
| R13 | Public API frozen before real multi-module proof | High | High | Build read-only adapters for all five real modules before stabilization, or ship API as experimental and gate the second migration | Public core type must change after a second module depends on it |
| R14 | Composite/angular items not expressible | High | Medium | `ItemGroup` (one id, one hit region, one semantics node) + `AngularPoint` dual angles + leader line | A star resolves as separate dot/line/text hit or semantics targets |
| R15 | Hybrid Canvas+Widget board has no renderer | High | Medium | Hybrid composition contract sharing geometry, controller, hit ids | QiZheng cannot render rings (Canvas) and interactive star badges (widgets) on one board |
| R16 | Theme ownership collides with `package:theme` | High | Medium | Ownership decision: host `XuanThemeData.chartTokens` as base tokens, package `BoardTheme` for standalone; role-mapping table; schema reconciled with `chart_tokens.yaml` | Package introduces a third theme system disconnected from `ChartThemeTokens` |
| R17 | Business enums leak into core via deny-list scan | High | Medium | Allow-list boundary scan including `package:metaphysics_core`/`theme`/`xuan_config` | A core file imports `package:metaphysics_core` and the scan still passes |
| R18 | Double migration collides on the same painters | High | Medium | Sequence after / fold in the in-flight token migration; state surviving theme owner | Both migrations edit the same painter files concurrently, or `BoardTheme` orphans `ChartThemeTokens` |
| R19 | Domain projection leaks into generic package or accumulates rounding drift | High | Medium | Adapter-owned, versioned cumulative-boundary mapping; integer display millidegrees; boundary tests | Core exposes source-span/projection API, or `365.25` does not map exactly to `360000` |
| R20 | Sparse arcs are treated as invalid incomplete circles or gain phantom interaction | High | Medium | Explicit coverage mode; half-open range validation; shared resolved geometry | Sparse range expands to full circle, shifts another ring, or blank angle is hit/announced |
| R21 | Sparse range overlap/wrap/caps diverge across renderers | High | Medium | Same-layer overlap forbidden; wrap split explicitly; shared cap geometry and conformance goldens | Canvas/Widget disagree on paths, hit ids, z-order, or border caps |

## Boundary Rules

The boundary check is an **allow-list**, not a deny-list of a few module names. Core / layouts / renderers may import only the modules listed under "MAY Import"; anything else fails the scan. A deny-list of the five consuming packages is insufficient because the business enums (`EnumStars`, `Enum28Constellations`, `EnumTwelveGong`, …) actually live in `package:metaphysics_core`, which a deny-list of module names would not catch.

### Package Core MAY Import (exhaustive allow-list)

- `flutter/widgets.dart`
- `flutter/material.dart` where visual widgets or ThemeExtension require it
- `dart:ui`, `dart:math`
- `yaml`
- named, justified pure-Dart utilities (e.g. `equatable`, `collection`) — each addition recorded in the allow-list test

### Package Core MUST NOT Import (non-exhaustive, enforced by the allow-list)

- `package:qizhengsiyu`, `package:qimendunjia`, `package:daliuren`, `package:ziwei`, `package:taiyishenshu`
- `package:metaphysics_core` (carries business enums — belongs in adapters only)
- `package:theme` (host theme pipeline — bridged in adapters / host layer, not core)
- `package:xuan_config`
- any module `domain/**`, `model/**`, `viewmodel/**`, or repository implementation package

The import-boundary test enumerates the allow-list and fails on any import outside it, scoped to `lib/src/core`, `lib/src/layouts`, `lib/src/renderers`. Adapters legitimately import `metaphysics_core` and module models, so the scan excludes the adapter layer.

### Module Adapters MAY Import

- their own domain and UI state models
- `metaphysics_chart_ui` public adapter contracts

### Module Adapters MUST NOT

- call private package internals under `src/`
- mutate package geometry
- pass domain objects into renderer public fields
- pass non-normalized source angles or delegate domain projection to package core

## Validation Gates

### Documentation Gates

- No unfinished marker language: no incomplete marker terms, deferred-work claims, or incomplete acceptance statements.
- Proposal, design, tasks, spec delta, and acceptance package all reference the same change id.
- Every risk has a mitigation and stop-the-line condition.
- Every renderer has at least one acceptance scenario.
- Every module family has at least one mapping scenario.
- P0.1-P0.14 map to concrete evidence and `evidence/P0-go-no-go.md` records GO
  before P1 begins.

### Static Gates

- Package name and identifiers avoid `xuan_`/`xuan-`.
- Core import scan finds no module package imports.
- Adapter import scan confirms module dependencies stay in adapter layer.
- YAML fixtures use fallback for optional roles and strict production failure
  for missing required `invalidRing*` roles.
- Package-core API and imports contain no source-domain span or QiZhengSiYu
  projection policy.

### Unit Gates

- Geometry snapshot tests for circular equal sectors, full custom arcs, sparse
  partial arcs, ticks, angle points, matrix grid, and perimeter layout.
- Center tests cover absent, Canvas, Widget, and hybrid `BoardCenterSpec` and
  verify the first ring boundary plus paint envelope.
- Optional zero-width tests cover skipped identity/order/no-output, re-enable at
  the same position, and required-zero rejection.
- Track/body tests cover independent transforms and inverse hit testing while
  preserving one ring's resolved radii.
- Hit-test tests for sector, tick, point item, matrix cell, and perimeter cell.
- Sparse tests cover disjoint and adjacent ranges, reject overlap/zero-length/
  out-of-range/implicit-wrap input, preserve blank hit/semantics regions, and
  verify split wrap-around plus cap/border geometry across Canvas and Widget.
- QiZhengSiYu adapter tests map `0/182.625/365.25` to
  `0/180000/360000` by cumulative boundaries and preserve sparse gaps.
- Interaction state tests for hover, selected, pressed, focus, disabled.
- Theme resolution precedence tests.

### Golden Gates

- Circular Canvas example golden.
- Circular Widget example golden.
- Rect Grid Canvas example golden.
- Rect Grid Widget example golden.
- QiZhengSiYu parity golden before replacing old painter layers.

### gStack Gates

After implementation creates an example app, gStack/browser QA must collect:

- desktop screenshot for all four renderers
- narrow/mobile screenshot for all four renderers
- hover visual evidence for Canvas circular and Canvas rect renderers
- tap/selected evidence for all four renderers
- theme switch or YAML-loaded theme evidence
- accessibility/keyboard smoke evidence for selectable regions
- sparse arc evidence in both circular renderers: blank angles, caps, overlap
  hit priority, disabled pass-through, semantics, and responsive clipping

All evidence is recorded against one commit SHA. OpenSpec “artifact complete”
means only that required documents exist; it is not implementation or production
completion. Implementation readiness requires all P0 evidence. Production
readiness requires all static, unit, golden, gStack, rollback, and evidence-
manifest gates against the same commit.

The machine-readable manifest is
`openspec/changes/create-metaphysics-chart-ui-package/evidence/production-readiness-manifest.yaml`:

```yaml
schemaVersion: 1
changeId: create-metaphysics-chart-ui-package
commitSha: <40-character tested commit>
artifacts:
  - id: package-unit
    category: unit
    path: evidence/package-tests.txt
    sha256: <64 lowercase hex characters>
    command: flutter test
    status: passed
```

The closed required artifact catalog is:

| ID | Category |
| --- | --- |
| `openspec-strict` | documentation |
| `p0-go-no-go` | documentation |
| `package-analyze` | static |
| `import-api-boundary` | architecture |
| `package-unit` | unit |
| `adapter-unit` | unit |
| `theme-strict` | theme |
| `geometry-goldens` | golden |
| `renderer-conformance` | conformance |
| `sparse-conformance` | conformance |
| `qizheng-legacy-parity` | migration |
| `hit-performance` | performance |
| `accessibility-traversal` | accessibility |
| `gstack-desktop` | gstack |
| `gstack-mobile` | gstack |
| `gstack-interaction` | gstack |
| `rollback-failure-injection` | rollback |

Schema version changes are required to add/remove/rename a required ID.
`tool/verify_production_readiness.dart` validates schema,
exact HEAD commit, required IDs, `passed` status, file existence, and SHA-256:

```bash
dart run tool/verify_production_readiness.dart \
  --manifest openspec/changes/create-metaphysics-chart-ui-package/evidence/production-readiness-manifest.yaml \
  --expected-commit "$(git rev-parse HEAD)"
```

CI runs the verifier. Missing/duplicate IDs, stale commit, missing files, hash
mismatch, or non-passed status fail readiness. A negative fixture deliberately
omits one required runtime artifact and must fail even when OpenSpec reports
all document artifacts present.

## Not Done Conditions

The change is not ready for implementation if:

- The data model cannot represent 12-sector, 16-sector, 360-tick, 28-arc, 3x3 grid, and 12-perimeter examples on paper.
- The data model cannot represent sparse partial-arc coverage without fake
  transparent sectors, or package core must know a `365.25` source span.
- The data model cannot express a composite star (`ItemGroup`) or its dual-angle leader line (`AngularPoint`).
- The hybrid Canvas+Widget composition is not specified, so the real QiZhengSiYu board has no renderer target.
- Canvas hit-testing is not specified before code begins, or hit geometry is derived from the stroked/open draw path.
- Theme ownership versus `package:theme` / `XuanThemeData.chartTokens` is undecided, or precedence is unclear.
- Module instance ownership is unclear.
- The boundary scan is a deny-list rather than an allow-list, so `package:metaphysics_core` could leak into core.
- The adapter is not specified to consume a resolved immutable snapshot.
- No external-agent risk review has been requested.
- Sparse overlap, wrap-around, border caps, blank-angle interaction, and
  adapter-owned normalization do not have executable acceptance scenarios.

The change is not ready for production if:

- All four renderers plus the hybrid composition do not exist.
- Renderer conformance tests do not prove shared behavior, including per-ring `behavior` parameters.
- The hit-test performance budget (under 2 ms on the reference board) is unmet.
- gStack evidence is missing for interactive behavior.
- Golden tests are absent for migrated QiZhengSiYu layers.
- Accessibility semantics are unverified by a bounded-node traversal assertion.
