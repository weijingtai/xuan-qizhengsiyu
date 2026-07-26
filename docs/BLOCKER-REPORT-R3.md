# BLOCKER-REPORT — R3 轨道

## BLOCKER-1: repository_interface_bazi git ref 冲突

**现象**：`flutter pub get` 失败，依赖解析无法完成。

**根因**：
- `bazi_embed_ui_interface` 的 pubspec.yaml 声明依赖 `repository_interface_bazi` 时指定 `ref: main`
- `persistence_preferences`（来自 xuan-storage）的 pubspec.yaml 声明依赖 `repository_interface_bazi` 时不指定 ref（即 HEAD）
- Dart pub 将不同 git ref 视为不兼容的 source spec，即使 HEAD == main（同一 commit `df3e486`），仍判定为不兼容

**影响**：无法执行 `flutter pub get`，因此所有后续步骤（编译、测试）均无法进行。

**涉及的依赖链**：
```
qizhengsiyu
├── bazi_embed_ui_interface (git, ref: main)
│   └── repository_interface_bazi (git, ref: main) ← 要求 main
└── persistence_preferences (git, 无 ref = HEAD)
    └── repository_interface_bazi (git, 无 ref = HEAD) ← 要求 HEAD
```

**已尝试的修复**：
1. dependency_overrides 指定 `ref: main` → 失败（persistence_preferences 仍要求 HEAD）
2. dependency_overrides 使用 `path: ../repository-interface-bazi` → 失败（pub 仍检测到两个消费方的 ref 不兼容）
3. 从 dependencies 移除 repository_interface_bazi → 失败（同上）

**建议的修复方案（任选其一）**：
- A. 在 xuan-storage/preferences/pubspec.yaml 中为 `repository_interface_bazi` 添加 `ref: main`
- B. 在 bazi-embed-ui-interface/pubspec.yaml 中移除 `ref: main`（改为无 ref）
- C. 两个包都改用 `ref: main`（推荐）

**BLOCKER-2: BaziBirthContext 的 chineseDateInfo 字段缺失**

**现象**：构造完整的 BaziBirthContext 需要 ChineseDateInfo（含 Phenology、JieQiInfo、YuanYunOrder、NineYun 等复杂类型），当前 QiZhengSiYuViewModel 未暴露这些字段。

**影响**：即使依赖冲突解决，showDayunLiunianSheet 的调用也只能使用占位 ChineseDateInfo，数据不完整。

**建议**：ViewModel 需新增 lunarDateInfoNotifier 的数据暴露，或由 bazi 侧自行计算 ChineseDateInfo。

---

## 本轨已完成的代码变更

尽管 pub get 失败，以下代码变更已就位（编译正确性待依赖解决后验证）：

1. **pubspec.yaml**：添加 `repository_interface_bazi` 和 `bazi_embed_ui_interface` 依赖声明
2. **di.dart**：注册 `Provider<BaziEmbedUiPort?>`（nullable）
3. **beauty_view_page.dart**：添加 `_buildBaziEmbedSection()` 方法，构造 BaziBirthContext 并调用 `showDayunLiunianSheet`
4. **rise_set_info_panel.dart**：`_pickDate` 方法添加 `@Deprecated` 注解和中文迁移说明
5. **test/presentation/bazi_embed_smoke_test.dart**：冻结测试（port 类型 + BaziBirthContext 构造 + 具体值断言）
