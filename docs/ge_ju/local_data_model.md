# GeJu 数据模型设计文档 — 本地阶段

> 版本：v1.3（本地阶段定稿）
> 日期：2026-02-08
> 远期社区协作层设计见 [community.md](./community.md)

---

## 一、设计背景与核心问题

### 1.1 现实中的格局知识结构

七政四余中的"格局"（GeJu）是一种命理判断模式。同一个格局名称，在不同流派（果老派、琴堂派、天官派等）、
不同典籍（《星学大成》、《琴堂五星术》、《琴堂五星术补遗》等）中，可能存在以下任意组合的分歧：

- **描述不同**：对格局含义的文字阐述完全不同
- **吉凶不同**：一派认为大吉，另一派认为平或凶
- **判断条件不同**：一派要求"日月同宫"，另一派认为"日月三合"即可
- **类型不同**：一派归为"贵格"，另一派归为"富格"

更复杂的是，**同一流派内部**的不同典籍也可能存在分歧。例如《琴堂五星术》与《琴堂五星术补遗》
对同一格局的判断条件可能不同，甚至相互矛盾。

### 1.2 用户的实际需求

用户在使用过程中可能会：

1. 发现某个流派的判断条件不够准确，想基于实践经验创建自己的判断方案
2. 对某个格局有自己的理解，想写注解但不想改动原始判断条件
3. 同时参考多个流派的解释，但只使用其中一套判断条件进行评估
4. 在不同场景下切换不同的判断方案（比如研究时用宽松条件，正式论命时用严格条件）

### 1.3 核心设计原则

基于以上现实，本模型遵循三个核心原则：

**原则一：注解与判断分离**
> 对格局"怎么解释"和"怎么判断"是两个独立的关注点。
> 用户可能认同 A 派的解释但使用 B 派的条件，反之亦然。
> 将它们耦合在一起会限制用户的灵活性。

**原则二：判断方案自包含**
> 每套判断方案持有完整的条件集合，不依赖其他方案的运行时继承。
> 这确保了：方案之间互不影响；评估逻辑极简（拿到条件直接执行）；
> 不会出现"上游方案改了导致下游行为意外变化"的问题。

**原则三：薄锚点，厚分支**
> Rule（格局）本身只是一个命名锚点，不持有任何实质内容。
> 所有实质内容（描述、吉凶、条件）都在 Annotation 和 ConditionSet 中。
> 这反映了现实——"格局A"这个名字是各派共识，但名字之下的一切都可能有分歧。

---

## 二、数据模型总览

```
GeJuRule（锚点 — 只有名字）
  │
  ├── GeJuAnnotation[]（文字层 — 描述、吉凶、解释）
  │     各流派/典籍/用户对格局含义的阐述
  │     注解之间可以形成引用谱系（A 引用 B，C 修正 A）
  │
  └── GeJuConditionSet[]（逻辑层 — 可执行的判断条件）
        各流派/典籍/用户的判断方案
        每套方案完全自包含，独立评估
        方案之间通过 derivedFrom 记录溯源（不影响执行）
```

Annotation 与 ConditionSet 之间通过 ID 列表双向关联，
表达"这些是相关的"，但不区分具体关系类型。
详细的关系语义（explains / challenges / resolves 等）留给远期 Link 实体承载。

---

## 三、模型定义

### 3.1 GeJuRule — 格局锚点

```
GeJuRule:
  id: String                         # 唯一标识
  name: String                       # 格局名称（主名称）
  aliases: [GeJuAlias]               # 别名列表
  disambiguationNote: String?        # 消歧注释（可选）
```

#### 设计说明

**为什么 Rule 这么薄？**

Rule 不持有 description、jiXiong、conditions 等任何实质字段。
这是因为这些信息在不同流派间可能完全不同，甚至完全矛盾。
如果 Rule 层持有一个"默认"description，会产生误导——
暗示这是某种"标准定义"，而实际上不存在跨流派的标准定义。

Rule 的唯一职责是：让不同来源的 Annotation 和 ConditionSet
能归到同一个名下，方便用户按格局名查找和对比。

**disambiguationNote 的用途**

当两个genuinely不同的格局在不同流派中碰巧同名时（同名异义），
需要人工判断它们应该归为同一个 Rule（加别名）还是两个不同的 Rule。
这个字段用于记录编纂者的判断依据，例如：
"此格局与琴堂派中同名的'天乙格'不同，果老派所指为日月相关，琴堂派所指为木星相关"

---

### 3.2 GeJuAlias — 格局别名

```
GeJuAlias:
  name: String                       # 别名
  schools: [EnumSchool]?             # 哪些流派使用这个叫法
  source: GeJuSource?                # 出自哪本典籍
```

#### 设计说明

**为什么别名需要标注流派和出处？**

同一个格局在不同典籍中可能有不同的名字：
- 果老派/《星学大成》称之为"日月交辉"
- 果老派/《果老星宗》称之为"日月并明"
- 琴堂派/《琴堂五星术》称之为"日月同明"

