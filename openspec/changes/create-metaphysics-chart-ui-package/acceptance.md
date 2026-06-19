# Acceptance Package: Metaphysics Chart UI Package

## Scope

This package creates reusable chart-board UI infrastructure for circular Canvas, circular Widget, rectangular Canvas, and rectangular Widget renderers. It must support QiZhengSiYu, TaiYiShenShu, ZiWeiDouShu, DaLiuRen, and QiMenDunJia adapters without moving module business logic into package core.

## BDD Scenarios

### Scenario: Mixed QiZhengSiYu circular board can be modeled

- **GIVEN** a board contains a 12-sector palace layer, 360-degree tick layer, 28 non-uniform constellation arcs, and angle-positioned star items
- **WHEN** the adapter builds a `ChartBoard`
- **THEN** the circular layout engine resolves every layer
- **AND** no package core file imports QiZhengSiYu domain classes

### Scenario: TaiYi 16-sector board can be modeled

- **GIVEN** a TaiYi-like board has 16 work positions
- **WHEN** it is rendered through `CircularCanvasBoard`
- **THEN** all 16 sectors are visible, clickable, and styled by the resolved theme

### Scenario: ZiWei perimeter board can be modeled

- **GIVEN** a ZiWei-like board has 12 palaces around a rounded rectangle
- **WHEN** it is rendered through `RectGridWidgetBoard` or a perimeter layout mode
- **THEN** all 12 cells keep stable ids and visible content slots

### Scenario: QiMen/DaLiuRen widget grid can be modeled

- **GIVEN** a board has grid cells with rich Row/Column content
- **WHEN** it is rendered through `RectGridWidgetBoard`
- **THEN** the module can provide rich palace/cell content without custom package-core code

### Scenario: Canvas hover changes visual state

- **GIVEN** an interactive Canvas board is visible on desktop
- **WHEN** the mouse pointer moves over a sector/cell
- **THEN** the hovered region changes fill, stroke, or shadow within one frame
- **AND** moving out clears the hover state

### Scenario: Canvas tap selects a region

- **GIVEN** an interactive Canvas board is visible
- **WHEN** the user taps or clicks a region
- **THEN** the board reports the stable region id
- **AND** selected styling remains until selection is cleared or changed

### Scenario: YAML fallback protects rendering

- **GIVEN** a YAML theme omits optional tokens
- **WHEN** the board renders
- **THEN** missing tokens use package fallback values
- **AND** the board remains visible and interactive

### Scenario: Multiple module instances do not leak state

- **GIVEN** two boards with different `instanceId` values are displayed
- **WHEN** the user selects a region on one board
- **THEN** the other board does not change selected or hovered state

### Scenario: A star behaves as one entity

- **GIVEN** a star drawn as guide dot, leader line, holder dot, name, and annotations
- **WHEN** the user taps any of those primitives
- **THEN** the board reports the single star group id
- **AND** the screen reader announces one labeled node for the star

### Scenario: Hybrid board keeps Canvas and widget selection consistent

- **GIVEN** a board paints rings on Canvas and hosts interactive star badges as overlay widgets
- **WHEN** the user selects a star via the widget badge
- **THEN** the Canvas base and the widget overlay reflect the same selected id through the shared controller

## Test/CI Gates

- `flutter analyze` for the new package.
- `flutter test` for package unit/golden tests.
- Import-boundary scan (allow-list enforced; the deny pattern below is a fast pre-check):

```bash
rg -n "package:(qizhengsiyu|qimendunjia|daliuren|ziwei|taiyishenshu|metaphysics_core|theme|xuan_config)" ../metaphysics-chart-ui/lib/src/core ../metaphysics-chart-ui/lib/src/layouts ../metaphysics-chart-ui/lib/src/renderers
```

Expected: no matches. The authoritative gate is an allow-list test that fails on any import outside Flutter, `dart:ui`, `dart:math`, `yaml`, and named utilities; `package:metaphysics_core` (business enums), `package:theme`, and `package:xuan_config` are explicitly forbidden in core/layouts/renderers.

