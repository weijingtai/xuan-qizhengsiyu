# 七政四余格局计算系统 - 原子任务清单

## 第一阶段：基础框架 ✅ 已完成

### 1.1 GeJuInput 输入模型
- [x] **T-001** 创建 `lib/domain/entities/models/ge_ju/ge_ju_input.dart` ✅
- [x] **T-002** 实现 GeJuInput 便捷方法 ✅

### 1.2 十二宫体系支持（黄道/赤道）
- [x] **T-002a** 创建 `lib/domain/entities/models/ge_ju/twelve_gong_system.dart` ✅
  - TwelveCi 枚举（玄枵/星纪/析木...）
  - TwelveZodiacAlias 枚举（宝瓶/磨羯...）
  - TwelveGongSystem.resolve() 方法

### 1.3 GeJuRule 规则模型
- [x] **T-003** 创建 `lib/domain/entities/models/ge_ju/ge_ju_rule.dart` ✅

### 1.4 GeJuCondition 条件基类
- [x] **T-004** 创建 `lib/domain/entities/models/ge_ju/ge_ju_condition.dart` ✅
- [x] **T-005** 实现逻辑组合条件类（And/Or/Not）✅

### 1.5 JSON 解析器
- [x] **T-006** 创建 `lib/domain/managers/ge_ju/ge_ju_rule_parser.dart` ✅

---

## 第二阶段：条件实现 ✅ 已完成

### 2.1 星曜位置条件 ✅
- [x] **T-007** `StarInGongCondition` ✅
- [x] **T-008** `StarInConstellationCondition` ✅
- [x] **T-009** `StarWalkingStateCondition` ✅
- [x] **T-010** `StarInKongWangCondition` ✅

### 2.2 星曜关系条件 ✅
- [x] **T-011** `SameGongCondition` ✅
- [x] **T-012** `SameConstellationCondition` ✅
- [x] **T-013** `OppositeGongCondition` ✅
- [x] **T-014** `TrineGongCondition` ✅
- [x] **T-015** `SquareGongCondition` ✅
- [x] **T-016** `SameJingCondition` ✅
- [x] **T-017** `SameLuoCondition` ✅

### 2.3 命盘结构条件 ✅
- [x] **T-018** `LifeGongAtCondition` ✅
- [x] **T-019** `LifeConstellationAtCondition` ✅
- [x] **T-020** `StarGuardLifeCondition` ✅
- [x] **T-021** `StarInDestinyGongCondition` ✅

### 2.4 用神条件 ✅
- [x] **T-022** `StarIsSiZhuCondition` ✅
- [x] **T-023** `StarFourTypeCondition` ✅
- [x] **T-024** `StarHasHuaYaoCondition` ✅

### 2.5 星曜庙旺状态条件 ⚠️
- [ ] **T-025** `StarGongStatusCondition` ⚠️ 框架已有，evaluate() 待完善
  - 需要在 GeJuInput 或 ElevenStarsInfo 中增加星曜庙旺状态字段

### 2.6 时间条件 ✅
- [x] **T-026** `SeasonIsCondition` ✅
- [x] **T-027** `IsDayBirthCondition` ✅
- [x] **T-028** `MoonPhaseIsCondition` ✅
- [x] **T-029** `MonthIsCondition` ✅

### 2.7 神煞条件 ✅
- [x] **T-030** `StarWithShenShaCondition` ✅
- [x] **T-031** `GongHasShenShaCondition` ✅

### 2.8 行限条件 ✅
- [x] **T-032** `XianAtGongCondition` ✅
- [x] **T-033** `XianAtConstellationCondition` ✅
- [x] **T-034** `XianMeetStarCondition` ✅

---

## 第三阶段：格局文本转JSON ⚠️ 部分完成