标注来源后可以实现：
1. 搜索时任意别名都能命中
2. 按流派筛选时，显示该流派惯用的名称
3. UI 上展示"此格局又名..."并标注出处

**schools 为列表**是因为多个流派可能共享同一个叫法。

---

### 3.3 GeJuAnnotation — 注解（文字层）

```
GeJuAnnotation:
  # ── 身份 ──
  id: String                         # 唯一标识
  ruleId: String                     # 所属格局

  # ── 来源 ──
  schools: [EnumSchool]?             # 所属流派（列表：可被多派共享）
  source: GeJuSource?                # 出自哪本典籍（内置注解必填，用户注解可选）

  # ── 作者 ──
  authorType: built-in | user        # 内置（来自典籍）还是用户创建
  authorId: String?                  # 用户 ID（内置为 null）

  # ── 版本（内置注解使用） ──
  version: String                    # "V.v" 格式，如 "1.0"、"2.1"
                                     # 内置注解：由 APP 开发者维护
                                     # 用户注解：固定为 "1.0"（本地阶段不对用户注解做语义版本）

  # ── 内容 ──
  description: String?               # 对格局含义的文字阐述
  jiXiong: EnumJiXiong?              # 吉凶判定
  geJuType: EnumGeJuType?            # 类型：贫/贱/富/贵/夭/寿/贤/愚
  className: String?                 # 分类名称

  # ── 谱系 ──
  parentAnnotationId: String?        # 引用/继承自哪个注解
  parentMajorVersion: int?           # 写注解时父注解的大版本号（如 1）
  relationToParent: RelationType?    # 与父注解的关系类型（见下方说明）
  references: [String]               # 旁引的其他注解 ID 列表

  # ── 关联 ──
  relatedConditionSetIds: [String]   # 相关的判断方案 ID 列表

  # ── 预埋（本地阶段记录但不启用逻辑） ──
  visibility: private                # 可见性（本地阶段默认 private）
  locale: "zh-Hans"                  # 原文语言标识
  createdAt: DateTime                # 创建时间
  updatedAt: DateTime                # 最后更新时间
```

#### 设计说明

**版本号 V.v 的语义**

内置注解采用"大版本.小版本"（V.v）格式：

- **小版本（v+1）**：文字修正、错别字、标点符号等不影响语义的修改。
  例如 v1.0 → v1.1："太阳在东边升起b" → "太阳在东边升起。"
  **子注解不受影响**——null 字段自动继承最新小版本的内容。

- **大版本（V+1）**：涉及语义变更的修改——描述含义改变、吉凶判定修正等。
  例如 v1.1 → v2.0："太阳在东边升起。" → "太阳在西边升起。"
  **旧大版本下的子注解自动归档**——不再在新大版本下显示。

只有当内容的**意思**发生改变时才更新大版本。纯粹的文字润色、排版调整等走小版本。
这个判断由 APP 开发者在编辑内置数据时做出。

**parentMajorVersion 的作用**

用户创建子注解时，系统自动记录当前父注解的大版本号。此字段决定了子注解的**可见性范围**：

```
子注解可见条件：
  parentMajorVersion == 父注解当前版本的大版本号

示例：
  父注解当前版本: v2.1
  子注解 A: parentMajorVersion = 1  → 不可见（归档于 v1.* 历史）
  子注解 B: parentMajorVersion = 2  → 可见
```

**内容字段为什么都是可空的？**

当 `relationToParent` 为 `annotate`（补充型）时，子注解可以只填写自己想补充的字段，
其余字段为 null 表示"沿用父注解的值"。解析时沿 parentAnnotationId 向上查找：

```
解析 annotation.jiXiong:
  如果当前 annotation.jiXiong != null → 使用当前值
  如果当前 annotation.jiXiong == null 且有 parentAnnotationId
    → 继承父注解 **当前版本** 的 jiXiong（同一大版本内，小版本更新自动传播）
  如果到根都是 null → 该格局在此注解链中未定义吉凶
```

但当 `relationToParent` 为 `revise`（修订）或 `contradict`（反驳）时，
所有内容字段必须显式提供，不继承父注解。因为修订和反驳意味着提出不同观点，
省略字段会造成歧义——无法区分"沿用"和"未表态"。

**继承与版本化的协同**

继承机制使得小版本更新（错别字修正等）能自动传播到子注解——
子注解的 null 字段始终读取父注解的最新内容，无需任何手动操作。
这正是选择继承而非自包含的核心理由：用户**希望**自动获得无害的文字修正，
只是不想被语义变更（大版本更新）悄悄影响。
版本化机制通过大版本归档精确地区分了这两种情况。

**relationToParent 的四种类型**

| 类型 | 含义 | 内容继承 | 典型场景 |
|---|---|---|---|
| `quote` | 原文引用 | 全部继承（子注解通常不修改内容） | 《星学大成》引用果老原文 |
| `annotate` | 补充注解 | null 字段继承父注解当前版本 | 在原文基础上加自己的理解 |
| `revise` | 修订 | 不继承，全部显式提供 | 认为原解释部分有误，提出修正 |
| `contradict` | 反驳 | 不继承，全部显式提供 | 完全不同意原解释，提出对立观点 |

