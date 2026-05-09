# 代码交付流水线

**目的：** 定义一个小功能从分支创建到合并的完整生命周期，与 SPEC Coding (phases.md) 并行运行。SPEC Coding 控制"怎么想"，交付流水线控制"怎么交付"，两者同时约束。

## 流水线总览

```
┌─────────────┐   准入满足    ┌─────────────┐   准入满足    ┌─────────────┐
│  Step 1     │ ────────────→ │  Step 2     │ ────────────→ │  Step 3     │
│  分支就绪    │               │  代码开发    │               │  自测验证    │
└─────────────┘               └─────────────┘               └─────────────┘
                                                                  │
                                                                  │ 准入满足
                                                                  ↓
┌─────────────┐   准入满足    ┌─────────────┐
│  Step 5     │ ←─────────── │  Step 4     │
│  合并归档    │               │  提交就绪    │
└─────────────┘               └─────────────┘
```

## Step 1: 分支就绪（Branch Ready）

**目的：** 基于最新 main 创建符合规范的开发分支。

| 准入条件 | 判断标准 |
|---------|---------|
| 当前在 main 分支且无脏文件 | `git status --porcelain` 输出为空 |
| main 分支已同步远端 | `git fetch && git diff main..origin/main` 输出为空 |
| 分支名符合规范 | 匹配 `<type>/<short-description>` |
| type 在允许列表中 | type ∈ {feat, fix, refactor, doc, chore} |
| 分支描述包含功能关键词 | 后段为中文拼音或英文关键字，不可为无意义数字 |

| 准出条件 | 判断标准 |
|---------|---------|
| 新分支已从 main 创建 | `git branch --show-current` 输出新分支名 |
| 分支名符合规范 | 匹配正则 `^(feat|fix|refactor|doc|chore)/[a-z][a-z0-9-]+[a-z0-9]$` |

MUST: 分支从 main 最新提交创建
MUST NOT: 从其他非 main 分支派生
MUST NOT: 在已有脏工作区时创建分支

## Step 2: 代码开发（Development）

**目的：** 在分支内完成代码开发，随时自查。此步骤对应 SPEC Coding Stage B1（代码实现）。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 1 准出全部满足 | 分支已就绪 |
| SPEC 已锁定（非平凡改动） | SPEC 状态为 "已锁定"，文件存在于 docs/superpowers/specs/ |
| 已阅读 code-style.md、directory-structure.md、doc-standards.md | AI 在会话中已读取对应模块 |

| 准出条件 | 判断标准 |
|---------|---------|
| 所有计划的功能点已实现 | 对照 SPEC 验收条件逐项勾选 |
| `flutter analyze` 无 error/warning | 运行 `flutter analyze` 输出 "No issues found!" |
| `dart format` 通过无需修改 | 运行 `dart format --set-exit-if-changed lib/ test/` 返回 0 |
| 无死代码/注释代码/调试打印 | Grep 搜索 `// TODO`、`print(`、注释掉的 import 等，全部清除 |
| 代码符合设计文档范围 | diff 中无超出 SPEC 范围的改动 |

MUST: 每次修改后立即运行 `flutter analyze`
MUST: 新增公开类/方法需有一行中文 `///` 注释
MUST NOT: 提交调试代码、打印语句、注释掉的废弃代码
MUST NOT: 超出 SPEC 范围进行修改
MUST NOT: 修改 analysis_options.yaml 降低 lint 标准

## Step 3: 自测验证（Testing）

**目的：** 确保代码正确、无回归。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 2 准出全部满足 | 代码开发完成且零 warning |
| 测试文件已存在或被新增 | 如为新增功能，对应 test/ 下有镜像结构的测试文件 |

| 准出条件 | 判断标准 |
|---------|---------|
| `flutter test` 全通过 | 输出 "All tests passed!" |
| 新增代码有对应测试覆盖（非平凡功能） | 新增公开函数/方法在 test/ 下有对应 test case |
| 无遗留 console 输出 | 测试输出中无异常的 print/debugPrint |
| 手动验证路径通过（UI 相关） | UI 改动已在模拟器或真机上确认 |

