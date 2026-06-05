# 竹罗三限算法 Plans

## 目标

建立一个可配置行限引擎。它能用同一套抽象公式表达 A 法、B 法，并可扩展 C、D 等新法。

## 统一公式

每一限记为：

```text
P_i(t) = M(S_i, N_i, D_i, t, theta)
```

含义：

```text
P_i(t)：第 i 限内第 t 年落宫
S_i：第 i 限主本命所在宫
N_i：第 i 限主星数
D_i：第 i 限限程
theta：算法配置
M：行宫函数
```

交限记为：

```text
G(P_i(t), t, D_i, S_{i+1}, theta) = true
```

含义：

```text
G 为真时，从当前限交到下一限。
```

十二宫用 0-11 表示：

```text
子=0，丑=1，寅=2，卯=3，辰=4，巳=5
午=6，未=7，申=8，酉=9，戌=10，亥=11
```

宫位移动：

```text
move(p, offset) = (p + offset) mod 12
```

年龄口径：

```text
实现统一使用虚岁 1 起的连续年表。
t 是当前限内第 t 个输出年，从 1 开始。
古文节点标注可作为术理解释，不直接作为自动测试年龄口径。
```

## A 法配置

名称：

```text
classic_inverse_sections
```

行宫函数：

```text
if 1 <= t <= N:
  P(t) = S

if N < t <= N + 10:
  P(t) = move(S, -2)

if N + 10 < t <= N + 20:
  P(t) = move(S, -4)

if N + 20 < t:
  P(t) = move(S, -4 + (t - N - 20))
```

参数：

```text
firstHold = starNumber
sectionLength = 10
inverseInclusiveCount = 3
inverseOffset = -2
remainderDirection = +1
transition = meetNextRuler
extension = continueRemainderDirectionUntilMeet
bridge = none
```

## B 法配置

名称：

```text
direct_annual_with_bridge
```

行宫函数：

```text
if 1 <= t <= N:
  P(t) = S

if N < t:
  P(t) = move(S, t - N)
```

参数：

```text
firstHold = starNumber
annualDirection = +1
transition = meetNextRuler
extension = continueAnnualDirectionUntilMeet
bridge = nextRulerNumberBridge
```

补桥函数：

```text
d = forwardDistance(currentPalace, nextRulerPalace)
m = nextRulerNumber
R = currentLimitRemainingYears

if R == d * m:
  each bridge palace holds m years
```

交限重叠处理：

```text
补桥最后一宫若等于下一限主宫，该宫同时是下一限起宫。
同一年龄只能输出一条记录。
该记录应标注 isTransitionYear=true、usedBridge=true。
下一限后续年份从该交限宫继续展开，不额外复制一条同龄记录。
```

## 可扩展 C 法

名称：

```text
direct_repeat_by_own_number
```

含义：

```text
每宫按本限主星数停留，然后顺行。
```

公式：

```text
P(t) = move(S, floor((t - 1) / N))
```

## 可扩展 D 法

名称：

```text
inverse_repeat_by_own_number
```

含义：

```text
每宫按本限主星数停留，然后逆行。
```

公式：

```text
P(t) = move(S, -floor((t - 1) / N))
```

## 设计原则

- 不把 A、B 写死成两个独立算法。
- 先实现共同数据：宫位、三限主、星数、限程。
- 再实现配置化行宫函数。
- 交限规则必须可配置。
- 补桥规则必须可关闭。
- 输出必须说明当前使用的算法配置名。
- 生产接入时优先复用项目已有 `EnumTwelveGong`。
- 七政限主先使用算法局部 `ZhuLuoRuler`，避免新代码直接引入带 `xuan_` 前缀的包；生产接入时再由 adapter 映射到现有星体模型。
- 本次 ACT 只做纯算法模块与测试，不接 UI、数据库、排盘管理器。