- Identifier scan:

```bash
rg -n "xuan_|xuan-" ../metaphysics-chart-ui/pubspec.yaml ../metaphysics-chart-ui/lib ../metaphysics-chart-ui/test
```

Expected: no program identifier matches. Directory/Git URL references, if any, must be explicitly reviewed.

- Geometry tests:
  - circular 12 equal sectors
  - circular 16 equal sectors
  - circular 360 ticks
  - circular 28 custom arcs
  - circular point layer (dual original/display angle + leader line)
  - rectangular 3x3 grid
  - rectangular 12 perimeter
  - arc-band hit region uses the filled wedge area, not the stroked draw path
  - dense reference board resolves pointer-move within the frame-time budget via spatial/angular index

- Interaction tests:
  - hover hit-test
  - tap selection
  - focus movement
  - disabled region ignores selection
  - two board instances do not share state
  - composite star resolves any sub-primitive to one `ItemGroup` id
  - hybrid Canvas+widget overlay shares one selection through common hit ids

- Theme tests:
  - fallback only
  - YAML full theme
  - YAML missing token fallback
  - module palette separation
  - instance override precedence
  - host `XuanThemeData.chartTokens` feed board as base tokens without core importing `package:theme`
  - each existing chart-style role maps to exactly one destination (core semantic / renderer token / module palette)

- Accessibility tests:
  - bounded semantics node count on the reference board (proportional to logical entities, not draw primitives)
  - non-interactive tick scale contributes no semantics nodes
  - every interactive sector exposes a label, selected/disabled state, and an activate action

## gStack Evidence Required

After implementation creates an example app, collect:

- Desktop screenshot showing all four renderers.
- Narrow/mobile screenshot showing all four renderers.
- Hover evidence for `CircularCanvasBoard`.
- Hover evidence for `RectGridCanvasBoard`.
- Tap/selected evidence for all four renderers.
- Hybrid Canvas+widget board evidence showing one consistent selection across the boundary.
- Theme/YAML switch evidence, including a host-token-fed board.
- Hit-test performance-budget evidence for the dense reference board.
- Accessibility evidence: a bounded-node semantics traversal for the reference board (interactive sectors labeled, tick scale excluded), not a generic smoke check.

## ZenTao Task Breakdown

No ZenTao update is required by this OpenSpec change unless the user assigns it to a ZenTao requirement/task. If ZenTao sync is requested for this change, publish only the scoped summary:

- Coding task: package scope, public contracts, renderer tasks, risks.
- BDD/acceptance task: scenarios and gStack evidence requirements.
- Test task: geometry, hit-test, theme, golden, and import-boundary gates.

## Evidence Required

- OpenSpec change id: `create-metaphysics-chart-ui-package`.
- OpenSpec files:
  - `proposal.md`
  - `design.md`
  - `tasks.md`
  - `specs/metaphysics-chart-ui/spec.md`
  - `acceptance.md`
- SuperPowers implementation plan:
  - `docs/superpowers/plans/2026-06-19-metaphysics-chart-ui-package.md`
- gStack evidence directory after implementation.
- External AI risk review notes before implementation starts.

## Residual Risk

- The public API stays at risk of being too broad until real read-only adapters for all five modules exercise it; until then it must be labeled experimental with a gate forbidding a second production migration.
- Theme ownership spans `package:theme` (host), the in-flight `QiZhengChartStyle`, and the package `BoardTheme`; the bridge must keep core free of `package:theme` and avoid a third parallel system.
- Canvas text measurement can drift between platforms and fonts; golden tests must use controlled fonts or documented tolerances.
- Rich Widget content cannot be rendered identically in Canvas; modules must choose Canvas for performance and Widget (or the hybrid composition) for complex content/accessibility.
- Perimeter geometry for ZiWei/DaLiuRen may reveal corner-specific rules that require refining `RectPerimeterLayoutEngine` before migration.
