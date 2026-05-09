# 项目上下文阅读规则

**目的：** AI 首次接入时建立正确心智模型，防止基于猜测编码。

## AI 首次接入必读清单

MUST 按以下顺序完整阅读：

### 第 1 批: AI 宪法层 (MUST 读全)
```
AI_README.md → docs/ai/ 全部 12 个模块
（包括: CONSTITUTION.md, board-protocol.md, glossary, principles, phases,
        delivery-pipeline, code-style, directory-structure, git-rules,
        doc-standards, toolchain, project-context-guide）
```

### 第 2 批: 项目概况层 (MUST 读全)
```
README.md → pubspec.yaml → analysis_options.yaml → docs/Plans.md
```

### 第 3 批: 目录结构层 (MUST 读全)
```
docs/README.md → docs/board/TASKS.md (读看板同步进度) → docs/project/README.md
```

### 第 4 批: 源码层 (MUST 读全)
```
lib/ 下所有 .dart 文件（按目录顺序）
```

### 第 5 批: 测试层 (MUST 读全)
```
test/ 下所有 test 文件
```

### 第 6 批: 其他 AI 工作区 (SHOULD)
```
docs/<other-ai>/ 下最近的任务目录，以同步上下文
```

### 第 7 批: 最近 SPEC (SHOULD)
```
docs/superpowers/specs/ 下最近 5 个 SPEC
```

## 任务前必读

收到具体任务时：

1. 确认已读过 docs/ai/ 全部 12 模块 + docs/Plans.md
2. 读取 docs/ai/CONSTITUTION.md 确认当前宪法版本号（用于写入 SELF.md）
3. 找到与任务相关的源文件
4. 阅读相关文件的所有直接 import（本项目内的，非 package/dart 内置）
5. 阅读对应的 test 文件
6. 如任务延续某功能 → 阅读该功能对应 AI 工作区的 SPEC
7. 如任务重构某功能 → 阅读被重构来源的完整 SPEC 和计划

**"直接相关"定义：** 任务要修改的代码块所在文件 + 该文件 import 的本项目文件 + 被依赖的文件

## 禁止

MUST NOT: 跳过 AI_README.md 直接编码
MUST NOT: 只读 pubspec.yaml 就推测项目结构
MUST NOT: 假设项目遵循某种模式而不验证
MUST NOT: 依赖训练数据推测（"Flutter 项目一般..."）
MUST NOT: 文档与代码矛盾时自行选一边 → MUST 向用户报告

## 文档与代码冲突处理

```
1. 停止当前任务
2. 明确指出: 文档说 X，代码实际 Y
3. 询问用户以哪个为准
4. 用户确认后:
   - 以文档为准 → 创建 fix 任务（修正代码以匹配文档）
   - 以代码为准 → 创建 doc 任务（修正文档以匹配代码）
5. MUST NOT 在确认前继续
```

## 同步更新规则

| 变更类型 | 需更新的文档 |
|---------|-------------|
| 架构变更 | docs/Plans.md |
| 新增依赖 | pubspec.yaml + docs/Plans.md |
| 目录调整 | docs/ai/directory-structure.md |
| 规范变更 | 对应 docs/ai/ 模块 |
| SPEC 交付完成 | SPEC 验收条件 + 状态字段 |
| 宪法模块版本升级 | docs/ai/CONSTITUTION.md |

MUST NOT: 只改代码不更新受影响文档
