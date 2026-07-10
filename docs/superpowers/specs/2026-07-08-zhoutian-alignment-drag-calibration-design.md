# 周天对齐点拖拽校准功能 · 设计文档

## 元信息

- 创建日期: 2026-07-08
- 文档类型: 功能设计（Design Spec，未实施）
- 状态: 已与用户对齐，待写实施计划
- 关联文档: `docs/project/architecture/003-三辰通载黄道恒星制盘制数据接入调研.md`（背景来源：多个互相冲突的历史对齐点候选，如"虚宿6°""奎宿9.75°"等，需要一种方式对比/校准/固化）

---

## 1. 背景与目标

七政四余排盘依赖"二十八宿环"与"十二宫环"之间的一个**对齐点**（某宿某度 = 某宫0°）。这个对齐点目前只能通过手改 JSON 资产或数字输入框设置，且不同史料给出的候选值经常互相冲突（见 003 文档第 12/15 章：虚宿6°、奎宿9.75°、用户表格反推出的虚宿1.6275° 等），肉眼很难判断哪个候选更合理。

**目标**：提供一个所见即所得的拖拽交互——用户用手指/鼠标拖动二十八宿环相对十二宫环旋转，实时看到盘面随之变化，松手后得到一个精确的对齐点（某宿+度数）。这个功能有两个使用者：

1. **终端用户**：为自己的排盘方案微调对齐点，结果保存进个人配置，长期生效（本次优先实现）。
2. **史料校准**：作为验证/试探不同历史候选对齐点的工具，找到的对齐点可以命名保存成新的候选，供以后复用（同一版本一起做）。

## 2. 范围

**做什么**：
- 拖拽二十八宿环相对十二宫环整体旋转（十二宫环不动），单一自由度。
- 实时读数反馈：显示当前对齐点对应的宿名+度数。
- 自由连续拖动，不做候选点吸附（snap）。
- 拖拽结果可保存进用户自己的排盘配置（`BasePanelConfig`），长期生效。
- 拖拽结果可命名保存为新的候选对齐点，供后续复用/对比。

**明确不做**（本版范围外）：
- 不涉及十二宫宫宽度调整（不等宫制 UI，见 003 文档 §13，是独立功能，不在本次范围）。
- 不做候选点吸附／磁性对齐。
- 不做多点触控/多指同时操作。
- 不解决 003 文档里尚未闭环的史料矛盾本身（本功能是"帮助收敛矛盾的工具"，不是"矛盾的答案"）。

## 3. 术语澄清：这不是 `ConstellationOffsetTier`

仓库里已有 `ConstellationOffsetTier`（古宿/矫正古宿/今宿，默认偏移 0°/+14°/0°）+ `constellationOffsetDeg` 数字覆写，链路完整（UI 数字输入框 → `BasePanelConfig` → `ZhouTianModel.applyOverrides()`）。这套机制解决的是**岁差校正档位**这一件事，语义上和本功能的"选择/校准某个历史对齐点"是两回事，**不复用、不合并**这两个字段。

但排查过程中发现：`applyOverrides()` 目前把 `constellationOffsetDeg` 只施加到 `zeroPointAtConstellation`（真实排盘基准），**没有**施加到 `alignmentPointAtConstellation`（`ZhouTianCalculator` 用来给二十八宿环定位的锚点）。这是一个既有的字段割裂问题，本次改动 `applyOverrides()` 时会顺带看一眼要不要一并修，但不作为本次目标，避免范围蔓延。

## 4. 关键设计决定：对齐点是一个绝对值，不是增量

拆开看 `ZhouTianCalculator` 的实现：`calculatePalaceAngles()` 只读 `alignmentPointAtGong` 给十二宫环定位；`calculateConstellationAngles()` 只读 `alignmentPointAtConstellation` 给二十八宿环定位——**两个锚点分别独立定位各自的环，不是同一个物理点的两种坐标读法**。

"拖拽二十八宿环、十二宫环不动"这个交互，翻译成数据变化就是：**只改 `alignmentPointAtConstellation`（某宿+度数的绝对值），`alignmentPointAtGong` 保持不动**。

因此：

- 拖拽产出 = 一个 `ConstellationDegree`（宿 + 度数）**绝对值**，不是相对某个默认值的偏移量（delta）。这个格式和 003 文档候选登记表（"虚宿6°""奎宿9.75°"）完全一致，交互结果可以直接誊入候选表，不需要换算。
- `zeroPointAtConstellation`（`generate_base_panel_service` 真实排盘用的基准）在现有资产中与 `alignmentPointAtConstellation` 数值相等（如 `yuan_shoushi` 两者都是"女宿1.971253°"），说明二者本该保持同步。**拖拽结束后，同一个绝对值同时写入这两个字段**，让视觉预览和实际排盘一致。
- `alignmentPointAtGong` / `zeroPointAtGong` 不受本功能影响。

## 5. 架构：三层设计，隔离迁移风险

CLAUDE.md 明确要求盘面渲染统一迁移到共享包 `metaphysics-chart-ui`，不能再扩展模块自有的 `StarXiuRingPainter`。但当前 checkout 里看不到 chart-ui 包代码，无法确认它是否已支持拖拽手势。经与用户确认：**先在本模块直接扩展 `StarXiuRingPainter` 做原型，接受这是技术债，但代码要按下表分层写，确保迁移时只需替换最外层**：

