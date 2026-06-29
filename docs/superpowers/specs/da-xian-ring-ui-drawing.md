# 大限环图 UI 绘制规范

> 所属项目：七政四余 (qizhengsiyu)
> 源文件：`lib/presentation/widgets/rings/da_xian_ring.dart`、`da_xian_ring_painter.dart`、`lib/utils/da_xian_calculate_helper.dart`

---

## 1. 概述

大限环图是一个**双层同心扇环图**，使用 Flutter `CustomPainter` 实现：

- **外环**：洞微大限（`DaXian`）的年限分配
- **内环**：洞微百六限（`Xian106`）的年限分配（使用固定年限表，不依赖于计算引擎）

每层环图将 360° 均分为 12 宫（每宫 30°），再将每宫的年限拆分为"每一年"的槽位。环图的视觉复杂度在于：**年限值都有小数部分（0.25/0.5/0.75年跨宫衔接）**，这导致了非均匀的角度分配算法。

---

## 2. 渲染架构

```
DaXianRing (StatelessWidget)
  └── CustomMultiChildLayout (DongWeiLayoutDelegate)
        ├── LayoutId 0: CustomPaint(Painter=DaXianRingPainter)   ← 外环: 大限
        └── LayoutId 1: CustomPaint(Painter=DaXianRingPainter)   ← 内环: 百六限
```

### 2.1 DaXianRing 参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `gongYearsMapper` | `Map<EnumTwelveGong, YearMonth>` | 12宫各自的年限 |
| `outerRadius` / `innerRadius` | `double` | 外环半径/内环半径 |
| `baseGongOffsetAngle` | `double` | 环图起始偏移角度 |
| `gongOrderSeq` | `List<EnumTwelveGong>` | 宫位顺序 |

### 2.2 硬编码特征

- 外环与内环的环宽差固定为 **16px**（`outerRadius - 16` 为内环外径）
- 百六限年限表硬编码在 `DaXianRing.daXian106` 中（子15/丑10/寅11/卯15/辰8/巳7/午11/未4.5/申4.5/酉4.5/戌5/亥5）
- `startAngle` 固定为 `30+30=60°`，`sweepRadian` 固定为 `90°`（即 `3*30°`）
  - **注意**：这个起始角和扫角是一个 demo 值，并非完整 360° 渲染——当前仅在 `main.dart` 中以独立 demo 方式展示

---

## 3. DaXianRingPainter 绘制流程

```
paint(Canvas, Size)
  │
  ├── 1. 计算每宫角度: eachGongAngle = 360° / 12 = 30°
  │
  ├── 2. 计算角度分配: generateDrawAngle()
  │     输入：Map<EnumTwelveGong, YearMonth> + eachGongAngle
  │     输出：List<List<double>> — 每宫被拆分为若干槽位，每个槽位对应一个角度值
  │
  ├── 3. 计算年限分配: generateDrawYearMonthList()
  │     输入：Map<EnumTwelveGong, YearMonth>
  │     输出：List<List<YearMonth>> — 每宫被拆分为若干槽位，每个槽位对应一段年限
  │
  └── 4. 逐宫绘制: printEachGongV2()
        ├── _drawGongBackground()  → 宫位底色 + 宫位边框
        └── for each slot:
              ├── paintEachSlot()  → 槽位底色 + 槽位边框
              └── printSlotText()  → 年龄文字渲染
```

### 3.1 角度分配算法 (generateDrawAngle)

这是核心算法。每一宫的年限可能不是整数年（如 4.5 年、11 年），需要将整数年和小数年分配到不同角度的槽位中。

**步骤：**

1. 将每个宫的 `YearMonth` 转为 `double`（`monthsToDouble()` 方法：月数 0→0.0, 1~4→0.25, 5~8→0.5, 9~11→0.75）
2. 用 `DaXianCalculateHelper.transformNumbers()` 将 `[3.25, 3, 4.75]` 拆分为 `[[1,1,1,0.25], [0.75,1,1,0.25], [0.75,1,1,1,1]]`
3. 用 `proportionalAllocationWithEnds()` 对每个宫内的槽位按比例分配 30°

**transformNumbers() 核心逻辑：**

```
prevRemFrac → 前一个宫末尾的小数年(0.25/0.5/0.75)
for each 宫:
  if prevRemFrac > 0:
    startVal = 1.0 - prevRemFrac  → 当前宫开头"补"上缺失的小数部分
    valueToBreakDown -= startVal
  fullUnits = valueToBreakDown.floor()  → 拆分出整数个 1
  endFrac = valueToBreakDown 的剩余小数部分 → 尾部的 0.25/0.5/0.75
  prevRemFrac = endFrac  → 传递给下一个宫
```

**proportionalAllocationWithEnds() 核心逻辑：**

将每一宫 30° 按照槽位的"单位数"比例分配。每个槽位的角度 = `(该槽位的 quarter 数 / 总 quarter 数) × 30°`。

关键假设：`first` 和 `last` 必须是 `{0.25, 0.50, 0.75, 1.00}` 之一。不在此集合中返回失败。

### 3.2 年限分配算法 (generateDrawYearMonthList)

与 `transformNumbers()` 逻辑相同，但输入输出从 `double` 改为 `YearMonth`。处理月数为 3/6/9 的跨宫衔接。

### 3.3 逐槽年龄文字渲染 (printSlotText)

每个槽位的中心位置渲染该槽位结束时的年龄。年龄文字由 `startFromYear` + 累加的 `slotYearMonth` 得到。

