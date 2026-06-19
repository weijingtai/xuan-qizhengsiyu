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

### Requirement: Composite marks are single addressable entities

The package SHALL represent a mark composed of multiple primitives (such as a star drawn as guide dot, leader line, holder dot, name, and annotations) as one logical entity with a single id, a single hit region, and a single semantics node.

#### Scenario: Star group resolves to one logical id

- **GIVEN** a star is rendered as several draw primitives grouped under one logical id
- **WHEN** the user hovers or taps any primitive of that star
- **THEN** the interaction controller reports the star's group id, not a sub-primitive id
- **AND** the board exposes at most one semantics node for that star

### Requirement: Circular layouts support equal sectors, custom arcs, ticks, and points

The circular layout engine SHALL support equal sector rings, non-uniform custom arc rings, configurable tick rings, and angle-positioned point/item layers in the same board.

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

- **GIVEN** the reference board has a 12-sector layer, a 360-tick layer, a 28-arc layer, and around eleven star groups
- **WHEN** the pointer moves over the board
- **THEN** hit-test resolution uses a spatial or angular index
- **AND** per pointer-move resolution stays within the documented frame-time budget

### Requirement: Theme and YAML resolution are deterministic

The package SHALL provide ThemeExtension and YAML-driven token loading with deterministic fallback and precedence.

#### Scenario: Missing YAML token falls back

- **GIVEN** a YAML theme omits a renderer token
- **WHEN** the theme is resolved
- **THEN** the missing token uses the package fallback
- **AND** rendering does not throw

#### Scenario: Module palette does not become semantic UI color

- **GIVEN** a module defines business/cultural palette keys
- **WHEN** renderer semantic colors are resolved
- **THEN** semantic UI tokens and module palette tokens remain separate objects
- **AND** package core does not require module enums

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
