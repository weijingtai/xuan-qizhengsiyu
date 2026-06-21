# Phase 1 Contract Verification

- OpenSpec change: `create-metaphysics-chart-ui-package`
- Implementation branch: `codex/phase1-contract-fix`
- Implementation commit: `63e7486`
- Package: `metaphysics-chart-ui`
- Decision: **PASS for Phase 1; Phase 2 may start**

## Closed Findings

### P1.3 immutable core contracts

Public collection-bearing contracts now defensively freeze constructor inputs:

- board layout, center, interaction config, semantics, layers, and metadata
- layer behavior, sectors, items, arcs, overlays, and item groups
- sparse coverage ranges and rectangular grid weights
- interaction state, geometry output, spatial index inputs, and candidates
- module palettes at both outer and inner map levels
- metadata recursively freezes nested maps, lists, and sets

The regression test mutates every source collection after construction and
also attempts mutation through every returned collection. Both paths must fail
to alter the constructed value.

### P1.11 semantic style roles

Geometry, layer, sector, arc, and item-style constructors now validate style
role strings at the public contract boundary. The following concrete color
forms throw `ArgumentError` before rendering:

- `#RRGGBB`
- `#AARRGGBB`
- `0xRRGGBB` / `0xAARRGGBB`
- CSS `rgb(...)`, `rgba(...)`, `hsl(...)`, and `hsla(...)`

Flutter `Color` and integer ARGB values remain rejected by the Dart field
types. Renderers continue to avoid interpreting metadata as styling.

## TDD Evidence

RED evidence:

- concrete-color tests returned constructed objects instead of throwing
- metadata, layer, coverage, geometry, interaction, and theme collections
  changed after their source collections were mutated
- recursive metadata test observed nested map/list/set mutation

GREEN evidence:

- scoped command:
  `flutter test test/architecture/deep_immutability_test.dart test/architecture/no_concrete_color_in_contracts_test.dart`
- result: 24 tests passed, 0 failed

## Full Verification

- `flutter analyze`: no issues found
- `flutter test`: 199 tests passed, 0 failed
- `git diff --check`: passed
- architecture import boundary and no-identifier tests: included in full suite
- gStack interaction evidence tests and renderer goldens: included in full suite

The second-migration gate scans sibling directories. The isolated worktree
therefore supplied a temporary `xuan-qizhengsiyu/pubspec.yaml` fixture copied
from the real consumer. The fixture was removed immediately after the run and
is not part of the commit.

## Compatibility Note

Collection-bearing contracts are no longer `const` constructible because
runtime defensive copies are required. The package remains experimental, and
all package examples and tests were migrated in the implementation commit.
