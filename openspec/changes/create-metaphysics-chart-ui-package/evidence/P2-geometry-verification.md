# Phase 2 Geometry Verification

## Scope

Phase 2 implements deterministic circular, sparse-arc, grid, perimeter,
point, tick, center, ring, overlay, semantics, and hit-index geometry in the
neutral `metaphysics_chart_ui` package. Source-domain projection remains in
the consuming module.

## Production Paths

- `CircularGeometryPlanner` validates canonical millidegrees before applying
  direction or offset and resolves sparse borders, caps, rings, center paint
  outsets, overlays, semantics, and hierarchical partitions.
- `ArcLayer.layoutSpec` routes sparse coverage through the same
  `CircularRingLayoutEngine` used by Canvas, Widget, and hybrid renderers.
- `BoardGeometry.maxUnindexedRegions` is fixed at 64. Dense Cartesian regions
  use `SpatialHitIndex`; interactive ticks use `AngularHitIndex` with their
  actual configured degree buckets.
- Candidate region ids resolve through an immutable id map. The prior linear
  `firstWhere` lookup was removed after the formal slope benchmark exposed an
  O(n) regression.

## Test Evidence

- `test/layouts/phase2_production_gate_test.dart`: sparse validation and blank
  angles, borders/caps, canonical boundaries, ring order/width/borders,
  optional and required zero widths, track/body transforms, inverse hits,
  overlay ordering and disabled policy, semantics ownership/actions, and
  absent/Canvas/Widget/hybrid center geometry.
- `test/layouts/phase2_hit_index_gate_test.dart`: non-interactive layers,
  interactive 360 ticks, non-1-degree configured buckets, fixed 64-region
  threshold, and point angle normalization.
- `test/renderers/sparse_renderer_conformance_test.dart`: real pointer hover
  parity for Canvas and Widget over the same sparse `ArcLayer`.
- `test/layouts/da_xian_106_fixture_test.dart`: configuration id `daXian106`,
  104 transformed children, twelve exact 30000-millidegree parents, and exact
  360000-millidegree closure.
- Existing circular, grid, perimeter, renderer golden, interaction,
  accessibility, and legacy compatibility suites remain enabled.

## Registered Benchmark

Command:

```text
flutter test test/performance/phase2_benchmark_protocol_test.dart -r expanded
```

Protocol: deterministic seed; 5 x 1,000 warm-ups; 10 x 10,000 measured
lookups; 128/256/512/1024 scaling samples.

Registered profile and observed result on 2026-06-21:

```text
profile=macos-arm64-m4-v1
os=macOS 26.6 (25G5043d)
arch=arm64
flutter=3.38.6
dart=3.10.7
device=Apple M4
p95=0.000583ms
slope=0.740792
```

The p95 is below 2 ms and the fitted log-log slope is below 0.85. A profile
mismatch is classified as informational and cannot emit registered passing
evidence.

## Final Gates

```text
flutter analyze                                            PASS (0 issues)
flutter test                                               PASS (228 tests)
OpenSpec strict validation                                 PASS
identifier/import/domain/color architecture scans          PASS (27 tests)
```

No test is skipped and no golden was updated to obtain these results.
