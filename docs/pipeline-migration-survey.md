# 七政四余管线迁移 M1 盘点调查报告

> ACT: `docs/launch-plan/pipeline-migration-m1-m5-act/01-qizheng-m1-survey.yaml`
> 产出仓: `xuan-qizhengsiyu`
> 阶段: M1 (只读盘点，零代码改动)
> 参考架构: `docs/launch-plan/DIVINATION-PIPELINE-ARCHITECTURE.md` §4、§6、§9、§11

---

## 1. 当前状态与 Git 清净性

### PRECHECK 结果

| 命令 | 输出 | 状态 |
|---|---|---|
| `git -C xuan-qizhengsiyu status --short --branch` | `## main...gitea/main` + 3 个未跟踪文件 | ✅ |
| `git -C xuan-qizhengsiyu rev-list --left-right --count gitea/main...HEAD` | `0\t0` | ✅ |
| `git -C repository-interface-divination-pipeline rev-parse --short HEAD` | `ed17984` | ✅ |
| `git -C xuan-storage rev-parse --short gitea/main` | `9254e89` | ✅ (de57f5b 是祖先，9254e89 更晚) |

**分支**: `main`，跟踪 `gitea/main`，0 ahead / 0 behind。

**未跟踪文件** (均为白名单，未触碰):
- `.agents/`
- `GEMINI.md`
- `docs/project/architecture/003-三洛通道荣归顾亡斋盘数据接入调研.md`

**已修改的跟踪文件**: 无。

**依赖版本核对**:
- `repository-interface-divination-pipeline` @ `ed17984` ✅
- `repository-interface-record` @ `ba31dbf` (AGENTS.md 声明) ✅
- `xuan-storage` @ `9254e89` (gitea/main，de57f5b 为祖先) ✅
- `xuan-qizhengsiyu` @ `main` 0 ahead / 0 behind gitea/main ✅

---

## 2. 时间输入字段与 JSON 编码

### 当前时间模型

**活跃类型**: `DivinationDatetimeModel` (位于 `xuan-metaphysics-core/lib/models/divination_datetime.dart`)

```
DivinationDatetimeModel
  ├── uuid: String
  ├── datetime: DateTime          ← 本地墙钟时间
  ├── observer: ObserverDataModel
  │     ├── timezoneStr: String   ← IANA 时区 (如 "Asia/Shanghai")
  │     ├── type: EnumDatetimeType ← 口径选择
  │     ├── coordinate: Coordinates? ← 经纬度
  │     ├── location: Location?    ← 地址 (province/city coordinates)
  │     ├── hourAdjusted: int?     ← removeDST 专有
  │     └── isManualCalibration: bool
  ├── yearJiaZi / monthJiaZi / dayJiaZi / timeJiaZi: JiaZi
  ├── lunarMonth / lunarDay / isLeapMonth
  ├── jieQiInfo: JieQiInfo
  ├── isDst / isSeersLocation
```

### JSON 编码方式

**双层编码** (double-encoding):

1. `DivinationDatetimeModel.toJson()` — 由 `json_annotation` 生成，返回 `Map<String, dynamic>`
2. `jsonEncode(map)` — 在 `pan_entity.dart:61` 进行，产生 JSON 字符串

```dart
// xuan-qizhengsiyu/lib/domain/entities/models/pan_entity.dart:61
divinationDatetimeJson: jsonEncode(divinationDatetimeModel.toJson()),
```

**示例 JSON 形状** (来自 `save_calculated_panel_usecase_test.dart:78-102` 的测试 fixture):

```json
{
  "uuid": "dt-1",
  "isDst": false,
  "isSeersLocation": false,
  "observer": {
    "type": "标准时间",
    "timezoneStr": "Asia/Shanghai",
    "isManualCalibration": false
  },
  "datetime": "1990-01-01T12:00:00.000",
  "yearJiaZi": "己巳",
  "monthJiaZi": "丙子",
  "dayJiaZi": "甲子",
  "timeJiaZi": "庚午",
  "lunarMonth": 11,
  "lunarDay": 5,
  "jieQiInfo": { "jieQi": "立春", "startAt": "...", "endAt": "..." },
  "isLeapMonth": false
}
```

**存储字段**: `QiZhengSiYuPanContract.divinationDatetimeJson` (String) — 整个 `DivinationDatetimeModel` 序列化为 JSON 字符串后再 `jsonEncode`。

### 相关字段

- `panelConfigJson` — `jsonEncode(panelConfig.toJson())`，同双层编码
- `panelModelJson` — `jsonEncode(panelModel.toJson())`，同双层编码

---

## 3. 地点、时区、经纬度来源

### 地理信息来源

**活跃类型**: `ObserverDataModel.location` (`Location` 类型，位于 `xuan-metaphysics-core/lib/datamodel/location.dart`)

