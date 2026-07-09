# 任务纪要：接入三辰通载

- 分支：`feat/sanchen-tongzai`
- WorkTree：`xuan-migration-worktrees/sanchen-tongzai`
- 任务：把《三辰通载》七政四余黄道宿度的**出处**与**正确数据**落地到程序（注释 + 资产）

---

## 验收标准区（勿改）

1. 《三辰通载》星宿-宫位对应关系的**出处**写进程序（作者、版本、锚点、文档链接可追溯）。
2. 资产数据与三辰通载原表一致（周天 365.255°、锚点 子宫0°=虚1.6275°），不得残留 AI 幻觉错数据。
3. 作者名以用户裁定为准，全仓统一，无一字之差硬伤。

---

## 踩坑墓地（别人失败过什么，勿重试）

- **⚠ 作者名一字之差是硬伤**：史料档案早期写「钱**汝**璧」，用户最终裁定「钱**如**璧」。已于 2026-07-09 由用户经 AskUserQuestion 拍板 = **钱如璧（如）**，并全仓统一。任何后续改动不得回退成「汝」。
- **⚠ 旧资产 `song_sanchentongzai.json` 是 AI 幻觉错数据**：原值 totalDegree=360、十二宫全 30、锚点危宿0°、注释带 `[2,6](@ref)` 假引用标记。切勿在此错数据上贴出处。已整体重写。
- **⚠ 史源判定演化**：`1D-claude-analysis.md` 早期把「虚1.6275°」判为「反推值/无史源」；但 `1D-sanchen-primary-source.md`（更新）经用户确认——那份 12 宫分段表**就是三辰通载原表 decimalized，不是反推**。以最新定论为准：锚点=子宫0°=虚1.6275°。
- **⚠ 开禧历锚点 AI 不可裁定**：两次独立 AI 检索（Gemini/MiMo）对《宋史·开禧历》给出互斥原文，虚5° vs 虚7°、奎9.25° vs 奎1~2°。史源留人工纸本坐实，**不写死进资产**。
- **⚠ zhou_tian_model.dart 旧注释「虚6°」「虚危交界子宫15°」不删**（用户明确要求）：只**追加**新出处补注，不动旧行。

---

## 当前状态

**本轮（2026-07-09）已完成**——出处落地 + 资产改对 + 作者名统一：

1. `lib/domain/entities/models/zhou_tian_model.dart` — 在 `alignmentPointAtConstellation` 字段头**追加**出处补注块（旧两行保留）：钱如璧/影宋抄本/子宫0°=虚1.6275°/周天365.255°/等宫30.4379°/文档链接；并标注「天禧历」疑为「开禧历」笔误（待人工坐实）。
2. `example/assets/qizhengsiyu/song_sanchentongzai.json` — **整体重写为新 schema**（`constellationSystemType`/`gongDegreeSeq`/`starInnDegreeSeq`/`alignmentPointAtConstellation`/`specificationList`）+ 正确数据（28宿宿度求和=365.255、等宫、锚点虚1.6275°）+ 出处写入 `specificationList`。
3. 全仓「钱汝璧」→「钱如璧」统一（`1D-sanchen-primary-source.md`、`1D-claude-analysis.md`）。

**验证**：
- JSON 合法性 ✓、宿度求和=365.255 ✓、宫度求和=365.255 ✓、宿28宫12 ✓、锚点虚1.6275°=子宫0° ✓。
- 四枚举值（黄道制/古宿制/恒星制/春分）逐一核对合法 ✓。春分=黄经0°，与 celestialLongitude:0.0 自洽。
- `flutter analyze` **无法运行**（环境缺失 `../calendar` path 依赖，pre-existing，与本改动无关）。改动为纯注释追加+资产 JSON，不参与编译。

**资产现状**：`song_sanchentongzai.json` 仍是**孤儿文件**（loader 走 `assets/historical_definitions/`，dart 代码零引用），本轮不接入 loader/排盘。`zeroPointOffsetToNow` 岁差参数暂置 0.0（未坐实），已在 specificationList 标注。

---

## 计划区

- [x] 恢复上下文（AGENTS.md / git / 考订档案），确认断点
- [x] 裁定作者名（用户拍板：钱如璧）
- [x] 改注释：`zhou_tian_model.dart` 追加三辰通载出处补注（不删旧行）
- [x] 改对资产：`song_sanchentongzai.json` 新 schema + 正确数据 + 出处
- [x] 全仓作者名统一（钱汝璧→钱如璧）
- [x] 验证：JSON 合法性 + 数据自洽 + 枚举值合法
- [x] commit 落盘（含前任未提交的 tasks/ 考订档案）
- [ ] （待用户决定）是否 push + 开 draft PR
- [ ] （后续任务，非本范围）接入 loader / 岁差参数 zeroPointOffsetToNow 计算 / 排盘联动

---

## 决定记录

| 日期 | 决定 | 依据 |
|---|---|---|
| 2026-07-09 | 作者名 = 钱如璧（如） | 用户经 AskUserQuestion 拍板，覆盖史料档案早期「汝」写法 |
| 2026-07-09 | 范围 = 注释补出处 + 改对资产，不接 loader/排盘 | 用户上个会话拍板 |
| 2026-07-09 | 锚点 = 子宫0°=虚1.6275°（等宫分段表口径） | `1D-sanchen-primary-source.md` §三净结论 |
| 2026-07-09 | 旧注释「虚6°」「子宫15°」保留，仅追加 | 用户明确要求不删 |
| 2026-07-09 | 开禧历锚点不写死进资产 | 两 AI 检索互斥，史源待人工纸本坐实 |