MUST: 每次新增公开方法 MUST 编写对应测试
MUST: 测试命名: `test('场景描述_预期结果')` 中文格式
MUST NOT: 用 `skip` 跳过失败的测试
MUST: 发现失败的旧测试时 MUST 先修复再继续
MUST NOT: 降低测试标准或删除测试来"通过"

**测试通过门槛：**
```
所有测试 MUST 通过，以下情况属于"不通过":
  - 任何 test case 返回 failure
  - flutter analyze 出现新 warning
  - 测试输出中有未预期的 stderr
```

## Step 4: 提交就绪（Commit Ready）

**目的：** 将变更组织为符合规范的提交。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 3 准出全部满足 | 测试全部通过 |
| 变更文件已确认 | `git diff --stat` 只包含预期文件 |
| 无意外文件变更 | 无 `build/`、`.dart_tool/`、用户 IDE 配置等 |

| 准出条件 | 判断标准 |
|---------|---------|
| 提交信息格式正确 | 匹配 `<type>: <中文简述>`，type ∈ {add, fix, update, refactor, remove, init} |
| 提交信息描述准确 | 第一行准确说明更改内容 |
| 一个提交 = 一个逻辑变更 | 本提交的 diff 可单独 revert 而不破坏其他功能 |
| 无敏感文件 | diff 中无 .env、私钥、密码、token |

**提交信息判断标准：**
```
正确: add 用户认证服务
      fix 登录超时边界错误
      update 数据库迁移配置
错误: "fix bug"
      "update"
      "修改了一些东西"
      "WIP"
      "merged"
```

MUST: 一个提交一个逻辑变更（单一职责）
MUST: 提交信息用中文，格式: `<type>: <简述>`
MUST NOT: 提交不相关的多个改动（分散在多个文件的不同逻辑）
MUST NOT: 提交含 `--no-verify` 跳过检查

## Step 5: 合并归档（Merge & Archive）

**目的：** 将开发分支合并到 main，保留历史清晰。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 4 准出全部满足 | 提交符合规范 |
| main 无新冲突 | `git fetch && git merge-base --is-ancestor HEAD origin/main` |
| 与 main 合并成功 | merge 无冲突（如有，需解决后重新走 Step 3） |

| 准出条件 | 判断标准 |
|---------|---------|
| main 已包含分支所有提交 | `git log origin/main..HEAD` 对比确认 |
| 提交历史无 "fix typo" / "fix fix" 等噪声 | 如果存在，在合并前 squash 清理 |
| 设计文档已更新（如必要） | 架构变更 MUST 同步更新 docs/Plans.md 或相关 spec |

MUST: 合并前确认所有测试再次通过（post-merge test）
MUST: 合并后删除远程开发分支
MUST: 架构变更 MUST 更新 docs/Plans.md
MUST NOT: 绕过流水线步骤直接推送 main
MUST NOT: 合并后遗留开发分支

---

## 判断标准分级

流水线中判断标准分三级，AI MUST 在每步自评：

| 级别 | 含义 | 行为 |
|------|------|------|
| **硬门禁 (Hard Gate)** | 未满足 = 绝对禁止进入下一步 | MUST 停止，修复后重试 |
| **软提醒 (Soft Reminder)** | 未满足 = 当前步骤不算完成 | SHOULD 完成后再进入下一步 |
| **最佳实践 (Best Practice)** | 推荐但不强制 | MAY 酌情处理 |

### 硬门禁示例
- `flutter analyze` 有 error
- 分支名不符合规范
- 提交信息为空或纯英文数字
- 提交包含密钥/凭证

### 软提醒示例
- 测试覆盖率未达到目标线
- 注释中缺少某个方法的简述
- 文件超过 300 行但职责单一无法拆分

### 最佳实践示例
- 使用 `const` 构造函数
- 变量用 `final` 而非 `var`
- 使用特定设计模式