**references vs parentAnnotationId**

- `parentAnnotationId`：主脉——"我主要是在延续/回应这个注解"，形成一棵清晰的树
- `references`：旁引——"我同时参考了这些注解"，不影响树状主干
- 未来 UI 做树状视图时，主干用 parentAnnotationId 构建，旁引用虚线标注

**relatedConditionSetIds 为什么是纯 ID 列表？**

本地阶段只需要表达"这个注解与这些判断方案相关"，不需要区分关系类型。
原因：在单人使用场景下，用户自己清楚注解和方案之间的关系。
远期社区阶段引入 Link 实体后，会用 `motivates / explains / challenges / resolves`
等关系类型取代这个简单的 ID 列表。

### 3.3.1 GeJuAnnotationVersionHistory — 注解版本历史

仅用于内置注解。记录每个发生过变更的内置注解的历史版本。

```
GeJuAnnotationVersionHistory:
  annotationId: String               # 哪个内置注解
  version: String                    # 版本号，如 "1.0"、"1.1"、"2.0"
  changeType: initial | minor | major  # 版本类型
  changeNote: String?                # 变更说明（如 "修正错别字"、"根据考据修正吉凶"）
  snapshot: JSON                     # 该版本的完整内容快照
  createdAt: DateTime                # 该版本的创建时间
```

#### 设计说明

**为什么需要单独的版本历史实体？**

内置注解本身只保留最新版本的内容。版本历史单独存储，用于：
1. Switcher Widget 展示历史版本线
2. 用户查看"原文从 v1 到 v2 改了什么"
3. 归档在旧大版本下的子注解需要有对应的父注解内容可供展示

**只记录发生过变更的注解**。从未修改过的内置注解（始终为 v1.0）不会出现在版本历史中。

---

### 3.4 GeJuConditionSet — 判断方案（逻辑层）

```
GeJuConditionSet:
  # ── 身份 ──
  id: String                         # 唯一标识
  ruleId: String                     # 所属格局

  # ── 标识 ──
  label: String                      # 方案名称（如"果老原始方案"、"我的改进方案"）

  # ── 来源 ──
  schools: [EnumSchool]?             # 所属流派
  source: GeJuSource?                # 出自哪本典籍

  # ── 作者 ──
  authorType: built-in | user        # 内置还是用户创建
  authorId: String?                  # 用户 ID

  # ── 条件（核心） ──
  conditions: [GeJuCondition]        # 完整的条件集合（自包含）

  # ── 溯源 ──
  derivedFrom: String?               # 基于哪个方案衍生（conditionSetId）
  changeNote: String?                # 改动说明

  # ── 关联 ──
  relatedAnnotationIds: [String]     # 相关的注解 ID 列表

  # ── 预埋 ──
  visibility: private                # 可见性
  createdAt: DateTime                # 创建时间
  updatedAt: DateTime                # 最后更新时间
```

#### 设计说明

**为什么 conditions 是自包含的，不做运行时继承？**

这是本模型最重要的设计决策之一。曾经考虑过"选择性覆盖"方案——
子方案声明"将父方案的条件 X 替换为 Y"，评估时递归解析继承链拼装最终条件。
最终放弃这个方案，原因如下：

1. **独立性**：用户的方案不应该因为上游内置方案的更新而意外改变行为。
   如果内置方案新增了一个条件，所有"继承"它的用户方案都会被影响，
   这对用户来说是不可预期的。

2. **Evaluator 简洁性**：自包含意味着 evaluator 拿到一个 ConditionSet 就能直接执行，
   不需要递归解析继承链、处理条件合并冲突、判断覆盖优先级。
   评估逻辑从 O(n) 链式查找简化为 O(1) 直接执行。

3. **可调试性**：当用户说"为什么这个格局没匹配上"，直接查看该方案的 conditions 即可，
   不需要追溯继承链上每一层的覆盖关系。

4. **数据冗余可接受**：一个格局的条件通常只有几个到十几个。
   即使多个用户方案与内置方案高度相似，冗余的数据量也很小。
   用简洁性换少量冗余是值得的。

**derivedFrom 的定位**

`derivedFrom` 不参与任何运行时逻辑。它只是元数据，回答"这个方案是怎么来的"。

用户创建新方案时的典型流程：
1. 在 UI 上选择"基于此方案创建新方案"
2. 系统复制选中方案的全部 conditions 到新方案
3. 新方案的 `derivedFrom` 指向原方案
4. 用户修改条件、填写 changeNote
5. 保存。从此新方案与原方案完全独立

UI 上可以利用 derivedFrom 展示：
- "此方案基于「果老原始方案」修改"
- 点击可查看原方案，方便对比差异

**changeNote 的作用**

记录用户修改的动机和依据。例如：
- "将同宫放宽为同宫或三方，因为实测中三方情况也能应验"
- "增加了夜生限制，《星学大成》卷三有相关论述"

