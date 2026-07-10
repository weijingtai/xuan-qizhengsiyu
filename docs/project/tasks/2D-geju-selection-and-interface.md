# 2-D d3 选型决策 + 接口定义：用户自建候选对齐点持久化

## 元信息

- 创建日期: 2026-07-09
- 文档类型: 选型决策 + 接口契约（Claude Code L3 决策产出）
- 所属阶段: 方向二 2-D d3（004 周天对齐点拖拽校准 · ③-乙 用户自建候选对齐点持久化存储）
- 决策依据: `docs/project/tasks/2D-geju-research-findings.md`（OpenCode 取数报告）
- 决策者: Claude Code
- 下游执行: OpenCode（按本文 §3 工单做最小实现）

---

## 1. 选型结论：Drift（以 `user_school_profile` 为直接模板）

**存储介质选 Drift SQLite，不选 JSON。**

### 决策理由（据取数报告，逐条挂证据）

1. **JSON 通道已废弃**。取数报告 Q1/Q3 证实：GeJu 的 JSON 文件（`user_rules.json`）只是旧格式遗留，`GeJuLegacyMigrator` 单向迁 Drift 后即归档为 `.migrated.bak`，**新数据一律走 Drift**。若候选对齐点新起一个 JSON 通道，等于逆着模块演进方向、复活一条已被判死的链路。
2. **`user_school_profile` 是现成同构模板**。取数报告 Q5 对比表显示：候选对齐点是「一条命名的轻量独立记录、无外键、需 create/list/delete」，`user_school_profile`（7 字段、独立记录、`upsert/listAll/softDelete`、`deletedAt` 软删、`user_<uuid>` 主键）在每一个维度上都最贴近——它就是「用户自建一条轻量记录」的既有落地范式，且是最新（schemaVersion 4，最后一张加进去的表）的写法。照它抄，风险最低。
3. **GeJu Rule 三实体级联不适用**。GeJu 规则那套（Rule + Annotation + ConditionSet 外键级联、DeletionRecords 审计）是为复杂规则设计的，候选对齐点用不上外键和审计，套过来是过度工程。取 `user_school_profile` 的扁平范式即可。
4. **Web 兼容白拿**。Drift 侧 `AppDatabase` 已配好 Web（`sqlite3.wasm`/`drift_worker.js`，取数报告 Q2.4），走 Drift 无需再为候选对齐点单独处理 Web 平台的文件 I/O stub（JSON 通道恰恰要 stub，见报告 Q3.2）。

### 与设计文档的一致性

设计文档第 6 节要求「沿用 GeJu 模块 `user_` 前缀自建数据的既有模式；Drift 表还是 JSON 留实施阶段按现有基础设施选型」。本决策落在「Drift + `user_<uuid>` 主键 + `Uuid().v4()`」，与既有基础设施完全对齐。

---

## 2. 接口契约（OpenCode 照此实现）

命名严格对齐取数报告 Q6 的既有约定：时间字段 `created_at`/`updated_at`（snake_case）、备注类 `_note` 后缀、序列化字段 `_json` 后缀、主键沿用 `user_school_profile` 的 `uuid` 风格（新表是轻量独立记录，与其同构，故取 `uuid` 而非 GeJu 的 `id`）。

### 2.1 Drift 表：`AlignmentPointCandidateTable`

新建文件 `lib/data/datasources/local/tables/alignment_point_candidate_table.dart`：

