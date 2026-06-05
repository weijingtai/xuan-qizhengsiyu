# gStack 验证报告

## 范围

验证对象：

```text
doc/zhu_luo_san_xian/竹罗三限调查报告.md
doc/zhu_luo_san_xian/plans.md
doc/zhu_luo_san_xian/tasks.md
doc/zhu_luo_san_xian/test_plan.md
doc/zhu_luo_san_xian/ACT.md
```

验证方式：

```text
按 gStack 的准出思路做文档可执行性审计：
1. 算法是否自洽。
2. ACT 是否能被低推理能力 agent 执行。
3. 测试是否能卡住 A/B 边界。
4. 是否会误碰现有项目结构。
```

## 发现与修正

### 1. LANG 不够精确

问题：

```text
ACT 写成 Dart 3.x，不符合“精确到小版本”的要求。
```

修正：

```text
改为 Flutter 3.38.6 / Dart 3.10.7。
```

### 2. 十二宫重复定义与七政依赖边界

问题：

```text
ACT 原本要求新建 TwelvePalace、SevenRuler。
项目已有 EnumTwelveGong、EnumStars。
同时，新代码若直接 import package:xuan_common/... 可能触碰项目关于 xuan_ 前缀的治理边界。
```

修正：

```text
ACT 改为复用 EnumTwelveGong。
七政限主使用算法局部 ZhuLuoRuler。
本轮不做生产星体 adapter，不导入 package:xuan_common/...。
```

### 3. B 法重叠交限年未写清楚

问题：

```text
腓特烈样例中 54-55 子既是中限补桥终点，也是末限起宫。
若未声明，agent 可能输出两条同龄记录。
```

修正：

```text
新增规则：同一年龄只能输出一条记录。
用 isTransitionYear、usedBridge 标注重叠交限。
```

### 4. A 法年龄口径可能混乱

问题：

```text
古文节点标注和连续年表不同。
例如“二岁午、十二辰”容易被误当成实现索引。
```

修正：

```text
所有实现与测试统一用虚岁 1 起连续年表。
古文节点只用于术理解释。
```

### 5. 现有占位 manager 可能被误改

问题：

```text
仓库已有 lib/domain/managers/fate/zhu_luo_san_xian_manager.dart。
ACT 若不限制，agent 可能直接改 manager、UI 或数据库。
```

修正：

```text
ACT 明确本轮只做纯算法模块。
禁止修改 manager、UI、数据库、既有洞微/飞限/小限代码。
```

## 剩余风险

### R1：A 法是否应完全采用古文节点年龄

当前处理：

```text
实现使用虚岁 1 起连续年表。
```

风险：

```text
若后续要严格复现某一古籍例盘，可能需要增加 classicalAgeLabelMode。
```

建议：

```text
先实现当前连续年表；古文节点模式作为后续 C/D 扩展，不混入 A/B 基线。
```

### R2：B 法补桥触发条件仍来自案例归纳

当前处理：

```text
R == d * nextRulerNumber 时启用补桥。
```

风险：

```text
该规则可复现腓特烈图，但仍需更多案例验证。
```

建议：

```text
保留 bridgeMode 可关闭，不把补桥写成所有算法通用真理。
```

## 准出结论

当前文档可作为编码前置规范使用。

准出条件：

```text
1. agent 必须按 ACT 顺序执行。
2. agent 不得重复定义项目已有十二宫枚举。
3. agent 不得导入 package:xuan_common/...。
4. agent 不得修改 UI、数据库、manager。
5. A/B 必须通过分叉测试。
6. 腓特烈样例必须通过 B 法关键年龄测试。
```