```
Location
  ├── address: Address?
  │     ├── province: Province (coordinates: Coordinates)
  │     └── city: City? (coordinates: Coordinates?)
  └── preciseCoordinates: Coordinates?  ← trueSolar 专用
```

**Coordinates** 包含 `latitude` 和 `longitude`。

### 时区来源

`ObserverDataModel.timezoneStr` — IANA 时区标识 (如 `"Asia/Shanghai"`)。

### 经纬度在 Viewmodel 中的映射

`qi_zheng_si_yu_viewmodel.dart:216-238` 中的 `_generateLifeObserverPosition` 方法切换 `EnumDatetimeType` 并映射坐标:

| EnumDatetimeType | 坐标来源 |
|---|---|
| `standard` | `observer.location.address.province.coordinates` |
| `removeDST` | `observer.location.address.province.coordinates` |
| `politicalCenter` | `observer.location.address.province.coordinates` |
| `meanSolar` | `observer.location.address.city?.coordinates ?? province.coordinates` |
| `trueSolar` | `observer.isManualCalibration ? preciseCoordinates! : location.coordinates!` |

### 时区转换

`ObserverPosition.toUtcTime()` (`observer_position.dart:110-119`) 使用 `timezone` 包将本地墙钟转换为 UTC:

```dart
static DateTime toUtcTime(String timezone, DateTime datetime) {
  tz.TZDateTime shanghaiTime = tz.TZDateTime(
    tz.getLocation(timezone),
    datetime.year, datetime.month, datetime.day,
    datetime.hour, datetime.minute);
  return shanghaiTime.toUtc();
}
```

### 时区/地点的新旧模型对比

| 新模型 (管线) | 旧模型 (七政) | 关系 |
|---|---|---|
| `DivinationMoment.instantUtc` | `ObserverPosition.utcDateTime` | 同概念，管线要求 UTC |
| `GeoPoint.latitude/longitude` | `ObserverPosition.latitude/longitude` | 同概念 |
| `GeoPoint.timeZoneId` | `ObserverDataModel.timezoneStr` | 同概念 |
| `CalendarMeridian` | (无) | 新增，politicalCenter 档使用 |

---

## 4. 口径路径与 EnumDatetimeType 使用

### EnumDatetimeType 当前定义

位于 `xuan-metaphysics-core/lib/models/divination_datetime.dart:33-47`:

```dart
enum EnumDatetimeType {
  @JsonValue("标准时间")     standard("标准时间"),
  @JsonValue("移除夏令时")   removeDST("移除夏令时"),
  @JsonValue("政治中心时间")  politicalCenter("政治中心时间"),
  @JsonValue("平太阳时")     meanSolar("平太阳时"),
  @JsonValue("真太阳时")     trueSolar("真太阳时");
}
```

**五档均已存在** (包含 `politicalCenter`)。`@JsonValue` 注解用于 JSON 序列化。

### 口径消费点 (3 个活跃 switch)

1. **`qi_zheng_si_yu_viewmodel.dart:216-238`** — `_generateLifeObserverPosition`: 切换 `datetimeModel.observer.type`，映射到不同坐标来源。`politicalCenter` 档当前映射到 `province.coordinates` (与 `standard`/`removeDST` 相同)。

2. **`lunar_date_info_v2_data.dart:24-36`** — `chineseDateInfo` getter: 切换 `inUsed` (EnumDatetimeType)，从 `DateTimeDetailsBundleLogicModel` 读取对应档的 `ChineseDateInfo`。

3. **`lunar_date_info_v2_data.dart:39-52`** — `dateTime` getter: 切换 `inUsed`，从 `DateTimeDetailsBundleLogicModel` 读取对应档的 `DateTime`。

### 口径数据来源

`DateTimeDetailsBundleLogicModel` (位于 `xuan-metaphysics-core/lib/models/datetime_details_bundle_logic_model.dart`) 是**多档槽位**结构:

```
standeredDatetime  + standeredChineseInfo    // 必填
removeDSTDatetime? + removeDSTChineseInfo?   // 可空
meanSolarDatetime? + meanSolarChineseInfo?   // 可空
trueSolarDatetime? + trueSolarChineseInfo?   // 可空
politicalCenterDatetime? + politicalCenterChineseInfo?  // 可空 (五档)
```

消费方通过 `inUsed` 字段切换读取哪档。**四档槽位、按需填充，三档可空** (缺少所需数据如经纬度时即为 null)。

### 口径归一缺失

七政模块**没有** `MomentResolver` 实现。口径换算逻辑分散在 viewmodel 和 bundle 模型中，没有统一的 `resolve()` 入口。

---

## 5. 计算入口与纯函数风险

### 活跃计算入口

