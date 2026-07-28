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

---

# BLOCKER-REPORT — P2 依赖解阻塞（2026-07-26）

## 阻塞原因

`flutter pub get` 失败：`bazi_embed_ui_interface` 声明 `repository_interface_bazi` 带 `ref: main`，而远程 `persistence_preferences`（gitea main: `269cd52`）声明无 ref，pub solver 将两者视为不兼容 source spec。

## 错误原文

```
Because every version of bazi_embed_ui_interface from git depends on repository_interface_bazi from git http://192.168.0.165:3000/xuan/repository-interface-bazi.git at main and every version of persistence_preferences from git depends on repository_interface_bazi from git http://192.168.0.165:3000/xuan/repository-interface-bazi.git at HEAD, bazi_embed_ui_interface from git is incompatible with persistence_preferences from git.
So, because qizhengsiyu depends on both persistence_preferences from git and bazi_embed_ui_interface from git, version solving failed.
```

## 已尝试解法（全部失败）

1. `dependency_overrides` 仅加 `repository_interface_bazi`（带 `ref: main`）: 失败
2. `dependency_overrides` 仅加 `repository_interface_bazi`（不带 ref）: 失败
3. `dependency_overrides` 同时加 `repository_interface_bazi` + `persistence_preferences`（均带 `ref: main`）: 失败
4. `flutter pub cache clean` 后重试: 失败
5. 删除 `pubspec.lock` 后重试: 失败

## 根因确认

```bash
# 远程 persistence_preferences 确实无 ref: main
$ git -C xuan-storage show main:preferences/pubspec.yaml | grep -A3 "repository_interface_bazi"
  repository_interface_bazi:
    git:
      url: http://192.168.0.165:3000/xuan/repository-interface-bazi.git
dev_dependencies:

# 远程 main HEAD 是 269cd52，不包含 fix commit c0a7f07
$ git -C xuan-storage ls-remote origin refs/heads/main
269cd5265af82fee7cd34dab489ccaf155fca8e2	refs/heads/main

# 本地有 fix commit 但未推送
$ git -C xuan-storage log --oneline -3
c0a7f07 fix(storage): repository_interface_bazi 补 ref: main 统一依赖来源
b0d0fd5 feat: 添加创建流审计日志表（CreationAuditLogs）
```

## 根治方案

`xuan-storage` 仓 `c0a7f07`（补 `ref: main`）需推送至 gitea main。但该仓属人类保留区，且全轮禁 push。

## 当前 `dependency_overrides` 状态

```yaml
dependency_overrides:
  repository_interface_bazi:
    git:
      url: http://192.168.0.165:3000/xuan/repository-interface-bazi.git
      ref: main
  persistence_preferences:
    git:
      url: http://192.168.0.165:3000/xuan/xuan-storage.git
      path: preferences
      ref: main
```
