# Acceptance Package: Metaphysics Chart UI Package

## Scope

This package creates reusable chart-board UI infrastructure for circular Canvas, circular Widget, rectangular Canvas, and rectangular Widget renderers. It must support QiZhengSiYu, TaiYiShenShu, ZiWeiDouShu, DaLiuRen, and QiMenDunJia adapters without moving module business logic into package core.

## BDD Scenarios

### Scenario: Mixed QiZhengSiYu circular board can be modeled

- **GIVEN** a board contains a 12-sector palace layer, 360-degree tick layer, 28 non-uniform constellation arcs, and angle-positioned star items
- **WHEN** the adapter builds a `ChartBoard`
- **THEN** the circular layout engine resolves every layer
- **AND** no package core file imports QiZhengSiYu domain classes

### Scenario: QiZhengSiYu owns 365.25-to-360 normalization

- **GIVEN** a QiZhengSiYu equatorial source coordinate system spans `365.25`
- **WHEN** its adapter maps cumulative boundaries into display millidegrees
- **THEN** `0`, `182.625`, and `365.25` become `0`, `180000`, and `360000`
- **AND** the package receives normalized values only
- **AND** no package-core type or function accepts a source span or projection table

### Scenario: Zhu-Luo-San-Xian sparse arcs can be modeled

- **GIVEN** independently addressable overlays paint `0..60` and `58..72`
- **WHEN** the circular geometry is resolved
- **THEN** each overlay paints only its normalized sparse range
- **AND** blank angles remain transparent, non-interactive, and absent from semantics
- **AND** both overlays retain deterministic z-order and the ring retains its full radial allocation

### Scenario: `BoardCenterSpec` is not treated as a ring

- **GIVEN** Canvas, Widget, and hybrid center fixtures reserve the same radius
- **WHEN** the circular board resolves
- **THEN** each first ring starts at the center boundary
- **AND** center content has no angular partition or ring-coverage validation

### Scenario: Optional zero-width ring is skipped without losing identity

- **GIVEN** `star-sequence` is optional and has width zero
- **WHEN** geometry resolves
- **THEN** it retains its stable source-plan id and order as `SkippedRingGeometry(reason: zeroWidth)`
- **AND** it allocates no radius, paint, hit region, or semantics

### Scenario: Star track and body have independent transforms

- **GIVEN** track and body `RingOverlaySpec` values reference one continuous star-orbit ring
- **WHEN** either overlay rotates independently
- **THEN** the other overlay and shared ring radii remain unchanged
- **AND** Canvas and Widget hit testing apply the corresponding inverse transform

### Scenario: New-renderer failure atomically preserves Legacy

- **GIVEN** Legacy holds current selection, rotation, and module state
- **WHEN** geometry, strict-theme, hit-index, or renderer initialization fails before or immediately after activation
- **THEN** Legacy remains or is atomically restored before an empty/partial board is exposed
- **AND** selection, rotation, and module state remain unchanged
- **AND** retry waits for a new validation revision

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

### Scenario: YAML fallback protects optional rendering roles

- **GIVEN** a YAML theme omits optional renderer tokens
- **WHEN** the board renders
- **THEN** missing tokens use package fallback values
- **AND** the board remains visible and interactive

### Scenario: Production theme requires invalid-ring roles

- **GIVEN** a production YAML theme omits any required `invalidRing*` role
- **WHEN** strict theme validation runs
- **THEN** validation fails before painting and identifies the missing key
- **AND** no renderer silently substitutes a module-local color

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
  - absent, Canvas, Widget, and hybrid circular center fixtures
  - optional zero-width skip/enable ordering and required zero-width rejection
  - required zero-width is board-fatal rather than an invisible ring-local error
  - circular 12 equal sectors
  - circular 16 equal sectors
  - circular 360 ticks
  - circular 28 custom arcs
  - circular sparse partial arcs: single, disjoint, adjacent, and split wrap-around
  - sparse invalid inputs: overlap in one layer, zero sweep, out of range, and implicit wrap-around
  - sparse border/cap geometry and blank-angle hit/semantics exclusion
  - circular point layer (dual original/display angle + leader line)
  - rectangular 3x3 grid
  - rectangular 12 perimeter
  - arc-band hit region uses the filled wedge area, not the stroked draw path
  - dense reference board resolves pointer-move within the frame-time budget via spatial/angular index
  - independent track/body overlay rotation, shared radii, and inverse-transform hit testing
  - performance protocol uses deterministic seed, 5 x 1,000 warm-ups and 10 x 10,000 measured lookups; registered environment metadata is recorded, p95 is below 2 ms, and 128/256/512/1024 scaling slope is below `0.85`