| UseCase/Service | 文件 | 是否 async | DateTime.now() | 说明 |
|---|---|---|---|---|
| `CalculateQiZhengBasePanelUseCase.execute()` | `calculate_qizheng_base_panel_usecase.dart:34` | ✅ Future | ❌ | 主命盘计算入口 |
| `GenerateBasePanelService.calculate()` | `generate_base_panel_service.dart` | ✅ Future | ❌ | 被 CalculateUseCase 调用 |
| `BuildQiZhengTimelineUseCase.execute()` | `build_qizheng_timeline_usecase.dart:45` | ✅ Future | ❌ | 时间线 + 流年 |
| `ComputeRiseSetUseCase.execute()` | `compute_rise_set_usecase.dart:11` | ❌ | ❌ | 日月出没 + 真太阳时 |
| `SaveCalculatedPanelUseCase.execute()` | `save_calculated_panel_usecase.dart:21` | ✅ Future | ✅ (line 29, 57) | 保存记录 |

### 计算链

```
CalculateQiZhengBasePanelUseCase.execute()
  ├── CalculationEngineFactory.create(config)  → async
  ├── engine.getSystemDefinition(config)       → async
  ├── engine.calculateStarPositions(...)       → async
  └── GenerateBasePanelService.calculate()
        ├── shenShaManager (async)
        └── huaYaoManager (async)
```

### DateTime.now() 分布

| 位置 | 用途 | 分类 |
|---|---|---|
| `save_calculated_panel_usecase.dart:29` | `createdAt` / `lastUpdatedAt` | 持久化时间戳 (非盘面计算) |
| `save_calculated_panel_usecase.dart:57` | `lastUpdatedAt` (update) | 持久化时间戳 (非盘面计算) |
| `qi_zheng_si_yu_viewmodel.dart:653` | `calculateDaXian` 默认 `fateDatetime` | UI 默认值 (非盘面计算) |

**盘面计算路径** (`CalculateQiZhengBasePanelUseCase` → `GenerateBasePanelService`) **不直接调用 `DateTime.now()`**。计算输入通过 `ObserverPosition` 传入，包含 `dateTime`、`utcDateTime`、`latitude`、`longitude` 等。

### 纯函数风险评估

- `GenerateBasePanelService.calculate()` 是 `async` (Future)，`shenShaManager` 和 `huaYaoManager` 均为 `await`。这与管线的 `ChartCalculator.calculate` (同步纯函数) 存在**签名冲突**。
- `CalculationEngineFactory.create()` 是 async，内部可能涉及资源加载。
- `GenerateBasePanelService` 使用静态常量 `referenceDateTimeUtc` (2013-4-8 18:58 UTC) 而非 `DateTime.now()`，这是确定性的。
- **风险**: async 计算链需要同步化或管线设计调整才能满足 `ChartCalculator` 纯函数要求。

### SolarTimeCalculator 使用

| 文件 | 用途 | 是否作为排盘口径入口 |
|---|---|---|
| `build_qizheng_timeline_usecase.dart:130` | 计算真太阳时用于显示 | ❌ 辅助显示，非排盘 |
| `compute_rise_set_usecase.dart:30` | 计算真太阳时用于显示 | ❌ 辅助显示，非排盘 |

**结论**: `SolarTimeCalculator` 当前仅用于**辅助显示** (日月出没卡片)，**不是排盘口径入口**。排盘通过 `ObserverPosition` 传入的预计算四柱，直接使用 `CalculationEngineFactory` 计算星体位置。

---

## 6. 持久化路径与记录编解码

### 记录 Contract

`QiZhengSiYuPanContract` (位于 `repository-interface-qizhengsiyu/lib/src/contracts/qizhengsiyu_pan_contract.dart`):

```dart
class QiZhengSiYuPanContract extends Equatable {
  final String uuid;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime? deletedAt;
  final String divinationRequestInfoUuid;
  final String divinationDatetimeJson;  // 双层 JSON 编码
  final String panelConfigJson;         // 双层 JSON 编码
  final String panelModelJson;          // 双层 JSON 编码
}
```

**存储方式**: 三个 JSON 字符串字段，分别存储整个 `DivinationDatetimeModel`、`BasePanelConfig`、`BasePanelModel` 的序列化结果。

### 编解码器

`QiZhengRecordCodec` (位于 `xuan-storage/drift/lib/qizhengsiyu/qizheng_record_codec.dart`):

- 实现 `RecordModuleCodec<QiZhengSiYuPanContract>`
- `module` = `'qizhengsiyu'`
- `category` = `'divination'`
- `divinationType` = `'qi_zheng'`

#### encode() 方法 (qizheng_record_codec.dart:27-46)

