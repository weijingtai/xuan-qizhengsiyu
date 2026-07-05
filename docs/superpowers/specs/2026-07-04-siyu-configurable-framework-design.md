# 四余可配置计算框架 · 设计（Spec）

> 本 spec 是对现有实施计划 `docs/superpowers/plans/2026-07-04-qizhengsiyu-siyu-rahu-ketu-convention.md` 的**架构上升**：把其中"紫气专用"的策略/注册表泛化为"全四余通用"的分组策略框架，并新增分段校准、流派档案、spec/工厂/UI。落地时**并入同一份计划**（紫气/罗计重构为框架实例）。

## 1. 目标与需求

让用户以**「选择 + 调参」**（非公式 DSL）自定义四余（罗睺/计都/月孛/紫气）的计算：

| 需求 | 说明 | 对应组件 |
|---|---|---|
| **R1** 自定义四余速率 + 计算逻辑 | 每组选算法变体（星历/古法平行/…）+ 调参（速率/历元/顺逆） | `SiYuGroupAlgorithm` + 变体 + `SiYuGroupSpec` |
| **R2/R3** 不同流派 × 星制 → 不同算法 | 例：果老+黄道→紫气算法A；琴堂+天赤道→紫气算法B | `SiYuProfile` + 单项覆盖 |
| **R4** 时间分段校准 | 节点前用典籍原始、节点后加校准；**硬切换、可多段** | `PiecewiseGroupAlgorithm` |
| 约束 | 自定义 = 选择 + 调参，**不做公式编辑器/脚本** | spec + 工厂 + 两层 UI |

## 2. 架构总览

```
配置(每盘持久化)
  siYuProfileId + siYuOverrides(Map<SiYuGroup,SiYuGroupSpec>) + coordinateOverride
        │  解析(档案默认 ⊕ 覆盖)
        ▼
  每组一个 SiYuGroupSpec  ──SiYuAlgorithmFactory.build──▶  SiYuGroupAlgorithm
        │                                                        │ computePositions(jd,dt)
        ▼                                                        ▼
  罗计组 / 月孛组 / 紫气组                              Map<EnumStars, double>(位置)
        │                                                        │
        └──────────────── 汇入现有 StarsAngle / StarPositionRawData 管线 ──────────────┘
```

## 3. 核心抽象：三个算法组

四余的计算按**算法组**而非单颗星组织（罗睺/计都天然成对）：

```dart
enum SiYuGroup { luoJi, yueBo, ziQi }

abstract interface class SiYuGroupAlgorithm {
  String get id;
  Set<EnumStars> get bodies;                 // 本组负责的星
  Map<EnumStars, double> computePositions({  // 一次产出本组所有星位置(度)
      required double julianDay, required DateTime datetime});
}
```

- **罗计组**：产出 `{罗睺, 计都}`，内建三铁律——**恒逆行、恒 180° 对冲、可互换升降**（`EnumRahuKetuConvention`：罗降计升=古法正统默认 / 罗升计降=民间西法）。升降分配由 `RahuKetuDefinition.assign(N, convention)` 强制。
- **月孛组**：产出 `{月孛}`，顺行。
- **紫气组**：产出 `{紫气}`，顺行、虚星无星历、纯平行。

## 4. 算法变体（每组可选）

| 变体类 | 适用组 | 说明 | 关键参数 |
|---|---|---|---|
| `EphemerisNodePairAlgorithm` | 罗计 | sweph 平交点 `SE_MEAN_NODE` → assign | convention |
| `LinearNodePairAlgorithm` | 罗计 | 交点古法平行（逆行）→ assign | dailyMotion(逆)、epoch、convention |
| `EphemerisApogeeAlgorithm` | 月孛 | sweph `SE_MEAN_APOG`(可选 `OSCU_APOG`) | variant |
| `LinearApogeeAlgorithm` | 月孛 | 远地点古法平行（顺行） | dailyMotion、epoch |
| `LinearZiQiAlgorithm` | 紫气 | 授时/Moira/自定义平行（顺行） | totalDegree、dailyMotion、epoch |
| `TianguanZiQiAlgorithm` | 紫气 | 逐年 13°05′ 粗算宫度 | epochYear、yearlyIncrement |

