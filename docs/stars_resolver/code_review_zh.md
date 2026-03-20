# StarsResolver 代码审查报告

**日期：** 2026-03-20
**审查文件：**
- `lib/presentation/pages/StarsResolver.dart`（860 行）
- `lib/presentation/models/ui_star_model.dart`（564 行）
- `test/ui_star_model_test.dart`（269 行）

**调用方：**
- `qi_zheng_si_yu_viewmodel.dart` — 调用 `calculateMinSafeAngle()`、`resolveUIStars()`
- `beauty_page_viewmodel.dart` — 调用 `calculateMinSafeAngle()`、`resolveUIStars()`

---

## 1. 整体目标与已完成工作

### 1.1 StarsResolver 的作用

`StarsResolver` 是一个 **UI 层的星体碰撞解析器**，用于解决圆形星盘上天体标签/图标的重叠问题。当多颗星体在星盘圆环上占据相同或相近的角度位置时，它们的显示会发生重叠。StarsResolver 通过调整星体的显示角度，使其分散排列、互不遮挡，同时尽可能贴近其真实天文位置。

### 1.2 核心问题领域

在一个半径为 R 的圆形星盘中，每颗星体占据一个由以下因素决定的角度"占位区"：
- 星体图标的物理尺寸（`starBodyRadius`）
- 圆环的几何参数（`outerR`、`innerR`）

当两颗星体的角度占位区发生重叠时，需要将其中一颗或两颗推开。这本质上是一个 **圆形域上的一维区间装箱问题**（0-360 度）。

### 1.3 已完成的算法清单

| 算法 | 方法 | 状态 |
|------|------|------|
| 最小安全角度计算 | `calculateMinSafeAngle()` | 已完成 |
| 两星重叠解析 | `doResolve2Stars()` | 已完成 |
| 同角度星体扇形展开 | `doResolveSameAngleStars()` | 已完成 |
| 多星星座构建 | `doResolveConstellation()` | 已完成 |
| 星座吸收单独星体 | `doResolveConstellationWithStars()` | 已完成 |
| 星座间重叠处理 | `handleTwoConstellationModel()` | 已完成 |
| 图的连通分量检测 | `GraphUtils.findConnectedComponents()` | 已完成 |
| 圆周角度排序 | `sortCircularAngles()` / `sortCircularAnglesByGivenCenter()` | 已完成 |
| 基于优先级的星体排序 | `sortInRangeStarsNoneSameAngleWithPriority()` | 已完成（未使用） |
| 完整流水线编排 | `resolveUIStars()` | 已完成 |

---

## 2. 算法详细说明

### 2.1 `calculateMinSafeAngle(outerR, innerR, r)` — 几何安全角度计算

**目的：** 给定由 `outerR`/`innerR` 定义的圆环和半径为 `r` 的星体图标，计算两颗星体不发生重叠所需的最小角度间隔（单位：度）。

**算法流程：**
1. 计算圆环的中线半径：`R = (outerR + innerR) / 2`
2. 计算星体半径与圆环半径之比：`ratio = r / R`
3. 若 `ratio >= 1`（星体和圆环一样大），返回 360（无法放置两颗星体）
4. 否则，使用反正弦公式：`2 * arcsin(ratio) * 180/pi`

**数学原理：** 两个半径为 `r` 的圆放置在半径为 `R` 的圆周上，当它们中心之间的圆心角等于 `2 * arcsin(r/R)` 时恰好相切。这是标准的圆周装箱公式。

**已处理的边界情况：** `outerR <= innerR`、`innerR` 为负、`r` 为零或负。

### 2.2 `resolveUIStars(stars)` — 完整流水线编排器

**目的：** 主入口方法。接收一个 `UIStarModel` 列表（每个星体包含原始角度和安全范围），返回经过调整后的显示角度列表。

**算法流程（流水线）：**
1. **排序** — 按 `originalAngle` 对星体排序
2. **分类** — 将星体分为两组：
   - `needHandled`：与至少一颗其他星体重叠的星体（通过 `setupInRangeAngle()` 检测）
   - `singleStar`：无重叠的独立星体
