# metaphysics-chart-ui Specification

## ADDED Requirements

### Requirement: Package provides a neutral chart-board model

The chart UI package SHALL expose a neutral `ChartBoard` model that represents chart-board layout, layers, sectors/cells, items, theme identity, interaction configuration, module ownership, and instance identity without depending on any consuming module's domain model.

#### Scenario: QiZhengSiYu data maps through an adapter

- **GIVEN** QiZhengSiYu has panel, ring, star, and constellation data
- **WHEN** the QiZhengSiYu adapter builds a `ChartBoard`
- **THEN** package core receives only neutral board data
- **AND** package core does not import `package:qizhengsiyu`

#### Scenario: Module instance identity is preserved

- **GIVEN** two boards from the same module are visible at the same time
- **WHEN** a user selects a region on one board
- **THEN** only that board's `instanceId` and interaction controller update
- **AND** the other board keeps its own hover and selected state

#### Scenario: Validation severity preserves only trustworthy geometry

- **GIVEN** duplicate stable IDs, negative/non-finite radial allocation, or unresolved required theme schema
- **WHEN** board validation runs
- **THEN** validation is board-fatal and no guessed geometry is painted
- **GIVEN** instead one partition or sparse coverage is invalid but its radial allocation is valid
- **WHEN** board validation runs
- **THEN** only that ring becomes the invalid-ring annulus
- **AND** neighboring rings retain geometry and interaction while invalid content emits no hit regions or semantics

### Requirement: Circular center content is independent from rings

The package SHALL model circular center content as `BoardCenterSpec`, not as a
ring or partition. Its radius SHALL establish the first ring's inner boundary
and its Canvas, Widget, or hybrid content SHALL use the board's shared instance,
interaction, semantics, clipping, and paint-envelope contracts.

#### Scenario: Center variants preserve the first ring boundary

- **GIVEN** absent, Canvas, Widget, and hybrid center fixtures with the same configured radius
- **WHEN** circular geometry is resolved
- **THEN** the first ring begins at that radius for every non-absent fixture
- **AND** an absent center reserves zero radius
- **AND** center content participates in no angular coverage validation

### Requirement: Optional zero-width rings preserve source identity

An optional ring with zero width SHALL remain identifiable in source-plan order
but SHALL resolve as a skipped entry that allocates no radius and emits no paint,
hit region, or semantics. A required zero-width ring SHALL be board-fatal
because no trustworthy radial band exists for an invalid-ring annulus.

#### Scenario: Optional ring can be enabled without losing order

- **GIVEN** an optional zero-width `star-sequence` ring between two positive-width rings
- **WHEN** the plan resolves
- **THEN** it produces `SkippedRingGeometry(reason: zeroWidth)` with its stable id
- **AND** the adjacent positive-width boundaries remain continuous
- **WHEN** its width becomes positive
- **THEN** it resolves at the same source-plan position

### Requirement: Composite marks are single addressable entities

The package SHALL represent a mark composed of multiple primitives (such as a
star drawn as guide dot, leader line, holder dot, name, and annotations) as one
logical entity with a single id and at most one semantics node. A contiguous
mark normally has one hit region; one logical target MAY own multiple hit-region
fragments when its declared coverage is disjoint or split across zero.

#### Scenario: Star group resolves to one logical id

- **GIVEN** a star is rendered as several draw primitives grouped under one logical id
- **WHEN** the user hovers or taps any primitive of that star
- **THEN** the interaction controller reports the star's group id, not a sub-primitive id
- **AND** the board exposes at most one semantics node for that star

#### Scenario: Split sparse fragments retain one logical identity

- **GIVEN** one logical interval is represented by `[350000,360000)` and `[0,20000)`
- **WHEN** either geometry fragment is tapped or focused
- **THEN** both resolve to the same logical target id and selection state
- **AND** semantics traversal exposes at most one node for the target

### Requirement: Circular layouts support full and sparse coverage

The circular layout engine SHALL support equal sector rings, non-uniform custom
arc rings, configurable tick rings, angle-positioned point/item layers, and
explicit full-circle or sparse partial-arc coverage in the same board. It SHALL
consume integer display millidegrees only and SHALL NOT project source-domain
coordinate systems.

#### Scenario: QiZhengSiYu mixed circular board resolves geometry

- **GIVEN** a board has a 12-sector palace layer, a 360-tick layer, a 28-custom-arc constellation layer, and an angle-positioned star layer
- **WHEN** the circular layout engine resolves geometry
- **THEN** every layer has deterministic paths or anchors
- **AND** every interactive layer has hit regions

#### Scenario: Angle-positioned star carries original and display angle

