# 七政四余可配置盘制/流派系统 · 完整设计（Spec）

> 面向实施与后续 `writing-plans`。目标：让用户可自由配置「坐标系 / 周天制 / 黄赤道换算 / 回归恒星 / 星宿表 / 起点 / 偏移量」，并以「流派 + 典籍」一键套配、支持自定义流派/星盘。**大量能力已存在，本 spec 以「暴露 + 接线 + 编排」为主，不重造轮子。**
> 领域基础见 `docs/project/architecture/001-七政四余盘制历法与星宿坐标领域模型.md`（维度 ①②③④⑤）。
> 换算算法基础见 `docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md` 与分支 `feat/chidao-huangdao-tuibian`（推变黄道三算法 + 周天缩放已接入 UI/管线）。

## 0. 现状对齐（已存在、可复用的轮子）

| 能力 | 已有载体 | 状态 |
|---|---|---|
| 坐标系 4 值 | `CelestialCoordinateSystem`：`Ecliptic`(现代黄道)/`Equatorial`(现代赤道)/`SkyEquatorial`(天赤道365.25)/`PseudoEcliptic`(古黄道=似黄道·赤道投影推黄道) | 枚举全有；UI 只暴露前 2 |
| 回归/恒星 | `PanelSystemType`：`Tropical`/`Sidereal` | UI 已暴露 |
| 星宿表 | `ConstellationSystemType`：`Classical`(古宿)/`AdjustedClassical`(矫正古宿)/`Modern`(今宿) | 枚举有；UI 无选择器 |
| 周天制 | `EnumZhouTianModel`：`degree360`/`degree36525` | 有；UI radio（feature 分支） |
| 黄赤道换算 | `ProjectionConfig`+`MappingStrategy`(linear/piecewise/tuiBianHuangDao)+`HuangChiDaoDiffType`(daren/jiyuan/shoushi)+`CelestialProjectorFactory`+投影器 | 已接 UI/管线（feature 分支） |
| 覆写接线 | `ZhouTianModel.copyWith`/`applyOverrides`；`SwephEngine.getSystemDefinition`(三元组→资产)；`ZhouTianModelManager` | 已用于周天制/换算覆写 |
| 每宿宿度 | `ZhouTianModel.starInnDegreeSeq`、`gongDegreeSeq`、`zeroPointAtConstellation`、`epochCorrection` | 数据在 JSON 资产；无编辑 UI |
| 弧矢割圆 | `lib/utils/math/arc_circle.dart`（`HushiGeyuan`，已移植+过测） | **未挂进投影链** |
| 四余档案(模板) | `SiYuProfile`/`BuiltInSiYuProfiles`/`SiYuProfileSelector`/`siYuOverrides`（`lib/domain/engines/siyu/profile/`：`si_yu_profile.dart`/`built_in_profiles.dart`/`si_yu_config_resolver.dart`） | ⚠⚠ **磁盘存在，但被 `.gitignore:15` 的裸模式 `profile` 误吞——整个 `siyu/profile/` 源码目录未进版本控制（HEAD 无、fresh clone 会丢）**。这是先决阻塞项：**B 层动工前必须先修 `.gitignore`（`profile` 改为精确到实际要忽略的路径）并把 `siyu/profile/` 源码提交**，否则 SchoolProfile 仿制的样板本身不可靠、且 B 层新代码可能同样被误忽略 |
| 流派选择 | `EnumSchool`/`SchoolSelector`/`updateSchoolType` | UI 在，但 `updateSchoolType` **整体注释=空操作**；`classicBook` 硬编码 |
| 用户星盘 | `ZhouTianModelManager.loadUserSchemes`(读 `user_schemes/` JSON) | 仅数据层；无 UI |

## 1. 目标与需求（对应领域维度）

| 需求 | 领域维度 | 摘要 |
|---|---|---|
| **G1** 选/自定义二十八星宿（每宿弧度、周天占比） | ④ | UI 选内置宿度表 + 高级逐宿覆写 |
| **G2** 选盘制（黄/赤/天赤道365.25/古黄道；含推黄道与直接 365.25÷360） | ③ | 坐标系 4 选项全暴露 + 换算含弧矢 |
| **G3** 回归/恒星 + 每年起点(春分/冬至) + 偏移量(如 14°) | ③ 零点锚定/0°原点 | 锚定 radio + 起点选择 + 偏移量(档位+数值) |
| **G4** 流派(果老/琴堂/天官)+典籍 → 自动套配 ①②③④⑤ | ②→③④⑤ | 选流派预载整套 A 层默认（可改） |
| **G5** 自定义流派/星盘 | ②/③ | 存命名档案到 Drift；星盘可基于 `user_schemes` 建/改 |