3. **构建重叠图** — 每颗星体映射到其重叠的星体集合
4. **提取连通分量** — 使用 DFS 图遍历（`GraphUtils`）
5. **解析每个分量** — 每个连通的重叠星体集合通过 `doResolveConstellation()` 构建为一个"星座"
6. **吸收邻近单独星体** — 对每个星座，检查是否有 `singleStar` 落入其扩展边缘内；若是，则吸收进星座
7. **解析星座间重叠** — 若存在多个星座，通过 `handleTwoConstellationModel()` 检查并解析星座间的重叠
8. **展平并返回** — 将所有星座内的星体和剩余的单独星体合并为一个列表

### 2.3 `doResolve2Stars(stars)` — 两星重叠解析

**目的：** 当恰好有 2 颗星体重叠时，将它们对称推开。

**算法流程：**
1. 若两者角度相同，委托给 `doResolveSameAngleStars()`
2. 按圆周位置排序（头/尾）
3. 检查头星的范围是否包含尾星（`inRangeAngle`）
4. 计算重叠距离的一半
5. 将头星向左推、尾星向右推该半距离

### 2.4 `doResolveSameAngleStars(stars)` — 同角度星体扇形展开

**目的：** 当 N 颗星体占据完全相同的角度时，围绕该点均匀展开。

**算法流程：**
- **奇数个星体：** 最高优先级的星体留在中心。其余星体交替向左/右分布，偏移量 = `rangeAngleEachSide * 位置序号`
- **偶数个星体：** 星体交替向左/右分布，每个偏移 `rangeAngleEachSide * 位置序号 +/- rangeAngleEachSide/2`

这会在原始角度周围形成对称的扇形排列，并尊重星体优先级（优先级越高越靠近中心）。

### 2.5 `doResolveConstellation(stars)` — 多星星座构建

**目的：** 将一组连通的重叠星体解析为不重叠的排列。

**算法流程：**
1. 若恰好 2 颗星体：使用 `doResolve2Stars()`
2. 若所有星体角度相同：使用 `doResolveSameAngleStars()`
3. 否则，按角度分组并分派到：
   - `_processOddCircularAngles()`（奇数组的情况）
   - `_processEvenCircularAngles()`（偶数组的情况）

**奇数情况：**
1. 找到中间角度组（中心）
2. 从该组构建中心星座
3. 处理左侧各组：每组的星体从中心向左推开
4. 处理右侧各组：每组的星体从中心向右推开

**偶数情况：**
1. 找到中间的两个角度组（左中、右中）
2. 从这两组构建中心（处理不同的星体数量比例）
3. 从中心向外处理剩余的左/右各组

### 2.6 `handleTwoConstellationModel(constellations)` — 星座间重叠处理

**目的：** 在各星座内部解析完成后，检查星座之间是否存在重叠并推开它们。

**算法流程：**
1. 对每一对 (i, j)，检查星座 j 的中心是否落入星座 i 的边缘范围内
2. 若中心同时重叠两侧边缘：抛出异常（实际中不应发生）
3. 若左侧重叠：将 j 向左推开重叠量
4. 若右侧重叠：将 j 向右推开重叠量

### 2.7 `GraphUtils.findConnectedComponents(graph)` — 图的 DFS 遍历

**目的：** 使用深度优先搜索提取连通分量。

**算法：** 经典 DFS + visited 集合。对每个未访问节点，遍历所有可达邻居，收集为一个分量。返回已排序的集合列表。

### 2.8 `sortCircularAngles(angles)` — 圆周角度排序

**目的：** 围绕选定的锚点对角度进行圆周排序，即使跨越 0°/360° 边界也能正确排列两侧的角度。

**算法流程：**
1. 选择锚点（输入的中位数）
2. 对每个其他角度，计算顺时针和逆时针到锚点的距离
3. 根据最短路径将每个角度分类为"锚点左侧"或"锚点右侧"
4. 分别按距锚点的距离排序
5. 合并为：`[...左侧(远到近), 锚点, ...右侧(近到远)]`

### 2.9 `checkAngleInRange(edges, otherAngle)` — 范围检测

**目的：** 判断一个角度是否落在给定弧段（由左/右边缘定义）内，处理跨 0° 的情况。

**返回值：** `Tuple3<是否在范围内, 左侧距离?, 右侧距离?>`
- `item1`：该角度是否在弧段范围内
- `item2`：到左侧边缘的距离（非 null 表示更靠近左侧边缘）
- `item3`：到右侧边缘的距离（非 null 表示更靠近右侧边缘）
- 两者均非 null：角度恰好在中点