这不仅帮助用户自己回忆修改原因，未来社区阶段其他用户也能理解这个方案的来龙去脉。

---

### 3.5 GeJuSource — 典籍信息

```
GeJuSource:
  bookName: String                   # 书名（如《星学大成》）
  school: EnumSchool                 # 所属流派
  section: String?                   # 篇章（可选，如"卷三·论格局"）
```

#### 设计说明

**为什么 Source 独立为一个结构？**

之前 source 是一个字符串（如 "星学大成"）。结构化后：
1. 可以按书名、流派进行精确筛选
2. section 字段让用户能追溯到具体篇章
3. 为未来添加 edition（版本）、year（年代）等字段预留空间

**school 在 Source 中是单值**，因为一本书通常属于一个流派。
而 Annotation 和 ConditionSet 上的 schools 是列表，
因为一段解释可以被多个流派共同采纳。

---

## 四、双库隔离架构

### 4.1 存储模型

本地阶段采用"内置库 + 用户库"双库隔离架构。
这是数据层面最重要的架构决策——内置内容与用户内容物理分离，查询时合并。

```
┌──────────────────────────────┐  ┌──────────────────────────────┐
│       内置库（只读）           │  │       用户库（读写）           │
│                              │  │                              │
│  GeJuRule                    │  │  GeJuRule（用户新建的格局）    │
│  GeJuAnnotation              │  │  GeJuAnnotation              │
│  GeJuConditionSet            │  │  GeJuConditionSet            │
│                              │  │  UserPreference              │
│  来源：JSON assets 加载       │  │  DeletionRecord              │
│  生命周期：随 APP 版本更新     │  │                              │
│  权限：运行时只读，不可修改    │  │  来源：本地 Drift DB          │
│                              │  │  生命周期：用户完全控制        │
│                              │  │  权限：可增删改查             │
└──────────────────────────────┘  └──────────────────────────────┘
```

#### 为什么要双库隔离？

1. **内置数据可恢复**：内置库从 assets JSON 加载，即使 APP 升级变更了内置数据，
   也不会影响用户库中的任何内容。用户可以随时"重置"内置数据（重新加载 assets）。

2. **用户数据独立管理**：用户库可以独立备份、导出。未来社区阶段，
   用户库中的 public 内容可直接上传到远端，无需从混合数据中挑拣。

3. **不可能误改内置数据**：内置库运行时只读，从根本上杜绝了用户操作意外修改
   典籍原文的可能。这对于严肃的命理研究至关重要——原文必须保持不变。

4. **查询逻辑清晰**：所有读操作都是"内置库 + 用户库"的合并查询，
   所有写操作都只发生在用户库。不存在"这条数据到底该写到哪里"的歧义。

### 4.2 UserPreference — 用户偏好

用户的筛选和隐藏操作不修改任何内容数据，而是记录在独立的偏好模型中。

```
UserPreference:
  # ── ConditionSet 控制 ──
  hiddenConditionSetIds: [String]    # 用户隐藏的内置方案 ID 列表
  conditionSetSchools: [EnumSchool]? # 按流派过滤方案（null = 不过滤）

  # ── Annotation 控制 ──
  hiddenAnnotationIds: [String]      # 用户隐藏的内置注解 ID 列表
  annotationSchools: [EnumSchool]?   # 按流派过滤注解（null = 不过滤）
```

#### 设计说明

**为什么用 hiddenIds 而不是 visibleIds？**

默认行为应该是"全部可见"。用户主动选择隐藏某些不认同的方案或注解。
用 hiddenIds 实现意味着：
- 新增的内置数据（APP 升级）自动可见，无需用户手动激活
- 用户只需要记录"我不想看的"，而不是维护"我想看的"的完整列表
- 列表通常较短（用户只会隐藏少数不认同的内容）

**ConditionSet 和 Annotation 的过滤独立运作。**

用户可以：
- 隐藏果老派的某个判断方案，但保留果老派的注解用于阅读参考
- 隐藏所有内置注解只看自己的笔记，但仍使用内置方案进行评估
- 按流派级别过滤（只看琴堂派），同时额外隐藏琴堂派中某个特定方案

两层过滤的执行顺序：
```
1. 先按 schools 过滤（粗筛）
2. 再排除 hiddenIds（细筛）
3. 加入用户库中的用户内容
```

### 4.3 内置注解的 Assets 双文件结构

内置注解的 JSON assets 分为两个文件：

```
assets/qizhengsiyu/ge_ju/
  ├── annotations_current.json        # 文件 A：所有条目的最新版本（完整集）
  └── annotations_changelog.json      # 文件 B：仅发生过变更的条目的历史版本
```

**文件 A — 当前数据（完整集，每次 APP 发版完整替换）：**

```json
[
  {
    "id": "builtin_guolao_001",
    "version": "2.0",
    "ruleId": "rule_001",
    "description": "太阳在西边升起。",
    "jiXiong": "吉",
    "schools": ["guolao"],
    "source": { "bookName": "星学大成", "school": "guolao", "section": "卷三" }
  },
  {
    "id": "builtin_guolao_002",
    "version": "1.0",
    "ruleId": "rule_002",
    "description": "月亮很亮。",
    "jiXiong": "平"
  }
]
```