```dart
RecordMeta encode(QiZhengSiYuPanContract c, {required String scopeUid}) {
  final data = <String, dynamic>{
    'divinationRequestInfoUuid': c.divinationRequestInfoUuid,
    'divinationDatetimeJson': c.divinationDatetimeJson,
    'panelConfigJson': c.panelConfigJson,
    'panelModelJson': c.panelModelJson,
  };
  final meta = RecordMeta(
    uuid: c.uuid, scopeUid: scopeUid, module: module, category: category,
    divinationType: divinationType,
    moduleDataJson: jsonEncode(data),
    navParamsJson: jsonEncode({'recordUuid': c.uuid}),
    occurredAtUtc: DateTime.tryParse(c.divinationDatetimeJson),  // ← BUG
    reckoningType: null, timezoneStr: null, latitude: null,
    longitude: null, locationName: null, spacetimeJson: null, gender: null,
    createdAt: c.createdAt, updatedAt: c.lastUpdatedAt,
    deletedAt: c.deletedAt, rev: 1,
  );
  return (meta: meta, moduleData: data);
}
```

#### 公共列填列状态

| RecordMeta 字段 | 当前值 | 应填内容 |
|---|---|---|
| `occurredAtUtc` | `DateTime.tryParse(c.divinationDatetimeJson)` → **null** | `DivinationDatetimeModel.datetime` |
| `reckoningType` | `null` | `EnumDatetimeType` 的 JSON 值 |
| `timezoneStr` | `null` | `ObserverDataModel.timezoneStr` |
| `latitude` | `null` | `ObserverDataModel.coordinate.latitude` |
| `longitude` | `null` | `ObserverDataModel.coordinate.longitude` |
| `locationName` | `null` | 地址名称 |
| `spacetimeJson` | `null` | 时空 JSON |
| `gender` | `null` | 性别 |

**全部公共列均为 null** — 公共列填列尚未实现。

### 实体转换

`QiZhengSiYuPanEntity.toContract()` (`pan_entity.dart:54-65`):
- `divinationDatetimeJson` = `jsonEncode(divinationDatetimeModel.toJson())`
- `panelConfigJson` = `jsonEncode(panelConfig.toJson())`
- `panelModelJson` = `jsonEncode(panelModel.toJson())`

`QiZhengSiYuPanEntity.fromContract()` (`pan_entity.dart:67-81`):
- `jsonDecode(contract.divinationDatetimeJson)` → `DivinationDatetimeModel.fromJson()`
- `jsonDecode(contract.panelConfigJson)` → `BasePanelConfig.fromJson()`
- `jsonDecode(contract.panelModelJson)` → `BasePanelModel.fromJson()`

### 模块注册

`QiZhengModuleRegistry` (`qizheng_module_registry.dart`):
- `codec()` → `QiZhengRecordCodec()`
- `repository(store, uuid)` → `RecordBackedQiZhengRepository`

`RecordBackedQiZhengRepository` extends `BaseRecordBackedRepository<QiZhengSiYuPanContract>`，实现 `QiZhengRecordRepository`。

---

## 7. 现有测试与预存失败

### 七政模块测试 (xuan-qizhengsiyu)

| 测试文件 | 类型 | 说明 |
|---|---|---|
| `test/domain/usecases/save_calculated_panel_usecase_test.dart` | UseCase | SaveCalculatedPanelUseCase — 包含 FakePanRepo/FakeRecordRepo |
| `test/domain/usecases/calculate_qizheng_base_panel_usecase_test.dart` | UseCase | CalculateQiZhengBasePanelUseCase — 使用 FakeEngine |
| `test/domain/usecases/compute_rise_set_usecase_test.dart` | UseCase | ComputeRiseSetUseCase |
| `test/domain/usecases/build_qizheng_timeline_usecase_test.dart` | UseCase | BuildQiZhengTimelineUseCase |
| `test/presentation/qi_zheng_si_yu_viewmodel_characterization_test.dart` | Characterization | Viewmodel 特征测试 |
| `test/presentation/qi_zheng_si_yu_viewmodel_equivalence_test.dart` | Equivalence | Viewmodel 等价性测试 |
| `test/presentation/qi_zheng_si_yu_viewmodel_usecase_wiring_test.dart` | Wiring | Viewmodel UseCase 装配测试 |
| `test/presentation/composition_root_test.dart` | Composition | 依赖注入根测试 |
| `test/architecture/import_boundary_test.dart` | Architecture | 导入边界测试 |
| `test/architecture/ui_boundary_test.dart` | Architecture | UI 边界测试 |
| `test/domain/engines/engine_provider_test.dart` | Engine | 引擎提供者测试 |
| `test/domain/engines/historical_engine_injection_test.dart` | Engine | 历史引擎注入测试 |

### 存储层测试 (xuan-storage)

| 测试文件 | 类型 | 说明 |
|---|---|---|
| `test/record/qizhengsiyu_record_codec_test.dart` | Codec | QiZhengRecordCodec round-trip — **使用 `divinationDatetimeJson: '{}'` 空 JSON，未能发现 `DateTime.tryParse` bug** |
| `test/record/record_backed_qizheng_repository_test.dart` | Repository | RecordBackedQiZhengRepository |

