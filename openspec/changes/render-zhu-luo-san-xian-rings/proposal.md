## Why

The existing DaXian ring assumes continuous full-circle allocation by palace. Zhu Luo San Xian is instead a sparse chronological path with holds, palace jumps, repeated palace visits, bridges, and overlapping stage transitions. A dedicated UI projection is required so these meanings are not forced into Dong Wei geometry.

## What Changes

- Project `ZhuLuoYearResult` records into contiguous visit segments and transition edges.
- Render three semantic stage groups from the center outward: initial, middle, and final limit.
- Insert sparse repeat-visit tracks immediately outside the owning stage's first-visit track.
- Divide each occupied 30-degree palace sector into one light-colored cell per year of that visit.
- Show one age-range label by default; retain user-selectable all-cell labels when zoom or space permits.
- Distinguish hold, inverse jump, direct movement, bridge, and stage transition without changing calculation.
- Keep algorithm selection outside the renderer; built-in and user-defined algorithms use one pipeline.

## Capabilities

### New Capabilities

- `zhu-luo-san-xian-ring-ui`: Sparse multi-track projection, geometry, rendering, interaction, and validation for Zhu Luo annual results.

### Modified Capabilities

None.

## Impact

- Affects the QiZheng Zhu Luo UI projection, circular board adapter, ring composition, style tokens, display preferences, and tests.
- Reuses `metaphysics_chart_ui` public `ArcLayer`, `ArcSegment`, circular geometry, theme, hit testing, and Canvas renderer APIs.
- Does not change `calculateZhuLuoSanXian`, A/B configuration, persistence, Dong Wei DaXian, FeiXian, or XiaoXian.
- The current circular `OverlayLayer` cannot render connectors; jump and transition connectors remain QiZheng-owned unless a separate chart-ui capability is approved.

## Goals

- Preserve stage, palace, age, visit order, phase, bridge, and transition semantics.
- Keep every annual cell inside its owning palace's 30-degree sector.
- Keep repeated visits distinct and readable.
- Make label density configurable without changing geometry.
- Produce deterministic geometry suitable for unit, golden, and hit-test verification.

## Non-Goals

- Recalculate or reinterpret Zhu Luo rules in the UI.
- Display multiple algorithms simultaneously.
- Replace the generic DaXian ring.
- Modify the shared chart package in the first implementation.
- Persist algorithm or label-density preferences.

## Current Evidence

- `ZhuLuoYearResult` already exposes age, stage, ruler, palace, algorithm ID, phase, transition state, and bridge state.
- Existing Frederick fixtures verify bridge and transition metadata.
- `metaphysics_chart_ui` renders independently addressable `ArcSegment` cells with soft dividers and hit regions.
- `ArcLayer` supports arbitrary start/sweep angles and dynamic radii.
- Circular `OverlayLayer` currently emits neither geometry nor paint.

## Approval State

The product geometry was approved in the 2026-06-24 brainstorming discussion. This change is ready for written review, but it is not implementation approval until the user approves the artifacts.
