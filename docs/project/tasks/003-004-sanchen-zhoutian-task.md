# 三辰通载/周天对齐校准 整体执行计划

## 元信息

- 创建日期: 2026-07-09
- 文档类型: 多 Agent 任务纪要(按 wjt-plan 协议蒸馏)
- 状态: 草稿,待人类拍板后 `aiwt adopt` 收编进 worktree
- 启动条件: 主工作区现在是 `main` 分支,真要动业务代码必须先 `aiwt new <agent> <任务>` 或 `aiwt adopt` 进对应 `.worktrees/` 目录
- 关联文档:
  - 调研基底: `docs/project/architecture/003-三辰通载黄道恒星制盘制数据接入调研.md`(395 行,16 节)
  - 设计基底: `docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md`(99 行,10 节)
- 管理方式: **不走禅道**,任务登记与进度跟踪全在本文档内
- Agent 分派原则:
  1. 能用 OpenCode 就别上 Claude Code / Codex(省 token)
  2. Claude Code / Codex 不亲自调研、不亲自取数;它们只写"调研 SOP"(去哪找、找什么样的、什么算合格),让 OpenCode / MiMo 执行取数,数据回交后再做判断
  3. 史料学(L5)和架构判断(L4)不指派任何 AI,人 / 顾问拍板

---

## 当前状态(本分支 agent/opencode/004-drag-calibration-tool)

> 【覆盖重写区】接手本分支先读这里

- 刚完成: 2-D d3 — 收到 OpenCode 取数报告(`2D-geju-research-findings.md`)后做选型决策: **Drift + user_school_profile 模板**,已定表/Converter/DAO 接口 + 8 步实现工单(`2D-geju-selection-and-interface.md`),并经 spec-task-executor + code-review-expert 两角色交叉审查修订(采纳 4 真问题,驳回 3 假阳性)
- 已落地(前序): 2-A ①层几何库 + 2-B ②层语义适配/applyOverrides(6a94707);2-C ③-甲 StarXiuDragCalibration 拖拽组件(3a191ec);2-D d1 SOP + findings 取数
- 下一步: 把 `2D-geju-selection-and-interface.md` §3 工单交 OpenCode 做最小实现(建表+Converter+DAO+注册+迁移 4→5+build_runner+DAO 往返测试)
- 微观意图: OpenCode 建表回来后进 2-E(集成+Widget 测试),把 onPanEnd 的两个保存动作接到新 DAO;顺手核对 alignmentPointOverride 与 constellationOffsetDeg 同时非空时的优先级(设计 004 §9 建议 override 优先)
- 验证: 本轮纯文档决策无需跑测试;工单交付后 OpenCode 跑 `flutter analyze` + DAO 往返测试
- 审查教训: spec-task-executor 本轮 0 工具调用致 3 处断言全错,其结论已回源码逐条证伪,详见决策文档 §5

---

## 总体目标(一句话)

把《三辰通载》黄道恒星制盘制数据接入 xuan-qizhengsiyu 项目(含 schema 迁移、资产落地、对齐点候选登记、不等宫死字段打通),并开发一个拖拽校准对齐点的可视化工具(004),用于在史料候选分歧未消时做间接验证。全程在 worktree 中开发,主分支零改动。

---

## 逻辑能力分级(本计划专用)

| 等级 | 触发条件 | 谁来 |
|---|---|---|
| L1 | 有明确文档 + 正模板,纯照抄改字段,所有判断已在他处做完 | OpenCode |
| L2 | 输入清楚但需写新函数/测试,数学/几何为主,有公式或 oracle | OpenCode |
| L3 | 跨 2-3 个现有模块契约,需理解"为什么这么写",可改字段/写扩展点 | Claude Code |
| L4 | 在"重构 vs 妥协""技术债 vs 进度""候选选哪个"之间做决策 | 人(不指派 AI) |
| L5 | 查经典史料原文,远超 AI 训练数据范围 | 人 / 顾问(任何 AI 都不可靠) |

---

## 三个方向 + 一个硬阻塞

| 方向 | 内容 | 逻辑能力 | 终验 |
|---|---|---|---|
| **方向一** | 003 三辰通载数据接入(schema 迁移 → 资产落地 → 外部包登记 → 锚点候选收口) | L1-L3 + L4/L5 阻塞 | 三辰通载专属 golden 测试(4 位小数一致) |
| **方向二** | 004 周天对齐点拖拽校准工具(三层架构,①②层可迁移 chart-ui) | L2-L3 | 拖动→读数→保存正确性,Widget 测试绿 |
| **方向三** | 不等宫死字段打通(003 §13 方案 B,运行时覆写;独立 PR,不混进 003/004) | L3 | 切换 houseDivisionSystem 后 calculatePalaceAngles 输出确实变 |

**硬阻塞**: 方向一的 1-D 阶段(锚点候选收口)是 L4-L5,任何 AI 都做不了。两个出路:
- **路径 A 史料路**: 核实"虚宿6°""奎宿9.75°"各自的原始史源(《开禧历》具体卷段),由 Claude Code 写"史料调研 SOP",MiMo/OpenCode 执行检索,找到的描述回交 Claude Code 判断是否符合"合格证词"标准,最终由人拍板
- **路径 B 工具路**: 直接批准 004 立项,用拖拽校准工具对各个候选做"哪个排盘更符合已知验证点(郑氏星案金标准)"的间接筛选

建议同时开线: 史料路走 Claude Code 指挥 + 人拍板,工具路走方向二独立推进。

---

## 方向一: 003 三辰通载数据接入

### 目标
为 xuan-qizhengsiyu 接入一份符合当前 `ZhouTianModel` schema 的"三辰通载·似黄道恒星制"资产,并修复既有 3 份旧 schema 资产的兼容性,使全部 4 份 example 资产 + 新增 1 份共 5 份都能经 `ZhouTianModel.fromJson` 正确解析并通过 6 类回归测试。

### 阶段计划与 Agent 分派