### 预存失败 (12 条)

AGENTS.md 声明七政全量测试存在 12 个 pre-existing 失败记录。本次 M1 调查未执行 `flutter test` 全量运行 (ACT01 仅允许写 survey，不允许运行测试)。需要在 M5 或后续 ACT 中执行 `flutter test` 并列出具体失败测试名与对照。

### 作为 M2-M4 特征测试的候选

| 迁移阶段 | 候选测试 | 用途 |
|---|---|---|
| M2 | `calculate_qizheng_base_panel_usecase_test.dart` | 盘面计算特征 — 验证抽取的 ChartCalculator 输出一致 |
| M2 | `build_qizheng_timeline_usecase_test.dart` | 时间线计算特征 |
| M3 | `qi_zheng_si_yu_viewmodel_characterization_test.dart` | Viewmodel 特征 — 验证 ChartRequest 构造后行为不变 |
| M3 | `qi_zheng_si_yu_viewmodel_equivalence_test.dart` | Viewmodel 等价性 |
| M4 | `qizhengsiyu_record_codec_test.dart` (xuan-storage) | Codec round-trip — 需补充真实 `divinationDatetimeJson` fixture |
| M4 | `save_calculated_panel_usecase_test.dart` | 保存流程 — 验证实体→Contract→Codec 链路 |

---

## 8. M2/M3/M4 proposed SCOPE.WRITE

### M2 — 抽取 ChartCalculator (纯函数)

**目标**: 将盘面计算抽取为 `ChartCalculator<QizhengParams, QizhengChart>` 纯函数。

**候选文件**:
1. `xuan-qizhengsiyu/lib/domain/usecases/calculate_qizheng_base_panel_usecase.dart` — 当前计算入口，需抽取核心逻辑
2. `xuan-qizhengsiyu/lib/domain/services/generate_base_panel_service.dart` — `GenerateBasePanelService.calculate()`，async 链需同步化或管线设计调整
3. `xuan-qizhengsiyu/lib/domain/entities/models/observer_position.dart` — `ObserverPosition` 需包装为 `QizhengParams` (或直接使用 `ResolvedMoment`)
4. `xuan-qizhengsiyu/lib/domain/entities/models/base_panel_model.dart` — `BasePanelModel` 需演进为 `QizhengChart implements Chart`
5. `xuan-qizhengsiyu/lib/domain/entities/models/panel_config.dart` — `BasePanelConfig` 作为 `QizhengParams` 字段

**阻点**: `GenerateBasePanelService.calculate()` 是 async (shenSha/huaYao manager await)，与 `ChartCalculator.calculate` (同步) 冲突。需要 Claude Code 裁决：可同步化 vs 管线设计调整。

### M3 — 接入公共管线 (ChartRequest)

**目标**: 输入改走 `ChartRequest`，删除模块自建的真太阳时计算。

**候选文件**:
1. `xuan-qizhengsiyu/lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` — `_generateLifeObserverPosition` (line 205-253) 构建 `ObserverPosition`，需改为构造 `ChartRequest`
2. `xuan-qizhengsiyu/lib/domain/entities/models/observer_position.dart` — `ObserverPosition` 需替换为 `DivinationMoment` + `ResolvedMoment`
3. `xuan-qizhengsiyu/lib/domain/usecases/compute_rise_set_usecase.dart` — 移除 `SolarTimeCalculator` 调用 (line 30)
4. `xuan-qizhengsiyu/lib/domain/usecases/build_qizheng_timeline_usecase.dart` — 移除 `SolarTimeCalculator` 调用 (line 130)
5. `xuan-qizhengsiyu/lib/presentation/models/lunar_date_info_v2_data.dart` — `chineseDateInfo`/`dateTime` getter 切换 `EnumDatetimeType`，需对接 `ResolvedMoment`

**阻点**: 无公共 `MomentResolver` 实现 (M3 blocker)。

### M4 — 改编编解码 (Contract → Chart)

**目标**: `QiZhengSiYuPanContract` 实现 `Chart`，codec 正确填公共列。

**候选文件**:
1. `repository-interface-qizhengsiyu/lib/src/contracts/qizhengsiyu_pan_contract.dart` — 实现 `Chart` 接口 (AMENDMENT-1: `@freezed ... implements Chart`)
2. `xuan-storage/drift/lib/qizhengsiyu/qizheng_record_codec.dart` — 修复 `occurredAtUtc` 解析，填 `reckoningType`/`timezoneStr`/经纬度/`spacetimeJson`
3. `xuan-qizhengsiyu/lib/domain/entities/models/pan_entity.dart` — `toContract()`/`fromContract()` 适配 Chart 接口
4. `xuan-qizhengsiyu/pubspec.yaml` — 补 `repository_interface_divination_pipeline` 依赖 (当前未依赖)

