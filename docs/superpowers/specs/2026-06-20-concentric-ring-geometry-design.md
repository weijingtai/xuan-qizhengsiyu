# Concentric Ring Geometry Design

## Status

Revised after the production-readiness gap review on 2026-06-20. The design
documents are ready for P0 baseline execution only. P1 implementation remains
blocked until every P0 task and its go/no-go evidence are complete. Document
approval alone is neither implementation nor production approval.

## Review Gap Closure

| Gap | Normative resolution | Acceptance evidence |
| --- | --- | --- |
| G-1 | DaXian 106 hierarchical fixture and quarter carry are specified below | exact child-sweep fixture test |
| G-2 | consuming adapters project source coordinates to `0..360000`; package core remains source-domain neutral | adapter projection plus package-boundary tests |
| G-3 | invalid-ring Theme/YAML keys and failure behavior are mandatory | schema load plus light/dark render tests |
| G-4 | center, nine model bands, and two unconnected DaXian bands are inventoried | adapter inventory assertion |
| G-5 | center content is an independent `BoardCenterSpec` | Canvas, Widget, and hybrid center tests |
| G-6 | track and body are independently transformed overlays on one orbit ring | independent rotation and hit-test tests |

## Goal

Replace the current four-layer QiZheng Canvas prototype with a reusable,
renderer-independent concentric-ring geometry system that can reproduce the
ten-plus-ring Legacy chart while supporting TaiYi, ZiWei, DaLiuRen, and future
submodules.

The Legacy chart is the geometry reference. The existing four-layer Canvas
prototype is not a parity reference.

## Design Principles

1. Radial placement and angular partitioning are independent concerns.
2. Every renderer consumes resolved geometry; renderers never reinterpret
   radius, diameter, or width values.
3. Ring widths use absolute radial design units. Responsive layouts scale the
   complete board uniformly.
4. Display angles use integer millidegrees internally. One rendered full circle
   is always `360000`, independently of the source coordinate system.
5. Invalid data affects only its owning ring and never shifts adjacent rings.
6. The package remains module-neutral. Submodules own content, instance state,
   domain adapters, and user-facing error presentation.

## Core Model

### BoardCenterSpec

Center content is an independent board slot, not a `RingSpec`. It has no
annular width or angular partition and therefore does not participate in ring
coverage validation. `BoardCenterSpec` reserves a `radius`; the first ordered
ring begins at that radius.

The center slot may provide Canvas content, a Widget child, or both through a
hybrid composition adapter. It owns its clipping, fit, semantics, interaction,
and optional background/border configuration. Center outsets are included in
the board paint envelope. A missing center is valid and reserves zero radius.

### ConcentricRingPlan

`ConcentricRingPlan.rings` is ordered from the center outward. Reordering the
list reorders the rings without modifying their content or angular strategy.

Each `RingSpec` contains:

- stable `id`
- optional stable `orderKey` for YAML-driven ordering
- absolute radial `width`
- independent inner and outer border specifications
- one angular partition strategy
- zero or more overlays such as ticks
- interaction and semantics configuration
- module-neutral metadata

Duplicate ring IDs, negative widths, and non-finite values are invalid. A zero
width is legal only for an explicitly optional ring. Such a ring retains its
stable ID and source-plan position but resolves as `SkippedRingGeometry` with
reason `zeroWidth`: it allocates no radius and emits no paint, hit region, or
semantics. Changing it to a positive width restores it at the same ordered
position without changing neighboring IDs.

Validation severity is explicit. Duplicate stable IDs, negative/non-finite
radial allocations, required zero-width rings, and an unresolved required theme schema are board-fatal
because trustworthy geometry cannot be allocated. Partition or coverage defects
are ring-local only when that ring's radial band is valid; neighboring geometry
and interaction remain available. Invalid rings expose no content hit regions
or content semantics.

An overlay never allocates another radial band unless it explicitly declares
an outset. Track, body, ticks, labels, and interaction effects may therefore
share one resolved ring without being mistaken for additional rings.

### ResolvedRingGeometry

The radial resolver produces one immutable result per ring:

