# 1B 测试报告

## 元信息

- 创建日期: 2026-07-09
- 前置: 1A schema 摸底报告 (`docs/project/tasks/1A-schema-diff-report.md`)
- 测试文件: `test/domain/entities/zhou_tian_model_asset_schema_test.dart`
- 迁移产出: `han_chidao_hengxin.v2.json`, `yuan_chidao_hengxing.v2.json`, `ming_si_huangdao_hengxing.v2.json`

---

## flutter analyze 结果

```
No issues found!
```

---

## flutter test 结果 (R1 修复后)

```
All tests passed! (24/24)
```

### 测试明细

#### 第 1 类: Schema 可解析性 (4 条)

| 文件 | 结果 |
|------|------|
| yuan_shoushi_chidao_hengxin.json | PASS |
| han_chidao_hengxin.v2.json | PASS |
| yuan_chidao_hengxing.v2.json | PASS |
| ming_si_huangdao_hengxing.v2.json | PASS |

#### 第 2 类: Round-trip (4 条) — R1 修复: 补 projectionConfig + zeroPointOffsetToNow

| 文件 | 结果 |
|------|------|
| yuan_shoushi_chidao_hengxin.json | PASS — 19 个可序列化字段全部逐项比对 |
| han_chidao_hengxin.v2.json | PASS |
| yuan_chidao_hengxing.v2.json | PASS |
| ming_si_huangdao_hengxing.v2.json | PASS |

#### 第 3 类: 度数总和自洽性 (8 条) — R1 修复: 按 starInn/gong 轴分离已知偏差

| 文件 | 序列 | 结果 | 容差 | 备注 |
|------|------|------|------|------|
| yuan_shoushi | starInnDegreeSeq | PASS | 5.26° | 已知偏差: 郭守敬距度表求和 ≈360 vs 365.25 |
| yuan_shoushi | gongDegreeSeq | PASS | 5.26° | 已知偏差: 12 宫各 30.0 求和 360 vs 365.25 |
| han_chidao_hengxin.v2 | starInnDegreeSeq | PASS | **0.01°** | 求和精确 = 365.25，R1 修复后容差回到 0.01° |
| han_chidao_hengxin.v2 | gongDegreeSeq | PASS | 0.04° | 已知偏差: 30.44×12=365.28，0.03° |
| yuan_chidao_hengxing.v2 | starInnDegreeSeq | PASS | **0.01°** | 求和 = 365.25 |
| yuan_chidao_hengxing.v2 | gongDegreeSeq | PASS | **0.01°** | 30.438×12=365.256，0.006° |
| ming_si_huangdao_hengxing.v2 | starInnDegreeSeq | PASS | **0.01°** | 求和精确 = 365.25，R1 修复后容差回到 0.01° |
| ming_si_huangdao_hengxing.v2 | gongDegreeSeq | PASS | 0.04° | 已知偏差: 30.44×12=365.28，0.03° |

#### 第 4 类: 对齐点自洽性 (8 条) — R1 修复: 从 returnsNormally 升级为宽度区间校验

| 文件 | 不抛异常 | 区间校验 | 备注 |
|------|---------|---------|------|
| yuan_shoushi | PASS | PASS | constellationAngles + palaceAngles 均包含对齐点目标，宽度总和在放宽容差内 |
| han_chidao_hengxin.v2 | PASS | PASS | |
| yuan_chidao_hengxing.v2 | PASS | PASS | |
| ming_si_huangdao_hengxing.v2 | PASS | PASS | |

---

## R1 修复清单（对应 1B-review-claude.md 返工项）

| 返工项 | 修复 |
|--------|------|
| R1-1: Round-trip 漏 2 字段 | 补 `projectionConfig`(strategy+offset) 和 `zeroPointOffsetToNow` 断言 |
| R1-2: 容差未按轴分离 | 拆分为 `_knownStarInnDeviations` 和 `_knownGongDeviations`，han/ming starInn 容差恢复到 0.01° |
| R1-3: 第 4 类弱断言 | 新增"计算结果包含对齐点目标且宽度落入 totalDegree 区间"子测试：验证对齐星宿/宫位存在于结果、宽度>0、宽度总和≈totalDegree |
| 溯源: 1A 报告缺失 | 已补齐 `docs/project/tasks/1A-schema-diff-report.md`，测试注释指向 003 §3 |

---

## 执行环境

- 主 workspace: `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/`
- Worktree: `/Users/jingtaiwei/Git/Public/xuan-migration/xuan-migration-worktrees/sanchen-tongzai/`

---

## 变更记录

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-07-09 | 1-B 完成: 3 份迁移 + 4 类测试全绿, analyze 0 error | OpenCode |
| 2026-07-09 | R1 修复: 按 Claude Code 复审意见修 3 返工 + 1 溯源缺陷, 24/24 全绿 | OpenCode |
