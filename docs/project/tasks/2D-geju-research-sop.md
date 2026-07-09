# 2-D 调研 SOP：GeJu 模块 `user_` 前缀自建数据现状

## 元信息

- 创建日期: 2026-07-09
- 文档类型: 调研 SOP（给执行 Agent 的取数指令，非结论文档）
- 所属阶段: 方向二 2-D（004 周天对齐点拖拽校准 · ③-乙 用户自建候选对齐点持久化存储）
- 上游依据:
  - `docs/project/tasks/003-004-sanchen-zhoutian-task.md` 「方向二 2-D」阶段（行 105）
  - `docs/superpowers/specs/2026-07-08-zhoutian-alignment-drag-calibration-design.md` 第 6 节（数据模型改动）
- SOP 作者: Claude Code（**未亲自读 GeJu 代码**，只据已知目录结构给出精确搜索起点）
- 执行者: OpenCode（按本 SOP 取数，回交报告）
- 产出落盘: `docs/project/tasks/2D-geju-research-findings.md`

---

## 0. 为什么调研（一句话背景）

2-D 要新增一张**「用户自建候选对齐点」轻量存储**，字段是：候选名称 / `ConstellationDegree`（宿+度数）/ 创建时间 / 来源备注（自由文本）。设计文档第 6 节要求：**沿用 GeJu 模块 `user_` 前缀自建数据的既有落地模式**，但「用 Drift 表还是 JSON 文件」这个选型，必须先把 GeJu 现状摸清楚才能定。本 SOP 就是让你把现状取回来，**你不做选型判断**——选型是 Claude Code 拿到你的报告后的活。

**你的唯一目标**：把 GeJu「用户自建数据」这条链路（存储介质、表结构/文件格式、CRUD 接口签名、命名约定、迁移机制、Web 兼容处理）如实抄回报告，每一条都带**文件路径 + 行号 + 代码摘录**。不做取舍、不做推荐、不美化。

---

## 1. 去哪些目录 / 文件找（精确搜索起点）

> 下列路径均相对 worktree 根目录 `.worktrees/opencode-004-drag-calibration-tool/`。**先从「精确起点」逐个打开读，再用「兜底搜索」补漏**，两步都要做，别只跑 grep 就交差。

### 1.1 精确起点（必读，逐个打开）

**Drift 一侧（数据库存储）：**
- `lib/data/datasources/local/app_database.dart` — Drift 主数据库定义（`@DriftDatabase`、注册了哪些表和 DAO、`schemaVersion`、`onUpgrade` 迁移逻辑）
- `lib/data/datasources/local/tables/ge_ju_tables.dart` — GeJu 相关 Drift 表结构定义（列、主键、约束）
- `lib/data/datasources/local/daos/ge_ju_dao.dart` — GeJu 的 DAO（CRUD 方法签名就在这里）
- `lib/data/datasources/local/ge_ju_sqlite_data_source.dart` — GeJu 走 SQLite/Drift 的数据源
- `lib/data/datasources/local/database_provider.dart` — 数据库连接/单例的装配方式

**JSON 文件一侧（文件存储 + 旧格式迁移）：**
- `lib/data/datasources/local/ge_ju_file_storage_io.dart` 及其配套 `ge_ju_file_storage_stub.dart` — GeJu 的 JSON 文件读写（文件路径模式、读写接口）
- `lib/data/datasources/local/ge_ju_legacy_migrator.dart` + `ge_ju_legacy_migrator_io.dart` + `ge_ju_legacy_migrator_stub.dart` — 旧 `user_rules.json` → Drift 的迁移器（旧 JSON 长什么样、user_ 前缀怎么处理）
- `lib/data/datasources/local/ge_ju_local_data_source.dart` — GeJu 本地数据源门面（是否在 Drift / JSON 之间做分流）

**上层封装（CRUD 契约的完整形状）：**
- `lib/data/repositories/`（找 `ge_ju` 相关 repository 实现）
- `lib/domain/repositories/`（对应的 repository 接口，如 `IGeJuRepository`）
- `lib/domain/services/`（找 `GeJuCrudService` 或同类，用户规则的增删改查、import/export、`user_` UUID 生成在这一层）

**第二参照样本（重点，和候选对齐点场景最像）：**
- `lib/data/datasources/local/tables/user_school_profile_table.dart`
- `lib/data/datasources/local/daos/user_school_profile_dao.dart`
- 理由：`user_school_profile` 是「用户自建的一条轻量记录」，形态比 GeJu 规则更接近 2-D 要建的「候选对齐点」（一条命名记录 + 少量字段）。把它的表结构和 DAO 签名也抄回来，作为选型的第二个对照锚。

### 1.2 兜底搜索（补漏，命令照跑）

```bash
cd .worktrees/opencode-004-drag-calibration-tool

# 1) user_ 前缀相关：UUID 生成、user_rules.json、user_ 命名约定
grep -rn "user_" lib/ --include='*.dart' | grep -iv '\.g\.dart' | grep -iE "user_rules|user_school|'user_|\"user_|userId|isUserCreated|isBuiltIn"

# 2) 所有 Drift 表定义（谁继承 Table）
grep -rn "extends Table" lib/data --include='*.dart'

# 3) 所有 DAO 与其 CRUD 方法
grep -rn -A3 "@DriftAccessor\|class .*Dao" lib/data --include='*.dart' | grep -iv '\.g\.dart'

# 4) JSON 文件存储：路径拼接、读写、序列化
grep -rn "getApplicationDocumentsDirectory\|File(\|writeAsString\|readAsString\|jsonEncode\|jsonDecode\|path.join" lib/data --include='*.dart' | grep -iv '\.g\.dart'

# 5) schemaVersion 与迁移
grep -rn "schemaVersion\|onUpgrade\|MigrationStrategy" lib/data --include='*.dart' | grep -iv '\.g\.dart'
```