```dart
ResolvedRingGeometry(
  innerRadius: 214,
  centerRadius: 238,
  outerRadius: 262,
  width: 48,
)
```

It also exposes content and border radii so painters do not derive geometry:

- `innerBorderRadius`
- `contentInnerRadius`
- `centerRadius`
- `contentOuterRadius`
- `outerBorderRadius`

The following construction helpers are equivalent inputs to the same resolved
model:

```dart
RadialBand.fromInner(innerRadius: 214, width: 48)
RadialBand.fromCenter(centerRadius: 238, width: 48)
RadialBand.fromOuter(outerRadius: 262, width: 48)
```

The concentric planner normally uses ordered widths. The explicit helpers are
available for imported Legacy geometry and specialized overlays.

## Ring Width And Borders

Each ring owns an independent absolute `ringWidth`. Width is selected by the
submodule according to its content volume; a one-label palace ring can be
narrower than a ShenSha ring.

Inner and outer borders are independently configurable:

```dart
RingBorderSpec(
  inner: RingStroke(width: 1.5),
  outer: RingStroke(width: 3),
)
```

Borders are drawn inward by default and consume only their owning ring's
allocated width. Changing border width does not move adjacent rings or change
the board's outer radius. A ring is invalid when borders and required content
cannot fit within its configured width.

Border color, width, visibility, and dash pattern resolve through Theme/YAML
tokens. Raw module colors are not embedded in the geometry model.

## Angular Partition Model

`segmentCount` is not the primary model. It is only a convenience input for an
equal partition generator.

Supported strategies are:

### EqualPartition

Generates equal segments for common 12- and 16-palace rings.

### ExplicitPartition

Accepts any number of explicitly sized segments, including 46, 71, or 73
segments. Every segment has a stable ID and millidegree sweep.

### HierarchicalPartition

Represents parent sectors with independently partitioned children. This covers
the outer QiZheng DaYun/LiuNian ring: twelve primary sectors may contain 8, 10,
12, 11, or other numbers of child segments, and those children need not be
equal.

Every child list must exactly cover its parent's sweep.

### ContinuousPartition

Represents a continuous orbit without content sectors. A star orbit uses this
strategy. A 360-degree scale is an independent `TickOverlay`, not 360 content
slots.

Every partition supports its own angular direction, zero-angle offset,
rotation, text orientation, hit testing, and semantics.

## Coverage Model

Angular partition and angular coverage are separate. Every circular ring or
overlay declares exactly one coverage mode:

- `FullCircleCoverage`: the resolved top-level partition must cover exactly
  `0..360000` with no gap or overlap.
- `SparseArcCoverage`: contains one or more normalized half-open ranges
  `[startMilliDegree, endMilliDegree)`. The ranges need not total `360000`.

Sparse ranges must have `0 <= start < end <= 360000`, non-zero sweep, stable
IDs, and no overlap within the same layer. Adjacent ranges are legal and are
not merged automatically because they may have different content, borders, or
cap styles. A range crossing zero must be supplied as two ranges, for example
`[350000, 360000)` and `[0, 20000)`; `start > end` is never interpreted as
implicit wrap-around.

Ranges and partitions are authored and validated in canonical clockwise
display space before ring direction, zero-angle offset, or overlay rotation is
applied. `360000` is legal only as an interval end boundary and aliases `0` for
point positions. Half-open ownership assigns a shared boundary to the range
starting there.

Each sparse range may contain an equal, explicit, hierarchical, or continuous
partition, but its children must exactly cover that range's own sweep. Blank
angles stay transparent and have no hit region or semantics node. The complete
radial band remains reserved, so changing sparse coverage never shifts another
ring.

Inner and outer borders follow only the painted arc ranges. Each range also
defines start/end radial borders and a `butt` or `round` cap style. Hover,
selection, shadows, outsets, and clipping envelopes are calculated from the
painted ranges and cap geometry. A round cap may visually protrude beyond its
nominal half-open interval, but that protrusion is paint-only: interaction and
semantics remain clipped to declared coverage. Adjacent ranges share one seam;
the range beginning at the boundary owns and paints it, preventing double-width
radial borders.

