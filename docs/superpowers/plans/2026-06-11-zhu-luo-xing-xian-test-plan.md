# Zhu Luo Xing Xian Integration Test Plan

## Scope

Validate that the existing Zhu Luo San Xian pure algorithm can be safely connected to the 行限 manager layer.

This test plan covers only:

- Production star-palace map to `ZhuLuoRuler` map.
- `BasePanelModel` to `ZhuLuoInput`.
- `ZhuLuoSanXianManager` typed delegation methods.
- Regression coverage for A/B algorithm behavior and Frederick key ages.

This test plan does not cover:

- UI rendering.
- Database persistence.
- Ge Ju rule evaluation.
- 洞微、飞限、小限 behavior.
- Any `xuan-common` failure.

## Test Matrix

| Area | Target | Required Assertion |
| --- | --- | --- |
| Pure algorithm regression | `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart` | Existing 8 tests still pass. |
| Bridge year metadata | Frederick B law age 54 and 55 | Age 54 stays one row at 子 with bridge metadata; age 55 starts 火限 at 子 as transition year. |
| Star adapter | `zhuLuoRulerPalacesFromStarPalaces` | Seven production `EnumStars` values map exactly to seven `ZhuLuoRuler` values. |
| Missing star defense | `zhuLuoRulerPalacesFromStarPalaces` | Missing required star throws `StateError` naming the missing star. |
| Star-palace input | `buildZhuLuoInputFromStarPalaces` | Frederick data produces life palace 酉, day sect, maxAge 80, config B, and 金寅/月午/火子. |
| Panel input | `buildZhuLuoInputFromPanel` | Reads life palace from `panel.bodyLifeModel.lifeGong` and star palaces from `panel.enteredGongMapper`. |
| Manager delegation | `calculateFromRulerPalaces` | Produces same result as direct `calculateZhuLuoSanXian`. |
| Manager star-palace path | `calculateFromStarPalaces` | Frederick data returns age 61 at 午 and age 75 at 申. |
| Manager panel path | `calculateFromPanel` | Same result as `calculateFromStarPalaces` for the same synthetic panel. |
| Chain compatibility | `calculate(DateTime)` | Keeps returning `void` and does not require panel data. |

## Required Test Files

Create:

- `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart`
- `test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart`

Modify:

- `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart`

Do not create:

- UI tests.
- Golden tests.
- Database tests.
- Any test that imports `xuan-common`.

## Local Gates

Run after test files are added:

```bash
flutter test test/xing_xian/zhu_luo_san_xian
flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Passing criteria:

- All focused tests pass.
- Analyzer reports no issues in the focused scope.
- Any unrelated `xuan-common` failure is ignored and must not be repaired in this work.

## Manual Review Checklist

- No new program identifier contains `xuan_` or `xuan-`.
- Pure algorithm files keep their existing behavior except explicit test metadata assertions.
- Adapter remains thin and contains no astrology judgment logic.
- Manager methods only construct input and delegate to `calculateZhuLuoSanXian`.
- `calculate(DateTime)` remains compatible with the existing `FateManager` chain.

## Residual Risk

The only meaningful risk is a mismatch between the synthetic test panel and future real panel data. Keep this contained by reading only `bodyLifeModel.lifeGong` and `enteredGongMapper[EnumStars.*].gong`.
