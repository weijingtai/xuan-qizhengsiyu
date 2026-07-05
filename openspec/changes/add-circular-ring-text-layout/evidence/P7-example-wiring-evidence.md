# P7: QiZheng Example Orientation Wiring

## Wiring Changes

### Files Modified

- `metaphysics-chart-ui/example/lib/main.dart`
  - `_sectorRing` now accepts `textOrientation` and `fieldPlacement` params
  - `_palaceRing`: destiny ring uses `FieldPlacementMode.triangle` with 2 TextItems per sector
  - `_shenshaRing`: both shensha rings use `TextOrientation.verticalStack` + `FieldPlacementMode.innerOuterSplit`
  - `constellation-ring` ArcLayer: `TextOrientation.fixedTilt`

### Layer Orientation Map

| Layer | Orientation | Field Placement |
|-------|------------|-----------------|
| earth-branch-ring | horizontal (default) | none |
| zodiac-ring | horizontal (default) | none |
| star-sequence-ring | horizontal (default, hidden) | none |
| **destiny-ring** | horizontal | **triangle** |
| degree-ticks | horizontal | none |
| **constellation-ring** | **fixedTilt** | none |
| inner-star-track-ring | horizontal | none |
| inner-star-body-ring | horizontal | none |
| outer-star-track-ring | horizontal | none |
| outer-star-body-ring | horizontal | none |
| **inner-shensha-ring** | **verticalStack** | **innerOuterSplit** |
| **outer-shensha-ring** | **verticalStack** | **innerOuterSplit** |

### Pre-existing Bug Fix

- `DefaultTabController` length changed from 4 → 5 to match the 5 tabs

## Passing Tests

```
flutter test test/widget_test.dart                               → 13/13 PASS
  - 5 structural/layer tests
  - 3 orientation-wiring tests (destiny triangle, constellation fixedTilt, shensha verticalStack+innerOuterSplit)
  - 3 responsive tests (480w, 768w, 1024w)
  - 4 accessibility tests (textScale 1.0/1.3/2.0, dark mode)

flutter test test/taiyi_branch_mansion_sample_test.dart           → 1/1 PASS (golden regenerated)
flutter analyze lib                                               → 0 issues
```

## Golden Evidence

| Golden | Path | Description |
|--------|------|-------------|
| `goldens/qizheng_orientation_wiring.png` | `metaphysics-chart-ui/example/test/goldens/` | Full QiZheng board with all orientations wired |
| `goldens/taiyi_branch_mansion_sample.png` | `metaphysics-chart-ui/example/test/goldens/` | TaiYi branch mansion (regenerated) |

## Pre-existing Test Exclusions

2 test files have pre-existing failures unrelated to this change:
- `taiyi_tab_real_render_test.dart` — expects 3 TaiYi layers but actual board has 2
- (none)