### 2.10 `calculateMidpointAngle(angleA, angleB)` — 圆上中点计算

**目的：** 求两个角度之间的中点角度，始终取较短弧。

**算法：** 计算 `diff = (B - A + 360) % 360`。若 diff > 180，交换 A/B（取短弧）。中点 = `(A + diff/2) % 360`。

---

## 3. 数据模型概要

### 3.1 `UIStarModel`

| 字段 | 类型 | 用途 |
|------|------|------|
| `star` | `EnumStars` | 星体标识（日、月等） |
| `originalAngle` | `double` | 真实天文位置（0-360） |
| `rangeAngleEachSide` | `double` | 角度占位区的一半（由图标尺寸和圆环几何计算） |
| `priority` | `int` | 显示优先级（4 为最高，决定居中放置） |
| `adjustedAngle` | `double?` | 碰撞解析后的显示位置 |
| `adjustCount` | `int` | 调整次数 |
| `previousAdjustedDirection` | `bool?` | 上次调整方向 |
| `originalEdges` | `Tuple3` | 原始范围的 (左边缘, 右边缘, 中心) |
| `adjustedEdges` | `Tuple3?` | 调整后的边缘 |
| `inRangeStar` | `Map` | 缓存的重叠信息 |

**关键属性：** `angle` getter 返回 `adjustedAngle ?? originalAngle`，因此所有下游计算在变更后自动使用调整后的位置。

### 3.2 `UIConstellationModel`

一组已解析的星体，作为单一视觉单元处理：
- `orderedStars`：按圆周位置排序的星体列表
- `edges`：由首/尾星体边缘计算得出的可缩放边界
- 方法：`addStar()`、`inRangeAngle()`、`adjustAngle()`（统一平移所有星体）

### 3.3 `Edge` mixin / `StarEdgeAngle` 接口

`UIStarModel` 和 `UIConstellationModel` 共享的多态接口，提供：
- `edges`（左/右/中心边界）
- `centerAngle`
- `inRangeAngle(other)` — 范围重叠检测
- `addStar(star)` — 将星体吸收到边缘持有者中

---

## 4. 已知缺陷（来自测试用例）

测试文件 `test/ui_star_model_test.dart` 记录了若干已知缺陷：

### 缺陷 3：`correctCircleAngle()` — 单次环绕 Bug
- **问题：** 仅执行一次 `+360` 或 `-360` 修正
- **影响：** 小于 -360 或大于等于 720 的角度无法归入 [0, 360) 范围
- **示例：** `correctCircleAngle(-400)` 返回 `-40` 而非 `320`
- **风险：** 实际中较低（调整量通常较小），但在大量累积调整时可能出错

### 缺陷 4：`getMinDiffAngleOfTwoStar()` — 使用 `max()` 而非 `sum()`
- **问题：** 返回 `max(star1.range, star2.range)` 而非 `star1.range + star2.range`
- **影响：** 当两颗星体图标大小不同时，计算出的安全距离过小，可能导致重叠
- **示例：** 范围分别为 3 和 5 的星体返回 5 而非 8
- **风险：** 中等 — 当星体尺寸不同时会导致间距不足

### 缺陷 5：（已记录但实际正确）
- `inRangeAngle()` 在目标恰好位于中心时正确返回两侧距离

### 缺陷 8：`adjustAngle()` 的累积调用
- **问题：** `adjustAngle()` 读取 `angle` getter（首次调用后返回 `adjustedAngle`），因此连续调用会累积叠加
- **影响：** 属于设计决策而非 Bug，但调用方必须知晓调整是相对于当前（可能已调整过的）位置
- **风险：** 若调用方知悉则低；若调用方假设调整相对于原始位置则高

### 缺陷 9：`compareTo()` 不对称
- **问题：** 相同星体返回 `0`，不同星体始终返回 `1` — 永远不返回 `-1`
- **影响：** 违反 `Comparable` 契约：`a.compareTo(b)` 应返回 `-b.compareTo(a)`
- **另外：** `compareTo() == 0` 并不意味着 `== true`（Equatable 使用 `[star, originalAngle]`）
- **风险：** 当前使用场景下较低（仅用于 `sort()`），但可能导致细微的排序不稳定

---

## 5. 代码质量问题

### 5.1 可变状态设计

