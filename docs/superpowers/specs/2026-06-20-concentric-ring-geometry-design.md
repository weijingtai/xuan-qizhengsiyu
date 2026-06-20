# Concentric Ring Geometry Design

## Status

Approved through the Superpowers brainstorming workflow on 2026-06-20.

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
4. Angles use integer millidegrees internally. One full circle is `360000`.
5. Invalid data affects only its owning ring and never shifts adjacent rings.
6. The package remains module-neutral. Submodules own content, instance state,
   domain adapters, and user-facing error presentation.

## Core Model

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

## QiZheng Migration

The current `QiZhengSiYuPanSizeDataModel` mixes diameters, radii, radial widths,
and derived sizes. It remains available only as a Legacy input during
migration. It is not a package contract.

`QiZhengLegacyRingPlanAdapter` converts the Legacy values once into named
absolute-width rings. All subsequent geometry uses the new model.

The migration must inventory every Legacy ring, including rings omitted by the
four-layer Canvas prototype. The expected set includes center content,
12-palace rings, constellation and degree rings, inner and outer star orbits,
ShenSha rings, and nested DaYun/LiuNian content. The inventory may exceed ten
rings and must be derived from the real Legacy composition rather than a test
copy.

## Theme And Instance Ownership

Geometry references semantic style roles only. Theme/YAML resolves normal,
hovered, selected, disabled, and invalid-ring styles.

Validation, interaction, and notification state is keyed by both `moduleId`
and `instanceId`. Two boards from the same or different submodules cannot share
hover, selection, validation, or Toast-deduplication state accidentally.

## Testing And Acceptance

### Geometry Tests

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
- top-level underflow and overflow produce invalid rings
- child underflow and overflow identify the full parent path

### QiZheng Calibration Tests

- every Legacy ring has a named new-plan equivalent
- inner, center, and outer radii match the Legacy reference within 0.5 pixels
- star guide anchors match the orbit inner edge
- displayed stars match the orbit centerline within 0.5 pixels
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