**文件 B — 变更历史（仅包含发生过变更的条目）：**

```json
[
  {
    "annotationId": "builtin_guolao_001",
    "history": [
      {
        "version": "1.0",
        "changeType": "initial",
        "changeNote": null,
        "snapshot": { "description": "太阳在东边升起b", "jiXiong": "吉" },
        "createdAt": "2025-11-01"
      },
      {
        "version": "1.1",
        "changeType": "minor",
        "changeNote": "修正标点符号",
        "snapshot": { "description": "太阳在东边升起。", "jiXiong": "吉" },
        "createdAt": "2025-12-01"
      },
      {
        "version": "2.0",
        "changeType": "major",
        "changeNote": "根据考据修正为西边",
        "snapshot": { "description": "太阳在西边升起。", "jiXiong": "吉" },
        "createdAt": "2026-01-15"
      }
    ]
  }
]
```

#### 设计说明

**为什么分两个文件？**

- 文件 A 是 APP 运行时的主数据源——加载快、结构简单、始终完整。
- 文件 B 是补充数据——仅供版本历史查看功能使用，体积通常很小
  （只有发生过变更的条目才会出现在文件 B 中）。
- 未修改过的条目（如 `builtin_guolao_002`，始终为 v1.0）不出现在文件 B 中。
- 两个文件独立加载：APP 启动时必须加载文件 A，文件 B 可以懒加载
  （用户点击 Switcher Widget 查看历史时才加载）。

### 4.4 注解版本可见性规则

用户注解通过 `parentMajorVersion` 绑定到父注解的某个大版本。
大版本更新后，旧大版本下的用户注解自动归档，不在新大版本下显示。

**完整示例：**

```
内置注解 "001" 的版本演进：
  v1.0: "太阳在东边升起b"
  v1.1: "太阳在东边升起。"（minor — 修标点，语义不变）
  v2.0: "太阳在西边升起。"（major — 语义修正）

用户注解 A: "日出东方说的很妙"（parentMajorVersion = 1）
用户注解 B: "确实是西边"（parentMajorVersion = 2）
```

各版本下的可见状态：

| 内置版本 | 用户注解 A | 用户注解 B | 原因 |
|---|---|---|---|
| v1.0 时期 | 可见 | 不存在 | A 的 parentMajorVersion == 1 |
| v1.1 时期 | 可见 | 不存在 | minor 更新，V 仍为 1 |
| v2.0 时期 | **归档** | 可见 | A 属于 V=1 → 归档；B 属于 V=2 → 可见 |

**渲染逻辑：**

```
显示某个内置注解下的用户注解:
  currentMajor = 内置注解当前版本的大版本号

  # 当前大版本下的可见注解
  visibleAnnotations = 用户注解
    .where(parentAnnotationId == 内置注解.id)
    .where(parentMajorVersion == currentMajor)

  # 归档注解（按大版本分组，供 Switcher Widget 使用）
  archivedByVersion = 用户注解
    .where(parentAnnotationId == 内置注解.id)
    .where(parentMajorVersion < currentMajor)
    .groupBy(parentMajorVersion)
```

**继承字段的版本解析：**

子注解的 null 字段继承父注解**当前版本**的内容（非快照）。
因为同一大版本内的小版本更新不改变语义，继承当前版本是安全的。

```
用户注解 A（parentMajorVersion = 1）在 v1.1 时期：
  A.description = null → 继承父注解当前内容 → "太阳在东边升起。"（v1.1 的文字）
  注意：不是 v1.0 的 "太阳在东边升起b"。小版本修正自动传播。
```

**大版本更新时的处理（本地阶段）：**

静默归档——APP 升级后，系统自动将旧大版本下的用户注解归入历史视图。
不做主动提醒（主动通知机制为远期 community 功能，见 [community.md](./community.md)）。

### 4.5 Switcher Widget — 版本切换

格局详情页的注解区域提供 Switcher Widget，让用户在不同大版本之间切换查看。

```
┌─────────────────────────────────────────────────┐
│  内置注解 "001"                                  │
│  当前版本: v2.0                                  │
│  "太阳在西边升起。"                               │
│                                                 │
│  用户注解（v2.* 下）:                             │
│  └── "确实是西边" — 我                           │
│                                                 │
│  ┌─ Switcher ────────────────────────────────┐  │
│  │  ● v2.*（当前）  ○ v1.*                    │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  [切换到 v1.* 后]:                               │
│  ┌───────────────────────────────────────────┐  │
│  │  版本线:                                    │  │
│  │  v1.0: "太阳在东边升起b"                    │  │
│  │  v1.1: "太阳在东边升起。" ← minor 修正       │  │
│  │                                            │  │
│  │  v1.* 下的用户注解:                          │  │
│  │  └── "日出东方说的很妙" — 我                 │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

#### 设计说明

**Switcher 只在有历史版本时出现。**
如果内置注解从未发生过大版本更新（始终为 v1.*），不显示 Switcher。

**版本线展示该大版本内的所有小版本变迁。**
帮助用户理解"这段原文在 v1.* 期间经历了哪些修正"。
数据来源为 `annotations_changelog.json`（文件 B），按需懒加载。

**归档注解仍然可以编辑和删除。**
用户可以在 v1.* 视图中管理自己的旧注解——虽然它们不再在当前版本下显示，
但作为个人的研究记录，用户应该保留完整的管理权限。

---

## 五、评估流程

### 5.1 核心流程

UI 格局列表**仅展示匹配上的格局**。未匹配的格局不显示（数量可达 400+，全部展示无意义）。

```
输入：GeJuInput（命盘数据）、UserPreference（用户偏好）