- **GIVEN** a star item with an original (pre-collision) angle and a resolved display (post-collision) angle
- **WHEN** the circular layout engine resolves the point layer
- **THEN** the inner guide dot anchors at the original angle and the outer holder anchors at the display angle
- **AND** a leader line connects the two anchors
- **AND** the package does not compute the collision adjustment itself

#### Scenario: TaiYi 16-sector board resolves geometry

- **GIVEN** a TaiYi-like circular board has 16 equal sectors
- **WHEN** the circular layout engine resolves geometry
- **THEN** the sectors occupy the full circle according to the configured start angle and direction

#### Scenario: QiZhengSiYu adapter normalizes 365.25 before package entry

- **GIVEN** QiZhengSiYu owns source boundaries `0`, `182.625`, and `365.25`
- **WHEN** its consuming adapter builds package circular geometry
- **THEN** the adapter supplies display boundaries `0`, `180000`, and `360000`
- **AND** it uses three-decimal source fixed point, integer rational arithmetic, and round-half-up on each shared cumulative boundary exactly once
- **AND** invalid full-coverage source closure, ordering, range, finiteness, or collapsed positive segments fail before package construction
- **AND** sparse source ranges require no aggregate closure and preserve their gaps
- **AND** package core receives no source span, mapping table, or projection callback
- **AND** full-circle validation is performed only against normalized `360000`

#### Scenario: Sparse partial arc leaves the rest of the ring blank

- **GIVEN** a ring reserves one radial band and declares sparse ranges `[0,60000)` and `[58000,72000)` on separate overlays
- **WHEN** the circular layout engine resolves geometry
- **THEN** each overlay paints only its declared range without expanding to a full circle
- **AND** the complete radial band remains reserved for ring ordering
- **AND** blank angles produce no hit region or semantics node

#### Scenario: Same-layer sparse input has deterministic validity

- **GIVEN** sparse ranges use half-open normalized millidegree boundaries
- **WHEN** ranges are disjoint or adjacent
- **THEN** they resolve without automatic merging
- **WHEN** ranges overlap, have zero sweep, leave `0..360000`, or encode wrap-around with `start > end`
- **THEN** the owning ring is invalid and package validation does not repair it
- **AND** valid wrap-around is represented by two explicit ranges

#### Scenario: Intentional partial-arc overlap uses overlays

- **GIVEN** Zhu-Luo-San-Xian needs independently addressable overlapping angular intervals
- **WHEN** the adapter creates separate overlays with explicit `zIndex`
- **THEN** paint order, hit-test priority, and semantics ownership follow overlay order
- **AND** Canvas and Widget renderers resolve the same paths, cap geometry, and logical ids
- **AND** paint order is `(zIndex, declarationOrder)`
- **AND** hit order is `(hitPriority, zIndex, declarationOrder)` with the declared disabled block/pass-through policy
- **AND** round-cap protrusion is paint-only and does not create blank-angle hit or semantics coverage
- **AND** exactly one `owner(targetId, semanticsOrder)` creates the logical semantics node
- **AND** the owner exclusively supplies role, primary label, selected/disabled state, and activate action
- **AND** `merge(targetId)` appends description fragments in declaration order and uniquely keyed non-activate actions without creating a node
- **AND** missing/duplicate owners, duplicate action IDs, or merge overrides of owner fields fail validation

#### Scenario: Track and body `RingOverlaySpec` values rotate independently on one ring

- **GIVEN** one continuous star-orbit ring with track and body overlays
- **WHEN** track rotation changes while body rotation remains fixed
- **THEN** only track geometry and hit transforms change
- **WHEN** body rotation changes while track rotation remains fixed
- **THEN** only body geometry and hit transforms change
- **AND** both overlays retain the same resolved ring radii and stable logical ids

### Requirement: Rectangular layouts support matrix grid and rounded perimeter boards

The rectangular layout engines SHALL support matrix grids and rounded-rectangle perimeter boards as separate layout families.

#### Scenario: QiMen matrix board renders through grid layout

- **GIVEN** a QiMen-like board has nine cells in a 3x3 matrix
- **WHEN** `RectGridWidgetBoard` renders it
- **THEN** each palace/cell receives its configured content slots
- **AND** selection callbacks report stable cell ids

#### Scenario: ZiWei perimeter board renders through perimeter layout

- **GIVEN** a ZiWei-like board has 12 palace cells around a rounded rectangle
- **WHEN** the perimeter layout engine resolves geometry
- **THEN** all twelve cells are assigned stable perimeter slots
- **AND** corner cells respect the configured corner radius

### Requirement: Package provides four renderer families