| 阶段 | 内容 | 逻辑 | Agent | 依赖 | 验收标准 |
|---|---|---|---|---|---|
| **1-A** schema 摸底 + 迁移方案细化 | 对照 003 §6.3 字段改名表 + 003 §10.1,逐份核对 3 份旧 JSON(`han_chidao_hengxin.json`/`yuan_chidao_hengxing.json`/`ming_si_huangdao_hengxing.json`)缺哪些字段、值要改哪些(`"似黄道制"`→`"似黄道恒星制"`,`"古宿"`→`"古宿制"`)。产出 3 份"字段差异清单 + 补全方案"草稿,先不改文件 | L1 | OpenCode | 003 §3/§6.3 | 3 份 JSON 的字段差异表逐字段对应到 `yuan_shoushi_chidao_hengxin.json` 当模板;`gongOrder`/`starInnOrder` 的补全方式有据可依(28 宿固定环序 + 十二地支退行) |
| **1-B** 3 份旧资产迁移执行 + 4 类回归测试 | 按 1-A 方案逐份手工重写为新 schema(先存 `*.v2.json`),补 `gongOrder`/`starInnOrder`/`specificationList`,修值名。同时新增 `test/domain/entities/zhou_tian_model_asset_schema_test.dart`,落地 003 §10.3 第 1/2/3/4 类测试(共 4 类 × 4+1 份)。Claude Code 复查回归测试的契约对齐 | L1-L2 | OpenCode(主写) + Claude Code(复审回归测试契约) | 1-A 完成 | (a) 4 份迁移文件全部经 `ZhouTianModel.fromJson` 不抛异常;(b) `toJson()`→`fromJson()` round-trip 字段不丢;(c) `starInnDegreeSeq` 求和≈`totalDegree`(容差 0.01°);(d) `gongDegreeSeq` 求和≈`totalDegree`(这条会暴露 `yuan_shoushi` 既有 bug,见 003 §3/§10.3);(e) 对齐点代入 `ZhouTianCalculator.calculateConstellationAngles()` 不报自洽错误 |
| **1-C** 三辰通载新资产落地 + 外部包登记 | (c1) 按 003 §4.3 直接按新 schema 写 `example/assets/qizhengsiyu/sanchen_tongzai_huangdao_hengxing.json`(暂用 `userTableDerived` 锚点,见下方"锚点默认值决策")。(c2) 003 §3 指出 `repository-interface-qizhengsiyu` 外部包有内置数据清单接口 `loadBuiltInZhouTianModels()`,需确认该包存在位置、是否要把新盘制挂进清单;若该外部包不在 worktree 可见范围,记录为阻塞项,不强行 | L2 | OpenCode | 1-B 完成(1-B 给了新 schema 模板),1-D 决策锚点默认值 | (a) 新 JSON 经 1-B 第 1/2 类测试通过(基本解析 + round-trip);(b) `totalDegree` = 365.255 与 28 宿度数表一致;(c) 外部包状态已探明:要么登记成功,要么明确列为阻塞项给出下一步 |
| **1-D** 锚点候选收口(史源核实 + 拍板) | 核实 5 个候选锚点(见 003 §15.3 候选登记表)各自的原始史源出处,具体到《开禧历》哪一卷哪一段。Claude Code 写"史料调研 SOP"指派 MiMo/OpenCode 检索;数据回交后由人拍板选哪个候选进资产 | L4-L5 | Claude Code (写 SOP,不亲自翻书) + MiMo/OpenCode (执行检索) + 人 (拍板) | 不依赖 1-A/1-B/1-C,可提早开线 | (a) 每个候选至少有一个史源引用,或明确标注"史源未找到,暂用反推值";(b) 人拍板后写入新资产的 `alignmentPointAtConstellation` 字段;(c) `zhou_tian_model.dart:60-61` 注释从"占位猜测"更新为"已落地,数据来源 X";(d) 注释中"天禧历"勘误为"开禧历" |

### 锚点默认值决策(供 1-C 用,等 1-D 拍板后回填)

按 003 §12.3 建议先采用 `userTableDerived`(虚宿 1.6275°=子宫0°)作为资产默认锚点,因为它是目前唯一被给定数据自洽验证的候选。其他 4 个候选(`codeComment_xu6`、`kaixiLi_xuwei_zi15`、`kaixiLi_kui9_75`、`sanChenTongZai_ziwu_unequal`)按 003 §12.3 设计为"可扩展登记表 + 运行时覆写",不写死进资产。

### 待补测试(1-D 闭环后才能补)
- **三辰通载专属 golden 测试**(003 §10.3 第 5 类): 锚点 `userTableDerived` + 三辰通载资产 → `ZhouTianCalculator.mapConstellationsToPalaces()` 输出与用户给的"12 宫对齐分段表"(003 §2.2)逐宫 4 位小数一致。**这是方向一的最终验收标准**。

### 决定记录(方向一)

| 决定 | 内容 | 来源 |
|---|---|---|
| ✅ schema 迁移走"迁移到新 schema",不加 `fromJson` 兼容分支 | 兼容分支会背上永久双 schema 维护负担;3 份文件都很小(<70 行),手工改成本低 | 003 §6.3 |
| ✅ 三辰通载新资产用新 schema 直接写,不迁移 | 003 §10.2 S2 已明确 | 003 §10.2 |
| ✅ 锚点默认值用 `userTableDerived`,其他候选走运行时覆写 | 唯一被给定数据自洽验证的候选;候选保留不删 | 003 §12.3 |
| ✅ 等宫制作为 1-C 起步默认 | 003 §12.1 撤回了"不等宫是误抄"判断,但 12 宫按 365.255÷12 各 30.4379 还是当前最稳妥的起步口径,不等宫=方向三独立推进 | 003 §12.1 / §13 |
| ❌ 不做"给 fromJson 加旧 schema 兼容分支" | 上方决定的反选项,被否 | 003 §6.3 |
| ❌ 不强行配平 `sanChenTongZai_ziwu_unequal` 的 0.6° 差到 365.255 | 史料原样保留,把偏差显式暴露给用户,不暗改 | 003 §12.1 / §13.1 |

### 踩坑墓地(方向一,执行中追加)

- (空,执行中追加)

---

## 方向二: 004 周天对齐点拖拽校准工具

