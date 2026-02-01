# 七政四余格局计算系统 - 原子任务清单

## 第一阶段：基础框架

### 1.1 GeJuInput 输入模型
- [ ] **T-001** 创建 `lib/domain/entities/models/ge_ju/ge_ju_input.dart`
  - 定义 GeJuInput 类，包含所有输入字段（coordinateSystem, starsSet, starRelationship, bodyLifeModel, destinyGongMapper, starsFourTypeMapper, huaYaoMapper, season, monthZhi, isDayBirth, moonPhase, shenShaMapper, jiaZiShenSha, 行限可选字段）
  - **新增**：`coordinateSystem` 字段（CelestialCoordinateSystem 类型），标识命盘使用的坐标体系
- [ ] **T-002** 实现 GeJuInput 便捷方法
  - `getStar(EnumStars)` - 获取指定星曜信息
  - `getStarGong(EnumStars)` - 获取星曜所在宫位
  - `getStarConstellation(EnumStars)` - 获取星曜所在星宿
  - `isSameGong(star1, star2)` - 判断两星同宫
  - `isOpposite(star1, star2)` - 判断两星对照
  - `isStarInKongWang(star)` - 判断星曜落空亡
  - 四主 getter（lifeGongMaster, bodyGongMaster, lifeConstellationMaster, bodyConstellationMaster）

### 1.2 十二宫体系支持（黄道/赤道）
- [ ] **T-002a** 创建 `lib/domain/entities/models/ge_ju/twelve_gong_system.dart`
  - 定义十二次枚举或映射：玄枵/星纪/析木/大火/寿星/鹑尾/鹑火/鹑首/实沈/大梁/降娄/娵訾
  - 实现十二次 ↔ EnumTwelveGong 双向映射
  - 实现黄道宫名（宝瓶/磨羯等）↔ EnumTwelveGong 映射
  - 提供 `resolveGongName(String name)` 方法，支持地支/黄道/赤道三种名称解析

### 1.3 GeJuRule 规则模型
- [ ] **T-003** 创建 `lib/domain/entities/models/ge_ju/ge_ju_rule.dart`
  - 定义 GeJuRule 类（扩展现有 GeJuModel），增加 id, source, scope, conditions 字段
  - **新增**：`coordinateSystem` 字段，指定该格局适用的坐标体系（null=跟随命盘, ecliptic=仅黄道, equatorial=仅赤道, both=两者皆可）
  - 定义 GeJuScope 枚举（natal, xingxian, both）
  - 实现 `GeJuRule.fromJson()` 工厂方法

### 1.3 GeJuCondition 条件基类
- [ ] **T-004** 创建 `lib/domain/entities/models/ge_ju/ge_ju_condition.dart`
  - 定义 `GeJuCondition` 抽象基类，含 `evaluate(GeJuInput)` 和 `describe()` 方法
  - 实现 `GeJuCondition.fromJson()` 工厂方法（条件类型路由）
- [ ] **T-005** 实现逻辑组合条件类
  - `AndCondition` - 所有子条件均满足
  - `OrCondition` - 任一子条件满足
  - `NotCondition` - 条件取反

### 1.4 JSON 解析器
- [ ] **T-006** 创建 `lib/domain/managers/ge_ju/ge_ju_rule_parser.dart`
  - 从 JSON Map 解析单个 GeJuRule
  - 从 JSON 文件解析格局规则列表
  - 递归解析嵌套条件（AND/OR/NOT + 具体条件）

---

## 第二阶段：条件实现

### 2.1 星曜位置条件
- [ ] **T-007** 实现 `StarInGongCondition`
  - 参数：star, gongs（宫位列表，支持地支名/黄道名/赤道十二次名）
  - 逻辑：使用 `resolveGongName()` 统一解析宫位名，判断 star 是否在指定宫位之一
- [ ] **T-008** 实现 `StarInConstellationCondition`
  - 参数：star, constellations（星宿列表）
  - 逻辑：判断 star 是否在指定星宿之一
- [ ] **T-009** 实现 `StarWalkingStateCondition`
  - 参数：star, states（FiveStarWalkingType 列表）
  - 逻辑：判断 star 运行状态是否匹配
- [ ] **T-010** 实现 `StarInKongWangCondition`
  - 参数：star
  - 逻辑：通过 jiaZiShenSha 判断星曜所在宫位是否为空亡

### 2.2 星曜关系条件
- [ ] **T-011** 实现 `SameGongCondition`
  - 参数：stars（两颗或多颗星）
  - 逻辑：查询 starRelationship.sameGongMap 判断同宫