- Adapter normalization tests:
  - QiZhengSiYu cumulative boundaries `0/182.625/365.25` map exactly to `0/180000/360000`
  - exact-half fixtures use the documented round-half-up rule identically on supported platforms
  - monotonic-boundary property tests preserve order and exact full closure
  - independently rounded sweeps are forbidden; sweeps are derived from mapped boundaries
  - sparse source ranges remain sparse after proportional mapping
  - non-finite, non-monotonic, out-of-range, invalid full-coverage closure, and collapsed-positive-segment inputs fail before package construction
  - package-core API scan finds no `sourceDomainSpan`, `365.25`, or projection callback

- Interaction tests:
  - hover hit-test
  - tap selection
  - focus movement
  - disabled region ignores selection
  - two board instances do not share state
  - composite star resolves any sub-primitive to one `ItemGroup` id
  - hybrid Canvas+widget overlay shares one selection through common hit ids
  - boundary probes at `b-1`, `b`, and `b+1` prove half-open ownership
  - split wrap-around fragments return one logical id and one semantics node
  - overlap tests cover equal priorities and disabled `block`/`passThrough`
  - round-cap protrusion and minimum-touch expansion create no blank-angle hit

- Theme tests:
  - fallback only
  - YAML full theme
  - YAML missing token fallback
  - strict production failure for each missing required invalid-ring token
  - module palette separation
  - instance override precedence
  - host `XuanThemeData.chartTokens` feed board as base tokens without core importing `package:theme`
  - each existing chart-style role maps to exactly one destination (core semantic / renderer token / module palette)

- Accessibility tests:
  - bounded semantics node count on the reference board (proportional to logical entities, not draw primitives)
  - non-interactive tick scale contributes no semantics nodes
  - every interactive sector exposes a label, selected/disabled state, and an activate action
  - split and overlapping sparse targets retain bounded deterministic traversal

- Validation severity tests:
  - malformed sparse coverage with valid radial allocation isolates one invalid ring and preserves neighbors
  - duplicate IDs, negative/non-finite width, and unresolved required theme schema are board-fatal

- Renderer conformance tests:
  - Canvas and Widget resolved integer geometry, IDs, transforms, hit results, and semantics ordering are exact
  - raster goldens use declared pixel and text-baseline tolerances rather than requiring byte equality across unlike primitives

## gStack Evidence Required

After implementation creates an example app, collect:

- Desktop screenshot showing all four renderers.
- Narrow/mobile screenshot showing all four renderers.
- Hover evidence for `CircularCanvasBoard`.
- Hover evidence for `RectGridCanvasBoard`.
- Tap/selected evidence for all four renderers.
- Hybrid Canvas+widget board evidence showing one consistent selection across the boundary.
- Theme/YAML switch evidence, including a host-token-fed board.
- Sparse arc evidence showing blank angles, overlap via ordered overlays, cap styles, hover, and selection in both circular renderers.
- Failure-injection evidence for geometry, strict-theme, hit-index, and renderer initialization proving Legacy remains visible and selection/rotation state is preserved.
- Evidence manifest keyed to commit SHA; omitting any required runtime artifact must fail production-readiness evaluation even when OpenSpec artifacts are complete.

Manifest gate:

```bash
dart run tool/verify_production_readiness.dart \
  --manifest openspec/changes/create-metaphysics-chart-ui-package/evidence/production-readiness-manifest.yaml \
  --expected-commit "$(git rev-parse HEAD)"
```

Expected: exit `0` only when schema v1, change id, exact commit, all unique
required evidence IDs, `passed` statuses, files, and SHA-256 hashes validate.

Required IDs are closed for schema v1:

```text
openspec-strict, p0-go-no-go, package-analyze, import-api-boundary, package-unit,
adapter-unit, theme-strict, geometry-goldens, renderer-conformance,
sparse-conformance, qizheng-legacy-parity, hit-performance,
accessibility-traversal, gstack-desktop, gstack-mobile, gstack-interaction,
rollback-failure-injection
```

Adding, removing, or renaming an ID requires a manifest schema-version change.
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
- `evidence/P0-go-no-go.md` mapping P0.1-P0.14 to concrete evidence and
  recording GO before P1 implementation begins.

## Residual Risk

- The public API stays at risk of being too broad until real read-only adapters for all five modules exercise it; until then it must be labeled experimental with a gate forbidding a second production migration.
- Theme ownership spans `package:theme` (host), the in-flight `QiZhengChartStyle`, and the package `BoardTheme`; the bridge must keep core free of `package:theme` and avoid a third parallel system.
- Canvas text measurement can drift between platforms and fonts; golden tests must use controlled fonts or documented tolerances.
- Rich Widget content cannot be rendered identically in Canvas; modules must choose Canvas for performance and Widget (or the hybrid composition) for complex content/accessibility.
- Perimeter geometry for ZiWei/DaLiuRen may reveal corner-specific rules that require refining `RectPerimeterLayoutEngine` before migration.