The package SHALL provide `CircularCanvasBoard`, `CircularWidgetBoard`, `RectGridCanvasBoard`, and `RectGridWidgetBoard`.

#### Scenario: Same circular data can use Canvas or Widget rendering

- **GIVEN** a circular `ChartBoard`
- **WHEN** it is rendered by both circular renderers
- **THEN** both renderers use the same layer order, geometry ids, and interaction controller semantics

#### Scenario: Same rectangular data can use Canvas or Widget rendering

- **GIVEN** a rectangular `ChartBoard`
- **WHEN** it is rendered by both rectangular renderers
- **THEN** both renderers report the same hit region ids for the same logical cells

### Requirement: Package supports hybrid Canvas and Widget composition

The package SHALL allow a single board to mix Canvas-painted layers and Widget-hosted overlay items positioned through the same geometry, sharing one interaction controller and one set of hit-region ids.

#### Scenario: QiZhengSiYu board mixes Canvas rings and widget star badges

- **GIVEN** a board declares Canvas-painted ring/tick/arc layers and Widget-hosted interactive star items
- **WHEN** the hybrid composition renders
- **THEN** each overlay widget is positioned on its painted geometry anchor
- **AND** hover and selection use the same hit-region ids across the Canvas base and the widget overlay

#### Scenario: Mirror-image rings differ only by behavior data

- **GIVEN** an inner-life ring and an outer-life ring that differ only in radius anchor and annotation side
- **WHEN** both are expressed as the same layer type with different `behavior` parameters
- **THEN** both produce the same hit-region ids for the same logical stars
- **AND** no renderer-internal branch is required to tell the two rings apart

### Requirement: Canvas renderers support interaction through geometry hit testing

Canvas renderers SHALL handle hover, tap, selection, pressed, focus, and disabled states by wrapping `CustomPaint` with pointer/focus widgets and hit-testing against `BoardHitRegion`.

#### Scenario: Hovering circular Canvas region updates visual state

- **GIVEN** a circular Canvas board has interactive sector regions
- **WHEN** the mouse pointer moves over a sector
- **THEN** the interaction controller records that sector as hovered
- **AND** the painter renders the configured hover fill, stroke, or shadow

#### Scenario: Tapping rectangular Canvas cell selects it

- **GIVEN** a rectangular Canvas board has interactive cells
- **WHEN** the user taps a cell
- **THEN** the interaction controller selects the cell id
- **AND** the painter renders selected-state styling

#### Scenario: Arc and tick hit regions use filled closed geometry

- **GIVEN** a 28-arc constellation band painted as a stroked arc and a 360-tick scale painted as lines
- **WHEN** hit regions are generated
- **THEN** an arc hit region is a filled, closed annular wedge, not the stroked draw path
- **AND** tick scales default to non-interactive, and when interactive are resolved by angular bucket rather than by point-in-line testing

#### Scenario: Dense board hit-test stays within budget

- **GIVEN** a versioned `BenchmarkTargetProfile` records hardware, OS, Flutter/Dart versions, build mode, and seed
- **AND** the reference board has a 12-sector layer, a 360-tick layer, a 28-arc layer, and around eleven star groups
- **WHEN** the documented profile/release benchmark runs deterministic seeded positions after 5 x 1,000 warm-ups for 10 x 10,000 measured lookups
- **THEN** hit-test resolution uses a spatial or angular index
- **AND** p95 is below 2 ms on the registered target whose hardware, OS, Flutter/Dart versions, build mode, and seed are recorded
- **AND** the 128/256/512/1024-region matrix has fitted log-log lookup-time slope below `0.85`
- **AND** only an exact versioned target-profile match can produce passing performance evidence
- **AND** unregistered environments are informational and require reviewed re-registration plus a full rerun before gating
- **AND** consumers cannot raise the mandatory indexing threshold above 64, though implementations may index earlier

### Requirement: Theme and YAML resolution are deterministic

The package SHALL provide ThemeExtension and YAML-driven token loading with deterministic fallback and precedence.

#### Scenario: Missing optional YAML token falls back

- **GIVEN** a YAML theme omits an optional renderer token
- **WHEN** the theme is resolved
- **THEN** the missing token uses the package fallback
- **AND** rendering does not throw

#### Scenario: Missing required invalid-ring token fails strict validation

- **GIVEN** a production YAML theme omits `invalidRingFill`, `invalidRingBorder`, `invalidRingLabel`, or `invalidRingBorderWidth`
- **WHEN** the theme is resolved in strict production mode
- **THEN** theme validation fails before painting with the missing semantic key
- **AND** no renderer substitutes a module-local color

#### Scenario: Module palette does not become semantic UI color