### 已锁定决策（brainstorming 产出）
1. **三轴并列独立**：坐标系(4) / 周天制 / 换算 三个控件各自可选；**新增合法性校验层**做安全网（矛盾组合警告 + 一键归正，不硬拦）。
2. **古黄道 = 复用 `PseudoEcliptic`**（不新增枚举）。
3. **流派套配 = 预载可改**：选流派+典籍填 A 层默认，用户仍可逐项微调（改后标"已自定义"）。
4. **星宿自定义 = 选内置表 + 可选逐宿覆写**（不做全 28 宿必填面板）。
5. **偏移量 = 档位 + 数值微调**（古宿/矫正古宿/今宿各带默认偏移，另给数值框）。
6. **交付 = 一份总设计（本 spec）+ 分阶段实施计划**（阶段一 A 层原语，阶段二 B 层流派编排）。
7. **流派档案仿 `SiYuProfile` 模式**；**弧矢割圆包成第 4 种换算策略**接进现有工厂链。

## 2. 架构总览（两层，坐落于领域 ①②③④⑤）

```
B 层·流派/星盘档案（编排，阶段二）           ← G4、G5
  SchoolProfile = A层各项的命名组合
  内置(果老/琴堂/天官 × 典籍) + 用户自定义档案(Drift)
        │ 选流派+典籍 → 预载填入 A 层默认（可改，改后标“已自定义”）
        ▼
A 层·配置原语（单个可选轴，阶段一）          ← G1、G2、G3
  坐标系(4) × 周天制(360/365.25) × 换算(线性/弧矢/大衍/纪元/授时球面)
      × 锚定(回归/恒星) × 星宿表(+逐宿覆写) × 起点(春分/冬至) × 偏移量(档位+数值)
        │ 三轴独立 + PanelSystemResolver 合法性校验（警告+归正）
        ▼
  BasePanelConfig（持久化载体）
        │
        ▼
  SwephEngine.getSystemDefinition(config)：
     model = ZhouTianModel.fromJson(按坐标三元组选资产)
     return model.applyOverrides(周天制, 换算, 起点, 偏移, 逐宿覆写)   // 默认全 null → 原样
        │
        ▼
  ZhouTianCalculator → CelestialProjectorFactory → 投影器(含弧矢)
```

## 3. A 层 · 配置原语（阶段一，逐项施工）

### 3.0 `ZhouTianModel.applyOverrides` 扩展契约（先定接口）
当前 `applyOverrides(EnumZhouTianModel?, ProjectionConfig?)` 只覆盖周天制 + 投影。本 spec 要新增起点/偏移/逐宿覆写，须先把接口扩成明确契约（**避免施工者各自发挥**）：

```dart
ZhouTianModel applyOverrides({
  EnumZhouTianModel? zhouTianModelOverride,   // 周天制
  ProjectionConfig? projectionOverride,       // 换算
  EnumZeroPointRef? zeroPointRef,             // 起点(春分/冬至/…)
  ConstellationOffsetTier? offsetTier,        // 偏移档位
  double? constellationOffsetDeg,            // 偏移数值(覆盖档位默认)
  Map<Enum28Constellations,double>? starInnDegreeOverrides, // 逐宿覆写
});
```

**硬契约（红线，须测试守护）**：
1. **所有入参全为 null → 返回 `identical(this)`**（零成本、零行为变化）。
2. **一律克隆新对象（走 `copyWith`），绝不原地 mutate**——尤其起点/偏移会改 `zeroPointAtConstellation`/`zeroPointAtGong`、逐宿覆写会改 `starInnDegreeSeq` 这类**列表/对象字段**，必须深拷贝后再改，不得触碰 `ZhouTianModelManager._mapper` 缓存实例。
3. 单项 null → 该维度保持资产原值；非 null → 仅覆写该维度。
4. 逐宿覆写后须校验 `Σ starInnDegreeSeq == totalDegree`（超差交由 §3.2 校验层告警）。

