# Git 分支与提交规范

## 分支命名

```
MUST 格式: <type>/<short-description>

type 允许值:
  feat      ← 新功能
  fix       ← 缺陷修复
  refactor  ← 纯重构（不改变功能）
  doc       ← 文档变更
  chore     ← 构建/依赖/工具变更

short-description:
  MUST: 小写英文字母 + 连字符
  MUST: 至少包含一个中文拼音或英文功能关键词
  MUST: 长度 8-40 字符
```

**正确示例：**
```
feat/oauth-login
fix/auth-timeout
refactor/list-view-extract
doc/api-readme
```

**错误示例：**
```
dev                   ← type 不在允许列表
feat/fix-bug          ← 描述无意义
feat/a                ← 描述太短
测试分支               ← 未使用英文/拼音
```

## 提交信息

```
MUST 格式: <type>: <中文简述>

type 允许值:
  add       ← 新增文件/功能
  fix       ← 修复缺陷
  update    ← 修改已有功能/逻辑
  refactor  ← 纯重构
  remove    ← 删除文件/功能
  init      ← 项目初始化

MUST: 简述不超过 30 个中文字
MUST: 简述准确描述"做了什么"，不描述"为什么"（为什么在注释中说明）
```

**正确示例：**
```
add 用户认证服务
fix 登录超时边界错误
update 数据库迁移配置
refactor 列表组件提取为独立组件
remove 废弃的旧缓存模型
init Flutter 项目基础结构
```

**错误示例：**
```
"fix bug"              ← type 错误 + 无意义
"fix"                  ← 缺少简述
"修改了一些代码"        ← 无意义
"WIP"                  ← 不可合并的临时提交
"update code"          ← 无意义 + type/subject 语言混合
"add: new feature"     ← 不该有冒号分隔符
```

## 提交粒度

MUST: 一个提交 = 一个逻辑变更
MUST: 一个逻辑变更的 diff 可独立 revert 而不破坏其他功能
MUST NOT: 混入不相关的文件修改（如修 A 功能时顺带改 B 功能的不相关代码）
MUST NOT: 提交调试代码、打印语句、注释掉的代码
MUST NOT: 提交 `--no-verify`（跳过 Git hooks）

## 提交内容红线

| MUST NOT | 示例 |
|----------|------|
| 密钥/凭证 | `.env`, `credentials.json`, API keys |
| 大二进制 | `*.apk`, `*.ipa`, `*.zip`, 图片资源（>100KB 的除外） |
| 生成目录 | `build/`, `.dart_tool/`, `.android/`, `.ios/` |
| IDE 配置 | `.vscode/`, `.idea/`（已在 .gitignore 中则为安全） |

MUST: Git 操作前确认 .gitignore 已排除生成目录
