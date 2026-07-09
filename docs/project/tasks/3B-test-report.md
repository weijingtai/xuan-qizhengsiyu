# 3B Test Report

更新时间：2026-07-09

范围：方向三「不等宫死字段打通」反向验证测试。

## 已验证

- `ZhouTianModel.applyOverrides()` 支持 `houseDivisionSystemOverride`，默认空参数保持原行为。
- `HouseDivisionSystem` 各枚举值均有公式分派断言。
- `equatorialZiWuSanChenTongZai` 保留子午 `30.4380`、其余十宫 `30.4979`，总和 `365.855`，不暗改配平。
- `PanelSystemResolver` 对三辰通载子午不等宫给 warning-only，不生成 suggested fix。
- `ZhouTianCalculator.calculatePalaceAngles()` 在切换宫位划分后输出宽度确实变化。
- 配置面板显示「宫位划分」控件，并可选「三辰通载子午」。

## 命令

```bash
flutter test test/domain/entities/zhou_tian_model_overrides_test.dart test/domain/managers/panel_system_resolver_test.dart test/domain/managers/zhou_tian_calculator_projection_test.dart test/presentation/config/custom_config_section_widget_test.dart
```

结果：`All tests passed!`

```bash
git diff --check
```

结果：通过，无 whitespace error。

## 备注

`dart analyze` targeted 文件无新增 error，但仓库既有 warnings/infos 仍会让命令返回非 0，包括 `sweph_engine.dart` 未使用 import/local、`zhou_tian_model.dart` 既有 duplicate import/override warning，以及 Flutter 新版本对 `DropdownButtonFormField.value` 的 deprecation 提示。
