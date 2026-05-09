# 格局评估系统架构说明 v1

> 适用分支: `feature/ge_ju`
> 最后更新: 2026-03-05

---

## 目录

1. [概述](#1-概述)
2. [数据模型](#2-数据模型三实体架构)
3. [数据来源](#3-数据来源双库分离)
4. [完整调用流程](#4-完整调用流程)
5. [条件系统](#5-条件系统)
6. [流派与吉凶体系](#6-流派与吉凶体系)
7. [依赖注入配置](#7-依赖注入配置)
8. [已知限制与待办](#8-已知限制与待办)

---

## 1. 概述

格局（GeJu）评估系统的职责是：给定一张已计算好的七政四余命盘，判断哪些天文格局条件成立，输出一份带有吉凶标注的匹配报告。

### 核心设计原则

- **分库**：内置规则数据库（只读 SQLite）与用户数据库（Drift）严格分离，互不干扰。
- **三实体**：一条格局由 `GeJuRule`（锚点）+ `GeJuAnnotation`（文字层）+ `GeJuConditionSet`（逻辑层）组成，三者独立演进。
- **流派隔离**：同一格局可有多个流派的判断方案，运行时按 `preferredSchools` 选择最合适的方案执行。
- **条件树**：判断逻辑以 JSON 序列化的布尔条件树表达，支持 AND / OR / NOT 任意嵌套。

---

## 2. 数据模型：三实体架构

```
GeJuRule          ←────────── 格局身份锚点
  id: String             唯一 ID（内置前缀 "common_001_..."）
  name: String           格局名称（如"日月夹命"）
  aliases: []            别名列表
  scope: GeJuScope       natal / xingxian / both
  authorType: String     'built-in' | 'user'

GeJuAnnotation    ←────────── 文字层（N:1 → Rule）
  id: String
  ruleId: String         → 对应 GeJuRule.id
  schools: []            适用流派 ID 列表
  jiXiong: JiXiongEnum   大吉/吉/小吉/平/小凶/凶/大凶
  geJuType: GeJuType     贵/富/贫/贱/夭/寿/贤/愚/其他
  description: String    格局文字含义

GeJuConditionSet  ←────────── 逻辑层（N:1 → Rule）
  id: String
  ruleId: String         → 对应 GeJuRule.id
  schools: []            适用流派 ID 列表
  conditions: GeJuCondition?  可执行的条件树（可为 null）
  label: String          方案标识（如"果老方案"）
```

### 三实体关系图

```
                    ┌──────────────┐
                    │  GeJuRule    │  (身份锚点)
                    │  id, name    │
                    └──────┬───────┘
                           │ 1:N
              ┌────────────┴────────────┐
              ▼                         ▼
   ┌──────────────────┐     ┌───────────────────────┐
   │ GeJuAnnotation   │     │   GeJuConditionSet    │
   │ (文字层)         │     │   (逻辑层)            │
   │ jiXiong          │     │   conditions (树)     │
   │ description      │     │   schools             │
   └──────────────────┘     └───────────────────────┘
```

评估时，`GeJuEvaluator` 将三者打包为 `RuleEvaluationData`，选中一个 `ConditionSet` 执行条件树，再匹配最相关的 `Annotation` 填充吉凶文字。

---

## 3. 数据来源：双库分离

### 3.1 内置数据库（只读）

| 项目 | 内容 |
|------|------|
| 文件路径 | `example/assets/qizhengsiyu/ge_ju/ge_ju_database.sqlite` |
| companion_system 源文件 | `companion_system/assets/ge_ju_database.sqlite` |
| Schema 版本 | v3（已移除 `level` 列，`jixiong` 统一为 7 级中文） |
| 内容规模 | 496 个格局，496 条规则，404 条含判断条件 |
| 吉凶分布 | 吉 278 / 凶 170 / 平 48 |
| 流派 | 全部归属 `guo_lao`（果老星宗） |

**表结构**

```sql
ge_ju_patterns (id TEXT PK, name TEXT, aliases TEXT)   -- 格局锚点
ge_ju_rules    (id INT PK, pattern_id, school_id,      -- 每条规则
                jixiong, ge_ju_type, scope,
                conditions TEXT, brief TEXT,
                explanation TEXT, version TEXT,
                is_active BOOL)
ge_ju_schools  (id TEXT PK, name TEXT)                  -- 流派
```

**加载机制**（`ge_ju_builtin_database.dart`）

```
App 启动
  └─ LazyDatabase 回调
       └─ 从 assets 将 SQLite 文件写入 ApplicationSupportDirectory
       └─ NativeDatabase 打开文件（只读模式使用，每次覆盖以保证最新）
```

### 3.2 用户数据库（读写）

| 项目 | 内容 |
|------|------|
| ORM | Drift（代码生成） |
| 文件 | `AppDatabase`，位于 `lib/data/datasources/local/app_database.dart` |
| 表 | `ge_ju_rules`、`ge_ju_condition_sets`、`ge_ju_annotations`、`ge_ju_user_preferences` |
| DAO | `GeJuDao` |
| 迁移 | 旧版 `user_rules.json` 通过 `GeJuLegacyMigrator` 首次启动时自动迁移 |

### 3.3 数据合并策略（`GeJuRepositoryImpl`）

```
loadAllRules()
  ├─ _builtInDataSource.loadBuiltInRules()    → built-in（内置 SQLite）
  └─ GeJuDao.getAllRules()                     → user（Drift DB）
  → concat: [内置规则..., 用户规则...]

getConditionSetsForRule(ruleId)
  ├─ 内置 ConditionSet（按 ruleId 过滤缓存列表）
  └─ Drift ConditionSet
  → concat

getAnnotationsForRule(ruleId)
  ├─ 内置 Annotation（按 ruleId 过滤缓存列表）
  └─ Drift Annotation
  → concat
```

内置数据第一次加载后缓存至内存（`_builtInRulesCache` 等）。`clearCache()` 清空三个缓存字段。

---

## 4. 完整调用流程

### 4.1 前置：星盘计算（已有流程）

```
UI 触发（用户输入出生信息）
  └─ QiZhengSiYuViewModel.calculate(observerPosition)
       └─ calculateWithConfig(config, observer)
            ├─ CalculationEngine.calculateStarPositions()
            ├─ GenerateBasePanelService.calculate()
            │    → 产出 BasePanelModel（含星位、宫位、化曜、神煞等）
            ├─ _basicLifePanel = panel              ✦ 存储
            ├─ _birthYearJiaZi = observer.yearGanZhi  ✦ 存储
            └─ _birthMonthZhi = observer.monthGanZhi.zhi ✦ 存储
```

### 4.2 格局评估调用链

```
UI 触发（如点击"格局"按钮）
  └─ QiZhengSiYuViewModel.evaluateGeJu()
       │
       ├─[1] GeJuInputBuilder.buildElevenStarsSetFromPanel(panel)
       │       ├─ 遍历 panel.starAngleMapper
       │       ├─ Sun  → SunInfo(angle, enterInfo)
       │       ├─ Moon → MoonInfo(angle, enterInfo, moonPhase=New)
       │       └─ 其余 → ElevenStarsInfo(star, angle, enterInfo,
       │                    walkingType from fiveStarWalkingTypeMapper)
       │       → Set<ElevenStarsInfo>
       │
       └─[2] GeJuEvaluationService.evaluateNatalChart(
                 panelModel, starsSet, monthZhi, yearJiaZi)
                 │
                 ├─[2a] GeJuInputBuilder.buildFromPanel(...)
                 │       → 构建 GeJuInput（完整评估上下文）
                 │         · coordinateSystem / preferredSchools
                 │         · starsSet + starRelationship（星间关系矩阵）
                 │         · bodyLifeModel（命身宫主）
                 │         · destinyGongMapper（十二宫映射）
                 │         · starsFourTypeMapper（恩难仇用）
                 │         · huaYaoMapper（禄暗福耗）
                 │         · season / monthZhi / isDayBirth / moonPhase
                 │         · shenShaMapper / jiaZiShenSha / yearJiaZi
                 │
                 └─[2b] _assembleRuleData()  [并发]
                         ├─ repository.loadAllRules()          → [Rule...]
                         └─ 对每条 Rule 并发:
                              repository.getConditionSetsForRule(id)
                              repository.getAnnotationsForRule(id)
                         → List<RuleEvaluationData>
                              (Rule + ConditionSets[] + Annotations[])
                         │
                         └─[2c] GeJuEvaluator.evaluateWithConditionSets(input, ruleData)
                                 │
                                 └─ 对每个 RuleEvaluationData:
                                    ├─ _isScopeApplicable()  // natal/xingxian/both
                                    └─ evaluateRuleWithConditionSets()
                                        ├─[A] 按 preferredSchools 选 ConditionSet
                                        │      → 无匹配则取第一个（回退）
                                        ├─[B] 按 preferredSchools / relatedAnnotationIds
                                        │      选最相关 Annotation
                                        ├─[C] conditions.evaluate(input)
                                        │      → true / false
                                        └─[D] GeJuResult.fromConditionSet(
                                                 rule, cs, annotation, matched)

       → GeJuEvaluationSummary
            · allResults: [GeJuResult...]
            · matchedPatterns      （matched=true 的子集）
            · matchedAuspiciousPatterns   （isJi() = true）
            · matchedInauspiciousPatterns （isXiong() = true）
       │
       └─ geJuSummaryNotifier.value = summary   ✦ 通知 UI
```

### 4.3 GeJuInput 字段一览

| 字段 | 类型 | 来源 |
|------|------|------|
| `coordinateSystem` | `CelestialCoordinateSystem` | 配置（默认 ecliptic） |
| `preferredSchools` | `Set<String>` | 参数（默认 `{'guo_lao'}`） |
| `starsSet` | `Set<ElevenStarsInfo>` | `buildElevenStarsSetFromPanel()` |
| `starRelationship` | `StarToStarRelationshipModel` | `create(starsSet)` |
| `bodyLifeModel` | `BodyLifeModel` | `BasePanelModel` |
| `destinyGongMapper` | `Map<EnumDestinyTwelveGong, EnumTwelveGong>` | 反转自 `BasePanelModel.twelveGongMapper` |
| `starsFourTypeMapper` | — | `EnumStarsFourType.getStarsFourTypeMapper()` |
| `huaYaoMapper` | — | `BasePanelModel.huaYaoItemMapper` |
| `season` | `FourSeasons` | `FourSeasons.getFourSeason(monthZhi)` |
| `monthZhi` | `DiZhi` | `observer.monthGanZhi.zhi` |
| `isDayBirth` | `bool` | 太阳是否在巳午未申宫 |
| `moonPhase` | `EnumMoonPhases` | MoonInfo 类型检查，缺省 New |
| `shenShaMapper` | — | `BasePanelModel.shenShaItemMapper` |
| `jiaZiShenSha` | `JiaZiShenSha` | 占位实例（空亡等静态方法仍可用） |
| `yearJiaZi` | `JiaZi` | `observer.yearGanZhi` |
| `currentXianGong` | `EnumTwelveGong?` | 行限评估专用，命盘评估为 null |
| `currentXianConstellation` | `Enum28Constellations?` | 行限评估专用 |
| `xianPalaceStars` | `List<EnumStars>?` | 行限评估专用 |

### 4.4 行限格局（XingXian）调用

与命盘评估相同，额外提供行限数据：

```dart
GeJuEvaluationService.evaluateXingXian(
  panelModel: panel,
  starsSet: starsSet,
  monthZhi: monthZhi,
  yearJiaZi: yearJiaZi,
  xianGong: currentDaXianGong,          // 大限/流年当前宫
  xianConstellation: currentXianInn,    // 当前星宿
)
```

评估器会过滤 `scope == xingxian` 或 `scope == both` 的规则（命盘规则的 `scope == natal`，不会被执行）。

---

## 5. 条件系统

### 5.1 条件基类

```
GeJuCondition (abstract)
  evaluate(GeJuInput) → bool
  describe() → String
  toJson() → Map
  factory fromJson(Map)  ← 类型分发入口
```

### 5.2 已实现的条件类型（13 种）

| 类型键 | 类 | 说明 | 实际使用量 |
|--------|----|------|-----------|
| `and` | `AndCondition` | 逻辑与（子条件全部为真） | 大量（组合器） |
| `or` | `OrCondition` | 逻辑或（任一子条件为真） | 大量（组合器） |
| `sameGong` | `SameGongCondition` | 指定星曜同宫 | 常用 |
| `trineGong` | `TrineGongCondition` | 指定星曜三合 | 常用 |
| `starInGong` | `StarInGongCondition` | 星曜在指定宫位（支持地支/十二次别名） | 常用 |
| `starInConstellation` | `StarInConstellationCondition` | 星曜在指定星宿 | 常用 |
| `starInKongWang` | `StarInKongWangCondition` | 星曜落空亡 | 使用 |
| `starWalkingState` | `StarWalkingStateCondition` | 星曜顺逆留迟速 | 使用 |
| `starGuardLife` | `StarGuardLifeCondition` | 星曜守命 | 使用 |
| `starInDestinyGong` | `StarInDestinyGongCondition` | 星曜在命理十二宫（命宫/财帛等） | 使用 |
| `starGongStatus` | `StarGongStatusCondition` | 星曜庙旺陷（需 starGongStatusMapper） | 使用 |
| `seasonIs` | `SeasonIsCondition` | 出生季节 | 使用 |
| `xianMeetStar` | `XianMeetStarCondition` | 行限遇指定星曜 | 行限专用 |

**SQLite 数据库中实际使用的类型分布**（按出现频次）：

```
and / or    → 组合多条件（大多数复杂格局）
sameGong    → 最常见的单一条件（日月同宫、五星会聚等）
trineGong   → 三合关系
starInGong  → 特定宫位要求
starInConstellation / starGongStatus / starWalkingState / starInKongWang
seasonIs / starGuardLife / starInDestinyGong / xianMeetStar
```

### 5.3 条件 JSON 格式示例

```json
// 简单：日月夹命
{"type": "sameGong", "stars": ["Sun", "Moon"]}

// 组合：AND 条件
{
  "type": "and",
  "conditions": [
    {"type": "starGuardLife", "star": "Venus"},
    {"type": "starGongStatus", "star": "Venus", "statuses": ["Miao", "Wang"]}
  ]
}

// 复杂：OR 嵌套
{
  "type": "or",
  "conditions": [
    {"type": "trineGong", "stars": ["Jupiter", "Mars", "Saturn", "Venus", "Mercury"]},
    {"type": "starInGong", "star": "Sun", "gongs": ["Zi", "Wu", "Mao", "You"]}
  ]
}
```

### 5.4 评估错误处理

条件树 `evaluate()` 发生异常时：

```dart
try {
  final matched = targetCs.conditions!.evaluate(input);
  ...
} catch (e) {
  // 静默捕获，该格局视为未匹配，不中断整体流程
  return GeJuResult.fromConditionSet(rule, targetCs, annotation, matched: false);
}
```

`GeJuSQLiteDataSource.loadBuiltInConditionSets()` 中 `GeJuCondition.fromJson()` 也有静默 `catch (_) {}`，解析失败的规则 `conditions` 置 `null`，会在评估时被视为未匹配。

---

## 6. 流派与吉凶体系

### 6.1 当前流派

| school_id | 名称 | 说明 |
|-----------|------|------|
| `guo_lao` | 果老星宗 | 内置数据库唯一流派，496 条规则全属此派 |

`preferredSchools` 默认值：`{'guo_lao'}`。
若没有偏好流派匹配的 ConditionSet，评估器回退至第一个 ConditionSet（保证不丢失规则）。

### 6.2 吉凶枚举（7 级）

```dart
enum JiXiongEnum {
  DA_JI("大吉"),  JI("吉"),  XIAO_JI("小吉"),
  PING("平"),
  XIAO_XIONG("小凶"),  XIONG("凶"),  DA_XIONG("大凶"),
  WEI_ZHI("未知"),
}

// 分类方法
isJi()   → DA_JI | JI | XIAO_JI
isXiong() → DA_XIONG | XIONG | XIAO_XIONG
```

**SQLite → JiXiongEnum 映射**（`GeJuSQLiteDataSource._toJiXiong()`）

```
DB 存储的中文字符串 → JiXiongEnum.fromName(value)
  "大吉" → DA_JI,  "吉" → JI,  "小吉" → XIAO_JI
  "平" → PING
  "小凶" → XIAO_XIONG,  "凶" → XIONG,  "大凶" → DA_XIONG
  其他 → WEI_ZHI → null（Annotation.jiXiong 为 null，评估结果 jiXiong = PING）
```

当前内置数据只有 `吉/平/凶` 三种值（原 companion_system 3 级），`大吉/小吉/大凶/小凶` 留待后期数据完善。

### 6.3 格局类型（GeJuType）

```dart
enum GeJuType {
  gui(贵), fu(富), pin(贫), jian(贱),
  yao(夭), shou(寿), xian(贤), yu(愚), other(其他)
}
```

---

## 7. 依赖注入配置

`lib/di.dart` Provider 注册顺序（精简版，顺序即依赖顺序）：

```
ShenShaLocalDataSource / HuaYaoLocalDataSource
ShenShaRepository / HuaYaoRepository
ShenShaService / HuaYaoService
ZhouTianModelManager / ShenShaManager / HuaYaoManager
──────── GeJu 基础设施（必须在 QiZhengSiYuViewModel 之前）────────
AppDatabase
GeJuDao(AppDatabase)
GeJuBuiltInDatabase(createGeJuBuiltInConnection())
GeJuBuiltInDataSource → GeJuSQLiteDataSource(GeJuBuiltInDatabase)
IGeJuRepository → GeJuRepositoryImpl(builtInDataSource, dao)
GeJuCrudService(IGeJuRepository)
GeJuEvaluationService(IGeJuRepository)           ← 核心评估服务
GeJuSchoolService(GeJuDao)
──────────────────────────────────────────────────────────────────
QiZhengSiYuViewModel(
  shenShaManager, huaYaoManager, zhouTianModelManager,
  geJuEvaluationService  ← 注入评估服务
)
GeJuListViewModel / GeJuEditorViewModel / GeJuDetailViewModel
GeJuSchoolListViewModel / GeJuSchoolEditorViewModel
```

---

## 8. 已知限制与待办

### 限制

| 问题 | 说明 |
|------|------|
| 月相缺失 | `buildElevenStarsSetFromPanel()` 中 Moon 月相固定为 `New`；`BasePanelModel` 不存储月相，`moonPhaseIs` 条件目前无法正确评估 |
| 庙旺状态缺失 | `GeJuInput.starGongStatusMapper` 为 `null`（未传入），`starGongStatus` 条件始终无法匹配 |
| 单流派 | 内置数据库目前只有 `guo_lao`，多流派选择功能已支持但无数据 |
| 吉凶精度 | 内置数据 `jixiong` 只有 3 级（吉/平/凶），7 级分级有待数据完善 |

### 短期待办

- [ ] **月相**：在 `GenerateBasePanelService` 中计算真实月相，存入 `BasePanelModel` 或 `ObserverPosition`，供 `buildElevenStarsSetFromPanel()` 使用
- [ ] **庙旺状态**：从数据集加载 `StarPositionStatusDatasetModel`，通过 `GeJuInputBuilder.build(starStatusDataList: ...)` 传入
- [ ] **行限格局**：`QiZhengSiYuViewModel.evaluateGeJu()` 扩展支持大限/流年参数调用 `evaluateXingXian()`
- [ ] **结果缓存**：`evaluateGeJu()` 避免命盘未变时重复评估（可比较 panel hashCode）
- [ ] **错误日志**：条件解析/评估失败时记录具体 ruleId 便于调试