### 目标
开发一个所见即所得的拖拽交互:用户用手指/鼠标拖动二十八宿环相对十二宫环旋转,实时看到对齐点读数(某宿+度数),松手后写入 `BasePanelConfig.alignmentPointOverride`。三层架构隔离迁移风险,①层纯几何天然可迁,③层明确标注技术债等 chart-ui 就绪后整层替换。

### 阶段计划与 Agent 分派

| 阶段 | 内容 | 逻辑 | Agent | 依赖 | 验收标准 |
|---|---|---|---|---|---|
| **2-A** ①层 纯几何环形角度增量库 | 纯函数: 给定环心坐标、半径、起止指针位置,算相对起始角的角度增量(double)。只 import `dart:math` + Flutter 基础几何类型,零业务依赖。处理 0°/360° 跨边界 | L2 | OpenCode | 无 | (a) 单元测试覆盖跨 0°/360° 边界;(b) 不 import 任何 `qizhengsiyu` 包内类型;(c) 函数签名只接受 `Offset`/`double` |
| **2-B** ②层 七政四余语义适配 + applyOverrides 改造 | (b1) 把①的角度增量翻译成"当前指向第几宿第几度",读 `ZhouTianModel.starInnOrder`/`starInnDegreeSeq`。(b2) `BasePanelConfig` 新增 `ConstellationDegree? alignmentPointOverride` 字段。(b3) `ZhouTianModel.applyOverrides()` 新增同名参数,非空时同时替换 `alignmentPointAtConstellation` 与 `zeroPointAtConstellation`(两字段写同一绝对值)。**不碰** `alignmentPointAtGong`/`zeroPointAtGong`/`gongDegreeSeq`/`starInnDegreeSeq` | L3 | Claude Code | 2-A 完成 | (a) 单元测试: 给定角度增量 + 一份 `ZhouTianModel`,换算出的"宿+度数"与手工计算一致;(b) `applyOverrides()` 回归测试: `alignmentPointOverride` 非空时两字段被替换为同一值,其他 4 字段保持不变;(c) 集成测试: 切换 override 前后 `ZhouTianCalculator.calculateConstellationAngles()` 输出确实变 |
| **2-C** ③-甲 Painter + GestureDetector 拼装 | 在现有 `StarXiuRingPainter` 外包手势识别,把①②串起来驱动实时重绘 + 实时读数显示(如"当前: 虚宿 3.42°")。**代码顶部明确标注技术债: chart-ui 就绪后整层替换,①②直接搬** | L2 | OpenCode | 2-A/2-B 完成 | (a) Widget 测试: 模拟拖拽手势断言实时读数文本随手势更新;(b) `// TECHNICAL DEBT` 标注存在 |
| **2-D** ③-乙 用户自建候选对齐点持久化存储 | (d1) Claude Code 写调研 SOP: 让 OpenCode 去读 GeJu 模块的 `user_` 前缀自建数据现有模式,告诉 Claude"它用 Drift 还是 JSON、文件路径模式、CRUD 接口形状、命名字段约定"。(d2) OpenCode 执行取数,回交报告。(d3) Claude Code 据报告选型并定接口: 新增轻量候选表,字段(候选名称/`ConstellationDegree`/创建时间/来源备注) | L3 | Claude Code (写 SOP + 选型决策) + OpenCode (取数执行) | 2-B 完成 | (a) 选型的根据(为什么是 Drift 或 JSON)写到决定记录;(b) 接口签名与现有 GeJu 自建数据模式对齐;(c) 至少有 mkdir/CRUD 的最小实现 |
| **2-E** 集成测试 + Widget 测试收尾 | (a) 拖动 → 实时读数变更;(b) `onPanEnd` 后两个保存动作(写配置 / 存候选)调用正确的持久化接口;(c) 切换 `alignmentPointOverride` 前后 `mapConstellationsToPalaces()` 输出确实改变(003 §10.3 第 6 类"待补"测试现在可写) | L2 | OpenCode | 2-A/2-B/2-C/2-D 全完成 | 全部测试绿;`flutter analyze` 0 error;`flutter test` 全绿 |

### 关键设计决定(方向二)

| 决定 | 内容 | 来源 |
|---|---|---|
| ✅ 对齐点 = `ConstellationDegree` 绝对值,不是增量 | 004 §4 明确:`calculatePalaceAngles()` 和 `calculateConstellationAngles()` 两个锚点各自独立定位各自的环,不是同一物理点的两种读法 | 004 §4 |
| ✅ 拖拽结束后同一绝对值同时写入 `alignmentPointAtConstellation` + `zeroPointAtConstellation` | 这两字段在现有资产中数值相等(`yuan_shoushi` 都是"女宿1.971253°"),写同一值让视觉预览和实际排盘一致 | 004 §4 |
| ✅ 不复用现有 `ConstellationOffsetTier` + `constellationOffsetDeg` | 那是岁差校正,语义上和"选择/校准某历史对齐点"是两回事,不合并 | 004 §3 |
| ✅ 不做候选点吸附(snap) | 自由连续拖动 | 004 §2 |
| ✅ 不等宫 UI(003 §13) 排除在本版外,单独立项(见方向三) | 避免范围蔓延 | 004 §2 |
| ❌ 不顺手处理 `constellationOffsetDeg` 没施加到 `alignmentPointAtConstellation` 的事 | 改 `applyOverrides()` 时留意别引入冲突,但本次不修;两个 override 同时非空的优先级留给实施计划明确(建议 `alignmentPointOverride` 优先) | 004 §9 |
| ❌ 不直接挖 chart-ui 包的接口手势支持现状 | 不在可见 checkout 范围内;①②层的可迁移性设计基于"尽量减少假设"的保守策略 | 004 §9 |
| 📋 2-D 调研 SOP 把 `user_school_profile` 定为第二参照样本 | 它是"一条命名的轻量用户自建记录",形态比 GeJu 规则更贴近候选对齐点(候选名+ConstellationDegree+时间+备注),可作 Drift/JSON 选型的第二对照锚 | 2026-07-09 SOP 撰写 |
| ✅ 2-D 候选对齐点存储选 Drift,以 user_school_profile 为模板 | GeJu 的 JSON 通道已废弃(单向迁 Drift 后归档),新数据一律走 Drift;user_school_profile 是同构轻量记录范式;Web 兼容白拿。表 `t_alignment_point_candidates`,字段 uuid/name/alignment_point_json/source_note/created_at/last_updated_at/deleted_at,schemaVersion 4→5。详见 `2D-geju-selection-and-interface.md` | 2026-07-09 2D-findings Q1/Q5/Q6 |
| ✅ 时间字段用 last_updated_at(随 user_school_profile) 而非 updated_at(GeJu) | 让 DAO listAll 排序可原样照抄 user_school_profile_dao,减少照抄出错 | 2026-07-09 两角色审查 R1 |
| 📋 两角色交叉审查裁定:code-review 全属实,spec-task-executor 0 工具调用 3 处断言全错已驳回 | 跨角色审查结论必须回源码核实,工具调用数是可信度强信号 | 2026-07-09 审查修订记录 |