evaluate(input, preference):
  results = []
  allRules = 内置库.rules + 用户库.rules

  for rule in allRules:
    # ── 合并两库的 ConditionSet，应用过滤 ──
    builtInSets = 内置库.getConditionSets(rule.id)
      .where(cs => preference.conditionSetSchools == null
                   || cs.schools 与 preference.conditionSetSchools 有交集)
      .where(cs => cs.id NOT IN preference.hiddenConditionSetIds)

    userSets = 用户库.getConditionSets(rule.id)

    activeSets = builtInSets + userSets

    # ── 逐方案独立评估 ──
    matchedSets = []
    for cs in activeSets:
      result = evaluateConditions(cs.conditions, input)
      if result.matched:
        matchedSets.add({
          conditionSet: cs,
          matchedConditions: result.details   # 逐条通过/未通过详情
        })

    # ── 只收集有匹配的格局 ──
    if matchedSets.isNotEmpty:
      results.add({ rule: rule, matches: matchedSets })

  return results
```

输出示例（仅包含匹配上的格局）：
```
[
  { rule: "格局A", matches: [
      { conditionSet: "用户改进方案", matchedConditions: [...] }
    ]
  },
  { rule: "格局B", matches: [
      { conditionSet: "果老原始方案", matchedConditions: [...] },
      { conditionSet: "琴堂标准方案", matchedConditions: [...] }
    ]
  },
]
```

#### 设计说明

**为什么一个格局可以有多个匹配的方案？**

同一格局的不同方案（来自不同流派或用户）可能同时命中。
例如果老方案和琴堂方案都判定"格局B"成立，但依据的条件不同。
UI 并列展示所有命中的方案，用户可以查看每个方案的条件详情，
理解"为什么不同流派都认为这个格局成立"。

**未匹配的格局完全不进入结果。**

格局总数可能在 400 以上，绝大多数不会匹配。
将未匹配结果排除出返回值，避免 UI 层做大量无用渲染，也避免结果列表被噪音淹没。
用户如果需要查看某个未匹配的格局，通过编辑模式中的搜索功能主动查找。

### 5.2 ConditionSet 的创建方式

用户创建自己的判断方案有两种方式。两种方式都只复制 ConditionSet，
**不复制 Annotation**——注解和判断是独立关注点，用户修改条件不代表要改解释。

**方式一：基于已有方案复制（Fork）**

```
forkConditionSet(originalId):
  original = 加载原始方案（内置库或用户库）
  newCs = GeJuConditionSet(
    id: "user_" + uuid(),
    ruleId: original.ruleId,
    label: "基于「${original.label}」的修改",   # 用户可自行修改
    schools: null,                               # 用户方案通常不归属流派
    source: null,
    authorType: user,
    conditions: deepCopy(original.conditions),   # 深拷贝全部条件
    derivedFrom: original.id,                    # 记录溯源
    changeNote: null,                            # 用户后续填写
    relatedAnnotationIds: [],                    # 可选，用户后续关联
    visibility: private,
  )
  保存到用户库
  return newCs   → 进入条件编辑器
```

**方式二：从零创建**

```
createConditionSet(ruleId):
  newCs = GeJuConditionSet(
    id: "user_" + uuid(),
    ruleId: ruleId,
    label: "我的方案",
    authorType: user,
    conditions: [],                              # 空条件，用户从零编写
    derivedFrom: null,                           # 无溯源
    ...
  )
  保存到用户库
  return newCs   → 进入条件编辑器
```

#### Fork 时为什么深拷贝而不是引用？

复制后的方案与原方案**完全独立**。这是"判断方案自包含"原则的直接体现：
- 原方案后续的任何变更（内置数据随 APP 升级更新）不影响用户的副本
- 用户对副本的任何修改不影响原方案
- `derivedFrom` 只是元数据，记录"我是从哪里来的"，不参与运行时逻辑

---

## 六、用户操作路径

### 6.1 路径一：正常使用（查看匹配结果）

用户输入命盘数据后，评估引擎自动运行，格局列表仅展示匹配上的格局。

```
命盘输入 → 评估引擎 → 格局列表（仅匹配项）