### 3.1 坐标系四选项全暴露（G2）
- `custom_config_section.dart` 的「星道制式」由 2 选项扩为 **4 选项**（`CelestialCoordinateSystem.values`），中文名取枚举 `name`：现代黄道/现代赤道/天赤道/古黄道。
- 三轴独立：坐标系、周天制、换算保持 3 个独立控件。**选坐标系时联动填入推荐默认**（`Ecliptic/Equatorial`→360+linear；`SkyEquatorial`→365.25+linear(保持赤道宿度)；`PseudoEcliptic`→365.25源+推变/弧矢→360），但用户可再改。
- **`SwephEngine.getSystemDefinition` 资产路由矩阵（须显式定义，不能只说"补齐资产键"）**：现状仅 `Ecliptic×Tropical×{Classical/Adjusted/Modern}` 与 `SkyEquatorial` 有分支；`Equatorial`/`PseudoEcliptic` **无直接资产**，必须明确"复用哪个基准资产 + 再套哪种 override"。落地前补全下表（示意，实际值施工时核定并写进 spec/代码注释）：

  | 坐标系 | 锚定(回归/恒星) | 星宿表 | 基准资产 | 叠加 override |
  |---|---|---|---|---|
  | 现代黄道 Ecliptic | 回归 | 古/矫正/今 | `ecliptic_tropical_classical(_adjusted/_modern).json` | 无(360, linear) |
  | 现代赤道 Equatorial | 回归/恒星 | 古/矫正/今 | **复用** `yuan_shoushi_chidao_hengxin.json` 或等价赤道基准 | zhouTian=资产原值, projection=null |
  | 天赤道 SkyEquatorial | 恒星 | 古/矫正/今 | `yuan_shoushi_chidao_hengxin.json` | zhouTian=365.2575, projection=null(保持赤道宿度) |
  | 古黄道 PseudoEcliptic | 回归/恒星 | 古/矫正/今 | **复用天赤道基准资产** | zhouTian=365.2575源, projection=推变/弧矢→360 |

- 无对应资产的组合：保留现有 `UnimplementedError`，并在 UI 兜底提示；`PanelSystemResolver`(§3.2) 须能据 `assetAvailability` 提前警告"该组合暂无资产"。

### 3.2 合法性校验层 `PanelSystemResolver`（新增，安全网）
- 位置：`lib/domain/managers/panel_system_resolver.dart`（纯函数，无副作用，可单测）。
- **输入拓宽**：`validate(BasePanelConfig config, AssetAvailability assets)`——须能读到 `celestialCoordinateSystem / panelSystemType(回归恒星) / constellationSystemType / zhouTianModelOverride / projectionOverride / zeroPointRef / offsetTier / constellationOffsetDeg / starInnDegreeOverrides`，外加"该三元组是否有资产"。输出 `{isCoherent, List<warning>, suggestedFix}`。（窄输入 `(coord,zhouTian,projection)` 校验不了起点/偏移/宿度Σ/资产缺失这些红线。）
- 规则(至少覆盖)：① 现代黄道/赤道 + 365.25 = 矛盾；② 现代黄道 + 推变黄道 = 矛盾（黄道本身不做赤黄投影）；③ 古黄道 + linear = 退化为直接缩放（允许但提示"未用推黄道算法"）；④ 回归/恒星 与 起点(春分/冬至) 语义冲突（如恒星制却选春分点起点）；⑤ 逐宿覆写 `Σ ≠ 周天` 超差；⑥ 当前(coord×panel×constellation)组合无资产。
- UI：不一致时在配置卡显示黄条警告 + "一键归正"按钮（套用 `suggestedFix`）。**非阻断**（尊重三轴独立）。

### 3.3 弧矢割圆接成第 4 种换算策略（G2 补口）
- **定死一种接法**（不留分叉）：`HushiGeyuan` 已有 `quadrant = 周天/4`（二至限）、`zhouTian=365.2575`、`daJu(黄赤交角)=23.9030`——与 `HuangChiDaoDiff` 的四象限进退外壳**同构**，故：**作为 `HuangChiDaoDiffType.hushi` 包成 `HushiGeyuanDiff` 挂到 `TuiBianHuangDaoProjector`**（放 `huang_chi_dao_diff.dart` 同域）。`CelestialProjectorFactory._buildDiff` 增 `hushi` 分支。
  - **仅当**实现时发现 `arc_circle` 的 `declination`/`rightAscension` 无法在象限内表达成 `d(c)=黄赤道差` 单值函数（不符四象限外壳），才退化为独立 `MappingStrategy` 投影器——此为例外，非默认选项。