`UIStarModel` 高度可变 — `adjustAngle()`、`toLeftAdjustAngle()`、`toRightAdjustAngle()` 均直接修改内部状态。这导致：
- **副作用耦合：** 调用 `doResolve2Stars()` 会直接修改输入的星体对象
- **重复运行风险：** 对相同星体列表运行两次 `resolveUIStars()` 会导致调整量叠加
- **测试困难：** 每个测试场景必须创建全新的实例

**建议：** 考虑使调整操作返回新模型（不可变方式），或至少在文档中明确标注 `resolveUIStars()` 具有破坏性。

### 5.2 代码重复

`inRangeAngle()` 被 **实现了三次**，逻辑几乎完全相同：
1. `UIStarModel.inRangeAngle()`（ui_star_model.dart 第 122-186 行）
2. `UIConstellationModel.inRangeAngle()`（ui_star_model.dart 第 470-531 行）
3. `StarsResolver.checkAngleInRange()`（StarsResolver.dart 第 380-435 行）

三者都实现了相同的跨 0° 范围检测逻辑。这违反了 DRY 原则，并存在分歧风险。

类似地，`sortCircularAngles()` 在 `StarsResolver` 和 `UIConstellationModel` 中均有实现，逻辑完全相同。

### 5.3 残留的调试代码

`StarsResolver.dart`（第 115-126、137、152-153 行）和 `ui_star_model.dart`（第 153、160、165 行等多处）中有大量被注释掉的 `print()` 语句。应当移除或替换为正式的日志记录。

### 5.4 拼写与命名问题

- `_scalebleEdges` 应为 `_scalableEdges`
- `caculateScalebleEdges` 应为 `calculateScalableEdges`
- `sortInRangeStarsNoneSameAngleWithPriority()` — 方法名过长，且在当前流水线中未被使用
- 文件名 `StarsResolver.dart` 使用了 PascalCase（按 Dart 规范应为 `stars_resolver.dart`）

### 5.5 基于异常的流程控制

多个方法在正常操作中可能出现的条件下抛出通用 `Exception`：
- `doResolveConstellation()` — 当 2 颗星体"不应聚群"时抛出
- `handleTwoConstellationModel()` — 在"中心重叠"时抛出
- `_adjustStarAngle()` — 当星体超出范围时抛出

这些异常在生产环境中会导致应用崩溃。应当优雅地处理这些情况，或在上游确保前置条件成立。

### 5.6 `Tuple` 的使用

代码大量依赖 `tuple` 包的 `Tuple2` 和 `Tuple3`。这降低了可读性 — `item1`、`item2`、`item3` 脱离上下文毫无意义。建议：
- 使用命名记录（Dart 3.0+）：`({bool inRange, double? leftDist, double? rightDist})`
- 使用专用的结果类

### 5.7 未使用的方法

`sortInRangeStarsNoneSameAngleWithPriority()`（第 258-294 行）已定义但在当前流水线中从未被调用。它实现了基于优先级的排序，但 `resolveUIStars()` 并未使用它。

---

## 6. 算法缺口与缺失部分

### 6.1 缺少迭代细化

当前算法为单次遍历：一旦星体被推开，不会再检查该推移是否导致了新的重叠。对于星体密集在相近角度的星盘，单次遍历可能无法完全消除所有重叠。

**缺失内容：** 一个迭代循环，在每轮调整后重新检查重叠，收敛到稳定布局（或在 N 次迭代后终止）。

### 6.2 缺少全局优化

每个星座独立解析，然后逐对解析星座间的重叠。这种贪心策略可能产生次优布局，总位移量大于必要值。

**缺失内容：** 一个全局优化步骤，在满足所有最小距离约束的前提下最小化所有星体的总角度位移（例如力导向布局或约束求解方法）。

### 6.3 缺少边界约束

星体可以被推到离原始位置任意远的地方。没有最大位移限制，可能将星体放置在完全不同的星盘区域。

**缺失内容：** 最大位移上限，或当星体被显著位移时的视觉指示。

### 6.4 优先级未被充分利用

`UIStarModel.priority`（1-4 级）在 `doResolveSameAngleStars()` 中用于中心放置，但在通用流水线中未被一致使用。未被调用的 `sortInRangeStarsNoneSameAngleWithPriority()` 方法表明这一功能已规划但未集成。