Overlapping ranges are forbidden inside one sparse layer. Intentional overlap,
including independently addressable Zhu-Luo-San-Xian intervals, uses separate
overlays with explicit `zIndex`, hit-test priority, and semantics ownership.
Paint order is `(zIndex, declarationOrder)`. Hit order is the total order
`(hitPriority, zIndex, declarationOrder)` with highest/later winning. A disabled
overlay declares `block` or `passThrough`; no renderer may infer the policy.
Focus traversal uses explicit semantics order, then declaration order. Every
overlay ID is unique. `owner(targetId, semanticsOrder)` creates the target's
single node and is unique per target. `merge(targetId)` contributes
supplementary semantics to that existing owner but creates no node. The owner exclusively
defines role, primary label, selected/disabled state, and activate action. A
merge may only append a description fragment and uniquely keyed non-activate
custom actions; fragments are concatenated in declaration order and duplicate
action IDs are invalid. Missing/duplicate owners or merge attempts to override
owner fields are validation errors. `none` contributes no semantics. Owner
ordering uses `semanticsOrder`, then declaration order, then stable target ID.

## Adapter-Owned Coordinate Normalization

The package accepts integer display millidegrees only. It has no `sourceDomainSpan`,
does not know that QiZhengSiYu may use a `365.25` equatorial system, and never
performs domain projection. A consuming submodule adapter owns a finite,
positive, versioned source-to-display mapping such as `365.25 -> 360`.
QiZhengSiYu first quantizes non-negative source degrees to three-decimal
fixed-point `sourceMilliDegree` using round-half-up, validates them, and then
projects each shared cumulative boundary exactly once using integer rational
arithmetic:

```text
sourceSpanMilliDegree = 365250
displayBoundary = roundHalfUp(
  sourceBoundaryMilliDegree * 360000 / sourceSpanMilliDegree
)
displaySweep[i] = displayBoundary[i + 1] - displayBoundary[i]
```

Before endpoint pinning, the adapter rejects non-finite values, negative or
out-of-range boundaries, and non-monotonic order. Full coverage additionally
requires source closure equal to the declared fixed-point source span; sparse
coverage validates each declared range but requires no aggregate source
closure. The adapter quantizes cumulative boundaries, never individual sweeps.
For valid full coverage it fixes the first display
boundary to `0` and final boundary to `360000`, then derives sweeps by
subtraction. For sparse coverage it projects only declared boundaries and does
not expand a range to a full circle. A positive source segment whose two
projected boundaries collapse is rejected by the adapter.

For a `365.25` equatorial system, source `0`, `182.625`, and `365.25` project to
display `0`, `180000`, and `360000`. Original source coordinates and mapping
revision remain in QiZhengSiYu-owned state or adapter diagnostics outside
package geometry. If copied into neutral metadata, values must be optional,
scalar/serializable, and ignored by layout, paint, interaction, equality, and
cache keys. The package validates only normalized millidegree input.

## Angle Precision And Validation

Domain doubles, when unavoidable, are quantized to three decimal places at the
consuming adapter boundary. The package public API and all geometry calculations
use integer millidegrees:

```text
30.000 degrees = 30000
2.000 degrees  = 2000
full circle    = 360000
```

`FullCircleCoverage` top-level segments must total exactly `360000`.
`SparseArcCoverage` top-level ranges need not, but every range and child
partition must satisfy the coverage rules above. Underflow, overflow, overlap,
out-of-range boundaries, implicit wrap-around, and collapsed non-zero segments
are invalid. Package validation never attempts to repair or re-project input.

Validation reports:

- ring and partition IDs
- expected and actual millidegrees
- signed difference
- offending segment or parent path
- board instance and module owner

## Invalid Ring Behavior

An invalid ring keeps its configured radial allocation so outer rings never
collapse inward.

The renderer draws a complete light-red error annulus using the
`invalidRingFill` and `invalidRingBorder` theme tokens. It does not draw invalid
segments or content. Other rings remain visible and interactive.