### 待补测试规格(004 §8 已细化)
- ①层单元测试:跨 0°/360° 边界
- ②层单元测试:角度增量→宿度换算
- `applyOverrides()` 回归测试:override 非空时双字段替换、其他字段不变
- 集成测试:切换 override 前后 calculator 输出确实变
- Widget 测试:拖拽实时读数 + 保存动作接口正确性

### 踩坑墓地(方向二,执行中追加)

- (空,执行中追加)

---

## 方向三: 不等宫死字段打通(独立 PR,不混进 003/004)

### 目标
把 `BasePanelConfig.houseDivisionSystem` 从孤儿字段升级为运行时真正影响 `gongDegreeSeq` 的开关(003 §13 方案 B)。独立立项,独立 PR,不和 003/004 混,因为也改 `applyOverrides()` 容易互相踩。

### 阶段计划与 Agent 分派

| 阶段 | 内容 | 逻辑 | Agent | 依赖 | 验收标准 |
|---|---|---|---|---|---|
| **3-A** applyOverrides 扩参 + 公式表 + 一致性校验 | (a1) `HouseDivisionSystem` 新增枚举值 `equatorialZiWuSanChenTongZai`(子午 30.4380/其余 30.4979,避免和既有 `equatorialZiWu` 撞名撞数字)。(a2) `applyOverrides()` 新增 `HouseDivisionSystem? houseDivisionSystemOverride` 参数,非空时按枚举现算 `gongDegreeSeq` 覆盖资产自带值;为空保持现状。(a3) `panel_system_resolver.dart` 新增⑦号一致性检查:`houseDivisionSystemOverride` 生效时重算 `gongDegreeSeq` 总和,与 `totalDegree` 差 >0.05° 给警告(不阻断)。0.6° 偏差显式暴露。(a4) `custom_config_section.dart` 补齐缺失的 `HouseDivisionSystem` 选择控件 | L3 | Claude Code | 无(可与 1-A/2-A 并行) | (a) `applyOverrides()` 加参数后向后兼容(为空时行为不变);(b) 公式表纯函数覆盖所有既有枚举值;(c) resolver⑦给警告但不阻断;(d) UI 可见选择控件接入 |
| **3-B** 反向验证测试 | 切换 `houseDivisionSystemOverride` 前后 `calculatePalaceAngles()` 输出确实变(003 §10.3 第 6 类测试现在可写);默认空时 `gongDegreeSeq` 与现有资产 round-trip 一致;0.6° 偏差在测试里被显式登记为"已知偏差,不阻断" | L2 | OpenCode | 3-A 完成 | 测试是 oracle,代码适配测试,不可反转断言迁就实现 |

### 关键设计决定(方向三)

| 决定 | 内容 | 来源 |
|---|---|---|
| ✅ 方案 B 运行时覆写(不是方案 A 资产自带) | 名副其实"用户可选不等宫方案",而非"用户可见但不可选" | 003 §13 + 用户拍板 |
| ✅ 新增枚举值 `equatorialZiWuSanChenTongZai`(不和 `equatorialZiWu` 撞) | 32.625° vs 30.4380°/30.4979° 数值不同,不能共用一个名字 | 003 §13.2 |
| ✅ 0.6° 总和偏差显式暴露给用户,不配平 | 003 §12.1 原则:不暗改史料 | 003 §13.2 / §13.3 |
| ✅ warning-only,不阻断 | 呼应 resolver 现有"non-blocking, warnings-only"风格 | 003 §13.3 |
| ❌ 不和 004 PR 混 | 两者都改 `applyOverrides()`,混在一起评审责任不清,容易互相踩 | 用户指示 |

### 踩坑墓地(方向三,执行中追加)

- (空,执行中追加)

---

## Agent 指派矩阵(按角色)

```
Claude Code (L3 契约对齐 / 调研总指挥):
  - 1-B 复审回归测试契约(读 OpenCode 写的测试代码,确认对 6 类测试规格的实现到位)
  - 1-D 写史料调研 SOP(指派 MiMo/OpenCode 去找《开禧历》卷段;不亲自翻书)
  - 2-B ②层语义适配 + applyOverrides 改造(主)
  - 2-D 写 GeJu 模式调研 SOP + 收到 OpenCode 报告后做选型决策
  - 3-A applyOverrides 扩参 + 公式表 + 一致性校验(主)

OpenCode (主力执行):
  - 1-A schema 摸底
  - 1-B 3 份资产迁移 + 4 类回归测试主写
  - 1-C 三辰通载新资产落地 + 外部包登记
  - 2-A ①层纯几何库
  - 2-C ③-甲 Painter 拼装
  - 2-D ③-乙 取数执行(按 Claude Code 的 SOP 读 GeJu 现状)
  - 2-E 集成 + Widget 测试
  - 3-B 反向验证测试

MiMo (检索执行,可选):
  - 1-D 按调研 SOP 执行史料检索(如 OpenCode 网络访问不便,可让 MiMo 跑)

人 / 顾问 (L4-L5):
  - 1-D 史料候选最终拍板(哪个候选进入资产)
  - 所有方向的"批准立项"指令
  - 决定外部包 repository-interface-qizhengsiyu 是否在可动范围
```

---

## 依赖图