- [ ] **T-012** 实现 `SameConstellationCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.sameStarInnMap 判断同宿
- [ ] **T-013** 实现 `OppositeGongCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.chongGongSet 判断对宫
- [ ] **T-014** 实现 `TrineGongCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.threeHeGongMap 判断三方
- [ ] **T-015** 实现 `SquareGongCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.fourZhengMap 判断四正
- [ ] **T-016** 实现 `SameJingCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.sameJingMap 判断同经
- [ ] **T-017** 实现 `SameLuoCondition`
  - 参数：stars
  - 逻辑：查询 starRelationship.sameLuoSet 判断同络

### 2.3 命盘结构条件
- [ ] **T-018** 实现 `LifeGongAtCondition`
  - 参数：gongs（宫位列表）
  - 逻辑：判断命宫是否在指定宫位之一
- [ ] **T-019** 实现 `LifeConstellationAtCondition`
  - 参数：constellations（星宿列表）
  - 逻辑：判断命度是否在指定星宿之一
- [ ] **T-020** 实现 `StarGuardLifeCondition`
  - 参数：star
  - 逻辑：判断星曜是否在命宫
- [ ] **T-021** 实现 `StarInDestinyGongCondition`
  - 参数：star, destinyGong（EnumDestinyTwelveGong）
  - 逻辑：通过 destinyGongMapper 找到对应宫位，判断星曜是否在该宫

### 2.4 用神条件
- [ ] **T-022** 实现 `StarIsSiZhuCondition`
  - 参数：star, siZhuTypes（四主类型列表）
  - 逻辑：判断 star 是否为命宫主/身宫主/命度主/身度主
- [ ] **T-023** 实现 `StarFourTypeCondition`
  - 参数：star, targetStar, fourTypes（EnumStarsFourType 列表）
  - 逻辑：查询 starsFourTypeMapper 判断 star 对 targetStar 的恩难仇用关系
- [ ] **T-024** 实现 `StarHasHuaYaoCondition`
  - 参数：star, huaYaoTypes（EnumGuoLaoHuaYao 列表）
  - 逻辑：查询 huaYaoMapper 判断星曜是否带指定化曜

### 2.5 星曜庙旺状态条件
- [ ] **T-025** 实现 `StarGongStatusCondition`
  - 参数：star, statuses（EnumStarGongPositionStatusType 列表）
  - 逻辑：判断星曜在当前宫位的庙旺陷状态

### 2.6 时间条件
- [ ] **T-026** 实现 `SeasonIsCondition`
  - 参数：seasons（FourSeasons 列表）
  - 逻辑：判断出生季节
- [ ] **T-027** 实现 `IsDayBirthCondition`
  - 参数：value（bool）
  - 逻辑：判断昼生/夜生
- [ ] **T-028** 实现 `MoonPhaseIsCondition`
  - 参数：phases（EnumMoonPhases 列表）
  - 逻辑：判断月相
- [ ] **T-029** 实现 `MonthIsCondition`
  - 参数：months（DiZhi 列表）
  - 逻辑：判断出生月份地支

### 2.7 神煞条件
- [ ] **T-030** 实现 `StarWithShenShaCondition`
  - 参数：star, shenSha（神煞列表）
  - 逻辑：判断星曜是否带指定神煞
- [ ] **T-031** 实现 `GongHasShenShaCondition`
  - 参数：gong（宫位或 "lifeGong"/"bodyGong" 特殊标识）, shenSha
  - 逻辑：判断宫位是否有指定神煞

### 2.8 行限条件
- [ ] **T-032** 实现 `XianAtGongCondition`
  - 参数：gong
  - 逻辑：判断当前行限宫位
- [ ] **T-033** 实现 `XianAtConstellationCondition`
  - 参数：constellation
  - 逻辑：判断当前行限星宿
- [ ] **T-034** 实现 `XianMeetStarCondition`
  - 参数：star
  - 逻辑：判断行限是否遇到指定星曜

---

## 第三阶段：格局文本转JSON

### 3.1 转换工具
- [ ] **T-035** 创建关键词映射表
  - 星曜映射（七政+四余+组合，如"木气"→["Jupiter","Qi"]）
  - 宫位映射（地支+黄道宫别名+赤道十二次+方位）
    - 地支：子/丑/寅/卯/辰/巳/午/未/申/酉/戌/亥
    - 黄道：宝瓶/磨羯/人马/天蝎/天秤/双女/狮子/巨蟹/双子/金牛/白羊/双鱼
    - 赤道十二次：玄枵/星纪/析木/大火/寿星/鹑尾/鹑火/鹑首/实沈/大梁/降娄/娵訾
  - 星宿映射（28宿）
- [ ] **T-036** 创建条件模式正则表
  - 同宫模式（同宮/同躔/同行/會）
  - 宫位模式（在X宮/居X/臨X/入X）
  - 星宿模式（躔X度/在X度）
  - 季节/昼夜/用神等模式
- [ ] **T-037** 实现 `GeJuTextParser` 类
  - `parse(String text)` - 解析单条格局文本
  - 元数据提取（名称、出处、描述、条件原文）
  - 条件自动解析（正则匹配+关键词映射）
  - 吉凶/格局类型推断
  - 输出带置信度和审核标记的 JSON
- [ ] **T-038** 实现批量转换脚本
  - 读取 ge_ju_1.txt，按星体分类拆分
  - 逐条调用 GeJuTextParser.parse()
  - 输出 draft JSON 文件（含 _autoGenerated 和 _needsReview 标记）

### 3.2 格局JSON数据文件
- [ ] **T-039** 转换木星格局（100条）→ `assets/ge_ju/mu_xing_ge_ju.json`
  - 自动解析 + 人工审核复杂条件
- [ ] **T-040** 转换火星格局（90条）→ `assets/ge_ju/huo_xing_ge_ju.json`
- [ ] **T-041** 转换土星格局（68条）→ `assets/ge_ju/tu_xing_ge_ju.json`
- [ ] **T-042** 转换金星格局（101条）→ `assets/ge_ju/jin_xing_ge_ju.json`
- [ ] **T-043** 转换水星格局（86条）→ `assets/ge_ju/shui_xing_ge_ju.json`

---

## 第四阶段：管理器与集成

### 4.1 结果模型
- [ ] **T-044** 创建 `lib/domain/entities/models/ge_ju/ge_ju_result.dart`
  - `GeJuResult` 类（rule, matched, matchedConditionDescriptions）
  - `GeJuEvaluationReport` 类（matchedPatterns, totalEvaluated, 分类筛选 getter）

### 4.2 输入构建器
- [ ] **T-045** 创建 `lib/domain/managers/ge_ju/ge_ju_input_builder.dart`
  - `buildFromPanel()` - 从命盘数据构建 GeJuInput
  - `extendForXingXian()` - 为行限扩展 GeJuInput

### 4.3 格局管理器
- [ ] **T-046** 创建 `lib/domain/managers/ge_ju/ge_ju_manager.dart`
  - `loadRulesFromAssets()` - 从 assets 加载规则 JSON
  - `loadRulesFromFile(path)` - 从文件系统加载规则
  - `evaluateNatal(input)` - 评估命盘格局
  - `evaluateXingXian(input)` - 评估行限格局
  - `evaluateAll(input)` - 评估所有格局

### 4.4 集成到命盘流程
- [ ] **T-047** 在 BasePanelModel 或相关 ViewModel 中集成 GeJuManager
  - 命盘计算完成后自动触发格局判断
  - 将 GeJuEvaluationReport 暴露给 UI 层

---

## 第五阶段：用户自定义与验证

### 5.1 用户自定义支持
- [ ] **T-048** 实现自定义规则文件加载
  - 从 `assets/ge_ju/custom/` 目录加载用户自定义 JSON
  - 自定义规则与内置规则合并
- [ ] **T-049** 实现规则增删改查接口
  - 添加自定义规则
  - 删除/禁用规则
  - 修改规则条件
  - 导出规则为 JSON

### 5.2 测试验证
- [ ] **T-050** 编写条件类单元测试
  - 每种 Condition 的 evaluate() 正确性
  - AND/OR/NOT 组合逻辑
  - JSON 解析与序列化
- [ ] **T-051** 编写集成测试
  - 使用已知命盘验证格局判断结果
  - 验证"日边红杏"等典型格局的匹配
- [ ] **T-052** 编写 GeJuTextParser 测试
  - 元数据提取准确性
  - 条件解析正确性
  - 吉凶推断准确性

---

## 依赖关系

```
T-001,002 ──┐
T-002a ─────┤  (十二宫体系支持)
T-003 ──────┤
T-004,005 ──┼──→ T-006 ──→ T-007~034（条件实现）──→ T-044~047（管理器集成）
            │
T-035~038 ──┼──→ T-039~043（JSON数据）──→ T-046（管理器加载规则）
            │
            └──→ T-048~049（用户自定义）
            └──→ T-050~052（测试）
```

## 任务统计

| 阶段 | 任务数 | 说明 |
|------|--------|------|
| 第一阶段：基础框架 | 7 | T-001 ~ T-006, T-002a |
| 第二阶段：条件实现 | 28 | T-007 ~ T-034 |
| 第三阶段：文本转JSON | 9 | T-035 ~ T-043 |
| 第四阶段：管理器集成 | 4 | T-044 ~ T-047 |
| 第五阶段：自定义与验证 | 5 | T-048 ~ T-052 |
| **合计** | **53** | |
