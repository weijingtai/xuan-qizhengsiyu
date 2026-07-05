## ADDED Requirements

### Requirement: Annual results are projected into contiguous visits

The system SHALL project the selected algorithm's deduplicated `ZhuLuoYearResult` sequence into immutable contiguous visits without recalculating Zhu Luo rules.

#### Scenario: Consecutive years remain one visit
- **WHEN** adjacent records have the same stage, ruler, palace, phase, bridge state, and consecutive ages
- **THEN** they SHALL become one visit with an inclusive age range

#### Scenario: Semantic change starts another visit
- **WHEN** stage, ruler, palace, phase, bridge state, or age continuity changes
- **THEN** the system SHALL start a new visit

#### Scenario: Projection preserves annual records
- **WHEN** the projector receives a calculator annual-result sequence
- **THEN** it SHALL create exactly one annual cell per input record
- **AND** it MUST NOT re-deduplicate, synthesize missing years, or call Zhu Luo duration/number rule helpers

### Requirement: Stage groups and repeat tracks have deterministic order

The UI SHALL render initial, middle, and final groups from the center outward, and SHALL insert repeat tracks immediately outside their owning stage's first track.

#### Scenario: Initial stage repeats before middle stage
- **WHEN** the initial stage has a second-visit track
- **THEN** radial order SHALL place it before the middle stage's first track

#### Scenario: Repeat track remains sparse
- **WHEN** only one palace has a second visit
- **THEN** the second-visit track SHALL paint only that palace
- **AND** all other palace sectors on that track SHALL remain transparent and non-interactive

### Requirement: A palace visit is divided into annual cells

Every contiguous visit SHALL occupy only its palace's 30-degree sector, divided into one equal angular cell per annual record.

#### Scenario: Four-year hold
- **WHEN** one visit covers four annual records
- **THEN** the palace SHALL contain four cells of 7.5 degrees each
- **AND** no cell SHALL cross the palace boundary
- **AND** the sum of all cell sweeps SHALL equal exactly 30 degrees within the chosen geometry tolerance
- **AND** the final cell SHALL end at the palace boundary

#### Scenario: One-year visit
- **WHEN** one visit contains one annual record
- **THEN** its cell SHALL occupy the complete 30-degree palace sector on that visit track

### Requirement: Repeated visits remain distinct

The UI MUST NOT merge, overwrite, or angularly concatenate separate visits to the same palace within one stage.

#### Scenario: Palace is entered three times
- **WHEN** one stage enters the same palace in three non-contiguous visits
- **THEN** they SHALL appear on visit tracks 1, 2, and 3
- **AND** each visit SHALL retain its own age range and hit regions

### Requirement: Label density is user-selectable

The UI SHALL support range-only, all-cell, and automatic age-label modes while preserving identical annual-cell geometry and interaction.

#### Scenario: Default range-only mode
- **WHEN** a multi-year visit renders at normal scale
- **THEN** the UI SHALL show one inclusive age-range label
- **AND** unlabeled annual cells SHALL remain visible and interactive

#### Scenario: User enables all-cell labels
- **WHEN** all-cell mode is selected and labels fit
- **THEN** every annual cell SHALL show its age

#### Scenario: Automatic mode is zoomed
- **WHEN** automatic mode crosses its zoom or available-sweep threshold
- **THEN** the UI SHALL switch to individual ages without rebuilding cell geometry

### Requirement: Movement phases remain distinguishable

The UI SHALL preserve hold, inverse jump, direct movement, bridge, and stage-transition semantics.

#### Scenario: A-style inverse jump
- **WHEN** an inverse transition moves to a non-adjacent palace
- **THEN** a jump connector SHALL link source and destination
- **AND** skipped palace sectors SHALL remain blank

#### Scenario: B-style bridge
- **WHEN** annual records have `usedBridge == true`
- **THEN** they SHALL remain annual cells in their actual palaces
- **AND** they SHALL use the bridge style role rather than a jump connector

#### Scenario: Shared transition age
- **WHEN** an annual result has `isTransitionYear == true`
- **THEN** exactly one annual cell SHALL represent that age
- **AND** an inter-stage marker SHALL communicate transition without duplicating it

### Requirement: Styling is theme-driven

The UI SHALL resolve colors and strokes from semantic roles, and annual separators SHALL use a low-emphasis divider rather than black.

#### Scenario: Light theme annual cells
- **WHEN** annual cells render in the light theme
- **THEN** separators SHALL use the resolved low-emphasis divider
- **AND** Zhu Luo presentation code SHALL not hard-code black or ARGB colors

#### Scenario: Semantic roles are consumed
- **WHEN** two otherwise identical ring plans differ only by initial/middle/final/bridge semantic role
- **THEN** the resolved segment or painter output SHALL differ according to that role
- **AND** the test SHALL fail if the renderer ignores the role

#### Scenario: Non-color affordances
- **WHEN** bridge cells, repeated tracks, jumps, or transition markers render
- **THEN** they SHALL use at least one non-color distinction such as dashes, hatching, edge ticks, marker shape, or stroke pattern

#### Scenario: Dark theme annual cells
- **WHEN** annual cells render in the dark theme
- **THEN** separators, labels, bridges, jumps, and transition markers SHALL remain visible without relying on light-theme colors

### Requirement: Every annual cell remains inspectable

Each annual cell SHALL have a stable logical ID and payload containing age, stage, ruler, palace, phase, algorithm ID, bridge state, and transition state.

#### Scenario: User selects an unlabeled cell
- **WHEN** a user selects a cell whose visible label is suppressed
- **THEN** the detail surface SHALL expose the complete payload

#### Scenario: Small cells remain selectable
- **WHEN** a visit produces small angular cells on an inner track
- **THEN** the user SHALL be able to select the relevant year through hit slop, visit-first disambiguation, zoom-on-touch, or an equivalent forgiving interaction

#### Scenario: Linear fallback exposes the same sequence
- **WHEN** the ring plan is available
- **THEN** the UI SHALL expose a linear annual-path representation with age, stage, palace, phase, bridge state, jump state, and transition state
- **AND** the linear representation SHALL derive from the same immutable plan as the ring

### Requirement: Renderer is independent of algorithm identity

The renderer SHALL consume selected annual results and MUST NOT branch for A, B, or user-defined algorithm IDs.

#### Scenario: User-defined algorithm
- **WHEN** a user-defined algorithm supplies valid annual records
- **THEN** the common projection and rendering pipeline SHALL display them
- **AND** no renderer modification SHALL be required

### Requirement: Production integration is reversible

Production integration SHALL remain behind a default-off feature flag until evidence passes, and SHALL not delete or modify legacy DaXian behavior.

#### Scenario: Feature is disabled
- **WHEN** the feature flag is off
- **THEN** current production board composition SHALL remain unchanged

#### Scenario: Radial budget is insufficient
- **WHEN** repeat tracks cannot satisfy minimum width
- **THEN** production enablement SHALL fail visibly
- **AND** the UI MUST NOT silently omit repeated visits