```
方向一                  方向二                  方向三
────────               ────────               ────────
1-A ─┐                 2-A ─┐                  3-A ─┐
     ├→ 1-B ─┐              ├→ 2-B ─┐                └→ 3-B
     │       ├→ 1-C         │       ├→ 2-C ─┐
     │       │              │       │       └→ 2-D ─┐
     │       │              │       │              └→ 2-E
     │       │              │       └──────────────┘
     │       └→ [Block: 1-D 史料/人拍板] ──┐
     │                                    │
     └→ 1-D 不阻塞 1-A/1-B/1-C,可提早开线  │
                                            ↓
                            1-D 拍板后回填 1-C 锚点
                            + 补方向一 golden 测试
```

**关键**: 1-D 不阻塞 1-A/1-B/1-C 的起步(可先按 `userTableDerived` 锚点推进),但阻塞方向一的最终 golden 测试(003 §10.3 第 5 类)和资产正式落地。

---

## 阻塞项清单

| 阻塞项 | 阻塞谁 | 解锁动作 |
|---|---|---|
| 1-D 史源核实(虚6°/奎9.75° 等具体卷段) | 方向一最终 golden 测试 + 资产正式落地 | 人指派 Claude Code 写 SOP + MiMo/OpenCode 检索 + 人拍板;或批准 004 立项做工具间接验证 |
| 外部包 `repository-interface-qizhengsiyu` 可动范围 | 1-C 的内置清单登记环节 | 人确认该包是否在本次任务可动范围;不在则 1-C 仅做仓库内 example 资产,内置清单留下次 |
| chart-ui 包手势支持现状(004 §9) | 2-C 实际迁移到 chart-ui 的时机(不阻塞 2-C 在本模块做原型) | 不解锁,继续按"已知技术债"在 StarXiuRingPainter 原型化,①②层可迁移设计兜底 |

---

## 人类行动指令手册(每个阶段该跟哪个 Agent 说什么)

> 谁完成,结果给谁,启动下一步——逐阶段明示

### 启动准备(最先做的一次性动作)

**人 → 终端,选择启动方式**:

- 方式 1: 三个方向都用同一 worktree
  ```
  cd /Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu
  aiwt adopt opencode 003-sanchen-zhoutian-integration
  ```
  把主工作区两份 untracked 文档(003 调研 + 004 设计)一并搬进 worktree,主工作区恢复干净。

- 方式 2: 三个方向分三个 worktree(推荐,避免互相踩)
  ```
  aiwt new opencode 003-sanchen-data-integration
  aiwt new claude 004-drag-calibration-tool
  aiwt new claude 005-house-division-deadfield
  ```
  注意: 003/004 两份 untracked 文档需手动 `cp` 进对应 worktree,或先 adopt 后再 new(主工作区干净了之后第二份 new 会自动从 main HEAD 拉)。

**人 → 各 worktree: 把本任务纪要 (`docs/project/tasks/003-004-sanchen-zhoutian-task.md`) cp 进每个 worktree 的同路径**。

---

### 方向一阶段指令

#### 1-A: 人 → OpenCode

启动 worktree: `003-sanchen-data-integration`(或方式 1 的合并 worktree)

**对 OpenCode 说的话**(全字面,零条件):
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-A"阶段。
再读 docs/project/architecture/003-三辰通载黄道恒星制盘制数据接入调研.md 的第 3 节和第 6.3 节。

任务: 对照 example/assets/qizhengsiyu/yuan_shoushi_chidao_hengxin.json(正模板)和另外 3 份旧 schema 文件(han_chidao_hengxin.json / yuan_chidao_hengxing.json / ming_si_huangdao_hengxing.json),逐字段核对差异,产出一份"字段差异清单 + 补全方案"草稿。

具体产出:
1. 3 份旧文件每一份,逐字段列出: 旧字段名 → 新字段名 + 值要不要改(如 "似黄道制"→"似黄道恒星制","古宿"→"古宿制")
2. 补全 gongOrder/starInnOrder 的方式: 从 yuan_shoushi_chidao_hengxin.json 复用 28 宿固定环序 + 十二地支退行
3. specificationList 每份文件的描述性文字(沿用 yuan_shoushi 写法)

把产出写到 docs/project/tasks/1A-schema-diff-report.md。不改任何 JSON 文件。

完成后跑 /wjt-handoff 把进度写进任务纪要。
```

**结果交给谁**: OpenCode 完成后,人(或 Hermes)把 `1A-schema-diff-report.md` 路径告诉 Claude Code,让 Claude Code 扫一眼字段对照无遗漏——是契约对齐审查,不是 Claude 亲自写。

**下一步**: 人确认无遗漏 → 启动 1-B。

#### 1-B: 人 → OpenCode(主) + Claude Code(复审)

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-B"阶段。
读 docs/project/tasks/1A-schema-diff-report.md(1-A 产出)。
读 docs/project/architecture/003-...调研.md 的第 10.2 节(S1-S5 步骤)和第 10.3 节(6 类验证测试)。

任务分两半:

(B1) 迁移 3 份旧 JSON:
- 按 1-A 差异表逐份手工重写为新 schema,先存为 *.v2.json 不覆盖原文件
- 补 gongOrder/starInnOrder/specificationList
- 修值名("似黄道制"→"似黄道恒星制"等)

(B2) 新增 test/domain/entities/zhou_tian_model_asset_schema_test.dart:
- 落地 003 §10.3 第 1/2/3/4 类测试(4 类 × 4+1 份资产)
- 参考现有 test/domain/entities/zhou_tian_model_test.dart 和 zhou_tian_model_overrides_test.dart 的写法和 fixture 加载方式
- 第 3 类(度数总和自洽性)会暴露 yuan_shoushi 12 宫写死 30.0 求和 360≠365.25 的既有 bug,先记录为已知偏差,断言容差 0.01°

完成后跑:
  flutter analyze   (要 0 error)
  flutter test test/domain/entities/zhou_tian_model_asset_schema_test.dart   (要全绿)

把测试输出贴进 docs/project/tasks/1B-test-report.md。完成后跑 /wjt-handoff。
```

**OpenCode 完成后,人 → Claude Code 复审**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-B"验收标准。
读 docs/project/tasks/1B-test-report.md(OpenCode 测试输出)和 zhou_tian_model_asset_schema_test.dart(OpenCode 写的测试代码)。
读 docs/project/architecture/003-...调研.md 第 10.3 节(6 类测试规格)。

