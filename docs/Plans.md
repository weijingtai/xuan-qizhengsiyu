# 太乙神数排盘开发计划

## 目标

本项目第一阶段目标是完成三种流派与四种盘类型的排盘能力，同时在模型、规则和界面上预留未来扩展“刻家”的空间。

### 支持流派

1. 金镜派
2. 统宗派
3. 集成派

### 支持盘类型

1. 年家
2. 月家
3. 日家
4. 时家

### 预留盘类型

1. 刻家

第一期实际目标是完成 `3 x 4 = 12` 套排盘组合。刻家暂不实现具体算法，但需要在枚举、输入模型、规则接口和 UI 选择逻辑中保留扩展位置。

## 总体原则

1. 算法内核与 Flutter UI 分离。
2. 三派差异通过规则集表达，不在界面层写大量条件判断。
3. 年家、月家、日家、时家通过统一盘类型建模，不复制四套独立排盘流程。
4. 每个关键算法步骤可单独测试。
5. 不确定或传本差异较大的规则，需要在结果中保留说明或警告。

## 推荐目录结构

```text
lib/
  taiyi/
    core/
      taiyi_enums.dart
      taiyi_input.dart
      taiyi_chart.dart
      taiyi_engine.dart
      taiyi_rule_set.dart

    rules/
      jing_mirror_rule_set.dart
      tong_zong_rule_set.dart
      ji_cheng_rule_set.dart

    calculators/
      accumulated_year_calculator.dart
      ju_number_calculator.dart
      taiyi_palace_calculator.dart
      wenchang_calculator.dart
      jishen_calculator.dart
      host_guest_calculator.dart
      eight_door_calculator.dart

    data/
      palace_constants.dart
      deity_constants.dart
      door_constants.dart
      stem_branch_constants.dart

    classics/
      classic_text.dart
      classic_chapter.dart
      classic_reference.dart
      classic_repository.dart
      classic_matcher.dart

    records/
      divination_record.dart
      divination_record_repository.dart
      local_record_store.dart
```

## 核心模型

### 流派枚举

```dart
enum TaiYiSchool {
  jingMirror,
  tongZong,
  jiCheng,
}
```

### 盘类型枚举

```dart
enum TaiYiChartType {
  year,
  month,
  day,
  hour,
  ke,
}
```

`ke` 先作为保留项存在。当前版本可以在规则集中返回暂不支持，后续实现刻家时不需要改动整体模型。

### 遁法枚举

```dart
enum DunType {
  yang,
  yin,
}
```

### 输入模型

```dart
class TaiYiInput {
  final DateTime dateTime;
  final TaiYiSchool school;
  final TaiYiChartType chartType;
  final bool useTrueSolarTime;
  final String? location;
}
```

### 输出模型

```dart
class TaiYiChart {
  final TaiYiSchool school;
  final TaiYiChartType chartType;
  final int accumulatedYear;
  final int juNumber;
  final DunType dunType;
  final int taiYiPalace;
  final int wenChangPalace;
  final int jiShenPalace;
  final List<TaiYiPalaceResult> palaces;
  final HostGuestResult hostGuest;
  final EightDoorResult eightDoors;
  final List<ClassicReference> classicReferences;
  final List<String> warnings;
}
```

`classicReferences` 用来保存本次排盘命中的典籍章节，供 UI 展示与用户点击查看。`warnings` 用来记录简化算法、传本差异、暂未实现项等信息。

## 统一排盘入口

建议建立统一入口 `TaiYiEngine`：

```dart
class TaiYiEngine {
  TaiYiChart calculate(TaiYiInput input) {
    final ruleSet = TaiYiRuleSetFactory.of(input.school);

    if (!ruleSet.supportsChartType(input.chartType)) {
      throw UnsupportedError('Unsupported chart type');
    }

    // 1. 计算积年
    // 2. 计算局数
    // 3. 判断阴阳遁
    // 4. 计算太乙行宫
    // 5. 计算天目/文昌
    // 6. 计算计神
    // 7. 计算主客算
    // 8. 排八门
    // 9. 生成 TaiYiChart
  }
}
```

## 规则集接口

三派差异由 `TaiYiRuleSet` 表达：

```dart
abstract class TaiYiRuleSet {
  TaiYiSchool get school;

  bool supportsChartType(TaiYiChartType type);

  int calculateAccumulatedYear(TaiYiInput input);

  int calculateJuNumber(TaiYiInput input, int accumulatedYear);

  DunType resolveDunType(TaiYiInput input);

  int calculateTaiYiPalace(TaiYiInput input, int juNumber, DunType dunType);

  int calculateWenChangPalace(TaiYiInput input, int juNumber, DunType dunType);

  int calculateJiShenPalace(TaiYiInput input, int accumulatedYear);

  HostGuestResult calculateHostGuest(TaiYiInput input, TaiYiChartDraft draft);

  EightDoorResult calculateEightDoors(TaiYiInput input, TaiYiChartDraft draft);
}
```