格局列表 Widget:
  ├── 格局A ✓（用户改进方案匹配）
  ├── 格局B ✓（果老原始方案 + 琴堂标准方案 均匹配）
  └── 格局C ✓（用户自建方案匹配）

点击某个格局 → 格局详情页:
  ├── 注解区域（按 UserPreference 中的 annotationSchools / hiddenAnnotationIds 过滤）
  │    ├── [内置] 果老派/星学大成: "此格局主大贵..."
  │    ├── [内置] 琴堂派/琴堂五星术: "此格局主富..."
  │    └── [用户] 我的注解（如有）
  │
  └── 匹配方案区域（展示命中的 ConditionSet）
       ├── 方案名 + 来源标签（内置/用户）
       └── 条件逐条展示（✓ 通过 / ✗ 未通过）
```

### 6.2 路径二：发现缺失格局（核心场景）

用户凭经验认为某个格局应该匹配，但格局列表中没有出现。
这是用户创建自定义判断方案的主要动机。

```
格局列表（目标格局不在其中）
  │
  └── 进入 [编辑模式]
       │
       └── [搜索格局]
            │  搜索范围：内置库 + 用户库
            │  匹配字段：name、aliases
            │
            ├── ── 搜索到了 ──
            │    │
            │    │  展示该格局的所有 ConditionSet（包括被隐藏的，但标注隐藏状态）
            │    │  用户可以查看每个方案的条件详情，理解"为什么没匹配上"
            │    │
            │    ├── [基于此方案创建新方案]（Fork）
            │    │    1. 系统深拷贝选中方案的全部 conditions
            │    │    2. 进入条件编辑器
            │    │    3. 用户修改条件（如将"同宫"改为"同宫或三方"）
            │    │    4. 填写 label、changeNote（changeNote 可选，为社区预留）
            │    │    5. 可选：关联注解（relatedAnnotationIds）
            │    │    6. 保存到用户库
            │    │
            │    ├── [从零创建新方案]
            │    │    同上流程，但 conditions 起始为空，derivedFrom 为 null
            │    │
            │    └── [隐藏原始方案]（可选）
            │         将不认同的内置方案 ID 加入 hiddenConditionSetIds
            │         该方案不再参与后续评估
            │         注意：隐藏不是删除，随时可以取消隐藏
            │
            └── ── 没搜索到 ──
                 │
                 └── [新建格局]
                      1. 输入格局名称 → 创建 GeJuRule（写入用户库）
                      2. 创建 GeJuConditionSet（从零编写条件）
                      3. 可选：创建 GeJuAnnotation（写自己的解释）
                      4. 全部保存到用户库
```

#### 为什么编辑模式中搜索要包含被隐藏的方案？

用户可能之前隐藏了某个方案，后来想基于它创建新方案，或重新启用它。
编辑模式是"管理"视角，应该展示完整信息。
被隐藏的方案在编辑模式中标注隐藏状态，用户可以取消隐藏。

### 6.3 路径三：管理已有方案

```
编辑模式
  └── [我的方案]
       │  展示用户库中所有用户创建的 ConditionSet
       │
       ├── 格局A — 我的改进方案
       │    derivedFrom: 果老原始方案
       │    changeNote: "将同宫放宽为三方"
       │
       ├── 格局D — 自建方案
       │    derivedFrom: null（从零创建）
       │
       └── 格局E — 三方扩展版
            derivedFrom: 琴堂标准方案

       对每个方案可以：
       ├── [编辑] → 进入条件编辑器
       ├── [删除] → 需填写删除原因（见"七、删除机制"）
       ├── [查看原始方案] → 通过 derivedFrom 跳转（如有）
       └── [管理关联注解] → 查看/添加/移除 relatedAnnotationIds
```

### 6.4 隐藏与取消隐藏

隐藏是一个轻量操作——不删除任何数据，只在 UserPreference 中记录 ID。

```
隐藏内置方案:
  preference.hiddenConditionSetIds.add(conditionSetId)
  → 该方案不再参与评估
  → 格局详情页不再展示该方案
  → 编辑模式中仍可见（标注"已隐藏"）

取消隐藏:
  preference.hiddenConditionSetIds.remove(conditionSetId)
  → 该方案恢复参与评估