任务: 审查 OpenCode 写的回归测试是否对齐 003 §10.3 的 6 类测试规格(契约对齐审查,不是自己重写)。

特别查:
1. Round-trip 测试是否对所有字段都做了等值比较(不是只查个别字段)
2. 度数总和自洽性测试的容差 0.01° 是否真到位
3. 对齐点自洽性测试是否真的调了 ZhouTianCalculator 的 calculateConstellationAngles,不是空断言

把审查结论写到 docs/project/tasks/1B-review-claude.md:通过 / 返工项(用"文件:行 问题一句话 | 通过标准"格式)。
然后跑 /wjt-review。
```

**下一步**: Claude Code 审查通过 → 启动 1-C;有返工项 → 把返工项交回 OpenCode,收敛后 Claude Code 再审一轮。超过 3 轮不收敛 → 熔断,人裁决。

#### 1-C: 人 → OpenCode

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-C"阶段。
读 docs/project/architecture/003-...调研.md 的第 4.3 节(需要新增/修改的东西)和第 3 节(外部包现状)。

任务分两半:

(C1) 写新资产 example/assets/qizhengsiyu/sanchen_tongzai_huangdao_hengxing.json:
- 严格采用 yuan_shoushi_chidao_hengxin.json 当前 schema
- totalDegree = 365.255(28 宿度数表求和)
- 28 宿度数 = 用户给的"第一组 28 宿黄道度数表"(见 003 §2.1)
- 12 宫 gongDegreeSeq: 暂用等宫 365.255/12 = 30.4379 各填(不等宫留方向三处理)
- 对齐点: 暂用 userTableDerived(虚宿 1.6275° = 子宫0°)作为默认锚点
- systemType = 似黄道恒星制, panelSystemType = 恒星制, constellationSystemType = 古宿制
- starInnOrder/gongOrder 沿用现有枚举不新增

(C2) 探查 repository-interface-qizhengsiyu 包:
- 在 pubspec.yaml 找到它的本地路径
- cd 进去(或在文件管理器里看),找 loadBuiltInZhouTianModels() 的实现位置
- 看它有没有内置数据清单数组,如果有,记录: 包路径、清单数组位置、新增一条需要改什么
- 如果该包不在可访问范围,记录为阻塞项,不强行

把产出写到 docs/project/tasks/1C-asset-and-external-package-report.md。完成后跑 /wjt-handoff。
```

**下一步**: 1-C 完成后,人确认外部包是否在可动范围。如果不在,1-C 的内置清单登记环节记为阻塞项,其余完成。然后等 1-D 拍板锚点回填资产。

#### 1-D: 人 → Claude Code(写 SOP) → MiMo/OpenCode(执行检索) → 人(拍板)

**对 Claude Code 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-D"阶段。
读 docs/project/architecture/003-...调研.md 的第 12.2 节(候选登记表)和第 15 节(史源勘误 + 候选)。

任务: 写一份"史料调研 SOP",用来指派别的 Agent 去检索史源,你本人不翻书。

SOP 要包含:
1. 5 个候选锚点各自的检索目标:
   - codeComment_xu6(虚宿6°=子宫0°,自称"三辰通载")
   - kaixiLi_xuwei_zi15(虚危交界=子宫15°,《开禧历》)
   - kaixiLi_kui9_75(奎宿9.75°=戌宫0°,《开禧历》)
   - userTableDerived(虚宿1.6275°=子宫0°,反推)
   - sanChenTongZai_ziwu_unequal(子午30.4380/其余30.4979,宫宽度)
2. 每个候选要找什么: 具体到《开禧历》《三辰通载》哪一卷哪一段的原文引用
3. 合格标准: 找到的描述必须是"某宿某度 = 某宫某度"这种成对表述的原文,而不是后人转述/二手研究
4. 不合格标准: 只有结论没有原始引文、是现代论文二手引用、作者自己也标注"推测"——这些都标"待补"不算定案
5. 检索渠道建议: 中国哲学书电子化计划(ctext.org)、汉籍电子文献瀚典、四库全书电子版、知网相关论文(只看引用的史源部分)

把 SOP 写到 docs/project/tasks/1D-source-research-sop.md。你不亲自检索。
完成后跑 /wjt-handoff。
```

**Claude Code 写完 SOP 后,人 → MiMo(或 OpenCode)**:
```
读 docs/project/tasks/1D-source-research-sop.md。

任务: 按 SOP 对 5 个候选锚点逐一检索史源。每个候选:
- 按 SOP 指定的渠道去找
- 找到的描述逐字记录原文 + 出处(书名/卷/段/URL)
- 用 SOP 的合格/不合格标准判定每条记录是不是"定案级证词"
- 不合格的标"待补",不要凑数

把结果写到 docs/project/tasks/1D-source-research-findings.md。
完成后跑 /wjt-handoff。
```

**MiMo/OpenCode 检索完成后,人 → Claude Code**:
```
读 docs/project/tasks/1D-source-research-findings.md(MiMo/OpenCode 的检索结果)。
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向一 1-D"验收标准。

任务: 不亲自翻书,只基于 MiMo/OpenCode 找到的材料做判断:
1. 每个候选的史源是"定案级证词"还是"待补"
2. 哪些候选之间有内部自洽性可以互证(003 §15.3 提到 kaixiLi_xuwei_zi15 和 kaixiLi_kui9_75 同属《开禧历》应该能互相导出)
3. 给人一个"推荐哪个候选进资产 + 理由"的建议,但最终拍板权在人