- **单位约束（写进实现契约）**：`diff(c)` 输入 = **赤道古度**（自本象限二分/二至起算，域 `[0, quadrant]`）；输出 = **黄赤道差 d（度）**；**周天恒取 `365.2575`**（与 `HushiGeyuan.zhouTianConst`、`ShoushiSphericalDiff` 默认一致；`365.25` 仅作近似别名，实现内部统一 365.2575）。
- UI 换算子选项增加"弧矢割圆术"。
- 金标：对 `test/utils/math/arc_circle_test.dart` 既有真值；接入后经工厂端到端复现。**不得改动 `arc_circle.dart` 已验证逻辑。**

### 3.4 起点 + 偏移量（G3）
- `BasePanelConfig` 新增：
  - `EnumZeroPointRef? zeroPointRef`（春分/冬至/…，null=用资产 `zeroPointJieQi`）
  - `ConstellationOffsetTier? offsetTier`（`guXiu`/`adjusted`/`modern`，各带默认偏移常数，如矫正=14°）
  - `double? constellationOffsetDeg`（数值微调，null=用档位默认）
- `applyOverrides` 据此平移 `ZhouTianModel` 零点（`epochCorrection`/`zeroPointAtConstellation` 侧），仅在非 null 时生效。
- UI：起点下拉 + 偏移量档位 radio + 数值框（档位变则数值框默认值随之变，可再手改）。

### 3.5 星宿表选择 + 逐宿覆写（G1）
- UI 暴露 `ConstellationSystemType`（古宿/矫正/今宿）选择器（现无）。
- `BasePanelConfig` 新增 `Map<Enum28Constellations,double>? starInnDegreeOverrides`（null/空=不覆写）。
- `applyOverrides` 用其覆写 `ZhouTianModel.starInnDegreeSeq` 对应宿的弧度；未覆写宿保持资产值；覆写后校验 Σ=周天（超差给警告，走校验层）。
- UI：高级区一个"逐宿微调"折叠面板，仅对被改宿写入 map（**不做 28 宿必填**）。

## 4. B 层 · 流派/星盘档案（阶段二）

### 4.1 `SchoolProfile`（仿 `SiYuProfile`）
- 位置：`lib/domain/engines/school/`（对齐 `siyu/profile/`）。
- 结构：`SchoolProfile { id, name, school(EnumSchool), classicBook, 一整套A层默认(coord/panel/constellation/zhouTian/projection/zeroPoint/offset/siYuProfileId) }`。
- `BuiltInSchoolProfiles`：内置果老/琴堂/天官 × 各典籍（不同典籍值有出入，各出一档），数据以 Dart 常量或 asset JSON 定义。

### 4.2 流派自动套配（G4，预载可改）
- 实现现被注释的 `PanelConfigViewModel.updateSchoolType(school, classicBook)`：`BuiltInSchoolProfiles.byId(...)` → `config.copyWith(...整套A层字段)` → `notifyListeners()`。
- `classicBook` 从硬编码改为由所选流派档案驱动（下拉列该流派的典籍集）。
- 用户改动任一 A 层项后，档案标记 `isCustomized=true`（UI 显示"已自定义"），不再自动跟随流派。

### 4.3 自定义流派/星盘（G5）
- 自定义流派：把当前 A 层 config 存成命名 `SchoolProfile`，持久化到 **Drift 新表 `user_school_profiles`**（仿现有用户数据存法；bump schemaVersion + onUpgrade）。
- 自定义星盘：在 `user_schemes/` 数据层基础上补最小 UI（列出/选择用户 `ZhouTianModel` JSON；创建/编辑可分期，先"导入选择"，全编辑器列 YAGNI 待需）。

## 5. 数据流 / 持久化 / 错误处理

