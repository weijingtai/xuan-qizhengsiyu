# 七政四余 星盘绘图专用 Theme Token 迁移计划

- 日期: 2026-06-17
- 状态: Plan (read-only survey + 迁移计划，未改动任何生产代码)
- 范围: `lib/painter/`、`lib/presentation/widgets/`、`lib/presentation/widgets/rings/` 中所有 CustomPaint / Canvas / Painter 的颜色、字体、绘图样式来源
- 非范围: 星盘天文计算（sweph/tyme）、`ZhouTianModelManager` / `StarPositionManager` 等布局与位置算法、信息卡 `lunar_date_info_card_v2.dart`（非星盘绘制）

---

## 0. 核心结论（先读这一段）

1. **绘图层与样式来源已天然解耦**：所有 Painter 都通过构造参数接收 `textStyle` / `colorMap` / `size` / `tickLength` 等，**没有任何 Painter 在 `paint()` 内调用 `Theme.of(context)`**。迁移不需要把 Painter 接到 BuildContext，只需把"散装样式参数"收敛成一个**绘图样式对象 `QiZhengChartStyle`**，并在唯一组装根注入。
2. **业务色已集中**：`QiZhengSiYuUIConstantResources.zhengColorMap` / `starsColorMap`（键为 `EnumStars`）是星体的文化语义色，已在单文件集中（[qi_zheng_si_yu_ui_constant_resources.dart](lib/qi_zheng_si_yu_ui_constant_resources.dart)）。**它不是装饰色，绝不能并入语义 Token**；它单独成 `QiZhengStarPalette` 命名空间。
3. **唯一组装根**：[beauty_view_page.dart](lib/presentation/pages/beauty_view_page.dart) 的 `panel()`（行 725–1095）与星体/神煞 builder（行 1500–2050）是所有 Painter 的构造点，也是注入点。无需改动其它页面。
4. **绝不套用普通 `ComponentStyle`**：星盘是像素级 Canvas，语义色/字体/几何与业务色混在同一对象会破坏"语义 ≠ 业务"边界。本计划定义专用 `QiZhengChartStyle` + 独立 `QiZhengStarPalette`，不复用通用组件样式。
5. **现状无 `xuan_config` 依赖、无 YAML 解析、无 dark mode、无 golden 基础设施** → import guard 为**预防性**；YAML 解析与 fallback 必须新建；像素回归 gate 必须新建（`flutter_test` 自带 `matchesGoldenFile`，无需新依赖）。

---

## 1. 现状勘察证据（UA + CodeGraph 只读结果）

### 1.1 绘图入口清单（按文件）

