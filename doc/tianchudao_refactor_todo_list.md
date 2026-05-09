### “天赤道制”集成开发任务清单 (TODO List) - V3 (最终版)

**核心思想：** 本计划将通过抽象的`ICalculationEngine`返回一个配置完备的`ZhouTianModel`实例。UI渲染层(`Painter`)完全依赖`ZhouTianModel`来动态绘制星盘，从而实现对“天赤道制”和现有SWEPH制的并行支持与隔离。

---

#### **阶段一：基础架构与抽象层搭建 (深化)**

- [x] **1.1：确认核心模型**
    - **复用 `ZhouTianModel`**: 确认 `domain/entities/models/zhou_tian_model.dart` 作为定义坐标系规则的核心模型。无需创建新模型。
    - **复用 `StarPosition`**: 确认或微调 `StarPosition` 类（或类似类），作为引擎计算结果的标准输出（应包含星体及其在该坐标系下的原生位置）。

- [x] **1.2：定义计算引擎接口 (`ICalculationEngine`)**
    - 在 `lib/domain/engines/` 中创建 `i_calculation_engine.dart`。
    - 定义 `ICalculationEngine` 抽象类，并包含以下核心方法：
        - `Future<ZhouTianModel> getSystemDefinition();`
        - `Future<List<StarPosition>> calculateStarPositions(DateTime birthDate, Location location);`

---

#### **阶段二：引擎实现与数据加载**

- [x] **2.1：创建“天赤道制”规则的数据源**
    - 在 `assets/` 下创建 `historical_definitions/` 文件夹。
    - 创建 `tian_chi_dao_system.json` 文件。此文件将包含构建“天赤道制” `ZhouTianModel` 所需的所有原始数据（例如：`totalDegree: 365.25`, 各宿大小，对齐点信息等）。

- [ ] **2.2：开发 `HistoricalEngine` (天赤道制引擎)**
    - [x] 在 `lib/domain/engines/` 中创建 `historical_engine.dart` 并实现 `ICalculationEngine` 接口。
    - [x] **2.2.1**：实现 `getSystemDefinition` 方法：从 `tian_chi_dao_system.json` 加载数据，并构建一个代表“天赤道制”的 `ZhouTianModel` 实例。
    - [x] **2.2.2**：实现 `calculateStarPositions` 方法：根据“天赤道制”的规则（查表、迭代累加等）计算11颗星体的原生位置。(已完成占位符实现)
    - [ ] **2.2.3**：为 `HistoricalEngine` 的核心计算逻辑编写单元测试。

- [x] **2.3：封装 `SwephEngine` (现有逻辑)**
    - [x] 在 `lib/domain/engines/` 中创建 `sweph_engine.dart` 并实现 `ICalculationEngine` 接口。
    - [x] **2.3.1**：将现有基于SWEPH的逻辑迁移至此。实现 `getSystemDefinition` 方法，构建并返回代表现代占星系统的 `ZhouTianModel` 实例。
    - [x] **2.3.2**：确保 `calculateStarPositions` 方法返回标准化的 `StarPosition` 列表。

- [x] **2.4：创建引擎工厂 (`CalculationEngineFactory`)**
    - 创建 `calculation_engine_factory.dart`，实现根据 `PanelSystemType` 返回不同引擎实例 (`HistoricalEngine` 或 `SwephEngine`) 的逻辑。

---

#### **阶段三：表现层(UI)重构与集成**

- [x] **3.1：在UI中添加新选项**
    - (已确认) 无需添加新枚举，使用 `CelestialCoordinateSystem.skyEquatorial` 即可触发新引擎。

- [x] **3.2：更新 ViewModel 和服务**
    - [x] 修改 `BeautyPageViewModel`，使其通过工厂获取 `ICalculationEngine` 实例。
    - [x] ViewModel需调用 `getSystemDefinition()` 获取 `ZhouTianModel`，并将其与星体位置列表一起管理。
    - [x] 重构 `GenerateBasePanelService` 以消费来自引擎的数据。

- [x] **阶段三：表现层(UI)重构与集成**

- [x] **3.1：在UI中添加新选项**
    - (已确认) 无需添加新枚举，使用 `CelestialCoordinateSystem.skyEquatorial` 即可触发新引擎。

- [x] **3.2：更新 ViewModel 和服务**
    - [x] 修改 `BeautyPageViewModel`，使其通过工厂获取 `ICalculationEngine` 实例。
    - [x] ViewModel需调用 `getSystemDefinition()` 获取 `ZhouTianModel`，并将其与星体位置列表一起管理。
    - [x] 重构 `GenerateBasePanelService` 以消费来自引擎的数据。

- [x] **3.3：重构 Painter 组件 (核心UI任务)**
    - [x] **3.3.1**：修改主罗盘UI，将 `ZhouTianModel` 对象作为参数传递给所有 `painter` 小部件。
    - [x] **3.3.2**：重构所有 `painter`（如 `gong_shen_sha_ring.dart`, `StarInn28RingPainter.dart` 等）。
        - [x] `StarXiuRingPainter` 已重构。
        - [x] `Gong12DiZhiRing` / `SectorPainter` 已重构。
        - [x] `Normal12GongRing` 已重构。
        - [x] `AllShenShaRing` 已重构。
        - [x] `RingSheetPainter` 已重构。
    - [x] **修改点**：所有硬编码的 `360` 度或 `30` 度等数值，全部改为从传入的 `ZhouTianModel` 对象的属性（如 `totalDegree`, `gongDegreeSeq`）中动态获取。
    - [x] **修改点**：绘制星体时，根据 `ZhouTianModel` 的总度数，将星体的原生位置转换为画布上的实际角度。
        - [x] 已在 `BeautyPageViewModel` 的 `_calculateUIStarsFromMapper` 方法中完成角度归一化。

---

#### **阶段四：测试与验证**

- [ ] **4.1：单元测试**
    - [x] 为 `CalculationEngineFactory` 编写单元测试。
    - [x] 为 `SwephEngine` 编写单元测试，确保重构后功能不变。
    - 确保 `HistoricalEngine` 和 `SwephEngine` 都有独立的单元测试，验证其计算的准确性。

- [ ] **4.2：端到端集成测试**
    - **场景1**：选择“天赤道制”，检查星盘的周天度数、宫位和星宿划分、星体落点是否符合“天赤道制”的规则。
    - **场景2**：切换回“回归黄道制”，检查星盘是否与重构前完全一致，确保没有引入回归性Bug。
