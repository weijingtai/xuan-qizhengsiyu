# GeJu 数据模型设计文档 — 本地阶段

> 版本：v1.0（本地阶段定稿）
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

  # ── 内容 ──
  description: String?               # 对格局含义的文字阐述
  jiXiong: EnumJiXiong?              # 吉凶判定
  geJuType: EnumGeJuType?            # 类型：贫/贱/富/贵/夭/寿/贤/愚
  className: String?                 # 分类名称

  # ── 谱系 ──
  parentAnnotationId: String?        # 引用/继承自哪个注解
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

**内容字段为什么都是可空的？**

当 `relationToParent` 为 `annotate`（补充型）时，子注解可以只填写自己想补充的字段，
其余字段为 null 表示"沿用父注解的值"。解析时沿 parentAnnotationId 向上查找：

```
解析 annotation.jiXiong:
  如果当前 annotation.jiXiong != null → 使用当前值
  如果当前 annotation.jiXiong == null 且有 parentAnnotationId
    → 递归查找父注解的 jiXiong
  如果到根都是 null → 该格局在此注解链中未定义吉凶
```

但当 `relationToParent` 为 `revise`（修订）或 `contradict`（反驳）时，
所有内容字段必须显式提供，不继承父注解。因为修订和反驳意味着提出不同观点，
省略字段会造成歧义——无法区分"沿用"和"未表态"。

**relationToParent 的四种类型**

| 类型 | 含义 | 内容继承 | 典型场景 |
|---|---|---|---|
| `quote` | 原文引用 | 全部继承（子注解通常不修改内容） | 《星学大成》引用果老原文 |
| `annotate` | 补充注解 | null 字段继承父注解 | 在原文基础上加自己的理解 |
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

## 四、评估流程

```
输入：GeJuInput（命盘数据）、用户筛选偏好

1. 加载所有 GeJuRule
2. 对每个 Rule:
   a. 获取其 conditionSets
   b. 按用户偏好过滤（流派、内置/用户）
   c. 对每个激活的 ConditionSet 独立执行 evaluate(conditions, input)
   d. 收集结果

输出：并列的多套评估结果
[
  { rule: "格局A", conditionSet: "果老原始方案",  matched: false },
  { rule: "格局A", conditionSet: "用户改进方案",  matched: true  },
  { rule: "格局B", conditionSet: "琴堂标准方案",  matched: true  },
]
```

**为什么返回并列结果而不是一个结论？**

因为不同方案可能给出截然不同的判断。系统不应该替用户做"哪个方案更权威"的决定。
用户在 UI 上看到所有激活方案的结果，自己决定采信哪个——这反映了格局研究的现实：
不同流派之间没有绝对的对错，只有不同的视角和经验。

---

## 五、筛选偏好

```
用户偏好:
  # ── Annotation 过滤 ──
  annotationSchools: [EnumSchool]     # 显示哪些流派的注解
  annotationShowUser: bool            # 是否显示自己创建的注解

  # ── ConditionSet 过滤 ──
  conditionSetSchools: [EnumSchool]   # 显示哪些流派的方案
  conditionSetShowUser: bool          # 是否显示自己创建的方案
```

**Annotation 和 ConditionSet 的过滤独立运作。**

这意味着用户可以：
- 只看果老派的注解，但同时使用果老和琴堂两派的判断方案
- 隐藏所有内置注解只看自己的笔记，但使用内置方案做评估
- 显示所有注解用于学习对比，但只激活一套方案用于实际论命

这种灵活性正是"注解与判断分离"带来的直接收益。

---

## 六、删除机制

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

## 七、与现有代码的迁移对照

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

## 八、术语表

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