This remains true for malformed sparse coverage: because invalid or overlapping
ranges cannot be trusted as paint geometry, the renderer paints the owning
ring's complete reserved band as the error annulus rather than guessing which
partial range was intended.

The package emits a structured `RingValidationIssue`; it does not directly
show a Toast. The host submodule maps the event to a Toast, banner, or logging
system and deduplicates notifications by board instance, ring ID, validation
revision, and error fingerprint.

The Theme/YAML schema must add these required semantic tokens before the new
renderer can become production-default:

```yaml
colors:
  invalidRingFill: "#FFFFE0E0"
  invalidRingBorder: "#FFE57373"
  invalidRingLabel: "#FFB71C1C"
geometry:
  invalidRingBorderWidth: 1.0
```

Missing required invalid-ring tokens are a theme validation error; renderers
must not silently substitute module-local colors. Dark themes may override the
values while retaining the same semantic keys.

## Space Reservation And Clipping Prevention

The planner computes the complete paint envelope before a renderer allocates
its surface. The envelope includes:

- all ring widths
- inward border consumption
- labels and icons
- star-body radial overhang
- hover and selection effects
- shadows and interaction strokes
- board-level safe padding

`requiredRadius` and `requiredDiameter` are renderer inputs. Callers do not
guess Canvas dimensions.

Supported fit policies are:

- `contain`: uniformly scale the complete board to the available box; default
- `expand`: request the complete logical drawing size
- `strict`: report insufficient space instead of clipping

Renderers may not shrink one ring independently, clip an outer ring, or render
half of an icon. If content cannot fit its ring width, that ring enters the
invalid-ring state rather than producing partial output.

## Renderer Contract

Canvas, Widget, and future renderers consume the same `ResolvedBoardGeometry`:

- named resolved rings
- resolved segment paths and anchors
- tick paths
- point and label anchors
- hit regions
- board paint envelope
- validation issues

Both circular renderers consume the same resolved full/sparse paths. Renderers
must not close a sparse arc into a full annulus, invent hit geometry in blank
angles, merge adjacent ranges, or reinterpret wrap-around.

One logical target may own multiple disjoint geometry and hit-region fragments,
including a split zero-crossing interval. Every fragment resolves to the same
logical target ID, selection state, and at most one semantics node. The earlier
single-hit-region rule applies to a contiguous primitive group, not to a
fragmented target.

The Canvas renderer must resolve each layer against its referenced ring. It may
not apply one global `innerRadius/outerRadius` pair to every layer.

`AngularPoint` radial positions are relative to its owning ring. For the
QiZheng star orbit, the original guide point anchors to the ring's inner edge
and the displayed star anchors to the ring centerline unless the submodule
specifies another policy.

### Independent Track And Body Overlays

A star orbit is one `ContinuousPartition` ring with independently transformed
overlays, not two radial rings:

```dart
RingOverlaySpec.track(
  id: 'fate-star-track',
  rotationMilliDegrees: trackRotation,
  radialAnchor: RingAnchor.innerEdge,
)
RingOverlaySpec.body(
  id: 'fate-star-body',
  rotationMilliDegrees: bodyRotation,
  radialAnchor: RingAnchor.centerline,
)
```

Every overlay has its own rotation, angular direction, z-index, hit regions,
semantics, and declared paint outset. Rotation is resolved relative to the
ring's zero angle and is never inherited from another overlay. Track and body
share the ring's resolved radii but may rotate independently, preserving the
Legacy `trackRotationAngle` and `bodyRotationAngle` behavior. Hit testing uses
the overlay's inverse transform before segment or point lookup.

## QiZheng Migration

The current `QiZhengSiYuPanSizeDataModel` mixes diameters, radii, radial widths,
and derived sizes. It remains available only as a Legacy input during
migration. It is not a package contract.

`QiZhengLegacyRingPlanAdapter` converts the Legacy values once into named
absolute-width rings. All subsequent geometry uses the new model.

The QiZhengSiYu adapter also owns every non-360 source mapping. It records a
versioned mapping policy (for example `equatorial-365.25-to-display-360-v1`),
normalizes cumulative boundaries into package millidegrees, and rejects source
input that is non-finite, non-monotonic, out of source range, or collapsed by
quantization. The package receives neither the mapping table nor source-domain
types.

