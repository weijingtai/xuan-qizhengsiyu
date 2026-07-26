# BLOCKER-REPORT — T3 轨道 A 阶段 1

## 轨道：七政四余 (xuan-qizhengsiyu)
## 日期：2026-07-25
## 阶段：Phase 1

---

## BLOCKER-1: bazi_embed_smoke_test 无法编写

**状态**：阻塞（blocked）

**原因**：
- G4 要求编写 `test/presentation/bazi_embed_smoke_test.dart`
- 该测试依赖 G3 BaziEmbed 组件的接入
- G3 BaziEmbed 接入在本轨道被明确列为禁区（人类尚未裁决，碰即 FAIL）
- 因此无法编写 bazi_embed_smoke_test

**影响**：
- 无法完成 G4 的完整冻结测试集
- unified_time_input_smoke_test.dart 已按计划编写并提交

**建议**：
- 等待人类裁决 G3 BaziEmbed 是否开放给本轨道
- 若 G3 开放后，补充编写 bazi_embed_smoke_test.dart

---

## 已完成的工作

| 阶段 | 状态 | 说明 |
|------|------|------|
| G2 依赖卫生 | ✅ 完成 | xuan_time_location 补正式 git 声明 |
| G1 统一时间输入 | ✅ 完成 | QizhengTimezoneProviderAdapter + QTIC 接入 |
| G4 冻结测试 | ⚠️ 部分完成 | unified_time_input_smoke_test.dart 已写，bazi_embed_smoke_test 阻塞 |

---

## 测试基线对照

| 指标 | 基线 | 完工 |
|------|------|------|
| 通过 | 754 | 待验证 |
| 跳过 | 12 | 待验证 |
| 失败 | 10 | 待验证 |