**文字渲染坐标计算：**
```
sectorCenterAngle = startRadians + sweepRadians / 2
middleRadius = (innerRadius + outerRadius) / 2
sectorCenter = (
  center.dx + middleRadius * cos(sectorCenterAngle),
  center.dy + middleRadius * sin(sectorCenterAngle)
)
```

文字格式：`year`（如 `15`）或 `year/month`（如 `15/6`）。

### 3.4 边框约定

`Border` 的字段与弧线的映射关系：

| Border 字段 | 绘制的弧线/线段 |
|---|---|
| `top` | 内弧线（inner arc） |
| `bottom` | 外弧线（outer arc） |
| `left` | 结束边（结束角度的径向线） |
| `right` | 起始边（起始角度的径向线） |

实际参数命名与 Flutter `Border` 语义不对应，**这是一个容易出错的点**。

---

## 4. DaXianCalculateHelper 详解

### 4.1 transformNumbers()

静态方法，将连续的数字数组转换为槽位列表。核心是处理**小数跨宫衔接**：

输入 `[3.25, 3, 4.75]` 表示三个宫位分别有 3.25 年、3 年、4.75 年。输出 `[[1,1,1,0.25], [0.75,1,1,0.25], [0.75,1,1,1,1]]` 表示 3 个宫位分别被拆分为 4 个、4 个、5 个槽位。

小数部分的跨宫"移交"机制：
- 第 1 宫末尾 0.25 年 → 第 2 宫开头变成 0.75 年（`1.0 - 0.25`）
- 第 2 宫末尾 0.25 年 → 第 3 宫开头变成 0.75 年

**浮点精度处理：** 使用 epsilon（1e-9）和 quarter（0.25）调整，所有小数都 snap 到最接近的 0.25 倍数。

### 4.2 transformYearMonths()

与 `transformNumbers()` 同构，但输入 `YearMonth`，输出 `List<List<YearMonth>>`。月数假定为 `{3, 6, 9}`。

### 4.3 proportionalAllocationWithEnds()

输入：`first`（开头元素的单位数）、`last`（末尾元素的单位数）、`kMiddle`（中间整数元素个数）、`total`（总角度）

输出：`(success, allocFirst, List<double> allocMiddle, allocLast)`

以 0.25 为基本单位，计算各槽位的角度。中间整年槽位每个分配 4 个单位的角量。

---

## 5. 重要注意事项

### 5.1 当前状态

- **大限环图目前仅在 `main.dart` 中以独立 demo 方式展示**，使用的是硬编码数据，尚未集成到正式面板流程中
- 飞限（FeiXian）和小限（XiaoXian/XiaoXian）**没有独立的环形 UI 渲染**，仅存在于数据模型层

### 5.2 已知问题/风险点

1. **Border 字段语义反转**：`top` 绘制内弧、`bottom` 绘制外弧、`left` 是结束边、`right` 是起始边——与实际 Flutter Border 语义不同，迁移时注意不要混淆
2. **角度起始固定值**：`startAngle = 60°` 和 `sweepRadian = 90°` 是 demo 遗留值，应改为可配置或者从 0° 扫到 360°
3. **槽位文字渲染的年月算法复杂**：`printEachGongV2()` 中有多处对 `newYearMonth` 的特殊处理（最后一个槽位加 1 年、第一个槽位重置月数、跨宫重置月数），这个逻辑很难一眼看懂，迁移时需仔细对照
4. **月份→小数的量化精度**：`monthsToDouble()` 将 1~4 月量化为 0.25、5~8 月为 0.5、9~11 月为 0.75，这是粗粒度的量化，迁移时需确认是否满足需求
5. **`shouldRepaint` 检查不全**：`DaXianRingPainter.shouldRepaint()` 未检查 `gongYearsMapper`、`gongOrderedSeq`、`textStyle`、`startFromYear` 的变化，可能导致在数据更新时不重绘
6. **百六限年限表与计算引擎不共享**：`DaXianRing.daXian106` 中的固定表与 `DongWeiHundredSixManager` 中的计算逻辑独立存在，需保持一致性
7. **跨宫年份衔接边界条件**：`transformNumbers()` 中前宫小数→后宫开始补全的逻辑，在首尾宫处理上有特殊路径，测试时需覆盖边界（整年宫、0带月进宫、最后一宫）
8. **`_InteractiveDot` 是未完成的组件**：`LayoutId 2` 已被注释掉，`_InteractiveDot` 虽然定义完整但未在布局中使用

### 5.3 关键文件清单

| 文件 | 行数 | 职责 |
|---|---|---|
| `lib/presentation/widgets/rings/da_xian_ring.dart` | 390 | Widget 布局层，双层环图结构 |
| `lib/presentation/widgets/rings/da_xian_ring_painter.dart` | 425 | CustomPainter，环图绘制引擎 |
| `lib/utils/da_xian_calculate_helper.dart` | 256 | 跨宫槽位拆分 + 角度比例分配算法 |
| `lib/main.dart` (L160) | — | demo 调用点 |

---

## 一句话交接

> **DaXian ring UI (大限环图)** renders a dual-layer concentric ring chart (`CustomPainter` in `da_xian_ring.dart` + `da_xian_ring_painter.dart`) where the outer ring shows DongWei DaXian yearly slots and the inner ring shows fixed Hundred-Six yearly slots, using `DaXianCalculateHelper.transformNumbers()` to split non-integer year spans across 12 zodiac palaces with cross-palace fractional-year bridging — see `docs/superpowers/specs/da-xian-ring-ui-drawing.md` for full spec, known pitfalls (Border semantic reversal, hardcoded startAngle, incomplete `shouldRepaint`, missing FeiXian/XiaoXian ring UI), and the slot-angle allocation algorithm.
