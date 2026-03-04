# companion_system 运行机制和架构说明

## 系统架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer (UI)                     │
├─────────────────────────────────────────────────────────────────┤
│  MainPage                                                   │
│   ├─ 卡片导航（规则列表/Pattern管理/School管理）                     │
│   └─ Grid布局展示各功能入口                                       │
│                                                               │
│  RuleListPage                                               │
│   ├─ 筛选栏（搜索/流派/吉凶）                                     │
│   ├─ 规则列表 (ListView.builder)                              │
│   ├─ 规则详情弹窗                                                │
│   └─ 浮动按钮（新建规则）                                         │
│                                                               │
│  RuleEditBottomSheet (待实现)                                  │
│   ├─ Pattern选择器                                             │
│   ├─ School选择器                                              │
│   ├─ 吉凶层级选择                                               │
│   ├─ 条件编辑器（JSON）                                          │
│   └─ 版本管理选项                                               │
└─────────────────────────────────────────────────────────────────┘
                                ▼ Provider
┌─────────────────────────────────────────────────────────────────┐
│                    State Management (Provider)                  │
├─────────────────────────────────────────────────────────────────┤
│  DBProvider                                                    │
│   ├─ AppDatabase 单例                                          │
│   ├─ 数据库初始化                                               │
│   └─ 插入默认数据（分类/流派）                                  │
│                                                               │
│  RuleProvider                                                 │
│   ├─ 规则列表状态 (_rules, _isLoading, _errorMessage)          │
│   ├─ 筛选条件 (searchKeyword, selectedSchoolId, ...)         │
│   ├─ 数据加载 (loadRules)                                       │
│   ├─ 筛选逻辑 (_filteredRules getter)                            │
│   └─ CRUD操作 (saveRule, deleteRule)                            │
└─────────────────────────────────────────────────────────────────┘
                                ▼ Repository
┌─────────────────────────────────────────────────────────────────┐
│                      Data Access (Drift ORM)                     │
├─────────────────────────────────────────────────────────────────┤
│  AppDatabase (DriftDatabase)                                  │
│   ├─ geJuCategories → Category表                                │
│   ├─ geJuSchools → School表                                      │
│   ├─ geJuRules → Rule表                                          │
│   ├─ geJuPatterns → Pattern表                                   │
│   └─ geJuVersions → Version表                                   │
│                                                               │
│  SQLite (flutter_sqlite3)                                     │
│   └─ 本地文件: <文档路径>/ge_ju.db                             │
└─────────────────────────────────────────────────────────────────┘
```

## 数据流详解

### 1. 应用启动流程

```
main.dart
   ↓
Provider初始化
   ├─ DBProvider (数据库单例)
   └─ RuleProvider (规则数据Provider)
   ↓
DBProvider.initialize()
   ├─ 创建 AppDatabase()
   └─ 插入默认数据
      ├─ GeJuCategories (common, mutually)
      └─ GeJuSchools (guo_lao, custom)
   ↓
显示 MainPage
```

### 2. 规则列表加载流程

```
RuleListPage.initState()
   ↓
context.read<RuleProvider>().loadRules()
   ↓
Provider: db.select(geJuRules).get()
   ↓
设置 _rules, notifyListeners()
   ↓
UI刷新显示 _filteredRules
```

### 3. 筛选流程

```
用户输入搜索关键字
   ↓
RuleProvider.setSearchKeyword(keyword)
   ↓
_filteredRules getter 触发
   ├─ 关键字过滤: rule.conditions?.contains(keyword)
   ├─ 流派过滤: rule.schoolId == selectedSchoolId
   ├─ 吉凶过滤: _jixiongFromString(rule.jixiong) == selectedJixiong
   └─ 层级过滤: _levelFromString(rule.level) == selectedLevel
   ↓
notifyListeners()
   ↓
UI刷新
```

### 4. 规则详情查看流程

```
用户点击规则卡片
   ↓
_showRuleDetail(context, rule)
   ↓
展示 AlertDialog
   ├─ Pattern ID, School ID
   ├─ 吉凶 (jixiong + level)
   ├─ 类型 (geJuType)
   ├─ 条件 (conditions JSON)
   ├─ 断语 (assertion)
   └─ 简介 (brief)