## 三派规则重点

### 金镜派

1. 古积年以 `10153917` 为基准。
2. 局数以 `72` 为周期。
3. 年、月、日多用阳遁，时家分阴阳遁。
4. 太乙行宫按 `(局数 - 1) / 3` 取余体系。
5. 天目阳遁起申，阴遁起寅，并保留重留规则。
6. 计神按十六神体系。
7. 主客算区分正宫与间神。
8. 八门随太乙宫起开门。

### 统宗派

1. 积年大体承金镜。
2. 五福宫加 `250` 盈差。
3. 时家阴阳遁分界需要更重视节气日。
4. 太乙行宫与金镜接近，但部分起算点有微调。
5. 天目重留规则简化。
6. 计神仍用十六神，但可配置跳间神。
7. 主客算中间神起算规则与金镜不同。
8. 八门规则需要保留随宫与固定两种配置可能。

### 集成派

1. 使用当代甲子元起算，不强依古积年。
2. 局数仍以 `72` 为周期。
3. 太乙行宫起算点与金镜不同。
4. 天目起申/寅，但取消重留。
5. 计神多用十二神。
6. 主客算统一起算。
7. 八门多采用固定宫位。

## 开发阶段

### 第一阶段：基础常量与模型

目标：搭好算法骨架。

任务：

1. 新增 `TaiYiSchool`、`TaiYiChartType`、`DunType`。
2. 新增 `TaiYiInput`、`TaiYiChart`、`TaiYiPalaceResult`。
3. 抽出九宫、八门、十六神、十二神、天干地支等常量。
4. 建立 `TaiYiRuleSet` 接口。
5. 建立 `TaiYiEngine` 统一入口。

验收：

1. 可以创建三派规则集实例。
2. 可以识别年家、月家、日家、时家、刻家五种类型。
3. 刻家暂时返回不支持，但不会破坏接口。

### 第二阶段：金镜派最小可用排盘

目标：以金镜派作为古法基准，实现第一条完整链路。

任务：

1. 实现金镜派年家。
2. 实现金镜派时家基础逻辑。
3. 完成积年、局数、阴阳遁、太乙宫、天目、计神、八门。
4. 主客算先实现基础版本，复杂传本差异以 `warnings` 标记。

验收：

1. 输入日期后能输出完整 `TaiYiChart`。
2. 九宫结果中能标出太乙、文昌、计神、八门。
3. 单元测试覆盖核心计算步骤。

### 第三阶段：统宗派规则

目标：在金镜派基础上实现统宗派差异。

任务：

1. 实现统宗派年家。
2. 实现统宗派月家。
3. 实现统宗派日家。
4. 实现统宗派时家。
5. 配置五福宫 `250` 盈差。
6. 配置天目重留简化、计神跳间神、主客算差异。

验收：

1. 四种盘类型均可排盘。
2. 与金镜派同一时间输入时，差异字段可解释。
3. 测试覆盖四种盘类型。

### 第四阶段：集成派规则

目标：实现简化流派。

任务：

1. 实现当代甲子元起算。
2. 实现集成年家、月家、日家、时家。
3. 实现十二神计神。
4. 实现固定八门。
5. 取消天目重留。

验收：

1. 集成派四种盘类型均可排盘。
2. 八门固定宫位与金镜派随宫排法可明确区分。
3. 测试覆盖积年、局数、太乙宫、计神、八门。

### 第五阶段：UI 接入

目标：将静态九宫盘改为动态排盘显示。

任务：

1. 首页增加日期时间选择。
2. 增加流派选择：金镜、统宗、集成。
3. 增加盘类型选择：年家、月家、日家、时家。
4. 刻家选项可以暂时隐藏，或显示为禁用状态。
5. `RectanglePanel` 改为接收 `TaiYiChart`。
6. 九宫内显示太乙、文昌、计神、八门、主客等结果。

验收：

1. 用户可以选择流派与盘类型并排盘。
2. 切换流派后盘面会重新计算。
3. 界面不直接包含流派算法判断。

### 第六阶段：测试与验盘

目标：保证后续扩展时不破坏已实现算法。

建议测试目录：

```text
test/
  taiyi/
    jing_mirror_year_test.dart
    jing_mirror_hour_test.dart
    tong_zong_test.dart
    ji_cheng_test.dart
```

每个测试至少覆盖：

1. 积年。
2. 局数。
3. 阴阳遁。
4. 太乙宫。
5. 天目宫。
6. 计神宫。
7. 八门排列。
8. 主客算。

## 刻家预留方案

