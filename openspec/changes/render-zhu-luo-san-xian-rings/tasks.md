## 1. Characterization And Contracts

- [ ] 1.1 Add fixtures for A jumps, B bridges, repeated visits, and shared transitions using calculator output.
- [ ] 1.2 Test that visits split only when stage, ruler, palace, phase, bridge state, or age continuity changes.
- [ ] 1.3 Test visit ordinals per `(stage, palace)` and maximum track count per stage.
- [ ] 1.4 Record passing calculator and manager baselines before presentation work.

## 2. Pure Ring Projection

- [ ] 2.1 Add immutable visit, annual-cell, transition-edge, stage-group, and ring-plan models under `lib/presentation/models/zhu_luo_san_xian/`.
- [ ] 2.2 Implement a pure projector from `List<ZhuLuoYearResult>`; it must not calculate Zhu Luo rules.
- [ ] 2.3 Add stable IDs containing algorithm, stage, visit ordinal, palace, and age.
- [ ] 2.4 Test exact 30-degree subdivision, sweep sum, final-boundary closure, sparse repeat tracks, radial order, and one annual cell per input record.

## 3. ArcLayer Adapter

- [ ] 3.1 Map each physical visit track to one `ArcLayer` and each annual cell to one `ArcSegment`.
- [ ] 3.2 Implement range-only, all-cell, and automatic labels without changing geometry or hit IDs.
- [ ] 3.3 Map initial, middle, final, bridge, divider, connector, and transition semantic style roles without raw colors.
- [ ] 3.4 Add QiZheng-local style roles only in the project theme/style boundary; do not edit `../metaphysics-chart-ui/`.
- [ ] 3.5 Test blank sectors, separate repeated-visit radii, stable IDs, annual hit payloads, and that changing semantic roles changes resolved segment/paint output.

## 4. Jump And Transition Foreground

- [ ] 4.1 Resolve connector geometry from ring-plan endpoints using the same angle/radius transform as arc cells.
- [ ] 4.2 Add a QiZheng foreground painter for inverse jumps and inter-stage markers only.
- [ ] 4.3 Add non-color affordances for repeated tracks, bridge cells, jumps, and transition markers.
- [ ] 4.4 Test that skipped palaces are not represented as visited, transition ages are not duplicated, and connectors stay lower emphasis than annual cells.
- [ ] 4.5 Add goldens for an A jump, B bridge, repeated visit, shared transition, light theme, and dark theme.

## 5. Controls And Interaction

- [ ] 5.1 Wire the algorithm radio control so one selected configuration supplies annual results to the common renderer.
- [ ] 5.2 Add label-density control with range-only default and all-cell capability; automatic mode reacts to zoom or available sweep.
- [ ] 5.3 Resolve selected cell IDs to age, stage, ruler, palace, phase, algorithm, bridge, and transition details.
- [ ] 5.4 Add forgiving selection for small angular cells through hit slop, visit-first disambiguation, zoom-on-touch, or an equivalent interaction.
- [ ] 5.5 Add a linear annual-path fallback/list derived from the same immutable ring plan.
- [ ] 5.6 Test that label-mode changes preserve cell count, geometry IDs, selection behavior, and linear fallback payloads.

## 6. Production Integration And Rollback

- [ ] 6.1 Add an additive board-composition seam without changing DaXian, Hundred-Six, FeiXian, or XiaoXian rendering.
- [ ] 6.2 Keep production wiring behind a default-off feature flag and test both states.
- [ ] 6.3 Add radial-budget validation that never drops repeated visits.
- [ ] 6.4 Run focused impact scans before touching production host files; stop for unexpected high-blast-radius results.
- [ ] 6.5 Run boundary scans for calculation leakage, legacy DaXian reuse, hard-coded colors, shared-package edits, and new skipped/focused tests.

## 7. Verification And Product QA

- [ ] 7.1 Run projection, adapter, painter, widget, calculator, manager, and existing chart-board tests with no skips.
- [ ] 7.2 Run focused Flutter analysis for changed presentation and test files.
- [ ] 7.3 Run no-skip/no-only scan for `test/presentation`.
- [ ] 7.4 Run goldens at normal and enlarged scales for range-only and all-cell modes, in light and dark themes.
- [ ] 7.5 Run gStack visual QA for stage order, sparse coverage, repeat tracks, light dividers, jumps, bridges, transitions, zoom labels, forgiving selection, non-color affordances, and linear fallback.
- [ ] 7.6 Record evidence and obtain user approval before default enablement.
