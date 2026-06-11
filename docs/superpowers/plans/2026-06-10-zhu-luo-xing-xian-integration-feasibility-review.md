# Zhu Luo Xing Xian Integration Feasibility Review

## Verdict

Feasible.

The current pure Zhu Luo San Xian algorithm is stable enough to connect into the existing 行限 manager layer through a thin adapter. The integration should not rewrite the algorithm, UI, database, 洞微, 飞限, or 小限 code.

## Verification Run

Branch:

```text
storage-refactor/qizhengsiyu
```

Commands:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
flutter analyze lib/xing_xian/zhu_luo_san_xian test/xing_xian/zhu_luo_san_xian
```

Result:

```text
8 Zhu Luo San Xian tests passed.
No analyzer issues found in the Zhu Luo San Xian algorithm/test scope.
```

## Feasibility Checks

- Existing pure module already separates tables, palace math, config, and calculator.
- A/B algorithm models are configuration-driven, so manager integration does not need branch-specific duplicated calculators.
- Production star enum names for Sun, Moon, Mars, Mercury, Jupiter, Venus, and Saturn are present and can be mapped to `ZhuLuoRuler`.
- The plan now includes both direct star-palace input and `BasePanelModel` input, so it has a realistic production entry path.
- The existing `ZhuLuoSanXianManager.calculate(DateTime)` chain behavior is preserved.

## Required Execution Order

1. Add `zhu_luo_san_xian_input_builder.dart`.
2. Add adapter tests for star-palace maps and `BasePanelModel`.
3. Add manager typed methods:
   - `calculateFromRulerPalaces`
   - `calculateFromStarPalaces`
   - `calculateFromPanel`
4. Add manager delegation tests.
5. Run focused Zhu Luo tests.
6. Run localized analyzer checks.

## Hard Boundaries

- Do not change the pure calculator behavior while wiring the manager.
- Do not introduce `xuan_` or `xuan-` in any new program identifier.
- Do not add dependency on `xuan-common` or repair common-related failures in this task.
- Do not change UI, persistence, 洞微, 飞限, 小限, or Ge Ju logic.
- Do not modify code on `main` or `master`.

## Main Risk

The only meaningful risk is model-shape mismatch in `BasePanelModel.enteredGongMapper`. The implementation plan reduces this by requiring a focused `BasePanelModel` adapter test before manager wiring.

## Final Gate

The integration can be accepted only after these commands pass:

```bash
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```