| 层 | 职责 | 依赖 | 迁移属性 |
|---|---|---|---|
| ① 通用环形拖拽手势库 | 纯几何计算：给定环心坐标、半径、指针位置，算出相对起始角的角度增量（`double`）。**不 import 任何 `qizhengsiyu` 包内类型**，只处理 `Offset`/`double`。 | 无（或仅 `dart:math`/Flutter 基础几何类型） | 天然可迁移，以后原样搬进 chart-ui |
| ② 七政四余语义适配层 | 把①的角度增量翻译成"当前指向第几宿第几度"（读 `ZhouTianModel.starInnOrder`/`starInnDegreeSeq`），负责读写 `BasePanelConfig.alignmentPointOverride` | `ZhouTianModel`、`Enum28Constellations` | 留在本模块的胶水层；迁移后 chart-ui 只需调用这一层暴露的"角度→宿度"转换接口 |
| ③ Painter + GestureDetector 拼装 | 在现有 `StarXiuRingPainter` 外包一层手势识别，把①②串起来渲染、驱动实时重绘 | Flutter widget 树、`StarXiuRingPainter` | 已知技术债；迁移时整层替换为 chart-ui 自己的手势入口，①②原样复用 |

## 6. 数据模型改动

- `BasePanelConfig` 新增字段 `ConstellationDegree? alignmentPointOverride`（默认 `null`，为空则完全沿用资产自带的 `alignmentPointAtConstellation`）。
- `ZhouTianModel.applyOverrides()` 新增参数 `ConstellationDegree? alignmentPointOverride`：非空时，直接替换 `alignmentPointAtConstellation` 与 `zeroPointAtConstellation`（两个字段写入同一个绝对值），不涉及 `gongDegreeSeq`/`starInnDegreeSeq`。
- `ZhouTianModelManager.getZhouTianModelBy()` 中把 `config.alignmentPointOverride` 一并传入 `applyOverrides()`（与现有 `starInnDegreeOverrides` 等参数并列）。
- 新增一张轻量的"用户自建候选对齐点"存储（沿用 GeJu 模块 `user_` 前缀自建数据的既有模式；具体是 Drift 表还是 JSON 文件存储，留到实施计划阶段按现有基础设施选型），记录：候选名称、`ConstellationDegree` 值、创建时间、来源备注（自由文本，例如"参照三辰通载/开禧历对比后手动校准"）。

## 7. 交互设计

1. 用户在盘面上按住二十八宿环任意位置拖动（十二宫环视觉上保持不动）。
2. `onPanUpdate` 实时计算角度增量 → 换算成"当前候选宿+度数" → 触发重绘，宿环随手指旋转；同时在盘面附近展示实时读数（如"当前：虚宿 3.42°"）。
3. 松手（`onPanEnd`）后，当前值成为本次会话的候选结果，界面给出两个动作：
   - **保存为我的排盘配置**：写入 `BasePanelConfig.alignmentPointOverride`，随配置持久化，下次打开自动生效。
   - **标定为新候选点**：弹出命名输入框，连同当前值一起存入候选点表（第 6 节）。
   - 两个动作互不排斥，可以都做，也可以都不做（仅本次会话预览，不保存）。
4. 全程自由连续拖动，不做候选点吸附。

## 8. 测试计划

1. **①层单元测试**：给定环心、半径、起止指针坐标，断言角度增量计算正确（覆盖跨 0°/360° 边界情况）。
2. **②层单元测试**：给定角度增量 + 一份 `ZhouTianModel`，断言换算出的"宿+度数"与手工计算一致（复用 003 文档 §10.3 已经设计的度数自洽性验证方法）。
3. **`applyOverrides()` 回归测试**：验证 `alignmentPointOverride` 非空时，`alignmentPointAtConstellation` 与 `zeroPointAtConstellation` 被替换为同一个值，`alignmentPointAtGong`/`zeroPointAtGong`/`gongDegreeSeq`/`starInnDegreeSeq` 保持不变。
4. **集成测试**：切换 `alignmentPointOverride` 前后，`ZhouTianCalculator.calculateConstellationAngles()`/`mapConstellationsToPalaces()` 输出确实随之改变（呼应 003 文档 §10.3 第 6 类"待补"测试，现在可以真正写出来）。
5. **Widget 测试**：模拟拖拽手势，断言实时读数文本随手势更新；松手后触发的保存动作调用了正确的持久化接口（可 mock）。

## 9. 开放问题 / 风险

- `applyOverrides()` 里 `constellationOffsetDeg`（岁差校正档位）是否也要顺带改成同时作用于 `alignmentPointAtConstellation`——本次不做，但会在改 `applyOverrides()` 时留意别引入冲突（两个 override 同时非空时的优先级需要明确，建议 `alignmentPointOverride` 优先于 `constellationOffsetDeg` 派生的偏移，写入实施计划时需要显式规定叠加/互斥规则）。
- "用户自建候选对齐点"表的具体存储技术（Drift vs JSON）未定，留给实施计划阶段结合现有 GeJu 自建数据的落地方式决定。
- chart-ui 包当前是否已支持手势输入，本次未验证（不在可见 checkout 范围内），①②层的可迁移性设计是基于"尽量减少假设"的保守策略，实际迁移时仍需按 chart-ui 实际接口做适配。

## 10. 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-07-08 | 初稿：经头脑风暴确认范围、三层架构、"对齐点是绝对值不是增量"的关键设计决定、数据模型改动与测试计划 | wjt / Claude |