**阻点**: `repository-interface-qizhengsiyu` 的 pubspec 不在 SCOPE.WRITE，需要额外批准。

---

## 9. 编码前停手条件

以下条件任一触发，必须停下并上报，不得擅自编码:

1. **无公共 `MomentResolver` 实现** — `repository-interface-divination-pipeline/lib/src/ports.dart:7` 声明了 `abstract interface class MomentResolver`，但全工作区没有任何 `implements MomentResolver` 的实现类。M3 无法接管线。

2. **`GenerateBasePanelService.calculate` 是 async** — `generate_base_panel_service.dart` 中 `calculate()` 返回 `Future<BasePanelModel>`，`shenShaManager` 和 `huaYaoManager` 均为 `await`。与 `ChartCalculator.calculate` (同步纯函数) 存在签名冲突。需要 Claude Code 裁决：可同步化 vs 管线设计调整。

3. **`QiZhengSiYuPanContract` 未实现 `Chart`** — M2 的 `ChartCalculator<QizhengParams, QiZhengSiYuPanContract>` 依赖泛型上界 `C extends Chart`，但 `QiZhengSiYuPanContract` 当前未实现 `Chart`。M4 必须先行或拆出 contract-Chart prep。

4. **`xuan-qizhengsiyu/pubspec.yaml` 未依赖 `repository_interface_divination_pipeline`** — M2/M3 需要 import `ModuleParams`/`ChartCalculator`/`ResolvedMoment`/`DivinationMoment` 等类型，但 pubspec 未声明该依赖 (仅有 `repository_interface_qizhengsiyu`)。

5. **12 个 pre-existing 测试失败** — AGENTS.md 声明存在 12 个预存失败。执行 `flutter test` 时必须区分 pre-existing 与新失败，不能归咎于迁移。

6. **双胞胎 Chart 实现风险** — M2 新建 `QizhengChart implements Chart` 与 M4 让 `QiZhengSiYuPanContract implements Chart` 可能产生两个 Chart 实现。需要 Claude Code 明确二者关系 (合一 / 转换函数 / M4 收敛删除 QizhengChart)。

7. **`DateTime.tryParse` bug 验证** — `QiZhengRecordCodec.encode()` line 39 使用 `DateTime.tryParse(c.divinationDatetimeJson)`，但 `c.divinationDatetimeJson` 是 JSON 对象字符串 (如 `{"uuid":"dt-1",...}`)，而非 ISO 8601 日期字符串。`DateTime.tryParse` 将返回 `null`，导致 `occurredAtUtc` 永远为空。M4 必须以真实 `DivinationDatetimeModel` 解析为准。

---

## FACTS_TO_VERIFY 逐条核实

### FACT 1: `QiZhengSiYuPanContract` 存储 divinationDatetimeJson/panelConfigJson/panelModelJson 作为字符串

**核实**: ✅ 确认。`qizhengsiyu_pan_contract.dart:12-14` 声明三个 `String` 字段。`pan_entity.dart:61-63` 通过 `jsonEncode()` 填充。

### FACT 2: `QiZhengSiYuPanEntity.toContract` 当前 jsonEncodes `DivinationDatetimeModel`

**核实**: ✅ 确认。`pan_entity.dart:61`: `divinationDatetimeJson: jsonEncode(divinationDatetimeModel.toJson())`。

### FACT 3: `QiZhengRecordCodec` 使用 `DateTime.tryParse(c.divinationDatetimeJson)` 解析 occurredAtUtc，验证是否适用于实际 JSON 形状

**核实**: ✅ 确认为 BUG。`qizheng_record_codec.dart:39`: `occurredAtUtc: DateTime.tryParse(c.divinationDatetimeJson)`。

`c.divinationDatetimeJson` 是 `jsonEncode(divinationDatetimeModel.toJson())` 的结果，形如 `{"uuid":"dt-1","datetime":"1990-01-01T12:00:00.000",...}` — 这是一个 JSON 对象字符串，**不是** ISO 8601 日期字符串。

`DateTime.tryParse` 期望 ISO 8601 格式 (如 `1990-01-01T12:00:00.000`)，传入 JSON 对象字符串将返回 `null`。

**验证依据**:
- `pan_entity.dart:61`: `divinationDatetimeJson: jsonEncode(divinationDatetimeModel.toJson())`
- `divination_datetime.dart:372`: `Map<String, dynamic> toJson() => _$DivinationDatetimeModelToJson(this)` (json_annotation 生成)
- `qizheng_record_codec.dart:39`: `occurredAtUtc: DateTime.tryParse(c.divinationDatetimeJson)`
- `save_calculated_panel_usecase_test.dart:78-102`: 测试 fixture 证实 JSON 形状为对象而非日期字符串