```

#### 隐藏 vs 删除

| | 隐藏 | 删除 |
|---|---|---|
| 对象 | 内置方案（只读，不能删除） | 用户方案（用户自己创建的） |
| 操作 | 在 UserPreference 中记录 ID | 标记 isDeleted + 填写删除原因 |
| 可逆性 | 随时取消 | 不可逆（但有 DeletionRecord 快照） |
| 数据影响 | 无（原数据不变） | 逻辑删除 + 审计记录 |

---

## 七、Community 预埋字段说明

本地阶段的数据模型中包含若干"预埋"字段。
这些字段在本地单机阶段**不参与任何运行时逻辑**，但在数据结构中保留，
以避免未来引入社区功能时需要做数据迁移。

| 字段 | 所在实体 | 本地阶段行为 | 远期用途 |
|---|---|---|---|
| `visibility` | Annotation, ConditionSet | 固定为 `private` | public 时其他用户可见 |
| `authorId` | Annotation, ConditionSet | 本地 UUID（设备标识） | 绑定云端账号 |
| `locale` | Annotation | 固定为 `"zh-Hans"` | 标识原文语言，用于翻译 overlay |
| `relatedAnnotationIds` | ConditionSet | 可选填写 | 社区阶段为分享提供上下文 |
| `relatedConditionSetIds` | Annotation | 可选填写 | 社区阶段为分享提供上下文 |
| `changeNote` | ConditionSet | 可选填写 | 社区阶段其他用户理解修改动机 |

**零成本预留原则**：不填不影响功能，填了未来有额外价值。
用户在本地阶段创建方案时，changeNote 和关联 ID 都是可选的。
但如果用户养成了填写的习惯，未来开放社区时这些信息就是现成的分享说明。

---

## 八、删除机制

### 本地阶段规则

用户只能删除自己创建的内容（`authorType: user`）。内置内容不可删除。

删除时，如果被删实体存在以下引用关系中的任意一种：
- 被其他 Annotation 的 `parentAnnotationId` 或 `references` 引用
- 被其他 ConditionSet 的 `derivedFrom` 引用
- 存在于其他实体的 `relatedConditionSetIds` / `relatedAnnotationIds` 中

则必须提交删除原因。系统记录：

```
DeletionRecord:
  deletedEntityType: annotation | conditionSet
  deletedEntityId: String
  deletedAt: DateTime
  reason: String                     # 必填
  snapshot: JSON                     # 删除前的完整内容快照
```

引用方在 UI 上看到："关联的 [注解/方案] 已被删除，原因：[reason]"，
并可展开查看删除前的内容快照。

**为什么本地阶段也需要删除审计？**

即使只有一个用户，随着研究深入，用户创建的注解和方案会越来越多。
删除审计防止用户误删后无法回忆"我当初写了什么"和"我为什么要删"。
这本质上是一种个人知识管理的保护机制。

---

## 九、与现有代码的迁移对照

| 现有结构 | 目标结构 | 迁移说明 |
|---|---|---|
| `GeJuRule.name` | `GeJuRule.name` | 保留 |
| `GeJuRule.scope` | 待定 | 需确认是否下沉到 ConditionSet |
| `GeJuRule.coordinateSystem` | 待定 | 需确认是否下沉到 ConditionSet |
| `GeJuVariant` | **拆分** | 一个 Variant 拆为一个 Annotation + 一个 ConditionSet |
| `GeJuVariant.description` | `GeJuAnnotation.description` | 移入注解 |
| `GeJuVariant.jiXiong` | `GeJuAnnotation.jiXiong` | 移入注解 |
| `GeJuVariant.geJuType` | `GeJuAnnotation.geJuType` | 移入注解 |
| `GeJuVariant.className` | `GeJuAnnotation.className` | 移入注解 |
| `GeJuVariant.conditions` | `GeJuConditionSet.conditions` | 移入判断方案 |
| `GeJuVariant.source` (String) | `GeJuSource` (结构体) | 提取为独立结构 |
| `GeJuVariant.schools` (List) | 各自的 `schools` (List) | Annotation 和 ConditionSet 各自持有 |
| `GeJuEvaluator` | 入参变更 | 从接受 Variant 改为接受 ConditionSet |

---

## 十、术语表

| 术语 | 英文 | 说明 |
|---|---|---|
| 格局 | GeJu | 命理判断模式，本模型的核心领域概念 |
| 流派 | School | 如果老派、琴堂派、天官派 |
| 典籍 | Source/Book | 如《星学大成》、《琴堂五星术》 |
| 注解 | Annotation | 对格局含义的文字阐述（文字层） |
| 判断方案 | ConditionSet | 可执行的判断条件集合（逻辑层） |
| 谱系 | Lineage | 注解之间的引用继承关系链 |
| 溯源 | Derivation | 判断方案之间的来源追溯（纯元数据） |
| 锚点 | Anchor | Rule 的角色定位——只提供名字，不持有实质内容 |
| 自包含 | Self-contained | ConditionSet 的核心特性——不依赖外部继承 |
| 双库隔离 | Dual-DB Isolation | 内置库（只读）与用户库（读写）物理分离 |
| 隐藏 | Hide | 用户将不认同的内置内容从视图和评估中排除，可随时取消 |
| Fork | Fork | 基于已有方案深拷贝创建用户自己的独立方案 |
| 预埋 | Pre-embedded | 本地阶段不启用但为远期社区功能保留的字段 |
| 大版本 | Major Version (V) | 语义变更——描述含义改变、吉凶修正等。旧大版本下的子注解自动归档 |
| 小版本 | Minor Version (v) | 无害修正——错别字、标点等。子注解自动跟随，不受影响 |
| 归档 | Archive | 大版本更新后旧注解进入历史视图，通过 Switcher Widget 可查看 |
| 版本历史 | Version History | 内置注解的变更记录，存于 assets 双文件中的 changelog 文件 |