把判断写到 docs/project/tasks/1D-claude-analysis.md。不替人拍板。
完成后跑 /wjt-handoff。
```

**最终**: 人看 Claude Code 的分析 + 自己判断 → 拍板哪个候选进资产 → 把决定告诉 OpenCode,让其回填 `sanchen_tongzai_huangdao_hengxing.json` 的 `alignmentPointAtConstellation` 字段 + 更新 `zhou_tian_model.dart:60-61` 注释(含"天禧历"→"开禧历"勘误)。

**1-D 闭环后**,人 → OpenCode:
```
1-D 锚点已拍板为 [人选]。现在补三辰通载专属 golden 测试(003 §10.3 第 5 类):
- 输入: sanchen_tongzai_huangdao_hengxing.json + 拍板锚点
- 调 ZhouTianCalculator.mapConstellationsToPalaces()
- 断言: 逐宫分段结果与用户给的"12 宫对齐分段表"(003 §2.2) 4 位小数完全一致
- 这是方向一最终验收标准
```

---

### 方向二阶段指令

#### 2-A: 人 → OpenCode

启动 worktree: `004-drag-calibration-tool`

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-A"阶段。
读 docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md 的第 5 节(三层架构)关于①层的描述。

任务: 写一个纯几何环形角度增量库。
- 纯函数: 给定环心坐标(Offset)、半径(double)、起始指针位置(Offset)、终止指针位置(Offset),返回相对起始角的角度增量(double)
- 只 import dart:math 和 Flutter 基础几何类型(Offset)
- 零业务依赖,不 import 任何 qizhengsiyu 包内类型
- 处理跨 0°/360° 边界(顺时针/逆时针都返回带符号增量)

建议路径: lib/domain/geometry/ring_drag_angle_delta.dart(或类似,具体路径执行时按现有项目目录结构定)

配套单元测试覆盖跨边界场景。完成后跑:
  flutter analyze
  flutter test [对应测试文件]
要全绿。完成后跑 /wjt-handoff。
```

**下一步**: 2-A 完成且测试绿 → 启动 2-B(依赖 2-A)。

#### 2-B: 人 → Claude Code

**对 Claude Code 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-B"阶段。
读 docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md 的第 4 节(对齐点是绝对值不是增量)、第 5 节②层、第 6 节(数据模型改动)。

任务分三步:

(B1) 写七政四余语义适配层:
- 把①层(2-A 产出的 ring_drag_angle_delta)的角度增量翻译成"当前指向第几宿第几度"
- 读 ZhouTianModel.starInnOrder 和 starInnDegreeSeq
- 输出一个 ConstellationDegree(宿 + 度数)绝对值

(B2) BasePanelConfig 新增字段:
- ConstellationDegree? alignmentPointOverride(默认 null,为空则完全沿用资产自带的 alignmentPointAtConstellation)

(B3) ZhouTianModel.applyOverrides() 扩参:
- 新增 ConstellationDegree? alignmentPointOverride 参数
- 非空时: 同时替换 alignmentPointAtConstellation 和 zeroPointAtConstellation(两字段写同一绝对值)
- 不碰 alignmentPointAtGong / zeroPointAtGong / gongDegreeSeq / starInnDegreeSeq
- ZhouTianModelManager.getZhouTianModelBy() 中把 config.alignmentPointOverride 一并传入 applyOverrides()

配套测试:
- ②层单元测试: 角度增量→宿度换算
- applyOverrides() 回归测试: override 非空时双字段替换、其他 4 字段不变
- 集成测试: 切换 override 前后 calculateConstellationAngles() 输出确实变

完成后跑:
  flutter analyze
  flutter test
要全绿。完成后跑 /wjt-handoff。
```

**下一步**: 2-B 完成且测试绿 → 启动 2-C 和 2-D(2-D 可与 2-C 并行)。

#### 2-C: 人 → OpenCode

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-C"阶段。
读 docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md 第 5 节③层、第 7 节(交互设计)。

任务: 在现有 StarXiuRingPainter 外包一层手势识别,把①层(2-A)和②层(2-B)串起来。
- onPanUpdate: 实时算角度增量→换算宿度→触发重绘→盘面附近显示实时读数(如"当前: 虚宿 3.42°")
- onPanEnd: 当前值成本次会话候选结果,给两个动作(保存为排盘配置 / 标定为新候选点)
- 全程自由连续拖动,不做候选点吸附

文件顶部明确标注:
// TECHNICAL DEBT: 本层是 StarXiuRingPainter 原型化,chart-ui 共享渲染包就绪后整层替换。
// ①②层(ring_drag_angle_delta + 语义适配)可直接搬迁,本层重写。

Widget 测试: 模拟拖拽手势断言实时读数文本随手势更新。
完成后跑:
  flutter analyze
  flutter test [对应测试文件]
要全绿。完成后跑 /wjt-handoff。
```

**下一步**: 2-C 完成后 → 等 2-D 一起进 2-E。

#### 2-D: 人 → Claude Code(写 SOP) → OpenCode(取数) → Claude Code(选型)

**对 Claude Code 说的话(写 SOP)**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-D"阶段。
读 docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md 第 6 节(用户自建候选对齐点存储)。

任务: 写一份调研 SOP,让 OpenCode 去读 GeJu 模块的 user_ 前缀自建数据现状,你不亲自查。

SOP 要明确:
1. 去哪些目录找 GeJu 模块的自建数据相关代码(按现有项目结构搜 user_ 前缀、自建配置相关的文件)
2. 要回答的问题:
   - GeJu 自建数据用的是 Drift(数据库)还是 JSON 文件?
   - 如果是 Drift: 表结构、DAO 接口形状、迁移机制
   - 如果是 JSON: 文件路径模式、读写接口、命名约定
   - CRUD 接口签名
3. 合格标准: 必须给出具体的文件路径 + 代码摘录,不是泛泛描述

把 SOP 写到 docs/project/tasks/2D-geju-research-sop.md。你不亲自读 GeJu 代码。
完成后跑 /wjt-handoff。
```

**Claude Code 写完 SOP 后,人 → OpenCode**:
```
读 docs/project/tasks/2D-geju-research-sop.md。

任务: 按 SOP 去读 GeJu 模块的 user_ 前缀自建数据现状,逐条回答 SOP 的问题。
- 每条答案给出具体文件路径 + 相关代码摘录
- 不合格的标"未找到"不凑数

把结果写到 docs/project/tasks/2D-geju-research-findings.md。
完成后跑 /wjt-handoff。
```

**OpenCode 取数完成后,人 → Claude Code(选型决策)**:
```
读 docs/project/tasks/2D-geju-research-findings.md(OpenCode 的取数报告)。
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-D"验收标准。