**结论**: `occurredAtUtc` 永远为 `null`。M4 必须从 `DivinationDatetimeModel.datetime` 提取并正确填充。

### FACT 4: `qi_zheng_si_yu_viewmodel` 切换 `EnumDatetimeType` 并映射 politicalCenter 到 province 坐标

**核实**: ✅ 确认。`qi_zheng_si_yu_viewmodel.dart:216-238`:

```dart
switch (datetimeModel.observer.type) {
  case EnumDatetimeType.standard:
  case EnumDatetimeType.removeDST:
    coordinates = datetimeModel.observer.location!.address!.province.coordinates;
    break;
  case EnumDatetimeType.politicalCenter:
    coordinates = datetimeModel.observer.location!.address!.province.coordinates;
    break;
  case EnumDatetimeType.meanSolar:
    coordinates = datetimeModel.observer.location!.address!.city?.coordinates ??
        datetimeModel.observer.location!.address!.province.coordinates;
    break;
  case EnumDatetimeType.trueSolar:
    if (datetimeModel.observer.isManualCalibration) {
      coordinates = datetimeModel.observer.location!.preciseCoordinates!;
    } else {
      coordinates = datetimeModel.observer.location!.coordinates!;
    }
    break;
}
```

`politicalCenter` 档当前映射到 `province.coordinates`，与 `standard`/`removeDST` 相同。

### FACT 5: `BuildQiZhengTimelineUseCase` 和 `ComputeRiseSetUseCase` 调用 `SolarTimeCalculator`，分类是否为面输入口径还是辅助显示/日升计算

**核实**: ✅ 确认为**辅助显示**，非排盘口径入口。

- `build_qizheng_timeline_usecase.dart:130-133`: `SolarTimeCalculator(dateTime: observer.utcDateTime, longitude: observer.longitude).getTrueSolarTime()` — 用于 `RiseSetDisplayData.trueSolarTime` 字段，**显示用途**。
- `compute_rise_set_usecase.dart:30-33`: 同上，`SolarTimeCalculator` 用于 `RiseSetDisplayData.trueSolarTime` — **显示用途**。

**分类**: 二者均为**辅助显示/日升计算**，不是面输入口径。面输入口径通过 `ObserverPosition` 传入的预计算四柱，直接使用 `CalculationEngineFactory` 计算星体位置。`SolarTimeCalculator` 不在排盘计算链中。

### FACT 6: `SaveCalculatedPanelUseCase` 使用 `DateTime.now()` 用于 createdAt/lastUpdatedAt，分类为持久化时间戳，非盘面计算

**核实**: ✅ 确认。`save_calculated_panel_usecase.dart:29`: `final now = DateTime.now();` 用于 `createdAt` 和 `lastUpdatedAt`。`save_calculated_panel_usecase.dart:57`: `final now = DateTime.now();` 用于 `lastUpdatedAt` (update)。

**分类**: 持久化时间戳，**非盘面计算**。盘面计算通过 `ObserverPosition` 传入的 `dateTime` 完成。

### FACT 7: 识别所有活跃测试作为 M2-M4 的特征测试

**核实**: ✅ 参见 §7 的候选列表:

| 迁移阶段 | 候选测试 | 理由 |
|---|---|---|
| M2 | `calculate_qizheng_base_panel_usecase_test.dart` | 盘面计算特征，验证 ChartCalculator 输出一致 |
| M2 | `build_qizheng_timeline_usecase_test.dart` | 时间线计算特征 |
| M3 | `qi_zheng_si_yu_viewmodel_characterization_test.dart` | Viewmodel 特征，验证 ChartRequest 构造后行为不变 |
| M3 | `qi_zheng_si_yu_viewmodel_equivalence_test.dart` | Viewmodel 等价性 |
| M4 | `qizhengsiyu_record_codec_test.dart` (xuan-storage) | Codec round-trip，需补充真实 `divinationDatetimeJson` fixture |
| M4 | `save_calculated_panel_usecase_test.dart` | 保存流程，验证实体→Contract→Codec 链路 |

---

## 附录: 关键代码位置索引