刻家暂不进入第一期实现，但应从一开始保留扩展位置。

### 当前保留项

1. `TaiYiChartType.ke`
2. `TaiYiRuleSet.supportsChartType(TaiYiChartType type)`
3. `TaiYiInput.dateTime` 保留分钟粒度。
4. `warnings` 字段说明刻家未实现。

### 未来实现刻家需要新增

1. `KeTimeResolver`：将一个时辰拆成刻。
2. 刻家局数递推规则。
3. 刻家阴阳遁规则。
4. 刻家星神递移规则。
5. UI 中启用刻家选项。

## 典籍与占卜记录设计

后续项目会整合“典籍”内容。用户占卜时，系统需要根据排盘结果提供相应章节，并在 UI 页面展示。同时，用户每次占卜的输入、排盘结果、解释内容、引用典籍和交互记录都需要本地保存。

### 设计目标

1. 排盘结果可以关联典籍章节。
2. UI 可以展示本次占卜命中的章节、原文、译注、断语和来源。
3. 用户点击典籍章节时可以记录点击行为，方便后续做“最近查看”“常用章节”“命中规则优化”。
4. 所有占卜内容保存在本地，支持历史查询、复盘、再次打开。
5. 本地数据结构应支持未来同步或导出，但第一期不依赖云端。

### 本地数据库建议

Flutter 端建议优先考虑 SQLite 方案，例如 `drift` 或 `sqflite`。

优先推荐 `drift`：

1. 类型安全。
2. 适合复杂查询。
3. 方便维护版本迁移。
4. 适合后续增加典籍全文、章节索引、占卜历史和点击统计。

如果第一期希望更轻量，可以先用 `sqflite`。但考虑到后续典籍检索和记录查询会变复杂，建议从一开始使用 `drift`。

### 典籍数据模型

建议将典籍拆为“书籍、卷、章节、段落、引用关系”。

```dart
class ClassicText {
  final String id;
  final String title;
  final String author;
  final String dynasty;
  final String sourceVersion;
  final String description;
}

class ClassicChapter {
  final String id;
  final String classicTextId;
  final String title;
  final String volume;
  final int orderIndex;
  final String originalText;
  final String? translation;
  final String? annotation;
}

class ClassicReference {
  final String id;
  final String classicTextId;
  final String chapterId;
  final String matchedRule;
  final String reason;
  final int priority;
}
```

字段说明：

1. `sourceVersion` 记录底本版本，例如四库本、整理本、民间传本等。
2. `matchedRule` 记录触发章节的规则，例如太乙入某宫、主客算某数、八门某组合。
3. `reason` 用于 UI 展示“为什么引用此章”。
4. `priority` 用于多个章节同时命中时排序。

### 占卜记录模型

每次占卜都保存一条完整记录。

```dart
class DivinationRecord {
  final String id;
  final DateTime createdAt;
  final DateTime divinationTime;
  final TaiYiSchool school;
  final TaiYiChartType chartType;
  final String question;
  final String? category;
  final String inputJson;
  final String chartJson;
  final String interpretation;
  final List<String> classicReferenceIds;
  final List<String> tags;
}
```

记录内容至少包括：

1. 用户问题。
2. 占卜时间。
3. 使用的流派。
4. 使用的盘类型。
5. 原始输入。
6. 完整排盘结果。
7. 断语或解释内容。
8. 命中的典籍章节。
9. 用户标签或分类。

`inputJson` 和 `chartJson` 用于保存当时的完整上下文，避免未来算法升级后旧记录无法复现。

### 点击与阅读记录模型

典籍章节点击、展开、复制、收藏等行为可以单独记录。

```dart
class ClassicInteractionRecord {
  final String id;
  final DateTime createdAt;
  final String divinationRecordId;
  final String classicTextId;
  final String chapterId;
  final String action;
  final String? extraJson;
}
```

`action` 建议包括：

1. `view`：查看章节。
2. `expand`：展开全文。
3. `collapse`：收起全文。
4. `favorite`：收藏章节。
5. `copy`：复制内容。
6. `search`：从搜索进入章节。

这些记录只保存在本地。后续如果增加同步，需要单独设计用户确认和隐私说明。

### 数据表建议

```text
classic_texts
  id
  title
  author
  dynasty
  source_version
  description

classic_chapters
  id
  classic_text_id
  title
  volume
  order_index
  original_text
  translation
  annotation

classic_reference_rules
  id
  school
  chart_type
  rule_key
  rule_value
  classic_text_id
  chapter_id
  priority
  reason

divination_records
  id
  created_at
  divination_time
  school
  chart_type
  question
  category
  input_json
  chart_json
  interpretation
  tags_json

divination_classic_references
  id
  divination_record_id
  classic_text_id
  chapter_id
  matched_rule
  reason
  priority

classic_interaction_records
  id
  created_at
  divination_record_id
  classic_text_id
  chapter_id
  action
  extra_json
```