> **注意**：`*.g.dart` 是 build_runner 生成物，**不是权威来源**，只在需要确认生成结果时参考；表/DAO/迁移的「事实」以手写的 `.dart` 源文件为准。

---

## 2. 要回答的问题（逐条作答，缺一不可）

### Q1 存储介质：Drift 还是 JSON？（还是两者并存？）
- GeJu 的**用户自建**数据当前实际落在哪里？Drift SQLite 表、JSON 文件、还是两条链路并存（例如 JSON 是旧格式、Drift 是现行）？
- 给出**判定依据的代码位置**（哪个文件哪几行表明它是 Drift / JSON）。

### Q2-Drift（若走 Drift，必答）
- **表结构**：GeJu 用户数据表叫什么？逐列列出（列名、类型、是否主键、是否可空、默认值、约束）。
- **DAO 接口形状**：DAO 类名 + 全部 CRUD 方法签名（方法名、参数类型、返回类型，含 `Future`/`Stream`）。
- **迁移机制**：`schemaVersion` 当前值；`onUpgrade`/`MigrationStrategy` 怎么写的；新增一张表要动哪里（照 MEMORY.md「加 Drift 表要 bump schemaVersion + onUpgrade」的既有规矩，看它实际怎么落地）。
- **单例/连接装配**：`AppDatabase` 是不是单例（MEMORY.md 提到 `factory AppDatabase()` 返回共享实例），连接在哪里创建、Web 平台怎么处理（`sqlite3.wasm` / `drift_worker.js`）。

### Q3-JSON（若走 JSON，必答）
- **文件路径模式**：文件存哪、文件名怎么拼（是否含 `user_` 前缀、UUID、时间戳）、用什么 API 定位目录。
- **读写接口**：读/写/删的函数签名，序列化方式（`jsonEncode`/`fromJson`/`toJson`）。
- **命名约定**：`user_` 前缀 UUID 怎么生成、内置数据与用户数据怎么区分、并存时怎么 merge。

### Q4 CRUD 接口签名（无论 Drift/JSON 都要答）
- 从**上层门面**（repository / service 层）看，用户自建一条记录的**增删改查 + import/export** 对外签名长什么样？
- 把 `IGeJuRepository`（或等价接口）与其实现类、`GeJuCrudService`（或同类）的相关方法签名整段抄回来。

### Q5 `user_school_profile` 对照（第二参照样本）
- `user_school_profile` 走 Drift 还是别的？表结构 + DAO 签名整段抄回。
- 它和 GeJu 用户数据在「一条轻量命名记录」这件事上，哪个更接近 2-D 的候选对齐点场景？**只描述事实差异，不下选型结论。**

### Q6 命名字段约定（供 2-D 表结构对齐）
- 现有自建表/文件里，「主键 id」「创建时间」「来源/备注」「显示名称」这几类字段分别叫什么、什么类型？（2-D 新表要跟这套命名对齐，避免又造一套。）

---

## 3. 合格标准（验收线，达不到即返工）

**合格：**
1. Q1–Q6 **每一条**都作答，没有「大概」「应该是」——不确定就写「未找到，已搜索范围：<列出跑过的 grep 与打开过的文件>」。
2. **每条结论都挂证据**：`文件相对路径:行号` + 该处 **原样代码摘录**（3–20 行，够看清结构即可，别整文件贴）。表结构、DAO 方法签名、迁移策略必须是**直接摘录**，不是你的转述。
3. Drift / JSON 的**判定**有代码为凭（指出是哪一行让你判定它是 Drift 或 JSON），不是凭文件名猜。
4. `user_school_profile` 参照样本已取，表结构 + DAO 签名到位。
5. 结尾附一张「字段命名对照小结」表（Q6），列出现有自建记录里 id/时间/名称/备注类字段的实际叫法，供 2-D 直接复用。

**不合格（返工项）：**
- 只给结论不给文件路径 / 行号 / 代码摘录。
- 用 `*.g.dart` 生成物当权威来源下结论。
- 把 SOP 的问题跳答、合并答、含糊答（如「用的是 Drift」但不给表结构和 DAO 签名）。
- 自己做了 Drift vs JSON 的**选型推荐**——这**不是你的活**，越权即返工；你只报现状。
- 「没找到」但没列出实际搜索过哪些目录/命令（无法判断是真没有还是没搜到）。

---

## 4. 产出格式与落盘

把报告写到 `docs/project/tasks/2D-geju-research-findings.md`，建议结构：

```
# 2-D 取数报告：GeJu 用户自建数据现状

## 一句话结论
GeJu 用户自建数据落在 <Drift / JSON / 并存>，判定依据：<文件:行>

## Q1 存储介质
（结论 + 文件:行 + 代码摘录）

## Q2 Drift 现状（表结构 / DAO 签名 / 迁移 / 单例 · 若适用）
## Q3 JSON 现状（路径 / 读写 / 命名 · 若适用）
## Q4 上层 CRUD 接口签名（repository + service）
## Q5 user_school_profile 参照样本
## Q6 字段命名对照小结（表格）

## 搜索足迹
（列出实际打开的文件 + 跑过的 grep 命令，证明覆盖面）

## 未决 / 未找到
（诚实标注，不凑数）
```

---

## 5. 收尾

- 取数完成后跑 `/wjt-handoff`，把 2-D 取数进度写进任务纪要。
- **不要**改任何 GeJu 代码、不要新建候选对齐点表——本阶段只读不写；建表是 Claude Code 选型定接口后的下一步。