| 符号 | 文件 | 行 |
|---|---|---|
| `QiZhengSiYuPanContract` | `repository-interface-qizhengsiyu/lib/src/contracts/qizhengsiyu_pan_contract.dart` | 6 |
| `QiZhengRecordCodec` | `xuan-storage/drift/lib/qizhengsiyu/qizheng_record_codec.dart` | 5 |
| `DateTime.tryParse` (bug) | `xuan-storage/drift/lib/qizhengsiyu/qizheng_record_codec.dart` | 39 |
| `QiZhengSiYuPanEntity.toContract` | `xuan-qizhengsiyu/lib/domain/entities/models/pan_entity.dart` | 54 |
| `EnumDatetimeType` | `xuan-metaphysics-core/lib/models/divination_datetime.dart` | 33 |
| `ObserverDataModel` | `xuan-metaphysics-core/lib/datamodel/observer_datamodel.dart` | 9 |
| `DivinationDatetimeModel` | `xuan-metaphysics-core/lib/models/divination_datetime.dart` | 51 |
| `SolarTimeCalculator` (viewmodel) | `xuan-qizhengsiyu/lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` | 216-238 |
| `SolarTimeCalculator` (timeline) | `xuan-qizhengsiyu/lib/domain/usecases/build_qizheng_timeline_usecase.dart` | 130 |
| `SolarTimeCalculator` (rise-set) | `xuan-qizhengsiyu/lib/domain/usecases/compute_rise_set_usecase.dart` | 30 |
| `DateTime.now()` (save) | `xuan-qizhengsiyu/lib/domain/usecases/save_calculated_panel_usecase.dart` | 29, 57 |
| `DateTime.now()` (viewmodel) | `xuan-qizhengsiyu/lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` | 653 |
| `CalculateQiZhengBasePanelUseCase` | `xuan-qizhengsiyu/lib/domain/usecases/calculate_qizheng_base_panel_usecase.dart` | 25 |
| `GenerateBasePanelService.calculate` | `xuan-qizhengsiyu/lib/domain/services/generate_base_panel_service.dart` | (async) |
| `ObserverPosition` | `xuan-qizhengsiyu/lib/domain/entities/models/observer_position.dart` | 28 |
| `RecordMeta` | `repository-interface-record/lib/src/models/record_meta.dart` | 3 |
| `RecordModuleCodec` | `repository-interface-record` (spike) | - |
| `ChartCalculator` (contract) | `repository-interface-divination-pipeline/lib/src/ports.dart` | 47 |
| `DivinationMoment` (contract) | `repository-interface-divination-pipeline/lib/src/moment.dart` | 23 |
| `ResolvedMoment` (contract) | `repository-interface-divination-pipeline/lib/src/resolved.dart` | 28 |
| `Chart` (contract) | `repository-interface-divination-pipeline/lib/src/chart.dart` | 23 |
| `ModuleParams` (contract) | `repository-interface-divination-pipeline/lib/src/chart.dart` | 12 |
| `MomentResolver` (contract) | `repository-interface-divination-pipeline/lib/src/ports.dart` | 7 |
| `QiZhengModuleRegistry` | `xuan-storage/drift/lib/qizhengsiyu/qizheng_module_registry.dart` | 8 |
| `RecordBackedQiZhengRepository` | `xuan-storage/drift/lib/qizhengsiyu/record_backed_qizheng_repository.dart` | 4 |
| `LunarDateInfoV2Data` | `xuan-qizhengsiyu/lib/presentation/models/lunar_date_info_v2_data.dart` | 11 |
| `DateTimeDetailsBundleLogicModel` | `xuan-metaphysics-core/lib/models/datetime_details_bundle_logic_model.dart` | - |

---

## 结论与建议

### proceed to M2 或 stop for Claude Code clarification?

**建议: STOP for Claude Code clarification**。

理由:

1. **M2 纯函数冲突**: `GenerateBasePanelService.calculate()` 是 async，`shenShaManager`/`huaYaoManager` 均为 `await`，与 `ChartCalculator.calculate` (同步纯函数) 存在签名冲突。需要 Claude Code 裁决: 可同步化 vs 管线设计调整。

2. **M3 MomentResolver 缺失**: 全工作区没有 `MomentResolver` 实现 (仅有契约声明)。M3 无法接管线。

3. **M4 Contract-Chart 前置**: `QiZhengSiYuPanContract` 未实现 `Chart`，M2 的 `ChartCalculator<QizhengParams, QiZhengSiYuPanContract>` 依赖泛型上界 `C extends Chart`。需要 Claude Code 明确: contract-Chart 先行 vs 拆出 prep。

4. **pubspec 依赖缺失**: `xuan-qizhengsiyu/pubspec.yaml` 未依赖 `repository_interface_divination_pipeline`，M2/M3 无法 import 管线类型。需要 Claude Code 批准 WRITE 范围扩展到 pubspec。

5. **双胞胎 Chart 风险**: M2 新建 `QizhengChart` 与 M4 让 `QiZhengSiYuPanContract implements Chart` 可能产生两个 Chart 实现。需要 Claude Code 明确二者关系。

6. **12 个 pre-existing 失败**: 需要在 M5 或后续 ACT 中执行 `flutter test` 并列出具体失败测试名，不能在 M1 调查中确定。

**M1 survey 已完成**，所有 9 个 SECTION 和 7 个 FACTS_TO_VERIFY 均已核实。建议 Claude Code 审核后裁决上述 6 个阻点，再生成 ACT02-ACT05。