**关键收敛**：`LinearNodePair`/`LinearApogee`/`LinearZiQi` 本质同一套「平行推算」——`(totalDegree, dailyMotion, direction, epochJd, epochPosition)` 参数化，仅顺逆/速率/历元不同。可用一个通用 `LinearParallelCore` 实现，三组各薄封装（罗计封装额外套 `RahuKetuDefinition`）。→ **R1（自定义速率）由 `dailyMotion` 参数一次满足全三组。**

坐标框架：`totalDegree`=360（黄道）或 365.25（天赤道古度），随 `coordinate` 传入；日行/归一化/出宿度均按该框架（度制铁律，勿跨框架混用）。

## 5. 分段多模型（R4）

```dart
class PiecewiseGroupAlgorithm implements SiYuGroupAlgorithm {
  // 段按 fromJulianDay 升序；computePositions 取 fromJulianDay ≤ jd 的最后一段
  final List<({double fromJulianDay, SiYuGroupAlgorithm algorithm})> segments;
}
```

- 任何组可被分段包装（罗计/月孛/紫气通用）。
- "节点前典籍、节点后校准"=两段：段0(典籍常数, 从 -∞)、段1(校准常数, 从 T节点)。因每段是完整算法，"偏移量"= 后段直接换成校准后的历元/速率（涵盖常量偏移与速率漂移），可叠多段多时代。
- **边界=硬切换**（节点处允许小跳变；后段历元由用户自行校准到与前段对齐，即"续上再漂"）。

## 6. 流派档案 + 单项覆盖（R2/R3）

```dart
class SiYuProfile {
  final String id, name;                        // "guolao_ecliptic" / "果老·黄道"
  final CelestialCoordinateSystem coordinate;   // 星制(默认，可被覆盖)
  final Map<SiYuGroup, SiYuGroupSpec> groups;   // 各组算法 spec(可含分段)
}
```

内建档案（示例，可扩充）：

| 档案 | 星制 | 罗计组 | 月孛组 | 紫气组 |
|---|---|---|---|---|
| 果老·黄道 | 黄道360° | 星历·罗降计升 | 星历·远地点 | 黄道平行（A） |
| 琴堂·天赤道 | 天赤道365.25 | 星历·罗降计升 | 星历·远地点 | 天赤道·Moira（B，已验证） |
| 清时宪 | 黄道 | 星历·罗升计降 | 星历·OSCU | 乾隆甲子元 |
| 耶律天官 | 黄道 | 星历·罗降计升 | 星历 | 逐年13°05′粗宫 |

**单项覆盖**：配置 `{profileId, overrides: Map<SiYuGroup, SiYuGroupSpec>, coordinateOverride?}`。某组/星制有覆盖用覆盖，否则用档案默认。星制**亦可单项覆盖**。

## 7. spec + 工厂 + 配置 + UI（选择 + 调参，无 DSL）

```dart
@JsonSerializable()
class SiYuGroupSpec {              // 可序列化描述，UI 产出，工厂消费
  final String kind;              // "ephemeris_node"/"linear_node"/"ephemeris_apogee"/"linear_apogee"/"linear_ziqi"/"tianguan"
  final Map<String, double> params;    // dailyMotion/epochJd/epochPos/direction/totalDegree...
  final List<SiYuSegmentSpec>? segments; // 分段(节点JD + 子spec)，可选
  final int? rahuKetuConventionIndex;    // 罗计组用
}

class SiYuAlgorithmFactory {       // kind → builder；可注册扩展新 kind
  SiYuGroupAlgorithm build(SiYuGroupSpec spec, CoordinateContext ctx);
}
```

- **配置持久化**（接 `BasePanelConfig`，`@JsonSerializable`，每盘可存，向后兼容缺省=默认档案）。
- **排盘解析**：档案默认 ⊕ 覆盖 → 每组 spec → 工厂造算法 → `computePositions` → 汇入 `StarsAngle`/`StarPositionRawData`。
- **UI 两层**：
  - 基础：选档案（下拉）即用全套默认。
  - 高级（展开某组）：选算法 kind（下拉）→ 填数字参数（速率/历元日期/历元位置/顺逆；罗计另有升降开关）→ 可"+ 增加节点"加分段（日期 + 子参数）→ 星制下拉覆盖。
  - **全程"选下拉 + 填数字 + 加时间段"，无公式/脚本。**
- **护栏**：工厂按 kind 校验参数；罗计组无论如何配置强制"逆行+180°+可互换"。

