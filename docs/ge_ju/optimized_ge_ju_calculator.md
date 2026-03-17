# 格局评估管线优化方案 — 技术文档

> 版本: v1.0 · 2026-03-10
> 范围: `lib/domain/managers/ge_ju/`, `lib/domain/services/`, `lib/data/repositories/`

---

## 1. 背景与动机

### 1.1 原始管线的问题

格局评估系统对约 500 条规则（404 条含条件）逐条执行完整的条件树 `evaluate()`，存在两类瓶颈：

**性能瓶颈**

| 环节 | 问题 | 量级 |
|------|------|------|
| 数据组装 | `_assembleRuleData()` 对每条规则单独调用 `getConditionSetsForRule(id)` 和 `getAnnotationsForRule(id)`，底层对全量缓存做 `.where()` 线性扫描 | O(N×M) ≈ 600K 次迭代 |
| 星曜查找 | `GeJuInput.getStarGong(star)` 每次遍历 11 颗星体找目标星 | 单次 O(11)，累计数千次 |
| 条件评估 | 所有规则无差别进入完整 `evaluate()`，包括条件缺失的 ~92 条和不可能匹配的大量规则 | 无短路、无预判 |
| 无缓存 | 每次评估（命盘计算完成后自动触发）都重新加载全部规则数据 | 重复 I/O |

**准确率瓶颈**

| 问题 | 影响 |
|------|------|
| `conditions == null` 的 ~92 条规则被静默标记为 `matched: false` | 无法区分"不匹配"和"无法评估" |
| 条件解析失败被 `catch (_) {}` 吞掉 | 错误不可追踪 |
| `starGongStatusMapper` 从未被填充 | ~18 条使用庙旺条件的规则永远 false |
| `moonPhase` 固定为 `New` | 月相条件不准确 |
| 无计时、无统计 | 无法衡量优化效果 |

### 1.2 优化目标

1. **降低评估耗时** — 通过索引、缓存、预过滤三层加速
2. **评估状态透明** — 每条规则的结果携带明确的状态标签，区分"不匹配"与各类"无法评估"
3. **可观测性** — 计时、统计、日志，为后续优化提供数据支撑
4. **行为不变** — 对已有逻辑不做语义变更，匹配结果与优化前完全一致

---

## 2. 优化架构总览

```
                      GeJuEvaluationService
                              │
                 ┌────────────┼────────────┐
                 ▼            ▼            ▼
          loadAllRules   loadAllCS    loadAllAnn    ← Phase 1: 批量加载
          (一次查询)     Grouped()    Grouped()       (索引 Map + 3 次异步)
                 │            │            │
                 └────────────┼────────────┘
                              ▼
                    _assembledRuleDataCache          ← Phase 2: 规则缓存
                              │                       (CRUD 后 invalidate)
                              ▼
              ┌── GeJuPreFilter.fromInput(input) ──┐
              │   一次性 O(11) 扫描 → 星盘事实表    │ ← Phase 6: 预过滤器
              └───────────────┬────────────────────┘
                              ▼
               ┌──────── 逐条规则 ────────┐
               │                          │
               ▼                          ▼
        quickEvaluate()             scope 检查
        三值逻辑判定                    │
           │                          ▼
     ┌─────┼─────┐            scopeSkipped
     ▼     ▼     ▼
   true  false  null
     │     │     │
     ▼     ▼     ▼
  matched  pre   完整 evaluate()      ← Phase 3: 评估状态追踪
           Filter                      (7 种 GeJuEvaluationStatus)
           Rejected
               │
               ▼
      GeJuEvaluationSummary            ← Phase 4: 计时 + 统计
      (withTiming + debugPrint)
```

---

## 3. 各 Phase 详细设计

### Phase 1: Repository 索引优化 + 批量加载

**问题**: `getConditionSetsForRule(ruleId)` 每次对全量缓存做 `.where()` 线性扫描

**方案**: 构建 `Map<String, List<T>>` 索引，查找 O(1)