- **数据流**：UI → `BasePanelConfig`(A层字段) →（B层流派预载 `copyWith`）→ `getSystemDefinition` `applyOverrides` 叠加所有覆写到查表 `ZhouTianModel` → 计算器 → 工厂 → 投影器。
- **持久化**：A 层新字段随 `BasePanelConfig` 走 Drift JSON 文本列 → **无 schema 迁移**；旧序列化缺字段→null→现状。B 层 `user_school_profiles` 为新表 → 需迁移。
- **错误处理**：非法组合走 `PanelSystemResolver` 警告（非阻断）；逐宿覆写 Σ 超差警告；资产缺失（未补齐的坐标三元组）保留现有 `UnimplementedError` 并在 UI 兜底提示。

## 6. 测试计划（TDD，金标锁真值）

1. 坐标系四选项 → 正确资产/覆写选择（含 `SkyEquatorial`/`PseudoEcliptic` 新分支）金标。
2. `PanelSystemResolver`：组合矩阵 → 期望 warnings/suggestedFix（含现代黄道+365.25、现代黄道+推变、古黄道+linear）。
3. 弧矢策略：经工厂 → `HushiGeyuanDiff`，`project` 复现 `arc_circle_test` 金标。
4. 起点/偏移量：设档位/数值 → 零点平移正确；null → 不变。
5. 星宿逐宿覆写：覆写个别宿 → `starInnDegreeSeq` 变、其余不变、Σ 校验。
6. 流派预载（B层）：每个内置 `SchoolProfile` → 期望整套 A 层 config。
7. 自定义档案：`user_school_profiles` 持久化往返；`isCustomized` 语义。
8. **向后兼容金标（红线，须逐项 golden，不可含糊）**：以下四种输入的盘面星体/宫位落点必须**与改动前逐位一致**：
   (a) 旧序列化 JSON 缺全部新字段（反序列化为 null）；
   (b) 新建默认 config（新字段全 null）；
   (c) UI 打开后不做任何操作即出盘；
   (d) 用户**显式选 `degree360` + linear** 与 (b) 的 **null 默认** 两条路径结果一致。
   **默认原则（红线）**：初始化/默认 config 一律用 **null（=沿用资产原值）**，**不得在 init 写入 `degree360`+`linear`**——避免默认路径与资产口径产生任何隐式偏差。
9. `flutter analyze` 0 error；`flutter test` 全绿。

## 7. 分阶段实施

- **阶段一 · A 层原语（可独立交付、可用）**：3.1 坐标 4 暴露 → 3.2 校验层 → 3.3 弧矢接入 → 3.4 起点/偏移 → 3.5 星宿选择+覆写。每步 TDD，向后兼容金标守护。
- **阶段二 · B 层流派编排**：4.1 `SchoolProfile` → 4.2 `updateSchoolType` 预载 + 典籍驱动 → 4.3 自定义档案持久化（+星盘导入 UI）。
- 每阶段前对将改符号跑 `impact`，改完 `detect_changes`；HIGH/CRITICAL 先告警。

## 8. 验收标准（DoD）

- [ ] 坐标系 UI 可选 4 项，各自接到正确周天制/换算；三轴独立且矛盾组合有警告+归正。
- [ ] 换算可选"弧矢割圆术"，金标复现 `arc_circle_test`。
- [ ] 回归/恒星、起点(春分/冬至)、偏移量(档位+数值) 均可选且生效。
- [ ] 星宿表可选（古/矫正/今），可对个别宿覆写弧度并生效。
- [ ] 选流派+典籍自动预载整套 A 层（可改，改后标"已自定义"）；`updateSchoolType` 不再是空操作。
- [ ] 可保存/加载自定义流派档案（Drift 往返）。
- [ ] 默认 config 盘面落点与改动前逐位一致（向后兼容金标）。
- [ ] `flutter analyze` 无错误、`flutter test` 全绿。

## 9. 不做（YAGNI / 范围外）

- 不新增坐标系枚举（古黄道复用 `PseudoEcliptic`）。
- 不做全 28 宿必填编辑面板（只逐宿覆写）。
- 不做公式编辑器/DSL；所有配置为"选择 + 调参"。
- 阶段二的自定义星盘先"导入选择"，完整可视化宿度编辑器待需再排。
- 不裁定"哪个流派/典籍正确"（差异取舍由数据档案承载，见领域文档 001 非目标）。
- 春分历元锚点(壁6-8°·待定 O1)沿用 002 现状，不在本 spec 内闭合。