| 文件 | 类 / 入口 | 类型 | 绘制对象 |
|------|-----------|------|----------|
| [painters.dart](lib/painter/painters.dart) | `MyCirclePainter`(6), `IndicatorScalePainter`(199), `StarBodyPainter`(274) | CustomPainter | 星体圆点+名字+荫/速标注、连线、刻度 |
| [star_body_ring_painter.dart](lib/painter/star_body_ring_painter.dart) | `OuterLifeStarRangePainter`(9), `InnerLifeStarRangePainter`(194), `RingSheetPainter`(405) | CustomPainter | 星轨环、连线、星点、星名标注、12 等分线 |
| [star_xiu_ring_painter.dart](lib/painter/star_xiu_ring_painter.dart) | `StarXiuRingPainter`(10) | CustomPainter | 28 宿弧段（业务色）、刻度、星宿名标注 |
| [StarInn28RingPainter.dart](lib/painter/StarInn28RingPainter.dart) | `Starinn28ringPainter`(7) | CustomPainter | 28 宿彩色弧段、星宿名 |
| [twelve_zhi_gong_circle_ring_printer.dart](lib/painter/twelve_zhi_gong_circle_ring_printer.dart) | `TwelveZhiGongCircleRingPrinter`(8) | CustomPainter | 12 宫扇环背景（业务色）、分隔线、宫名 |
| [rings/sector_painter.dart](lib/presentation/widgets/rings/sector_painter.dart) | `SectorPainter`(5) | CustomPainter | 扇环填充+边框 |
| [rings/circle_text_painter.dart](lib/presentation/widgets/rings/circle_text_painter.dart) | `CircleTextPainter`(8) | CustomPainter | 宫扇背景+年月/文字标注 |
| [rings/da_xian_ring_painter.dart](lib/presentation/widgets/rings/da_xian_ring_painter.dart) | `DaXianRingPainter`(9) | CustomPainter | 大限年月槽背景、边框、文字 |
| [center_text_circle_widget.dart](lib/presentation/widgets/center_text_circle_widget.dart) | 用 `CircleTextPainter` | Widget→CustomPaint | 中心身命度文字盘 |
| [rings/body_life_circle_widget.dart](lib/presentation/widgets/rings/body_life_circle_widget.dart) | 用 `CircleTextPainter` | Widget→CustomPaint | 身命宫星体+度数 |
| [rings/gong_12_dizhi.dart](lib/presentation/widgets/rings/gong_12_dizhi.dart) | `Gong12DiZhiRing`(23), `ShenShaItemV2`(404) | Widget(Transform+Text) | 神煞文字标注（非 Canvas） |
| [rings/gong_ming_li_ring.dart](lib/presentation/widgets/rings/gong_ming_li_ring.dart) | `GongShenShaRing`(113), `_ShenShaItem`(368) | Widget+SectorPainter | 宫内神煞文字（非 Canvas 文字） |
| [rings/gong_shen_sha_ring.dart](lib/presentation/widgets/rings/gong_shen_sha_ring.dart) | `AllShenShaRing`(40) | Widget+SectorPainter | 12 宫神煞编排 |
| [rings/da_xian_ring.dart](lib/presentation/widgets/rings/da_xian_ring.dart) | `DaXianRing`(11) | Widget→CustomPaint | 大限双环宿主 |
| [destiny_twelve_gong_ring.dart](lib/presentation/widgets/destiny_twelve_gong_ring.dart) | `DestinyTwelveGongRingWidget`(7) | Widget(Transform+Text) | 命理宫名+交互按钮 |
| [star_track_ring.dart](lib/presentation/widgets/star_track_ring.dart) | Inner/Outer track | Widget→CustomPaint | 星轨环宿主 |
| [star_body_ring.dart](lib/presentation/widgets/star_body_ring.dart) | Inner/Outer body rotating | Widget(AnimatedRotation+Text) | 旋转星体（非 Canvas） |
| [star_body.dart](lib/presentation/widgets/star_body.dart) | `StarBody`(4) | StatefulWidget | 交互星体徽章（非 Canvas） |
| [twelve_gong_text_ring.dart](lib/presentation/widgets/twelve_gong_text_ring.dart) / [twelve_gong_grid_ring.dart](lib/presentation/widgets/twelve_gong_grid_ring.dart) | text/grid ring | Widget→CustomPaint | 宫名环 / 网格线 |

### 1.2 颜色来源分类（语义 vs 业务，迁移的核心边界）

- **业务计算色（绝不可 Token 化为语义色，单独成 Palette）**：
  - `QiZhengSiYuUIConstantResources.starsColorMap[star]` / `zhengColorMap[gong.sevenZheng]`（行 6–36），消费点：[twelve_zhi_gong_circle_ring_printer.dart:143](lib/painter/twelve_zhi_gong_circle_ring_printer.dart)、[star_xiu_ring_painter.dart:63](lib/painter/star_xiu_ring_painter.dart)、[star_body_ring_painter.dart:80,294](lib/painter/star_body_ring_painter.dart)、[star_track_ring.dart:39,97](lib/presentation/widgets/star_track_ring.dart)、[center_text_circle_widget.dart:85–142](lib/presentation/widgets/center_text_circle_widget.dart)、[body_life_circle_widget.dart:118–178](lib/presentation/widgets/rings/body_life_circle_widget.dart)、[beauty_view_page.dart](lib/presentation/pages/beauty_view_page.dart) 多处。
  - `Starinn28ringPainter` 的 `twentyEightStarsList[i].item2`（[StarInn28RingPainter.dart:105](lib/painter/StarInn28RingPainter.dart)）— 业务色由调用方组装的元组携带。
  - 条件业务色：`MyCirclePainter`/`StarBodyPainter` 中 "速" 字判定 `["金木水火土"]`→`Colors.red`（[painters.dart:156,429](lib/painter/painters.dart)）；`DestinyTwelveGongRingWidget` "命宫"→`Colors.red`（[destiny_twelve_gong_ring.dart:150,176](lib/presentation/widgets/destiny_twelve_gong_ring.dart)）。
  - 透明度梯度（业务序号驱动）：`color.withAlpha(index*10[+50])`（[circle_text_painter.dart:76](lib/presentation/widgets/rings/circle_text_painter.dart)、[da_xian_ring_painter.dart:158](lib/presentation/widgets/rings/da_xian_ring_painter.dart)）。