```
修改文件:
├── lib/domain/repositories/ge_ju_repository.dart        ← 新增接口
├── lib/data/repositories/ge_ju_repository_impl.dart     ← 索引 + 实现
└── lib/data/datasources/local/daos/ge_ju_dao.dart       ← 全量查询方法
```

**新增索引字段**:
```dart
Map<String, List<GeJuConditionSet>>? _builtInConditionSetsByRuleId;
Map<String, List<GeJuAnnotation>>?   _builtInAnnotationsByRuleId;
```

在 `_ensureBuiltInConditionSetsLoaded()` / `_ensureBuiltInAnnotationsLoaded()` 中构建索引，`clearCache()` 同步清除。

**新增批量接口**:
```dart
// IGeJuRepository
Future<Map<String, List<GeJuConditionSet>>> loadAllConditionSetsGrouped();
Future<Map<String, List<GeJuAnnotation>>>   loadAllAnnotationsGrouped();
```

实现逻辑：合并 built-in 索引 + user 全量查询（`_dao.getAllConditionSets()`），单次返回。

**效果**: 数据组装从 N 次异步查询 → 3 次异步查询（rules + conditionSets + annotations）。

---

### Phase 2: 评估服务规则数据缓存

**问题**: `_assembleRuleData()` 每次评估都重新加载

**方案**: 缓存组装结果，CRUD 后手动失效

```
修改文件:
├── lib/domain/services/ge_ju_evaluation_service.dart     ← 缓存 + invalidate
└── lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart  ← CRUD 后调用
```

```dart
List<RuleEvaluationData>? _assembledRuleDataCache;

void invalidateRuleDataCache() {
  _assembledRuleDataCache = null;
}
```

`evaluateNatalChart()` / `evaluateXingXian()` 调用 `_assembleRuleData()` 时优先返回缓存。ViewModel 在用户增删改规则后调用 `invalidateGeJuCache()`。

---

### Phase 3: 评估状态追踪

**问题**: `conditions == null`、解析失败、scope 不适用的规则都被标记为 `matched: false`，无法区分

**方案**: 引入 7 级评估状态枚举

```dart
enum GeJuEvaluationStatus {
  matched,            // 条件评估通过
  unmatched,          // 条件评估不通过
  conditionSetMissing,// 无 ConditionSet
  conditionMissing,   // ConditionSet 存在但 conditions 为 null
  evaluationError,    // 条件评估抛异常（附 debugPrint 输出）
  scopeSkipped,       // scope 不适用（如本命盘跳过行限规则）
  preFilterRejected,  // 预过滤器判定条件不可能满足
}
```

`GeJuResult` 新增 `evaluationStatus` 字段。`GeJuEvaluationSummary` 新增统计 getter:

```dart
int get totalConditionMissing;
int get totalConditionSetMissing;
int get totalEvaluationErrors;
int get totalScopeSkipped;
int get totalPreFilterRejected;
```

**错误日志替换**: `ge_ju_sqlite_data_source.dart` 中的 `catch (_) {}` 替换为 `catch (e) { debugPrint(...) }`。

---

### Phase 4: 评估计时

```dart
final sw = Stopwatch()..start();
final summary = GeJuEvaluator.evaluateWithConditionSets(...);
sw.stop();
final timed = summary.withTiming(sw.elapsedMilliseconds);
```

`GeJuEvaluationSummary` 新增 `evaluationDurationMs` 字段和 `withTiming()` 方法。服务层输出汇总日志:

```
GeJu[NatalChart] 14/496 matched | preFilterRejected=312 | conditionMissing=42 | errors=0 | scopeSkipped=0 | 3ms
```

---

### Phase 5: 数据缺口文档化

两个已知数据缺口在代码中以 `debugPrint` 警告和 `TODO` 注释标记：

1. **`starGongStatusMapper`**: `buildFromPanel()` 不传入庙旺数据 → ~18 条使用 `starGongStatus` 条件的规则永远 `false`
2. **`moonPhase`**: `buildElevenStarsSetFromPanel()` 固定为 `EnumMoonPhases.New` → 需要从 `tyme` 库计算真实月相