```

## 核心数据模型

### Rule (规则表)
```dart
class Rule {
  int? id;                    // 自增主键
  String patternId;            // 关联Pattern外键
  String schoolId;             // 关联School外键
  String jixiong;             // '吉' | '平' | '凶'
  String level;               // '小' | '中' | '大'
  String geJuType;            // 格局类型
  String scope;               // 'natal' | 'xingxian' | 'both'
  String? coordinateSystem;   // 坐标系要求
  String? conditions;         // JSON格式条件
  String? assertion;          // 判断依据
  String? brief;              // 简介
  String? chapter;            // 章节
  String? originalText;       // 原文
  String? explanation;        // 白话解释
  String? notes;              // 备注
  String version;             // 版本号
  String? versionRemark;       // 版本备注
  bool isActive;               // 是否启用
  bool isVerified;            // 是否已验证
  int priority;               // 优先级
  int viewCount;              // 查看次数
  DateTime createdAt;         // 创建时间
  DateTime updatedAt;         // 更新时间
}
```

### Pattern (格局元信息表)
```dart
class Pattern {
  String id;                  // 唯一标识 (如 'ri_yue_jia_ming')
  String name;                 // 名称 (如 '日月夹命')
  String? englishName;         // 英文名
  String? pinyin;             // 拼音
  String? aliases;            // 别名 (JSON数组)
  String categoryId;          // 所属分类
  String? keywords;           // 关键词
  String? tags;               // 标签
  String? description;        // 描述
  String? originNotes;        // 来源备注
  int referenceCount;         // 引用次数
  int ruleCount;              // 关联规则数
  DateTime createdAt;         // 创建时间
}
```

### School (流派/典籍表)
```dart
class School {
  String id;                  // 唯一标识 (如 'guo_lao')
  String name;                 // 名称 (如 '果老星宗')
  String type;                 // 类型: 'book' | 'school'
  String? era;                // 时代
  String? founder;            // 创立者
  String? description;        // 描述
  bool isActive;              // 是否启用
  int ruleCount;              // 规则数量
  DateTime createdAt;         // 创建时间
}
```

## 关键功能模块

### 1. 現生格局判定核心 (xuan-qizhengsiyu/lib/domain/managers/ge_ju/)

这是主项目中的格局判定系统，companion_system是其管理工具：

```
ge_ju_manager.dart
   ├── loadRules() - 加载规则文件
   ├── evaluateNatalChart() - 评估命盘格局
   └── getMatchedPatterns() - 获取匹配的格局列表

ge_ju_input_builder.dart
   └── buildFromPanel() - 从命盘构建输入

ge_ju_evaluator.dart
   └── evaluate() - 评估规则匹配
```

### 2. 数据管理目标

companion_system 的核心目标是：

1. **管理格局规则数据**
   - 维护 Pattern (格局元信息)
   - 维护 School (流派/典籍)
   - 维护 Rule (单个格局在不同流派的规则)
   - 版本管理和历史记录

2. **辅助主项目**
   - 提供可视化的规则编辑界面
   - 批量处理规则数据
   - 导入导出规则
   - 规则质量验证

3. **质量保证**
   - JSON格式验证
   - 条件语法检查
   - 完整性验证
   - 手工审核界面

## 配套数据文件

主项目中有大量已转换的格局数据：

```
星格总论_校正_v3_final.json  - 星格总结的完整数据
格局2_校正.json             - 完整格局规则
灵台格_校正.json             - 灵台格局
合格_校正.json               - 合格格局
十三层_校正.json             - 十三层相关
```

这些数据需要通过 import 功能导入到 companion_system 的数据库中。

## 后续开发路线图

### 阶段1: 编译问题解决 (当前)
- [ ] 解决路径编码问题
- [ ] 成功编译运行应用
- [ ] 验证数据库初始化

### 阶段2: 基础功能完善
- [ ] 实现规则编辑BottomSheet
- [ ] 实现表单验证
- [ ] 添加示例规则数据
- [ ] 测试CRUD操作

### 阶段3: 批量操作
- [ ] 批量编辑规则
- [ ] 批量删除
- [ ] 批量导出/导入

### 阶段4: 高级功能
- [ ] 版本管理和回滚
- [ ] Pattern/School完整管理
- [ ] 数据验证工具
- [ ] 搜索优化

### 阶段5: 与主项目集成
- [ ] 从主项目导出数据到companion_system
- [ ] 在companion_system编辑后导出给主项目
- [ ] 数据同步机制

---
**最后更新**: 2024-02-12
**状态**: 架构完成，编译问题需解决
