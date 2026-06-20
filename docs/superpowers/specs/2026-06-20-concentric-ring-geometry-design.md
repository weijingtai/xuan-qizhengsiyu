# Concentric Ring Geometry Design

## Status

Revised after the production-readiness gap review on 2026-06-20. The design is
implementation-ready only when the acceptance gates in this document are
represented by executable tests; document approval alone is not production
approval.

## Review Gap Closure

| Gap | Normative resolution | Acceptance evidence |
| --- | --- | --- |
| G-1 | DaXian 106 hierarchical fixture and quarter carry are specified below | exact child-sweep fixture test |
| G-2 | source-domain coordinates project to a fixed `360000` display circle | `365.25` projection and closure tests |
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

Duplicate ring IDs, negative widths, and non-finite values are invalid.

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

## Source Coordinate Projection

The `360000` invariant belongs to rendered display space, not necessarily to
the source domain. A partition may declare a finite positive
`sourceDomainSpan`, such as `365.25` equatorial degrees. The adapter preserves
source values in segment metadata and projects cumulative source boundaries
onto one display circle:

```text
displayBoundary = round(sourceBoundary / sourceDomainSpan * 360000)
displaySweep[i] = displayBoundary[i + 1] - displayBoundary[i]
```

Projection quantizes cumulative boundaries, never individual sweeps. The first
display boundary is fixed to `0`, the final boundary is fixed to `360000`, and
the sweeps are derived by subtraction. This prevents rounding drift while
preserving order and exact closure. Source boundaries must be finite,
monotonic, within `[0, sourceDomainSpan]`, and must end exactly at the declared
source span after source precision normalization. A projection that collapses
a required non-zero segment to zero millidegrees is invalid.

For a `365.25` equatorial system, source `0`, `182.625`, and `365.25` project to
display `0`, `180000`, and `360000`. No renderer is allowed to draw a
`365.25`-degree Canvas arc or change the display full-circle invariant.

## Angle Precision And Validation

Public double input is quantized to three decimal places at the adapter
boundary. Internal calculations use integer millidegrees:

```text
30.000 degrees = 30000
2.000 degrees  = 2000
full circle    = 360000
```

Top-level segments must total exactly `360000`. Children must total exactly
their parent's sweep. Both underflow and overflow are invalid. Quantization
prevents binary floating-point accumulation from creating false failures.

Validation occurs in two stages. Source-space validation checks closure against
the declared `sourceDomainSpan`; display-space validation checks the projected
partition against `360000`. Error reports include both source and display
values when projection is active.

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
| 3 | `star-sequence` | `starSeq12GongHeight` | `0` | optional equal 12; omitted when width is zero |
| 4 | `destiny-palaces` | `destiny12GongHeight` | `70` | equal 12 |
| 5 | `fate-star-orbit` | `lifeStarRingHeight` | `48` | continuous; independent track/body overlays |
| 6 | `constellations` | `starXiu28RingHeight` | `36` | 28 explicit mansions plus scale tick overlay |
| 7 | `basic-star-orbit` | `lifeStarRingHeight` | `48` | continuous; independent track/body overlays |
| 8 | `inner-shensha` | `innerShenShaHeight` | `90` | 12 palace content groups |
| 9 | `outer-shensha` | `outerShenShaHeight` | `90` | 12 palace content groups |
| 10 | `daxian-outer` | `DaXianRing.outerRadius - 16` | `16` | hierarchical 12 x variable slots; not connected |
| 11 | `daxian-inner` | `DaXianRing.outerRadius - 32` | `16` | hierarchical 12 x variable slots; not connected |

This is one center slot plus nine named model bands, of which the star-sequence
band is currently zero-width, plus two currently unconnected DaXian bands.
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
- a `365.25` source-domain fixture projects cumulative boundaries to an exact
  `360000` display circle without reordering or drift
- top-level underflow and overflow produce invalid rings
- child underflow and overflow identify the full parent path

### Theme And Interaction Tests

- light and dark YAML fixtures provide every required invalid-ring token
- a missing required token fails theme validation before painting
- invalid rings render the configured fill, border, and label roles without
  drawing invalid segment content
- track and body hit tests apply their own inverse rotations and remain isolated
  by `moduleId` plus `instanceId`

### QiZheng Calibration Tests

- every inventory row above has a named center, ring, or overlay equivalent;
  unconnected DaXian rows have fixture-backed adapter output
- inner, center, and outer radii match the Legacy reference within 0.5 pixels
- star guide anchors match the orbit inner edge
- displayed stars match the orbit centerline within 0.5 pixels
- track and body rotations can change independently without changing resolved
  ring radii or each other's transforms
- all rings remain visible at desktop, minimum mobile, dark theme, and rotation
- no non-background pixel touches the unexpected clipping boundary

### Evidence Rules

The real Legacy page or a frozen render artifact captured from it is the visual
reference. A test-local reconstruction of Legacy widgets cannot be presented
as parity evidence.

Canvas and Legacy screenshots must use the same domain snapshot, logical board
size, theme, and rotation. Geometry assertions accompany Golden tests so an
incorrect Golden cannot bless misplaced tracks.

## Migration Safety

The real Legacy renderer remains the default production fallback until the new
Canvas renderer passes ring inventory, geometry calibration, visual comparison,
interaction, responsive, Theme/YAML, and invalid-data tests. No Legacy code is
deleted during this migration.