```dart
import 'package:drift/drift.dart';
import '../../../models/converters/constellation_degree_converter.dart';
import '../../../../domain/entities/models/naming_degree_pair.dart';

class AlignmentPointCandidateTable extends Table {
  @override
  String get tableName => 't_alignment_point_candidates';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get name => text().withLength(min: 1).named('name')(); // withLength 防空候选名(用户手输)
  // ConstellationDegree(宿+度数) 绝对值，序列化为 JSON 字符串
  TextColumn get alignmentPoint =>
      text().map(const ConstellationDegreeConverter()).named('alignment_point_json')();
  // 来源备注(自由文本，如"参照三辰通载/开禧历对比后手动校准")
  TextColumn get sourceNote => text().nullable().named('source_note')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  // ⚠ 命名对齐 user_school_profile 模板(lastUpdatedAt/last_updated_at)，非 GeJu 的 updatedAt——
  // 这样 DAO listAll 的 orderBy(t.lastUpdatedAt) 可原样照抄 user_school_profile_dao
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
```

字段对齐说明（对照取数报告 Q6）：
| 语义 | 本表字段 | 抄自 |
|---|---|---|
| 主键 | `uuid` | user_school_profile |
| 显示名称 | `name` | 三表一致 |
| 内容体(宿+度数) | `alignment_point_json` | `_json` 后缀约定 |
| 来源备注 | `source_note` | `_note` 后缀约定(disambiguation_note) |
| 创建时间 | `created_at` | 三表一致 |
| 更新时间 | `last_updated_at` | **user_school_profile**(非 GeJu，为让 DAO 可原样照抄) |
| 软删除 | `deleted_at` | user_school_profile |

### 2.2 TypeConverter：`ConstellationDegreeConverter`

新建文件 `lib/data/models/converters/constellation_degree_converter.dart`（照抄 `panel_config_converter.dart` 模板，**用相对 import 与该模板一致**；`ConstellationDegree` 已有 `toJson`/`fromJson`，见 `naming_degree_pair.dart:18-21`）：

> 序列化往返已验证安全：`Enum28Constellations` 经生成的 `_$Enum28ConstellationsEnumMap` 双向映射到**中文单字**（如 `娄`/`虚`/`奎`），`degree` 是 `double`（`(num).toDouble()`），对 1.6275°/9.75° 级精度充足。只要枚举值不删改，往返无损。

```dart
import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../domain/entities/models/naming_degree_pair.dart';

class ConstellationDegreeConverter extends TypeConverter<ConstellationDegree, String> {
  const ConstellationDegreeConverter();

  @override
  ConstellationDegree fromSql(String fromDb) {
    return ConstellationDegree.fromJson(jsonDecode(fromDb));
  }

  @override
  String toSql(ConstellationDegree value) {
    return jsonEncode(value.toJson());
  }
}
```

### 2.3 DAO：`AlignmentPointCandidateDao`

新建文件 `lib/data/datasources/local/daos/alignment_point_candidate_dao.dart`（形状照抄 `user_school_profile_dao.dart`，CRUD 取候选场景需要的 create/list/delete；create 用独立方法而非 upsert，因为候选是「标定一个新点」语义，不覆盖同名）：

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/alignment_point_candidate_table.dart';
import '../../../../domain/entities/models/naming_degree_pair.dart';

part 'alignment_point_candidate_dao.g.dart';

