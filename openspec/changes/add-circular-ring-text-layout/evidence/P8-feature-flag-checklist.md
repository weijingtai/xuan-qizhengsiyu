# P8c: Feature Flag Checklist — Circular Ring Text Layout

## Gating Strategy

The glyph-level text layout is inherently gated by YAML theme configuration.
No explicit Dart-level feature flag is needed because:

1. **`glyphPlacementsByLayer`** on `BoardGeometry` is `null` by default — any
   consumer that doesn't call `_buildTextMetrics`/`_addCenterGeometry` with the
   engine sees no change.
2. **New LayerBehavior fields** (`textOrientation`, `fieldPlacement`) have safe
   defaults (`horizontal`, `null`) — existing YAML themes with
   `labelOrientation: horizontal` continue to work unchanged.
3. **`charSpacing`** in YAML is `double?` with default `null` → effective 1.0.
4. **Widget and hybrid renderers** don't call `_buildTextMetrics` yet — they
   fall through to the existing `_paintGlyphAt` path.

## Rollback Plan

| Scenario | Rollback action |
|----------|----------------|
| Glyph paint regression | Delete `glyphPlacementsByLayer` paint loop in `circular_canvas_board.dart`; glyphs fall back to `_paintGlyphAt` |
| Engine crash (unlikely) | Remove `textMetrics` ctor param from `CircularRingLayoutEngine` |
| Qizheng example regression | Remove `_palaceRing`/`_shenshaRing` calls; use original `_sectorRing` |
| charSpacing YAML crash | Remove `charSpacing` from `CircularRendererTokens` + loader parse |

## Canary Pre-Deploy

- [x] `flutter analyze lib` — 0 issues
- [x] `flutter test` on core package — all 122 tests pass (5 pre-existing exclusions)
- [x] Example widget tests — 13/13 pass
- [x] Example golden test — renders and matches
- [ ] Visual review: confirm no pixel drift in existing QiZheng adapter goldens
- [ ] Visual review: confirm `constellation-ring` texts are fixed-tilt rendered
- [ ] Visual review: confirm `shensha-ring` texts stack vertically

## Rollback Record

| Date | Event | Action |
|------|-------|--------|
| — | — | — |