- **语义 UI 色（可 Token 化）**：环描边/分隔线/边框/阴影/刻度/通用文字 —— `Colors.grey/black87/black45/black38/black12/black26/black54/transparent`、`Color.fromRGBO(55,53,52,1)`、`Colors.red`（刻度/北方线）、`Colors.teal`（按钮装饰）。分布于全部 Painter，量大且散。

### 1.3 字体来源

- Painter 内联硬编码字体：`GoogleFonts.maShanZheng`（[star_xiu_ring_painter.dart:141](lib/painter/star_xiu_ring_painter.dart)）、`GoogleFonts.notoSans`（[star_track_ring.dart:45,103](lib/presentation/widgets/star_track_ring.dart)、[star_body_ring.dart:108](lib/presentation/widgets/star_body_ring.dart)）。
- 组装根内联字体：`maShanZheng/longCang/zhiMangXing/notoSans`（[beauty_view_page.dart:404,742,768,1517…](lib/presentation/pages/beauty_view_page.dart)）。
- **风险**：所有 Painter 均 `TextPainter.layout()` 后读 `width/height` 居中（文本测量耦合）。换字族/字号会改变测量值→标注位移。字体必须作为 Typography Token，且默认值 = 现有 GoogleFonts，逐角色（星宿名/星名/宫名/度数/年月）分别定义。

### 1.4 几何/缩放

- 半径来自 `size.width/2` 或构造参 `innerSize/outerSize/trackSize`（布局语义，**不进 Token**）。
- `strokeWidth`、`tickLength/longTickLength`、`innerPadding/outerPadding`、固定偏移（`itemSize-20`、`-16` 双环步进）—— **可进 Token（几何 Token）**，但迁移值必须逐字节等值。
- 角度数学（30°/宫、`pi/180`、扇区分配）属布局语义，**不进 Token**。

---

## 2. 目标架构

```
YAML / ThemeExtension  ──►  ChartStyleResolver (interface, in lib/)
                                   │  解析 + 校验 + fallback
                                   ▼
            QiZhengChartStyle (语义色 + Typography + 几何, 含 light/dark)
            QiZhengStarPalette (业务色, EnumStars→Color, 独立命名空间)
                                   │ 注入于唯一组装根
                                   ▼
        beauty_view_page.panel()  ──►  各 Painter(required this.style[, palette])
```

- `QiZhengChartStyle`（immutable，`copyWith`，`==`/`hashCode`）：
  - `ChartSemanticColors`：`ringStroke / divider / border / shadow / scaleTick / scaleTickAccent / labelDefault / labelMuted / annotationYin / annotationSu` 等。
  - `ChartTypography`：按角色 `constellationName / starName / gongName / degree / yearMonth / shenSha`，每个含 family+size+weight+height。
  - `ChartGeometry`：`ringStrokeWidth / tickLength / longTickLength / innerPadding / outerPadding / guideDotRadius / starHolderRadius`。
  - `brightness` 维度：`QiZhengChartStyle.light()` / `.dark()`。
- `QiZhengStarPalette`：包 `zhengColorMap`/`starsColorMap`，提供 `colorOf(EnumStars, {brightness})`。**独立类型，不与 `ChartSemanticColors` 共享字段/构造**，编译期即阻止混淆。
- `ChartStyleResolver`：`QiZhengChartStyle resolve(Brightness)` + `QiZhengStarPalette resolvePalette(Brightness)`。生产实现从 `ThemeExtension`/DI 读；YAML→ThemeExtension 的装配只在 example/ 或薄适配层。

---

## 3. Painter 分级（合格标准核心交付）

### Tier A —— 可直接 Token 化（纯几何/纯语义，或业务色已是注入参数）

| Painter | 依据 |
|---------|------|
| `SectorPainter` | 仅 `borderColor=Colors.black12`，填充来自参数；无文字 ([sector_painter.dart](lib/presentation/widgets/rings/sector_painter.dart)) |
| `RingSheetPainter` | 仅 `Colors.black87/red` 分隔线；纯线 ([star_body_ring_painter.dart:405](lib/painter/star_body_ring_painter.dart)) |
| `IndicatorScalePainter` | 仅 `Colors.red` 刻度；纯几何 ([painters.dart:199](lib/painter/painters.dart)) |
| `TwelveZhiGongCircleRingPrinter` | 语义 white/grey + 业务 `starColorMapper` 已为参数；只需补语义/几何 Token + Typography ([…printer.dart:8](lib/painter/twelve_zhi_gong_circle_ring_printer.dart)) |
| `Starinn28ringPainter` | 语义 white + 业务色经 `twentyEightStarsList` 注入；`textStyle` 已为参数 ([StarInn28RingPainter.dart:7](lib/painter/StarInn28RingPainter.dart)) |