## 8. 已验证数据与考证参数（作为框架内 spec 的常数）

- **紫气·天赤道·Moira 实测**（已 4 点最小二乘验证，残差<0.65 古度）：totalDegree=365.25、dailyMotion=0.0356771 古度/日、锚 2026-07-04 15:15(JD 2461226.135)=翼宿4°38′36″=333.843、郭守敬赤道宿距表（累加365.25）。
- **紫气·天赤道·授时正典**：10227.1792 日、女宿二度、1280 冬至历元（合典籍，与 Moira 差 ~9°/700 年）。
- **紫气·黄道·时宪西法**：
  - 历元基准：乾隆九年甲子（1744年）冬至。
  - 元度：「七宫17°50′」，宫序以春分白羊为初宫起算（西洋黄道宫）。
  - 基准绝对黄经：`197.833333°`（整分，命理及默认配置）。
  - 原始历书高精度版（含秒微：七宫17度50分14秒53微）：`197.837237°`（供精细计算配置）。
- **紫气·赤道·耶律天官**：
  - 历元基准：上古上元甲子岁首（不对应公元年份，采用相对积年 $N$ 的偏移推算）。
  - 速率：`13°05'/年` (13.083333°/年)。
  - 起元度数：「子宫虚六度」，子宫以冬至起算（中式赤道十二次，不使用西洋黄道白羊宫），对应的赤道绝对起点经度为 `6.0°`。
  - 坐标系统：赤道十二次（子宫起0°）。与黄道时宪系完全隔离。
- **紫气·赤道·符天箕宿**：
  - 历元基准：动态从 `ZhouTianCalculator.getStartEquatorialLon(Enum28Constellations.Ji)` 提取箕宿赤道起点（避免硬编码，兼容岁差偏移）。
  - 坐标隔离：为避免循环依赖，`zhou_tian_model.dart` 作为纯物理常数层禁止导入任何业务层和校准器。`ZhouTianCalculator` 仅暴露无状态静态内存查表快捷方法，由 `SwephEngine` 等上层调度获取值后，注入 `EpochCalibrator` 进行平行推算。
- **罗计**：默认罗降计升（古法正统），见 `docs/.../…rahu-ketu-convention.md` 的《罗计史料裁定》。

## 9. 与现有 16-Task 计划的整合

- **保留并泛化**：`RahuKetuDefinition`(Task 2)→罗计组内部；`ZiQiAlgorithm`+Registry(Task 9–13)→`SiYuGroupAlgorithm`+`SiYuAlgorithmFactory`；`totalDegree`、郭守敬宿距(Task 16)、Moira 常数(Task 15) 全部保留。
- **新增**：`SiYuGroupAlgorithm` 接口 + 三组 + 变体类、`LinearParallelCore`、`PiecewiseGroupAlgorithm`、`SiYuProfile` + 内建档案、`SiYuGroupSpec` + 工厂、config 字段(profileId/overrides/coordinateOverride) + 两层 UI。
- **重构**：罗计从 `StarsAngle.toMap` 单点翻转，升格为罗计组算法（`toMap` 仍是出口，但升降由组算法产出）；紫气从 `SiYuCalculator._computeZiQi`/注入式 `ZiQiAlgorithm` 升格为紫气组算法。
- **Part A 罗计用户可选默认罗降计升、零回归**的原则不变；紫气 Moira 默认不变。

## 10. 测试策略

- 三组算法各单测（罗计 180°/逆行/convention 互换、月孛顺行、紫气 Moira 四点 golden）。
- `LinearParallelCore` 参数化单测（速率/顺逆/框架 mod）。
- `PiecewiseGroupAlgorithm` 段选择 + 节点边界单测。
- `SiYuProfile` 解析 + 单项覆盖单测；工厂 build + 参数校验单测。
- config 序列化往返 + 向后兼容单测。
- 端到端：切档案/覆盖后 `StarPositionRawData` 中四余位置随之变化，默认档案零回归。

## 11. 明确不做（YAGNI）

- 公式/脚本 DSL（用户不编写逻辑，只选择+调参）。
- 赤道制/似黄道恒星制的**七政**完整管线（`HistoricalEngine` 补全）——本框架仅保证四余在两坐标系自洽。
- TT/UT 时间基准统一、黄道紫气岁差——登记为遗留议题。