这两个缺口需要上游数据支持，本次不实现具体接入。

---

### Phase 6: 预过滤器（GeJuPreFilter）— 核心优化

这是本次优化中收益最大的改进，基于以下核心洞察：

> **如果星盘中不存在同宫关系，那么所有含 `sameGong` 的规则直接标为不符合；**
> **如果出生季节为春，那么需要判断夏/秋/冬的格局也不需要判断；**
> **如果木星在"井木犴"，那么所有判断木星在其他星宿的格局都标为不符合。**

#### 6.1 设计原理

预过滤器从 `GeJuInput` 一次性提取"星盘事实"（O(11) 扫描），然后对每条规则的条件树做 **三值逻辑快速判定**，无需进入完整的 `evaluate()` 调用：

| 返回值 | 含义 | 后续动作 |
|--------|------|---------|
| `true` | 条件**一定**满足 | 直接标记 `matched`，跳过 `evaluate()` |
| `false` | 条件**一定**不满足 | 标记 `preFilterRejected`，跳过 `evaluate()` |
| `null` | 无法确定 | 回退到完整 `evaluate()` |

#### 6.2 预计算的星盘事实表

| 字段 | 类型 | 来源 | 用途 |
|------|------|------|------|
| `_starGongMap` | `Map<Star, Gong>` | 遍历 `starsSet` | 替代 `getStarGong()` 的 O(11) 扫描 |
| `_starConstellationNameMap` | `Map<Star, String>` | 遍历 `starsSet` | 星宿名 O(1) 查找 |
| `_starWalkingTypeMap` | `Map<Star, WalkingType>` | `fiveStarWalkingTypeMapper` | 运行状态 |
| `_lifeGong` | `EnumTwelveGong` | `bodyLifeModel.lifeGong` | 命宫 |
| `_lifeConstellationName` | `String` | `lifeConstellation.starName` | 命度 |
| `_destinyGongMapper` | `Map<DestinyGong, Gong>` | `destinyGongMapper` | 功能宫映射 |
| `_siZhuMap` | `Map<String, Star>` | 4 个 master | 四主 |
| `_starsFourTypeMapper` | `Map<Star, Map<FourType, Set<Star>>>` | 直接复用 | 恩难仇用 |
| `_huaYaoMapper` | `Map<Star, List<HuaYaoItem>>` | 直接复用 | 化曜 |
| `_starGongStatusMapper` | `Map<Star, List<Status>>?` | 直接复用 | 庙旺（可能 null） |
| `_shenShaMapper` | `Map<Gong, List<ShenSha>>` | 直接复用 | 神煞 |
| `_season` / `_isDayBirth` / `_monthZhi` / `_moonPhase` | 各标量 | `GeJuInput` | 时间条件 |
| `_kongWangSet` | `Set<DiZhi>` | `JiaZiShenSha.getKongWangAtDiZhi()` | 空亡 |
| `_currentXianGong` / `_xianPalaceStarsSet` | 可选 | `GeJuInput` | 行限条件 |

#### 6.3 AND/OR 三值逻辑传播

```
AND(a, b, c):
  任一 child = false  →  AND = false（短路退出）
  全部 child = true   →  AND = true
  否则                →  AND = null

OR(a, b, c):
  任一 child = true   →  OR = true（短路退出）
  全部 child = false  →  OR = false
  否则                →  OR = null

NOT(x):
  x = true   →  NOT = false
  x = false  →  NOT = true
  x = null   →  NOT = null
```

对于 62.6% 的 `and` 根节点规则，只要一个廉价的子条件（如 `seasonIs`、`isDayBirth`）返回 `false`，整条规则立即被拒绝，后续昂贵的空间查找完全跳过。

#### 6.4 条件覆盖率

预过滤器覆盖 **23 种叶子条件类型，对应当前 837 个叶子节点的 100%**：