> Tier A 的迁移 = 把散装样式参数替换为 `required this.style`（业务色仍走既有注入参数/Palette），值等价。

### Tier B —— 须先拆 style adapter（内联字体 / 内联条件业务色 / 测量耦合）

| Painter | 必须先解决的耦合 |
|---------|------------------|
| `StarXiuRingPainter` | `paint()` 内联 `GoogleFonts.maShanZheng` + 内联 `Color.fromRGBO(55,53,52)` + shadow ([:141](lib/painter/star_xiu_ring_painter.dart)) → 抽 Typography/语义色 |
| `MyCirclePainter` / `StarBodyPainter` | 内联 "荫"`black45`/"速"`red` 且 "速" 由 `["金木水火土"]` 字符串判定（业务条件）混语义 ([painters.dart:129,156,402,429](lib/painter/painters.dart)）→ adapter 区分语义标注色与业务条件标注 |
| `OuterLifeStarRangePainter` / `InnerLifeStarRangePainter` | 业务 `starsColorMap` 已注入，但内联 `grey/black45/red` + "荫/速" + `TextPainter` 测量 ([star_body_ring_painter.dart](lib/painter/star_body_ring_painter.dart)) |
| `CircleTextPainter` | `withAlpha(index*10)` 业务梯度 + 文本测量 ([:76,247](lib/presentation/widgets/rings/circle_text_painter.dart))（被中心盘/身命盘复用，改动放大半径） |
| `DaXianRingPainter` | `withAlpha(index*10+50)` + `Border` 拆解为 4 边 + 年月槽几何 + 测量 ([:158,190,368](lib/presentation/widgets/rings/da_xian_ring_painter.dart)) |

> adapter = 在 Painter 之外建 `XxxStyleAdapter`，把"语义 Token / Typography / 业务 Palette / 业务条件函数"组装成 Painter 当前所需的纯参数；Painter 签名先不变 → 验证等价 → 再内联收敛。

### Tier C —— 暂缓（非 Canvas 的 widget-Transform 标注 / 交互 / 动画 / 高几何风险）

| 对象 | 暂缓理由 |
|------|----------|
| `StarBody`(Stateful 动画)、`Inner/OuterStarBodyRotatingWidget`(AnimatedRotation) | 非 Canvas，旋转角度承载布局语义；动画态像素不稳定，不适合 golden |
| `Gong12DiZhiRing`/`ShenShaItemV2`/`GongShenShaRing`/`_ShenShaItem`/`AllShenShaRing` | widget `Transform`+`Text` 渲染，含 clamp 定位与逐字旋转，几何回归风险高、收益低 |
| `DestinyTwelveGongRingWidget` | 交互按钮 + "命宫"业务条件文本；属 widget 主题化轨道，另立计划 |
| `lunar_date_info_card_v2.dart` | 非星盘绘制，超范围 |

> Tier C 在本期仅做"只读样式来源登记"，不改代码；待 Tier A/B 稳定后另开 widget 主题化计划。

---

## 4. 分阶段实施

- **P0 基础设施（不动 Painter）**：建 `QiZhengChartStyle`/`QiZhengStarPalette`/`ChartStyleResolver`；`fallback()` 逐字段 = 现有硬编码值（4.x 节锚点逐一拷贝）；建 import guard 测试；建 golden harness。
- **P1 Tier A**：5 个 Painter 改 `required this.style`，业务色保持注入；每个配 golden + 颜色断言，绿后合。
- **P2 Tier B**：逐个抽 `*StyleAdapter`（Painter 签名不变）→ 等价验证 → 再收敛签名。`CircleTextPainter` 因被中心盘/身命盘复用，单独成 PR。
- **P3 组装根收敛**：`beauty_view_page` 注入 `resolver.resolve(brightness)`，删除内联 `GoogleFonts`/散装 `textStyle`/手传 colorMap，改走 `style`+`palette`。
- **P4 深浅色**：补 `.dark()` 语义色 + 业务色暗色变体（`QiZhengStarPalette` 暗色），dark golden。
- **P5 YAML**：YAML→ThemeExtension 装配（仅 example/ 或适配层），缺键走 fallback。

---

## 5. 测试方案（合格标准）

1. **几何/位置语义不变（最高优先级）**：
   - 复用 [test/resources/golden_base_star_positions.json](test/resources/golden_base_star_positions.json) 与 `qizhengsiyu_decoupling_contract_fixture.json`，断言 `ZhouTian`/`StarPosition` 输出不变（Painter 是下游，迁移不得触碰这些）。
2. **Style 平价测试（parity）**：单测断言 `QiZhengChartStyle.fallback()` 的每个语义色/字号/几何字段 == 4.x 锚点引用的原字面量；`QiZhengStarPalette` 默认 == `QiZhengSiYuUIConstantResources` 现值。
3. **像素回归 golden**（`matchesGoldenFile`，`flutter_test` 自带）：固定 `Size` + 固定 fixture + `fallback()` 样式，每个 Tier A/B Painter 出 1 张基线；迁移前后**字节一致**为通过门。dark 单独基线。
4. **颜色断言**：对业务色路径，pump 后断言关键像素或暴露 resolved `Paint.color`，确认走 `palette` 而非语义 Token（防混淆回归）。
5. **文本测量回归**：Typography 默认族/字号不变；golden 捕捉换字导致的标注位移；Tier B adapter 须保留逐字 `TextStyle` 等价。

---

## 6. Fallback 规则

- `QiZhengChartStyle.fallback()` / `QiZhengStarPalette.fallback()` = 当前硬编码值的**逐字段常量**，任何 Painter 永不抛异常缺样式。
- YAML 缺失/解析失败 → 整体回退 fallback 并 `log.warn`；**单键缺失 → 该键回退默认**，其余正常（per-token fallback）。
- 业务色缺键（`EnumStars` 未命中）→ 沿用现状语义（现状即 `map[star]!`，迁移后改为 `palette.colorOf(star)` 内部回退到 fallback 业务色，消除 `!` 崩溃风险，但默认值不变）。

---

## 7. Import Guard（禁止生产代码依赖 xuan_config）

- 现状：`grep xuan_config lib/` = 0 命中（预防性）。
- 守卫测试 `test/architecture/no_xuan_config_in_lib_test.dart`：扫描 `lib/**/*.dart`，命中 `package:xuan_config` 即 `fail`；同时禁止 Painter 直接 `import 'xuan_config'`。
- 架构约束：`xuan_config` 只允许出现在 `example/` 或 `ChartStyleResolver` 的薄适配实现里，且适配层不得被 `lib/` 反向 import。
- 可叠加 `dependency_validator`/自定义 lint，但以"测试 = 红线门"为主，确保 CI 拦截。

---

## 8. 不改变星盘计算/布局语义的验证证据

1. Painter 仅消费样式，**不参与**天文/排盘计算；本计划 0 改动 `domain/managers/`、`sweph`、`tyme`、`ZhouTian*`。
2. 半径/角度/扇区分配/旋转保持原值，不纳入 Token；§5.1 契约测试为不回归证据。
3. §5.2 parity + §5.3 字节级 golden 双证：样式对象初值与渲染像素均与迁移前一致。
4. 组装根改造（P3）为"同值替换"：删内联样式、改走 `style`/`palette`，golden 不变即语义未变。

---

## 9. 风险与缓解

| 风险 | 缓解 |
|------|------|
| 语义色与业务色混淆 | 两个独立类型（`ChartSemanticColors` vs `QiZhengStarPalette`），编译期隔离；§5.4 颜色断言 |
| 换字导致文本测量位移 | Typography 默认 = 原 GoogleFonts；golden 兜底；Tier B 保 `TextStyle` 等价 |
| `CircleTextPainter` 多处复用，改动放大 | 单独 PR + 中心盘/身命盘各出 golden |
| 缩放/半径误纳入 Token | 几何 Token 只收 stroke/tick/padding，半径/角度留布局；parity 锁定值 |
| dark mode 业务色失真 | 业务暗色由领域同学确认色值，非自动反色；dark golden |

---

## 10. 待确认（Open Questions）

1. YAML 的归属与 schema：复用 `xuan-common` 现有主题体系，还是本模块自带 `assets/theme/chart.yaml`？（现状两者皆无）
2. 业务色暗色变体由谁定义（文化语义色不能机械反色）？
3. Tier C 的 widget 主题化是否本期纳入，还是确认另立计划。