@DriftAccessor(tables: [AlignmentPointCandidateTable])
class AlignmentPointCandidateDao
    extends DatabaseAccessor<AppDatabase> with _$AlignmentPointCandidateDaoMixin {
  AlignmentPointCandidateDao(AppDatabase db) : super(db);

  /// 新建一条候选(uuid 由上层 service 以 'user_${Uuid().v4()}' 生成后传入)
  Future<void> insertCandidate({
    required String uuid,
    required String name,
    required ConstellationDegree alignmentPoint,
    String? sourceNote,
  });

  /// 列出未软删的候选，按 lastUpdatedAt 降序
  Future<List<AlignmentPointCandidateTableData>> listAll();

  /// 软删除(设 deletedAt = now())
  Future<void> softDelete(String uuid);
}
```

> DAO 方法体实现照 `user_school_profile_dao.dart` 的 `upsert`/`listAll`/`softDelete` 三方法写法可**原样照抄**（构造函数 `AlignmentPointCandidateDao(AppDatabase db) : super(db);` 与模板 dao:11 一致，模板并无 `this.db` 字段声明；`(select(...)..where((t)=>t.deletedAt.isNull())..orderBy([(t)=>OrderingTerm.desc(t.lastUpdatedAt)])).get()`；`(update(...)..where((t)=>t.uuid.equals(uuid))).write(Companion(deletedAt: Value(DateTime.now())))`）。insert 用 `into(alignmentPointCandidateTable).insert(Companion(...))`，`createdAt`/`lastUpdatedAt` 均写入 `DateTime.now()`。

### 2.4 上层 Service（可选，本轮最小实现可暂缓）

对齐 `UserSchoolProfileService` 范式，`user_` 前缀 UUID 在 service 层生成：

```dart
class AlignmentPointCandidateService {
  Future<String> saveCandidate({
    required String name,
    required ConstellationDegree alignmentPoint,
    String? sourceNote,
  });  // uuid = 'user_${const Uuid().v4()}'，返回 uuid
  Future<List<AlignmentPointCandidateTableData>> listAll();
  Future<void> delete(String uuid);  // soft delete
}
```

---

## 3. 给 OpenCode 的实现工单（最小实现）

> 严格按取数报告 Q2.3「新增一张 Drift 表的操作清单」执行，一步不落：

1. **建表类**：`lib/data/datasources/local/tables/alignment_point_candidate_table.dart`（§2.1）
2. **建 Converter**：`lib/data/models/converters/constellation_degree_converter.dart`（§2.2）
3. **建 DAO**：`lib/data/datasources/local/daos/alignment_point_candidate_dao.dart`（§2.3）
4. **注册进 `app_database.dart`**：
   - 顶部补两条 import（与文件现有 `package:qizhengsiyu/...` 风格一致）：
     ```dart
     import 'package:qizhengsiyu/data/datasources/local/tables/alignment_point_candidate_table.dart';
     import 'package:qizhengsiyu/data/datasources/local/daos/alignment_point_candidate_dao.dart';
     ```
   - `@DriftDatabase(tables: [...])` 追加 `AlignmentPointCandidateTable`
   - `daos: [...]` 追加 `AlignmentPointCandidateDao`
5. **迁移**（关键，照 Q2.3）：
   - `MigrationStrategy.onUpgrade` 增 `if (from < 5) { await m.createTable(alignmentPointCandidateTable); }`（`alignmentPointCandidateTable` getter 由 build_runner 在步骤 6 生成，编辑器此时红线正常，步骤 6 后消除）
   - **bump `schemaVersion` 4 → 5**
   - onCreate 路径无需动：现有 `m.createAll()` 会自动含新注册的表（已验证）
6. **跑代码生成**：`dart run build_runner build --delete-conflicting-outputs`（同时生成 `alignment_point_candidate_dao.g.dart` 与更新 `app_database.g.dart`）
7. **（可选）建 Service**：§2.4，最小实现可只做 DAO，Service 留 2-E 接线时补
8. **最小验证**：写一个 DAO 往返测试（insert → listAll 拿回同一条、`ConstellationDegree` 值不丢；softDelete 后 listAll 不含该条），跑 `flutter analyze`（0 error）+ 该测试绿

### 红线（照 SOP 合格标准延伸）

- **不碰 GeJu 既有表/DAO/迁移**，只新增，不改存量。
- **schemaVersion 必须 bump 到 5**，且 `onUpgrade` 的 `if (from < 5)` 分支到位——漏了会导致老用户升级时新表不创建，运行时崩。
- **`.g.dart` 不手改**，只跑 build_runner。

---

## 4. 决定记录（供回填任务纪要「方向二决定记录」）

| 决定 | 内容 | 来源 |
|---|---|---|
| ✅ 候选对齐点存储选 Drift，不选 JSON | GeJu 的 JSON 通道已废弃(单向迁 Drift 后归档)，新数据一律走 Drift；Drift 侧 Web 兼容已配好，无需为候选点单独 stub | 2D-findings Q1/Q3/Q2.4 |
| ✅ 以 `user_school_profile` 为直接模板，不套 GeJu Rule 三实体级联 | 候选点是「一条命名轻量独立记录、无外键、create/list/delete」，与 user_school_profile 同构；GeJu Rule 的外键级联+审计是过度工程 | 2D-findings Q5 对比表 |
| ✅ 表名 `t_alignment_point_candidates`，字段 `uuid`/`name`/`alignment_point_json`/`source_note`/`created_at`/`updated_at`/`deleted_at` | 命名严格对齐 Q6 既有约定(_json/_note 后缀、snake_case 时间、uuid 主键随 user_school_profile) | 2D-findings Q6 |
| ✅ `ConstellationDegree` 经 TypeConverter 存 JSON 列 | ConstellationDegree 已有 toJson/fromJson，照抄 PanelConfigConverter 模板即可 | naming_degree_pair.dart:18-21 |
| ✅ schemaVersion 4→5，onUpgrade 加 `if (from < 5)` | 照 Q2.3 新增表操作清单 | 2D-findings Q2.3 |

---

## 5. 审查修订记录（2026-07-09，两角色交叉验证）

启用 spec-task-executor（执行者视角）+ code-review-expert（代码正确性视角）两角色对本文档交叉审查，逐条裁定：

### 已采纳修正（真问题）

| # | 问题 | 修正 | 证据 |
|---|---|---|---|
| R1 | 时间字段用了 `updatedAt`/`updated_at`(GeJu 风格)，但模板 `user_school_profile_dao.dart:37` 的 listAll 排序用 `t.lastUpdatedAt`，OpenCode 照抄 DAO 会编译失败 | 改为 `lastUpdatedAt`/`last_updated_at`，与模板完全对齐，DAO 可原样照抄 | user_school_profile_dao.dart:37 亲验 |
| R2 | `name` 无长度约束，允许空候选名(用户手输场景更易触发) | 加 `.withLength(min: 1)` | code-review 问题2 |
| R3 | 枚举序列化描述缺失/工单未写清 | 补注：`Enum28Constellations` 经 `_$Enum28ConstellationsEnumMap` 映射到**中文单字**(娄/虚/奎)，往返无损 | naming_degree_pair.g.dart 亲验 EnumMap |
| R4 | §3 缺显式 import 语句、onCreate 是否漏建表未说明 | 补两条 package import + 注明 `createAll()` 自动含新表 | app_database.dart:72 亲验 |

### 已驳回（执行者报告的假阳性，亲自读码证伪）

| # | 执行者声称 | 证伪 |
|---|---|---|
| F1【假阻塞】 | DAO 构造函数模板是 `UserSchoolProfileDao(this.db)` + `final AppDatabase db`，工单漏了=阻塞 | **模板真身是 `UserSchoolProfileDao(AppDatabase db) : super(db);`(dao:11)，并无 this.db 字段**。工单原样正确 |
| F2【假警告】 | converter 模板用 package import | **模板 `panel_config_converter.dart:4` 用相对 import**。工单原样正确 |
| F3【假事实】 | 枚举序列化成英文名('jiao'/'stomach') | **实为中文单字**(见 R3)。执行者自报 0 次工具调用，未读生成码 |

> 教训入墓：执行者角色(spec-task-executor)本轮 0 工具调用、3 处对模板的断言全错，其「阻塞」判定不可直接采信；code-review-expert 19 次工具调用、结论经亲验全部属实。**跨角色审查结论必须回到源码核实，工具调用数是可信度的强信号。**

### 已知技术债（登记，不阻断本轮）

- 候选表纯软删(`deleted_at`)、无硬删/过期清理，与 `user_school_profile` 模板一致。低频场景(几十条)无碍；后续可按需加「硬删或清理软删超 N 天记录」。