| 类别 | 条件类型 | 叶子数 | 占比 |
|------|---------|--------|------|
| **关系** | `sameGong`, `sameConstellation`, `oppositeGong`, `trineGong`, `squareGong` | 218 | 26.0% |
| **位置** | `starInGong`, `starInConstellation`, `starInKongWang`, `starWalkingState` | 230 | 27.5% |
| **时间** | `seasonIs`, `isDayBirth`, `monthIs`, `moonPhaseIs` | 142 | 17.0% |
| **结构** | `lifeGongAt`, `lifeConstellationAt`, `starGuardLife`, `starInDestinyGong` | 142 | 17.0% |
| **用神** | `starIsSiZhu`, `starFourType`, `starHasHuaYao` | 5 | 0.6% |
| **庙旺** | `starGongStatus` | 18 | 2.2% |
| **神煞** | `starWithShenSha`, `gongHasShenSha` | 1 | 0.1% |
| **行限** | `xianAtGong`, `xianAtConstellation`, `xianMeetStar` | 7 | 0.8% |

仅 `sameJing` 和 `sameLuo` 两种（当前 0 条规则使用）返回 `null`。

#### 6.5 预期效果

以一个典型命盘为例（11 星分布在 12 宫，约 2-3 对同宫）：

- ~92 条无 conditions → `conditionMissing`（不进入评估）
- ~312 条有 conditions 但预过滤器判定 `false` → `preFilterRejected`（O(1) 跳过）
- ~14 条匹配 → `matched`（其中部分由预过滤器直接判定 `true`）
- ~78 条完整评估后 `unmatched`

**实际进入 `evaluate()` 的规则数从 ~404 降至 ~78**，减少约 80%。

---

## 4. 文件变更清单

| 文件 | Phase | 变更 |
|------|-------|------|
| `lib/domain/managers/ge_ju/ge_ju_pre_filter.dart` | 6 | **新增** · 预过滤器（23 种叶子 + 三值逻辑） |
| `lib/domain/entities/models/ge_ju/ge_ju_result.dart` | 3, 4 | 新增 `GeJuEvaluationStatus` 枚举（7 级）+ 统计 getter + 计时 |
| `lib/domain/managers/ge_ju/ge_ju_evaluator.dart` | 3, 6 | 集成预过滤器 + 传播 `evaluationStatus` |
| `lib/domain/services/ge_ju_evaluation_service.dart` | 2, 4 | 规则缓存 + 批量组装 + 计时 + 日志 |
| `lib/domain/repositories/ge_ju_repository.dart` | 1 | 新增批量加载接口 |
| `lib/data/repositories/ge_ju_repository_impl.dart` | 1 | 索引 Map + 批量实现 |
| `lib/data/datasources/local/daos/ge_ju_dao.dart` | 1 | 新增 `getAllConditionSets()` / `getAllAnnotations()` |
| `lib/data/datasources/local/ge_ju_sqlite_data_source.dart` | 3 | 条件解析错误日志（替换 `catch (_) {}`） |
| `lib/domain/managers/ge_ju/ge_ju_input_builder.dart` | 5 | 数据缺口警告 + TODO |
| `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` | 2 | CRUD 后失效缓存 |
| `lib/presentation/widgets/ge_ju/ge_ju_result_panel.dart` | — | 中国风 UI 重写 + Wrap 布局 + `singleColumnMode` |

---

## 5. 验证方案

### 5.1 静态检查

```bash
flutter analyze   # 预期: 0 error
flutter test      # 预期: GeJu 相关测试全部通过
```

### 5.2 运行时检查

运行 example app → 计算星盘 → 检查 `debugPrint` 输出：

```
GeJu[NatalChart] 14/496 matched | preFilterRejected=312 | conditionMissing=42 | errors=0 | scopeSkipped=0 | 3ms
```

关注指标：
- `preFilterRejected` 应 > 200（大量规则被快速跳过）
- `conditionMissing` 应 ≈ 42（已知的无条件规则）
- `errors` 应 = 0
- 耗时应在个位数毫秒级

### 5.3 一致性验证