任务: 基于取数报告做选型决策 + 定接口:
1. 选 Drift 还是 JSON,理由写清(对齐现有 GeJu 模式优先)
2. 定义新候选表接口: 表/文件名、字段(候选名称/ConstellationDegree/创建时间/来源备注)、CRUD 签名
3. 把选型根据写到决定记录(任务纪要的"方向二决定记录"追加一行)

然后让 OpenCode 按你定的接口做最小实现(mkdir/CRUD)。
完成后跑 /wjt-handoff。
```

**下一步**: 2-D 接口定好 + 最小实现完成 → 启动 2-E。

#### 2-E: 人 → OpenCode

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向二 2-E"阶段。
读 docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md 的第 8 节(测试计划)。

任务: 收尾集成测试 + Widget 测试:
(a) 拖动→实时读数变更
(b) onPanEnd 后两个保存动作(写配置 / 存候选)调用正确的持久化接口(可 mock)
(c) 切换 alignmentPointOverride 前后 mapConstellationsToPalaces() 输出确实改变(003 §10.3 第 6 类"待补"测试现在可写)

完成后跑:
  flutter analyze   (0 error)
  flutter test      (全绿)
把输出贴到 docs/project/tasks/2E-test-report.md。完成后跑 /wjt-handoff。
```

**最终**: 人验收 → 方向二完成。

---

### 方向三阶段指令

#### 3-A: 人 → Claude Code

启动 worktree: `005-house-division-deadfield`

**对 Claude Code 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向三 3-A"阶段。
读 docs/project/architecture/003-...调研.md 的第 9 节、第 13 节(方案 B + 公式表 + 一致性校验)。

任务分四步:

(a1) HouseDivisionSystem 新增枚举值 equatorialZiWuSanChenTongZai:
- 子午两宫 30.4380°, 其余十宫 30.4979°(003 §13.2)
- description 写清公式, 区别于既有 equatorialZiWu(32.625°)
- 不和既有 equatorialZiWu 撞名撞数字

(a2) ZhouTianModel.applyOverrides() 扩参:
- 新增 HouseDivisionSystem? houseDivisionSystemOverride 参数
- 非空时按枚举现算 gongDegreeSeq(12 个 GongDegree)覆盖资产自带值
- 为空时保持现状, 完全向后兼容
- 公式表纯函数分派所有枚举值(equal/equatorialEqual/equatorialFourZheng/equatorialSunMoon/equatorialZiWu/equatorialZiWuSanChenTongZai/unequal)

(a3) panel_system_resolver.dart 新增⑦号一致性检查:
- houseDivisionSystemOverride 生效时重算 gongDegreeSeq 总和
- 与 totalDegree 差 >0.05° 给警告(不阻断)
- 例如 "当前不等宫方案(三辰通载子午)总和 365.855° 与周天 365.255° 相差 0.6°, 盘面首尾宫位可能出现缝隙, 请确认史料口径"
- warning-only, 呼应 resolver 现有 non-blocking 风格

(a4) custom_config_section.dart 补齐 HouseDivisionSystem 选择控件:
- 目前完全缺失(003 §9.1 核查结论)
- 接入要避免选出不存在的组合

完成后跑:
  flutter analyze   (0 error)
  flutter test      (现有测试不退化)
完成后跑 /wjt-handoff。
```

**下一步**: 3-A 完成后 → 启动 3-B。

#### 3-B: 人 → OpenCode

**对 OpenCode 说的话**:
```
读 docs/project/tasks/003-004-sanchen-zhoutian-task.md 的"方向三 3-B"阶段。
读 docs/project/architecture/003-...调研.md 的第 10.3 节第 6 类测试 + 第 13.5 节第 7 点。

任务: 反向验证测试(测试是 oracle, 代码适配测试, 绝不可改断言迁就实现):

(a) 切换 houseDivisionSystemOverride 前后 calculatePalaceAngles() 输出确实变
(b) 默认空时 gongDegreeSeq 与现有资产 round-trip 一致
(c) 0.6° 偏差在测试里被显式登记为"已知偏差, 不阻断"(equatorialZiWuSanChenTongZai 总和 365.855 vs totalDegree 365.255)
(d) 每个枚举值的公式分派都有对应断言(包括 equatorialFourZheng/equatorialSunMoon/equatorialZiWu 既有公式, 防回归)

完成后跑:
  flutter analyze   (0 error)
  flutter test      (全绿)
把输出贴到 docs/project/tasks/3B-test-report.md。完成后跑 /wjt-handoff。
```

**下一步**: 3-B 测试绿 → 人验收 → 方向三完成 → 单独 PR 不和 003/004 混。

---

## 熔断规则

- 任一阶段 OpenCode ↔ Claude Code 往返审查超过 3 轮不收敛 → 熔断,停止派发,报告人(病根通常在计划或验收标准,需人裁决)
- 任一阶段 `flutter analyze` 出 error / `flutter test` 不绿 → 不准进下一阶段
- 1-D 史料检索找不到"定案级证词"不算熔断,按"待补"保留候选,拍板由人

---

## 验收总闸(三个方向各自独立验收)

| 方向 | 验收命令 | 终验标准 |
|---|---|---|
| 一 | `flutter analyze` + `flutter test` + 三辰通载专属 golden 测试 | 0 error + 全绿 + 12 宫分段表 4 位小数一致(003 §10.3 第 5 类) |
| 二 | `flutter analyze` + `flutter test` | 0 error + 全绿(含 5 类测试: ①层边界/②层换算/applyOverrides 回归/集成切换/Widget 拖拽) |
| 三 | `flutter analyze` + `flutter test` | 0 error + 全绿(含切换前后输出变化 + 0.6° 偏差显式登记) |

**人最终拍板**: 三个方向各自独立合并进 main(走 `aiwt done`--no-ff 保留分支历史 + 归档纪要)。

---

## 变更记录

| 日期 | 变更 | 作者 |
|---|---|---|
| 2026-07-09 | 初稿: 按 wjt-plan 协议蒸馏 003+004 研讨成果,分三个方向 + 一个硬阻塞,给出每阶段 Agent 分派 + 人类行动指令手册 | wjt / Hermes |
