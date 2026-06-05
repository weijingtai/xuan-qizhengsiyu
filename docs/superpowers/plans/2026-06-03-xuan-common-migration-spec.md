# OpenSpec: `xuan_common` 依赖彻底清除与架构重组规范

**文档编号:** SPEC-MIGRATION-2024-001  
**状态:** 评审中 (DRAFT)  
**作者:** Gemini CLI (Orchestrator Mode)  
**日期:** 2026-06-03
**目标:** 100% 消除 `package:xuan_common` 依赖，实现模块纯净化。

---

## 1. 战略意图 (Strategic Intent)

### 1.1 背景与现状
`xuan_common` 目前是一个典型的“大泥球 (Big Ball of Mud)”依赖，它混合了：
*   **元物理核心逻辑** (如 `YearMonth`, `ShenSha`)
*   **持久层能力** (如 `AppDatabase`, `WorldInfo`)
*   **通用 UI 组件** (如 `LunarDateInfoCard`)
*   **开发工具** (如 `Logger`)

这种耦合导致 `qizhengsiyu` 项目在多环境下（测试、Web、Worktree）维护成本极高，且容易产生循环依赖。

### 1.2 “10星级”迁移标准
*   **0 残留:** `pubspec.yaml` 中不再包含任何 `xuan_common` 关键字。
*   **二进制兼容:** 迁移后的计算结果（特别是星盘坐标、神煞推算）必须与迁移前 100% 一致（位对位一致）。
*   **零侵入性:** 外部调用接口不应因为内部依赖的变更而发生大规模重构。

---

## 2. 目标架构 (Target Architecture)

重组后的依赖拓扑应遵循以下分层逻辑：

1.  **元物理核心 (`metaphysics_core`)**: 唯一的真相来源 (Source of Truth)。所有天干、地支、日期转换、星体计算实体均归口于此。
2.  **存储核心 (`persistence_core`)**: 统一的持久化抽象。处理地理位置、时区数据库、用户偏好。
3.  **本地组件 (Local Widgets)**: 属于 `qizhengsiyu` 自身业务逻辑的 UI 组件（如 `LunarDateInfoCard`）直接本地化，减少跨包 UI 耦合。

---

## 3. 详细替换映射表 (Replacement Mapping)

执行 Agent 必须遵循以下精确映射关系，严禁自行发明新接口。

| 类别 | 原始路径 (xuan_common) | 目标路径 (metaphysics_core/persistence_core/Local) | 备注 |
| :--- | :--- | :--- | :--- |
| **元物理模型** | `models/year_month.dart` | `package:metaphysics_core/models/year_month.dart` | 需检查 `YearMonth.fromDateTime` 行为 |
| **日期时间** | `models/divination_datetime.dart` | `package:metaphysics_core/models/divination_datetime.dart` | 确保 `DivinationDateTime` 字段对齐 |
| **神煞系统** | `models/shen_sha.dart` | `package:metaphysics_core/models/shen_sha.dart` | 重点检查 `ShenShaBundled` 的初始化 |
| **数据库** | `database/app_database.dart` | `package:persistence_core/database/app_database.dart` | 检查 Drift 生成代码的 Table Name 兼容性 |
| **地理位置** | `datasource/geo_location_repository.dart` | `package:persistence_core/datasource/geo_location_repository.dart` | 确保 Binary 资源文件路径正确 |
| **UI 组件** | `widgets/lunar_date_info_card_v2.dart` | `lib/presentation/widgets/common/lunar_date_info_card.dart` | 源码拷贝并内部适配 |
| **日志** | `common_logger.dart` | `package:xuan_logger/xuan_logger.dart` | 已在项目中的 `xuan_logger` 代替 |

---

## 4. 关键实现原则 (Implementation Principles)

### 4.1 最小化重构原则
除非接口完全不兼容，否则不应修改现有业务逻辑文件的代码逻辑，仅通过修改 `import` 语句完成迁移。

### 4.2 TDD 强制验证
在修改任何 `lib/` 下的源文件前，必须先修复 `test/` 目录下对应的测试文件。如果测试文件无法通过新的依赖运行，说明迁移存在风险。

### 4.3 UI 本地化策略
针对 `LunarDateInfoCardV2`：
1.  **Extract**: 提取其及其关联的 `DivinationInfoModel` 到本地。
2.  **Decouple**: 移除其内部对 `xuan_common` 的引用，改为引用 `metaphysics_core`。

---

## 5. 边界情况与风险处理 (Edge Cases)

*   **字段缺失**: 如果 `metaphysics_core` 中的模型缺少 `xuan_common` 时代的某个字段，应在 `qizhengsiyu` 内部通过 `extension` 进行扩展，严禁随意修改 `metaphysics_core` 源码以防破坏其他项目。
*   **Drift 迁移**: `persistence_core` 可能使用的是更高版本的 `drift`。迁移时需同步运行 `build_runner`，并检查 `.g.dart` 文件是否产生冲突。
*   **Git Overrides**: 迁移完成后，必须确保 `pubspec.yaml` 中没有针对 `xuan_common` 的 `dependency_overrides`。

---

## 6. 验收标准 (Acceptance Criteria)

1.  **编译检查**: `flutter build` 成功，无任何关于 `xuan_common` 的找不到包的错误。
2.  **单元测试**: `flutter test` 所有 19 个相关测试用例全部 PASS。
3.  **依赖树验证**: 运行 `flutter pub deps | grep xuan_common` 输出为空。
4.  **功能验证**: 在 `example` 中打开“配置页面”，地理位置搜索和时区自动识别功能正常工作。

---

## 7. 执行步骤建议 (Step-by-Step for Execution Agent)

1.  **Phase A (Infrastructure)**: 更新所有 `pubspec.yaml`，引入目标包，保持 `xuan_common` 并存。
2.  **Phase B (Test-First)**: 逐个修复 `test/` 目录下的 5 个测试文件，使其依赖于新包。
3.  **Phase C (Surgical Replacement)**: 使用 `replace` 工具，全局替换非 UI 类的 `import` 路径。
4.  **Phase D (UI Internalization)**: 手动迁移 Widget 源码。
5.  **Phase E (Cleanup)**: 彻底删除 `xuan_common` 依赖并运行 `flutter clean`。
