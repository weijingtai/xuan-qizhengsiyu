# 竹罗三限算法 Tasks

## Task 1：定义基础数据

必须实现：

- 复用项目已有 `EnumTwelveGong`，顺序固定为子、丑、寅、卯、辰、巳、午、未、申、酉、戌、亥。
- 新增算法局部 `ZhuLuoRuler`，只包含日、月、火、水、木、金、土。
- 昼夜枚举：昼生、夜生。
- 三限序枚举：初限、中限、末限。

禁止：

- 不要重复定义十二宫枚举。
- 不要导入或新增带 `xuan_` 前缀的新依赖。
- 不要使用项目名前缀作为程序标识符。
- 不要把宫位顺序写成临时字符串数组后到处复制。

## Task 2：定义共同表

必须实现：

- 三限主表。
- 星数表。
- 限程表。

验收：

```text
巳酉丑昼生 = 金、月、火
巳酉丑夜生 = 月、金、火
金星数 = 4
火星数 = 2
金限程 = 26
火限程 = 28
```

禁止：

- 不要在算法函数内部散落硬编码表。

## Task 3：定义算法配置模型

必须实现：

- algorithmId。
- firstHoldMode。
- phasePattern。
- transitionRule。
- extensionRule。
- bridgeRule。

必须内置两个配置：

```text
classic_inverse_sections
direct_annual_with_bridge
```

禁止：

- 不要用 if algorithmId == A 到处写分支。
- 不要把 A、B 写成完全重复的两个计算器。

## Task 4：实现宫位移动工具

必须实现：

```text
move(palace, offset)
forwardDistance(from, to)
```

验收：

```text
move(巳, -2) = 卯
move(卯, -2) = 丑
move(寅, 1) = 卯
forwardDistance(未, 子) = 5
```

禁止：

- 不要用大量 switch 手写每个宫位跳转。

## Task 5：实现 A 法配置化计算

必须实现：

```text
classic_inverse_sections
```

验收样例：

```text
土在巳，土数 5，土限 26：
1-5 巳
6-15 卯
16-25 丑
26 寅
```

禁止：

- 不要把“逆数三宫”实现成 offset -3。
- 必须实现成 offset -2。

## Task 6：实现 B 法配置化计算

必须实现：

```text
direct_annual_with_bridge
```

验收样例：

```text
金在寅，金数 4：
1-4 寅
5 卯
6 辰
7 巳
```

腓特烈样例：

```text
命宫酉，昼生，金月火
金在寅，月在午，火在子

19 岁 = 巳
29 岁 = 卯
32 岁 = 午
46-47 岁 = 申
54-55 岁 = 子
61 岁 = 午
75 岁 = 申
```

禁止：

- 不要用 A 法去验证腓特烈图。
- 不要忽略补桥。
- 不要为 54-55 岁生成两条年度记录；它是重叠交限年，必须用字段标注。

## Task 7：输出结构

每年输出必须包含：

```text
age
limitIndex
limitRuler
palace
algorithmId
phase
isTransitionYear
```

可选输出：

```text
usedBridge
bridgeRuler
note
```

禁止：

- 不要只输出宫位。
- 不要让调用方猜当前是哪一限。
- 不要把同一年龄拆成多条记录。

## Task 8：测试

必须覆盖：

- 三限主表。
- 星数表。
- 限程表。
- 宫位移动。
- A 法土在巳。
- B 法金在寅。
- B 法腓特烈样例。
- A、B 同输入不同输出。

禁止：

- 不要只测 happy path。
- 不要用截图作为测试依据。