### 典籍匹配流程

排盘完成后增加典籍匹配步骤：

```text
TaiYiInput
  -> TaiYiEngine.calculate()
  -> TaiYiChart
  -> ClassicMatcher.match(chart)
  -> List<ClassicReference>
  -> DivinationRecordRepository.save()
  -> UI 展示盘面、断语、典籍章节
```

`ClassicMatcher` 不应直接写死章节文本，而是根据规则表匹配：

1. 流派。
2. 盘类型。
3. 太乙宫。
4. 文昌/天目宫。
5. 计神宫。
6. 八门。
7. 主客算。
8. 特殊格局。
9. 用户问题分类。

这样后续增加典籍时，可以主要增加数据和规则，不必频繁改算法代码。

### UI 展示设计

占卜结果页建议分为四个区域：

1. 排盘区域：九宫、星神、八门、主客。
2. 断语区域：本次占卜综合解释。
3. 典籍依据区域：展示命中章节、原文、译注、引用原因。
4. 历史入口：保存后可以进入历史记录详情。

典籍依据区域建议支持：

1. 按优先级排序。
2. 默认显示章节标题、来源和引用原因。
3. 点击后展开原文与注解。
4. 点击行为写入 `classic_interaction_records`。
5. 支持收藏或标记重点章节。

### 历史记录设计

本地历史记录需要支持：

1. 按时间倒序查看。
2. 按流派筛选。
3. 按盘类型筛选。
4. 按问题关键词搜索。
5. 按标签筛选。
6. 打开历史记录时恢复当时的排盘结果和典籍引用。

历史详情页展示：

1. 用户问题。
2. 占卜时间和创建时间。
3. 流派与盘类型。
4. 完整盘面。
5. 断语。
6. 命中典籍。
7. 当时的算法版本或规则版本。

### 隐私与数据边界

占卜问题、断语、标签、历史记录都属于用户本地数据。第一期原则：

1. 默认只保存在本地。
2. 不自动上传。
3. 不自动同步。
4. 不把历史记录作为外部请求参数。
5. 如果未来增加云同步、分享、导出或 AI 远程解读，需要在功能层明确提示用户。

### 数据版本与迁移

由于典籍文本、匹配规则和算法都会迭代，需要保存版本信息：

1. `schemaVersion`：数据库结构版本。
2. `algorithmVersion`：排盘算法版本。
3. `classicDataVersion`：典籍数据版本。
4. `ruleVersion`：章节匹配规则版本。

占卜记录中建议保存 `algorithmVersion`、`classicDataVersion` 和 `ruleVersion`，保证旧记录可解释。

## 建议里程碑

### MVP

1. 完成算法模型和枚举。
2. 完成金镜派年家排盘。
3. 完成九宫 UI 动态显示。
4. 增加一个验盘样例。
5. 预留占卜记录模型和本地数据库接口。

### 第二版

1. 补金镜派时家。
2. 补统宗派年、月、日、时。
3. 补集成派年、月、日、时。
4. 增加单元测试。

### 第三版

1. 主客算细化。
2. 天目重留规则配置化。
3. 八门随宫与固定宫位配置化。
4. 增加排盘结果说明。
5. 增加三派差异对照显示。
6. 增加占卜历史记录保存与查看。

### 第四版

1. 预研刻家。
2. 实现刻家排盘。
3. 增加民间流派扩展入口。
4. 增加典籍章节库。
5. 增加典籍匹配规则与结果页引用展示。

### 第五版

1. 增加典籍章节点击、收藏、复制等本地交互记录。
2. 增加历史记录搜索、筛选、标签。
3. 增加典籍全文检索。
4. 增加数据版本迁移机制。

## 风险点

1. 不同传本对积年、起局、重留、主客算存在差异，需要记录来源和规则版本。
2. 时家涉及节气分界，必须依赖可靠历法库或统一时间转换规则。
3. UI 当前存在较多静态硬编码，需要逐步改为数据驱动。
4. 当前部分源码文本疑似存在编码显示问题，后续整理 UI 文案时需要统一使用 UTF-8。
5. 典籍文本来源、底本版本和章节切分需要稳定，否则引用关系会频繁失效。
6. 占卜历史包含用户问题和断语，需要默认本地保存并谨慎设计导出、同步和分享。
7. 点击记录属于本地行为数据，需要避免无感上传或被误用于外部请求。

## 下一步建议

优先实现“基础模型 + 规则接口 + 金镜派年家”。同时预留本地记录模型和数据库仓储接口，但不要过早绑定具体典籍内容。排盘链路稳定后，再加入典籍章节库、匹配规则和结果页展示。