- **GIVEN** a module defines business/cultural palette keys
- **WHEN** renderer semantic colors are resolved
- **THEN** semantic UI tokens and module palette tokens remain separate objects
- **AND** package core does not require module enums

#### Scenario: Geometry cannot bypass theme resolution with literal colors

- **GIVEN** package geometry, layer, ring-border, and item-style public contracts
- **WHEN** architecture/API tests inspect their fields and serialized fixtures
- **THEN** styling is represented only by semantic role or token keys
- **AND** no contract accepts Flutter `Color`, ARGB integers, or hex color strings
- **AND** renderers never interpret opaque metadata as styling
- **AND** concrete colors appear only in `ResolvedBoardTheme`

#### Scenario: Host theme tokens supply base tokens without coupling core

- **GIVEN** a board runs inside the host where `XuanThemeData.chartTokens` provides chart tokens
- **WHEN** the host adapter feeds those tokens to the board as base tokens
- **THEN** the resolved theme honors them at the base-tokens precedence slot
- **AND** package core does not import `package:theme`
- **AND** a standalone board with no host tokens resolves from the package YAML/fallback instead

### Requirement: Canvas accessibility is bounded and grouped

The package SHALL expose accessibility semantics that are chosen independently of hit-testing, collapse composite marks to single nodes, and follow a deterministic traversal order, so that Canvas boards do not emit unbounded nodes and do not regress current widget accessibility.

#### Scenario: Tick scale is excluded from semantics

- **GIVEN** a board has an interactive 12-sector layer and a non-interactive 360-tick layer
- **WHEN** the semantics tree is built
- **THEN** each interactive sector has one labeled semantics node
- **AND** the 360 ticks contribute no semantics nodes
- **AND** the total node count is bounded by the number of logical entities, not by the number of draw primitives

### Requirement: Package boundary forbids module-domain imports in core

The package core SHALL restrict its imports to an explicit allow-list (Flutter, `dart:ui`, `dart:math`, `yaml`, and named pure-Dart utilities) so that no consuming module package, shared business-enum package, or host theme package can leak into core, layouts, or renderers.

#### Scenario: Allow-list scan rejects business-enum package

- **GIVEN** package core, layouts, and renderers are scanned against the import allow-list
- **WHEN** production readiness is claimed
- **THEN** there are no imports for `package:qizhengsiyu`, `package:qimendunjia`, `package:daliuren`, `package:ziwei`, or `package:taiyishenshu`
- **AND** there is no import for `package:metaphysics_core`, `package:theme`, or `package:xuan_config`
- **AND** any import outside the allow-list fails the scan

#### Scenario: Adapter layer may import module and enum packages

- **GIVEN** an adapter file outside `lib/src/core`, `lib/src/layouts`, and `lib/src/renderers`
- **WHEN** the import boundary scan runs
- **THEN** the adapter may import `package:metaphysics_core` and its own module models
- **AND** core source remains free of those imports

### Requirement: Visual migration is protected by tests and gStack evidence

Migration from existing module UI SHALL be protected by geometry tests, hit-test tests, golden tests, and gStack/browser-visible evidence before production replacement.

#### Scenario: QiZhengSiYu layer migration has parity evidence

- **GIVEN** a QiZhengSiYu layer is migrated to the new package
- **WHEN** the migration is proposed for user-facing replacement
- **THEN** a golden or documented visual comparison exists
- **AND** any difference is approved as an intentional visual change

#### Scenario: Four renderer demos have gStack evidence

- **GIVEN** the package example app exists
- **WHEN** production readiness is claimed
- **THEN** gStack/browser QA evidence includes screenshots and interaction checks for all four renderers

### Requirement: QiZhengSiYu activation is atomic and reversible

QiZhengSiYu SHALL keep Legacy as the production renderer until the new board is
fully initialized for the current instance. Activation SHALL transfer only
normalized render state and SHALL be reversible without recalculation or loss
of module state.

#### Scenario: Initialization failure retains Legacy

- **GIVEN** Legacy is active with current selection and rotation state
- **WHEN** geometry, strict-theme, hit-index, or renderer initialization fails before activation
- **THEN** the new board is not mounted as active
- **AND** Legacy remains visible with the same selection, rotation, and module state
- **AND** one structured failure is emitted for the current instance

#### Scenario: Failure after mount atomically restores Legacy

- **GIVEN** the new board is active and a guarded runtime initialization dependency fails
- **WHEN** the host activation controller handles the failure
- **THEN** it atomically restores Legacy before exposing an empty or partial board
- **AND** selection, rotation, and module state are transferred unchanged
- **AND** retry requires a new validation revision rather than an automatic render loop