### Source-Derived Legacy Inventory

`QiZhengSiYuPanSizeDataModel` stores diameters for boundaries and radial widths
for its `*Height` inputs. The adapter must use the inputs below as radial
widths, rather than halving them a second time. The production defaults are
from `BeautyViewPage`.

| Order | Stable ID | Legacy source | Default radial width | Partition/composition |
| ---: | --- | --- | ---: | --- |
| C | `center` | `centerSize = 140` diameter | radius `70` | independent `BoardCenterSpec` |
| 1 | `earthly-branches` | `diZhi12GongHeight` | `50` | equal 12 |
| 2 | `zodiac` | `zodiac12GongHeight` | `24` | equal 12 |
| 3 | `star-sequence` | `starSeq12GongHeight` | `0` | optional equal 12; retained in source order and skipped from resolved paint when zero |
| 4 | `destiny-palaces` | `destiny12GongHeight` | `70` | equal 12 |
| 5 | `fate-star-orbit` | `lifeStarRingHeight` | `48` | continuous; independent track/body overlays |
| 6 | `constellations` | `starXiu28RingHeight` | `36` | 28 explicit mansions plus scale tick overlay |
| 7 | `basic-star-orbit` | `lifeStarRingHeight` | `48` | continuous; independent track/body overlays |
| 8 | `inner-shensha` | `innerShenShaHeight` | `90` | 12 palace content groups |
| 9 | `outer-shensha` | `outerShenShaHeight` | `90` | 12 palace content groups |
| 10 | `daxian-outer` | `DaXianRing.outerRadius - 16` | `16` | hierarchical 12 x variable slots; not connected |
| 11 | `daxian-inner` | `DaXianRing.outerRadius - 32` | `16` | hierarchical 12 x variable slots; not connected |

This is one center slot plus nine named model bands, of which the star-sequence
band currently resolves as a zero-width skipped entry, plus two currently
unconnected DaXian bands.
Track/body and 360-degree ticks are visual overlays and do not increase the
radial-band count. This counting rule is normative for migration inventory and
prevents either hidden overlays or zero-width optional bands from being lost.

The real composition order remains configurable; the table records the Legacy
reference order used by parity tests, not a permanent package restriction.

### DaXian Hierarchical Fixture

The first mandatory `HierarchicalPartition` fixture is exported from
`DaXianRing.daXian106` in palace order Zi through Hai. Each parent covers
exactly `30000` millidegrees. Input durations are:

```text
[15y, 10y, 11y, 15y, 8y, 7y, 11y, 4y6m, 4y6m, 4y6m, 5y, 5y]
```

Quarter-year carry is continuous across parent boundaries, matching
`DaXianCalculateHelper.transformNumbers`. After cumulative-boundary
quantization, the expected child sweeps in millidegrees are:

```text
Zi:   [2000 x 15]
Chou: [3000 x 10]
Yin:  [2727,2728,2727,2727,2727,2728,2727,2727,2727,2728,2727]
Mao:  [2000 x 15]
Chen: [3750 x 8]
Si:   [4286,4285,4286,4286,4286,4285,4286]
Wu:   [2727,2728,2727,2727,2727,2728,2727,2727,2727,2728,2727]
Wei:  [6667,6666,6667,6667,3333]
Shen: [3333,6667,6667,6666,6667]
You:  [6667,6666,6667,6667,3333]
Xu:   [3000,6000,6000,6000,6000,3000]
Hai:  [3000,6000,6000,6000,6000,3000]
```

`[value x count]` is test-fixture shorthand and expands before assertion. Tests
must assert each parent sum is `30000`, the board sum is `360000`, child IDs
remain stable, and the Wei-to-Hai cross-parent quarter carry is preserved.

## Theme And Instance Ownership

Geometry references semantic style roles only. Theme/YAML resolves normal,
hovered, selected, disabled, and invalid-ring styles.