### 6.5 缺少多圈层支持

该算法仅在单个圆环上运作。若星盘有多个圈层（如本命盘 + 流年盘），每个圈层必须独立解析。跨圈层的标签碰撞未被处理。

### 6.6 `_createStarMap` 的键冲突

`_createStarMap()`（第 495-501 行）将 `角度 → 星体` 映射。若两颗星体共享同一角度，后者会静默覆盖前者，导致数据丢失。该方法用于 `doResolveConstellationWithStars()` 和排序方法中。

---

## 7. 测试覆盖率评估

### 7.1 已测试内容（ui_star_model_test.dart）

- `correctCircleAngle` — 归一化、边界情况、已知环绕 Bug
- `getMinDiffAngleOfTwoStar` — 相同/不同范围、已知 max-vs-sum Bug
- `adjustAngle` — 状态变更、边缘重算、累积行为
- `inRangeAngle` — 非跨 0°、跨 0°、精确中心情况
- `compareTo` — 不对称 Bug、`==` 语义不匹配
- `addStar` — 同角度、超出范围、范围内推移

### 7.2 未测试内容

- **`StarsResolver` 方法**：`resolveUIStars()`、`doResolve2Stars()`、`doResolveConstellation()`、`handleTwoConstellationModel()`、`sortCircularAngles()`、`calculateMinSafeAngle()` — 均无直接单元测试
- **`UIConstellationModel`**：`addStar()`、`inRangeAngle()`、`adjustAngle()`、`caculateScalebleEdges()` — 未测试
- **`GraphUtils.findConnectedComponents()`** — 未测试
- **边界情况**：完整流水线中的 0°/360° 边界跨越、3+ 颗星体重叠、星座间重叠解析
- **集成测试**：使用真实星体数据的端到端测试（例如：在已知位置模拟 11 颗星体，验证所有输出角度均不重叠）

### 7.3 建议增加的测试

1. **StarsResolver.calculateMinSafeAngle** — 边界输入、几何验证
2. **StarsResolver.resolveUIStars** — 使用模拟星体的集成测试，覆盖：
   - 所有星体已分离（无需调整）
   - 2 颗星体重叠
   - 3+ 颗星体处于同一角度
   - 星体位于 0°/360° 边界附近
   - 所有 11 颗星体聚集在同一区域
3. **GraphUtils** — 简单图连通性验证
4. **sortCircularAngles** — 跨 0° 排序正确性

---

## 8. 架构观察

### 8.1 层次违规

`StarsResolver` 位于 `lib/presentation/pages/`，但它是一个纯算法类，没有任何 UI 依赖。应当放在工具层或领域层（例如 `lib/presentation/utils/` 或 `lib/domain/utils/`）。

### 8.2 模型位置

`UIStarModel` 正确地位于 `lib/presentation/models/`，因为它是 UI 特有的模型。但它包含大量业务逻辑（范围检测、星体添加），这些逻辑可以从数据模型中分离出来。

### 8.3 依赖项

代码依赖 `tuple` 包。Dart 3.0+ 已提供 Records 语法，可以消除此依赖。

---

## 9. 总结

### 做得好的地方
- 整体流水线设计（分类 → 建图 → 连通分量 → 解析 → 合并）架构合理
- 圆周角度处理（0°/360° 边界）在全代码中得到一致处理
- 基于优先级的同角度星体居中放置是良好的 UX 选择
- 基于图论的连通分量检测是发现重叠集群的正确方法

### 主要风险
1. **可变状态** 使系统脆弱且难以测试
2. **缺少迭代细化** 可能在密集星盘中留下未解决的重叠
3. **正常路径中抛异常** 可能导致应用崩溃
4. **`StarsResolver` 本身无测试覆盖**
5. **`correctCircleAngle` 和 `getMinDiffAngleOfTwoStar` 的已知缺陷** 可能导致边界情况 Bug

### 建议优先行动
1. 为 `resolveUIStars()` 添加集成测试，覆盖各种星体配置
2. 修复 `correctCircleAngle()`，使用取模运算 `((angle % 360) + 360) % 360`
3. 修复 `getMinDiffAngleOfTwoStar()`，将范围求和而非取最大值
4. 移除或守护正常路径上的异常抛出代码
5. 将重复的 `inRangeAngle` 逻辑提取为单一共享工具方法
