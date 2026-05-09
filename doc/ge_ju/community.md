# GeJu 社区协作层 — 远期规划

> 本文档整理所有与"用户互见"、"社交协作"、"远端同步"相关的远期设计讨论。
> 当前阶段为纯本地方案，本文档内容不纳入近期实现。

---

## 1. 用户互见需求概述

用户可以将自己创建的 Annotation（注解）和 ConditionSet（判断方案）设为 public，其他用户可以看到并使用。

用户操作：
- 查看其他用户的注解和判断方案
- 基于其他用户的方案创建自己的衍生方案
- 筛选显示/隐藏特定用户的内容

---

## 2. 远端存储与同步

### 离线优先架构

本地 JSON/Drift 存储始终作为 source of truth。远端为增量同步层。

### 预埋字段（本地阶段已包含，远期启用）

| 字段 | 用途 |
|---|---|
| `authorId` | 本地阶段用设备标识/本地 UUID，远期绑定账号 |
| `visibility` | 本地阶段默认 private，远期支持 public |
| `version` / `lastSyncedAt` | 增量同步版本控制 |
| `isDeleted` | 软删除标记，不做物理删除，保证同步一致性 |
| `createdAt` / `updatedAt` | 时间戳，用于排序和同步 |

### 同步机制

- 离线时用户只能看自己的内容
- 上线后拉取其他用户的 public 内容
- 冲突解决策略：待远期设计时确定

---

## 3. Link 实体 — 关联生命周期管理

Annotation 和 ConditionSet 之间通过 Link 实体连接，承载关系语义和完整生命周期。

### Link 数据模型

```
GeJuLink:
  id
  fromType: annotation | conditionSet
  fromId
  toType: annotation | conditionSet
  toId
  relation: motivates | explains | challenges | resolves
  status: open | resolved | archived
  createdBy, createdAt
  thread: [GeJuComment]    ← 讨论串
```

### 关联关系类型

| 场景 | from | to | relation |
|---|---|---|---|
| 用户基于注解的描述创建了新方案 | annotation | conditionSet | `motivates` |
| 用户为自己的方案写了解释性注解 | conditionSet | annotation | `explains` |
| 注解质疑某个方案的合理性 | annotation | conditionSet | `challenges` |
| 新方案解决了注解中提出的疑问 | conditionSet | annotation | `resolves` |

### 生命周期（仿 GitHub Issue/PR）

```
阶段一：发起关联
  用户 A 创建 ConditionSet，引用某个 Annotation
  → 系统自动创建 Link（status: open）
  → Annotation 侧显示通知："有新的判断方案引用了此注解"

阶段二：讨论
  用户在 Link 的 thread 下评论
  → 类似 GitHub PR 的 review comment
  → 内容作者可以更新内容并回复说明改动

阶段三：解决/采纳
  某一方将 Link status 改为 resolved
  → 双方都能看到 resolved 状态和完整讨论历史

阶段四：归档或删除
  如果某一方删除自己的内容
  → 必须提交删除原因
  → Link 变为 archived，保留完整历史
  → 另一方看到："关联的 [注解/方案] 已被作者删除，原因：..."
```

---

## 4. 删除审计机制

### 核心原则

1. **不物理删除** — 标记 `isDeleted = true`，内容保留在数据库中
2. **删除前强制通知** — 有 active Link 的实体删除时，必须提交原因，通知所有关联方
3. **关联方可以接手** — 被删内容的引用方可以复制快照作为自己的新实体

### 删除记录

```
GeJuDeletionRecord:
  deletedEntityType: annotation | conditionSet
  deletedEntityId
  deletedBy, deletedAt
  reason: String               ← 必填
  affectedLinks: [linkId]      ← 受影响的关联
  snapshot: JSON               ← 删除前的内容快照
```

---

## 5. Discussion Thread

每个 Link 可以附带一个讨论串：

```
GeJuComment:
  id
  linkId
  authorId
  content: String
  createdAt
  replyToCommentId?    ← 支持嵌套回复
```

---

## 6. 通知系统

触发通知的事件：
- 自己的 Annotation/ConditionSet 被他人引用（新 Link 创建）
- 自己参与的 Link 有新评论
- 关联的实体被修改或删除
- 自己的 derivedFrom 源方案发生了更新

### 6.1 内置注解大版本更新通知

当 APP 升级导致内置注解发生大版本更新（V+1）时，用户在该大版本下的注解将自动归档至旧版本历史。
社区阶段需要主动通知受影响的用户。

**本地阶段行为**：静默归档——注解自动归入旧大版本的历史视图，
用户通过 Switcher Widget 查看时才会发现。不做主动提醒。

**社区阶段行为**：主动通知——APP 启动或进入相关格局时提醒用户。

触发条件：
- APP 升级后检测到内置注解的大版本号（V）发生变化
- 用户库中存在 `parentAnnotationId` 指向该内置注解且 `parentMajorVersion < 当前 V` 的用户注解

通知内容示例：
```
"您在「格局A · 果老注解」下的 N 条注解因原文重大更新（v1.x → v2.0）
 已归档至 v1.* 历史版本。

 更新原因：根据考据修正方向

 [查看变更详情]  [查看我的归档注解]"
```

通知行为：
- 列出受影响的所有格局和注解数量
- 提供直达链接：查看原文变更 diff、查看自己被归档的注解
- 用户可选操作：
  - 在新大版本下重新撰写注解
  - 忽略（旧注解保留在历史视图中）

社区扩展：
- 如果用户的 public 注解被归档，其他曾引用该注解的用户也收到通知
- 通知内容补充："用户A 在「格局A」下的注解因原文更新已归档"

---

## 7. 国际化 — 翻译 Overlay 层（远期）

### 方案

独立翻译层，key = `{entityId}_{field}_{locale}`。

- 实体本身只存原文（通常为简体中文）
- 翻译表独立存储，查询时先查翻译表，miss 则 fallback 到原文
- 翻译可以由社区用户贡献

### 近期策略（已纳入本地方案）

- 简繁之间用算法自动转换（opencc 或类似方案），不存两份
- 英文翻译作为远期 overlay 处理
- 实体上预留 `locale` 字段标识原文语言

---

## 8. 用户筛选偏好（远期扩展部分）

远期阶段在本地筛选偏好基础上增加：

```
用户偏好（社区扩展）:
  显示用户方案: true/false
  显示的用户: [all] 或 [特定 userId]
  订阅的用户: [userId]    ← 自动拉取其更新
```

---

## 9. 从本地迁移到社区的路径

1. 本地阶段的 `authorId`（设备 UUID）绑定到云端账号
2. 用户选择将哪些 private 内容改为 public
3. `derivedFrom` / `relatedAnnotationIds` / `relatedConditionSetIds` 等引用关系迁移为完整的 Link 实体
4. 启用同步机制，本地保持 source of truth，远端为分发层