### 3.1 转换工具
- [x] **T-035** 创建关键词映射表 ✅ `ge_ju_text_constants.dart`
- [ ] **T-036** 创建条件模式正则表 ⚠️ 部分完成
- [ ] **T-037** 完善 `GeJuTextParser._extractConditions()` ⚠️
  - [x] 同宫模式（同宮/同躔/同行）
  - [x] 星在宫模式（在X宮/居X/臨X/入X）
  - [x] 命立宫模式（命立X/安命X）
  - [ ] **待补充**：对照/对宫模式（对照/冲）
  - [ ] **待补充**：三合模式（三合/三方/拱）
  - [ ] **待补充**：四正模式（四正）
  - [ ] **待补充**：季节模式（春生/夏生/秋冬）
  - [ ] **待补充**：昼夜模式（昼生/夜生）
  - [ ] **待补充**：用神模式（为命主/为官/为用）
  - [ ] **待补充**：恩难仇用模式（为恩/为难/为仇/为用）
  - [ ] **待补充**：化曜模式（化禄/化暗）
- [ ] **T-038** 实现批量转换脚本

### 3.2 格局JSON数据文件 ❌ 未开始
- [ ] **T-039** 转换木星格局（100条）
- [ ] **T-040** 转换火星格局（90条）
- [ ] **T-041** 转换土星格局（68条）
- [ ] **T-042** 转换金星格局（101条）
- [ ] **T-043** 转换水星格局（86条）

---

## 第四阶段：管理器与集成 ❌ 未开始

### 4.1 结果模型
- [ ] **T-044** 创建 `ge_ju_result.dart`

### 4.2 输入构建器
- [ ] **T-045** 创建 `ge_ju_input_builder.dart`

### 4.3 格局管理器
- [ ] **T-046** 创建 `ge_ju_manager.dart`

### 4.4 集成到命盘流程
- [ ] **T-047** 集成 GeJuManager 到 BasePanelModel/ViewModel

---

## 第五阶段：用户自定义与验证 ❌ 未开始

### 5.1 用户自定义支持
- [ ] **T-048** 实现自定义规则文件加载
- [ ] **T-049** 实现规则增删改查接口

### 5.2 测试验证
- [ ] **T-050** 编写条件类单元测试
- [ ] **T-051** 编写集成测试
- [ ] **T-052** 编写 GeJuTextParser 测试

---

## 当前待完成任务（按优先级）

### 优先级 1：完善文本解析器
| 任务 | 说明 | 文件 |
|------|------|------|
| T-037 | 补充 `_extractConditions()` 正则 | `ge_ju_text_parser.dart` |

需要增加的正则模式：
```dart
// 对照/对宫
r'([星曜])与([星曜])对照'
r'([星曜])冲([星曜])'

// 三合/三方
r'([星曜]+)三合'
r'([星曜])拱([星曜])'

// 四正
r'([星曜]+)四正'

// 季节
r'(春|夏|秋|冬)[生值月]'
r'(春夏|秋冬)'

// 昼夜
r'(昼|夜|晝)[生值]'
r'逢(昼|夜|晝)'

// 用神
r'为(命主|身主|官|用神)'
r'([星曜])为(恩|难|仇|用)'

// 化曜
r'([星曜])化(禄|暗|福|耗)'
```

### 优先级 2：修复庙旺状态条件
| 任务 | 说明 | 文件 |
|------|------|------|
| T-025 | 完善 `StarGongStatusCondition.evaluate()` | `gong_status_conditions.dart` |

需要：
1. 在 `GeJuInput` 增加 `getStarGongStatus(star)` 方法
2. 或在 `ElevenStarsInfo` 中确认是否有庙旺状态字段

### 优先级 3：管理器与集成
| 任务 | 说明 |
|------|------|
| T-044~047 | 创建 GeJuManager 并集成到命盘流程 |

---

## 任务统计

| 阶段 | 总数 | 已完成 | 进行中 | 待开始 |
|------|------|--------|--------|--------|
| 第一阶段：基础框架 | 7 | 7 | 0 | 0 |
| 第二阶段：条件实现 | 28 | 27 | 1 | 0 |
| 第三阶段：文本转JSON | 9 | 1 | 2 | 6 |
| 第四阶段：管理器集成 | 4 | 0 | 0 | 4 |
| 第五阶段：自定义与验证 | 5 | 0 | 0 | 5 |
| **合计** | **53** | **35** | **3** | **15** |

**完成进度：66%**