对比优化前后同一星盘的匹配结果（`matched` 的规则 ID 集合）应完全一致。预过滤器只改变速度，不改变语义。

---

## 6. 后续扩展方案

### 6.1 短期（可直接实施）

| 方案 | 预期收益 | 复杂度 |
|------|---------|--------|
| **接入 `starGongStatusMapper`** | ~18 条规则恢复正确评估 | 中 — 需从上游加载庙旺数据 |
| **计算真实月相** | `moonPhaseIs` 条件准确化 | 低 — 从 `tyme` 库获取农历日 |
| **`sameJing`/`sameLuo` 预过滤** | 覆盖率从 99.8% → 100% | 低 — 目前 0 条规则使用，仅预留 |

### 6.2 中期（需数据支持）

| 方案 | 说明 |
|------|------|
| **AND 子条件重排序** | 解析 `and` 时将廉价条件（`isDayBirth`/`seasonIs`）排到前面，进一步提升短路命中率。当前 `and` 子条件按 JSON 原始顺序，未必最优 |
| **条件 TwelveGongSystem.resolve 预解析** | `StarInGongCondition.gongs` 中的宫位名在 JSON 解析时已确定，可预先 resolve 为 `EnumTwelveGong` 缓存到条件对象上，避免每次评估重复 resolve |
| **按 scope 预分区规则** | 将 `ruleData` 预分为 `natalRules` / `xingxianRules` / `bothRules`，`evaluateNatalChart` 只迭代 natal + both，避免遍历行限专用规则 |

### 6.3 长期（架构级）

| 方案 | 说明 |
|------|------|
| **倒排索引** | 为每种条件类型建立 `条件参数 → 规则ID集合` 的倒排索引。例如 `sameGong(Sun, Moon) → [rule_001, rule_042, ...]`。评估时先从星盘事实查出满足的条件参数，再反查关联规则，只评估有可能匹配的规则子集。将 O(N) 逐条评估降为 O(K) 候选评估（K << N）|
| **增量评估** | 行限格局随流年变化时，仅重新评估 scope=xingxian/both 的规则；命盘不变时复用命盘格局缓存 |
| **条件指纹** | 为每条规则的条件树生成确定性哈希，当条件相同时复用评估结果（跨用户/跨会话） |

---

## 7. 数据分析附录

基于 `example/assets/tmp/ge_ju_conditions_dump.json`（404 条含条件规则）的统计：

### 7.1 根节点类型分布

```
and:                  253  (62.6%)
starInGong:            51  (12.6%)
sameGong:              47  (11.6%)
or:                    16  ( 4.0%)
starInConstellation:   14  ( 3.5%)
starGuardLife:          6  ( 1.5%)
starInKongWang:         4  ( 1.0%)
其他:                  13  ( 3.2%)
```

### 7.2 叶子条件类型分布

```
sameGong:             214  (25.6%)    ← 同宫
starInGong:           208  (24.9%)    ← 星在宫
seasonIs:              90  (10.8%)    ← 季节
starInConstellation:   74  ( 8.8%)    ← 星在宿
lifeGongAt:            57  ( 6.8%)    ← 命宫位置
starGuardLife:         50  ( 6.0%)    ← 星守命
isDayBirth:            44  ( 5.3%)    ← 昼夜
starInDestinyGong:     31  ( 3.7%)    ← 星在功能宫
starGongStatus:        18  ( 2.2%)    ← 庙旺状态
starInKongWang:        15  ( 1.8%)    ← 空亡
其他 13 种:            36  ( 4.3%)
─────────────────────────────────
合计:                 837  (100%)
```

### 7.3 条件嵌套深度

```
depth 1:  135 规则  (33.4%)    ← 单条件
depth 2:  221 规则  (54.7%)    ← AND/OR 一层
depth 3:   43 规则  (10.6%)    ← 嵌套两层
depth 4:    4 规则  ( 1.0%)
depth 5:    1 规则  ( 0.2%)
```

最深仅 5 层，递归开销可忽略。优化重点应放在叶子条件的快速判定上。
