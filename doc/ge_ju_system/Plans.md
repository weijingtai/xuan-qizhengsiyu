# 系统架构与实施计划 (Plans)

## 1. 数据模型

### 1.1 格局索引 (`patterns_index.json`)

抽象格局的注册表。

```json
{
  "geju_qi_cha_sai_mei": {
    "key": "GEJU_QI_CHA_SAI_MEI", 
    "category": "noble", // 贵格
    "default_definition_id": "def_guolao_001"
  }
}
```

### 1.2 定义仓库 (`definitions.json`)

具体的实现细节。

```json
[
  {
    "id": "def_guolao_001",
    "pattern_id": "geju_qi_cha_sai_mei",
    "type": "canonical", // 典籍标准
    "source": { "school": "school_guolao", "book": "book_guolao_xingzong" },
    "is_universal": true, // 通用标记
    "conditions": { "type": "and", "rules": [...] }
  },
  {
    "id": "def_user_custom_001",
    "pattern_id": "geju_qi_cha_sai_mei",
    "type": "user_custom", // 用户自定义
    "based_on": "def_guolao_001",
    "conditions": { "type": "and", "rules": [...] }
  }
]
```

## 2. 执行流程

### 2.1 解析逻辑 (选择器 Selector)

输入: `PatternID`, `UserSettings` (用户设置)
输出: `DefinitionJSON`

**算法**:

1. 检查是否存在针对该 PatternID 的 `用户自定义定义`。 -> 若有则返回。
2. 检查是否存在针对该 PatternID 的 `当前选定流派定义`。 -> 若有则返回。
3. 检查是否存在针对该 PatternID 的 `通用定义`。 -> 若有则返回。
4. 返回 Null (该视图下不适用此格局)。

### 2.2 计算引擎

输入: `DefinitionJSON`, `NatalChart` (命盘)
输出: `Result`

引擎处理 `conditions` 块。它支持一套原子函数的领域特定语言 (DSL)。

## 3. DSL 规范 (功能码)

| 功能码 | 参数 | 用途 |
| :--- | :--- | :--- |
| `starInGong` | `star`, `gong` | 基础定位（星在某宫） |
| `gongDegree` | `gong`, `range` | 精确度数检查 |
| `angleBetween` | `stars`, `deg` | 相位/夹角计算 |
| `starGuardLife` | `star` | 动态判断命主星 |
| `isDayBirth` | `bool` | 昼夜生判断 |

## 4. UI 组件

* **PatternListView (列表视图)**：按分类显示格局。
* **SchoolSelector (流派选择器)**：下拉菜单切换当前“视图”（果老 / 琴堂 / 天官 / 自定义）。
* **PatternDetailView (详情视图)**：显示描述、来源和注解。
* **LogicBuilder (逻辑构建器)**：用于自定义逻辑的可视化积木编辑器。