Validation, interaction, and notification state is keyed by both `moduleId`
and `instanceId`. Two boards from the same or different submodules cannot share
hover, selection, validation, or Toast-deduplication state accidentally.

## Testing And Acceptance

### Geometry Tests

- absent, Canvas, Widget, and hybrid center configurations reserve the expected
  center radius and place the first ring at its boundary
- reordered input produces reordered, continuous radial bands
- an optional zero-width ring preserves source order and stable ID, allocates no
  radius/paint/hit/semantics, and returns to the same position when enabled
- every configured width is preserved exactly in design units
- inner and outer borders stay inside their owning ring
- adjacent ring boundaries are equal with no gap or overlap
- required paint envelope includes all declared outsets
- `contain` scaling is uniform on both axes

### Partition Tests

- equal 12- and 16-part rings cover 360 degrees
- explicit 46-, 71-, and 73-part fixtures cover 360 degrees
- mixed 30-degree and 2-degree segments resolve correctly
- hierarchical child sums equal their parent sweep
- the DaXian 106 fixture matches every child sweep above and preserves
  cross-parent quarter carry
- full-circle package input under or over `360000` is rejected without repair
- sparse fixtures `[0,60000)` and `[58000,72000)` are rejected in one layer but
  succeed as separate ordered overlays sharing one complete radial band
- disjoint, adjacent, overlapping, zero-length, out-of-range, and split
  wrap-around sparse fixtures follow the coverage rules above
- top-level underflow and overflow produce invalid rings
- child underflow and overflow identify the full parent path

### Theme And Interaction Tests

- light and dark YAML fixtures provide every required invalid-ring token
- a missing required token fails theme validation before painting
- invalid rings render the configured fill, border, and label roles without
  drawing invalid segment content
- track and body hit tests apply their own inverse rotations and remain isolated
  by `moduleId` plus `instanceId`
- boundary probes at `b-1`, `b`, and `b+1` millidegrees verify half-open
  ownership, paint-only cap protrusion, and no expanded hit target in blank space
- fragmented wrap-around targets return one logical ID and one semantics node

### QiZheng Calibration Tests

- every inventory row above has a named center, ring, or overlay equivalent;
  unconnected DaXian rows have fixture-backed adapter output
- inner, center, and outer radii match the Legacy reference within 0.5 pixels
- star guide anchors match the orbit inner edge
- displayed stars match the orbit centerline within 0.5 pixels
- track and body rotations can change independently without changing resolved
  ring radii or each other's transforms
- the QiZheng adapter maps a `365.25` full source span to exact display
  boundaries `0`, `180000`, and `360000` without package-core projection code
- a QiZheng sparse source range is proportionally mapped without being expanded
  to a full circle, and preserves its blank angular intervals
- all rings remain visible at desktop, minimum mobile, dark theme, and rotation
- no non-background pixel touches the unexpected clipping boundary

### Evidence Rules

The real Legacy page or a frozen render artifact captured from it is the visual
reference. A test-local reconstruction of Legacy widgets cannot be presented
as parity evidence.

Canvas and Legacy screenshots must use the same domain snapshot, logical board
size, theme, and rotation. Geometry assertions accompany Golden tests so an
incorrect Golden cannot bless misplaced tracks.

Canvas and Widget conformance is exact for resolved integer geometry, logical
IDs, transforms, hit results, selection, and semantics structure. Raster
comparison uses declared pixel and text-baseline tolerances where Flutter's
Canvas and Widget text/layout primitives cannot be byte-identical.

## Migration Safety

The real Legacy renderer remains the default production fallback until the new
Canvas renderer passes ring inventory, geometry calibration, visual comparison,
interaction, responsive, Theme/YAML, and invalid-data tests. No Legacy code is
deleted during this migration.

Activation is instance-safe and reversible. Any geometry, strict-theme,
hit-index, or renderer initialization failure keeps or restores Legacy without
losing the current selection, rotation, or module state. Evidence is keyed to
the tested commit SHA. “OpenSpec artifact complete” means documents exist only;
implementation readiness requires all P0 evidence, and production readiness
requires all runtime gates against the same commit.
