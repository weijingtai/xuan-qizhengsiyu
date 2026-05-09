# 七政四余开发计划

## 目标

本项目实现一套**七政四余**（Chinese astrology / horology）排盘与分析系统。以 Flutter module 的形态嵌入原生宿主 app，对外提供：

1. **天体定位**——七政（日月与五星）、四余（罗、计、孛、炁）等星体在二十八宿/十二宫的星历计算
2. **十二宫映射**——命/财/兄/田 等十二宫位的安宫、流转
3. **格局评估**——基于规则集（GeJu / 神煞 / 化曜）的命盘条件匹配
4. **流年（流盘）演算**——大限、流年盘的复用计算
5. **可扩展规则数据**——内置规则 JSON + 用户自定义规则双源合并

第一阶段已建立 Clean Architecture 三层骨架与核心子系统；当前阶段重点是**格局规则模型**（GeJuRule / GeJuAnnotation / GeJuConditionSet 三实体模型）的成熟与流年支持完善。

## 总体原则

1. 算法内核（domain/managers, domain/services）与 Flutter UI 严格分离
2. 不同流派/学派差异通过规则数据表达，不在 UI 或 manager 内写大量条件判断
3. 命盘类型（本命 / 流年 / 大限）共享同一套星历与宫位算法
4. 每个关键算法步骤可单独测试（test/managers/*_test.dart）
5. 规则数据双源：内置 JSON + 用户 Drift DB；用户规则永远以 `user_` 前缀 UUID 标识
6. 不确定或传本差异较大的规则，结果中保留说明或警告字段；不静默假设

## 推荐目录结构

实际目录见 [docs/ai/directory-structure.md](ai/directory-structure.md) 与本文件以下约定：

```text
lib/
  main.dart                              ← Flutter module 入口（example app 使用）
  navigator.dart                         ← 路由
  di.dart                                ← Provider 依赖注入装配
  qi_zheng_si_yu_constant_resources.dart ← 全局常量（星体、宫位、文本）
  qi_zheng_si_yu_ui_constant_resources.dart ← UI 常量

  domain/                                ← 领域层
    entities/                            ← 实体与值对象（含 ge_ju/conditions/、models/）
    managers/                            ← 业务编排（GeJuEvaluator、StarPositionManager、HuaYaoManager、ShenShaManager、ZhouTianModelManager、Fate*）
    services/                            ← CRUD 与查询（GeJuCrudService 等）
    repositories/                        ← 仓储接口

  data/                                  ← 数据层
    datasources/local/                   ← JSON / 本地存储数据源（GeJuLocalDataSource、ShenShaLocalDataSource 等）
    repositories/                        ← 仓储实现（合并、缓存、迁移）

  presentation/
    pages/                               ← 页面 Widget
    widgets/                             ← 复用组件
    viewmodels/                          ← ChangeNotifier-based ViewModels

  database/                              ← Drift 数据库定义（AppDatabase, 表, migration）
  dataset/                               ← 数据集（如内置语料、文本资源）
  enums/                                 ← 领域枚举（enum_ 前缀）
  controllers/                           ← 全局控制器
  painter/                               ← 自定义绘制
  theme/                                 ← 主题
  utils/                                 ← 工具类
  xing_xian/                             ← 行星/星限相关计算

example/
  lib/                                   ← 嵌入示例 app
  assets/qizhengsiyu/                    ← 内置规则 JSON 资源
    ge_ju/rules/                         ← 格局规则条件
    ge_ju/content/                       ← 格局展示文本
```

MUST: 新增子系统按 manager + service + repository + datasource 四件套划分
MUST: 领域概念命名优先使用拼音（GeJu、ShenSha、HuaYao、ZhouTian、QiZheng、SiYu）
MUST: 枚举文件以 `enum_` 前缀
MUST: Repository 接口使用 `I` 前缀（`IGeJuRepository`）或无前缀但语义清晰

## 关键子系统

| 子系统 | 职责 | 关键文件 |
|--------|------|---------|
| **GeJu (格局)** | 规则化的星-宫-时-神煞条件匹配引擎 | `lib/domain/entities/models/ge_ju/`、`lib/domain/managers/ge_ju/` |
| **ShenSha (神煞)** | 各宫神煞计算与查询 | `shen_sha_manager.dart`、`shen_sha_service.dart` |
| **HuaYao (化曜)** | 禄/暗/福/耗 的星变映射 | `hua_yao_manager.dart`、`hua_yao_service.dart` |
| **ZhouTian (周天)** | 天体坐标 / 位置建模与查询 | `zhou_tian_model_manager.dart`、`zhou_tian_calculator.dart` |
| **Fate (命理)** | 命宫 / 大限 / 流年 推算 | `lib/domain/managers/fate/` |
| **YuanLe (垣乐)** | 星体在宫的庙旺喜乐等位置状态展示 | `yuan_le_panel_builder.dart`、`yuan_le_result_panel.dart` |

## 核心模型（GeJu 三实体模型）

GeJu 系统已重构为三实体模型，详情见 docs/ge_ju/* 与 docs/superpowers/specs/。当前结构：

```dart
class GeJuRule { /* 薄锚点，承载 ID 与元信息 */ }

class GeJuAnnotation { /* 文本层：名称、来源、解释、典籍引用 */ }

class GeJuConditionSet { /* 逻辑层：条件树 + AND/OR/NOT 组合子 */ }
```

8 类 `GeJuCondition` 子类位于 `lib/domain/entities/models/ge_ju/conditions/`：

- `position_conditions` — 星在宫 / 星在宿
- `relationship_conditions` — 同宫 / 对宫 / 三合 / 四正
- `structure_conditions` — 命宫 / 守垣
- `yong_shen_conditions` — 星四类（恩/难/仇/用）
- `time_conditions` — 季节、昼夜、月相
- `gong_status_conditions` — 庙/旺/喜/乐 等宫位状态
- `shen_sha_conditions` — 神煞条件
- `xian_conditions` — 大限 / 流年

MUST: 新增条件类型 MUST extends `GeJuCondition` 并实现 `evaluate()` / `describe()`
MUST: 在 `GeJuCondition.fromJson()` 类型分发处注册新类型

## 开发阶段（按当前推进顺序）

| 阶段 | 状态 | 重点 |
|------|------|------|
| 一、星历与宫位基础 | 已交付 | sweph 集成、十二宫定位、二十八宿映射 |
| 二、化曜 / 神煞 / 周天模型 | 已交付 | HuaYao / ShenSha / ZhouTian manager |
| 三、GeJu 三实体模型重构 | 已交付 | Rule + Annotation + ConditionSet 拆分、Drift 持久化、内置 JSON 迁移 |
| 四、UI 整合（化曜面板、垣乐面板） | 已交付 | 化曜统一卡片、垣乐表格 + 流年 PageView |
| 五、流年盘条件支持完善 | 进行中 | xian_conditions 流年场景验收、流年 GeJu 评估 |
| 六、用户自定义规则 UX | 进行中 | 规则编辑器、导入导出、校验提示 |
| 七、性能与缓存 | 待启动 | 评估器缓存、内置规则懒加载、面板异步渲染优化 |
| 八、宿主集成验收 | 待启动 | embedded module 与原生宿主联调 |

## 里程碑

| 里程碑 | 说明 |
|--------|------|
| **M1: 三实体模型可用** | GeJu 重构完成、内置规则全量加载、评估器单元测试覆盖 8 类条件 |
| **M2: 流年盘闭环** | 流年盘 GeJu 评估全通路、垣乐流年 PageView 切换验收 |
| **M3: 自定义规则可用** | 用户可创建/编辑/导入/导出 GeJu 规则，Drift 持久化 + JSON 互转 |
| **M4: 嵌入宿主联调** | Flutter module 在原生宿主 app 内可启动，关键页面无回归 |
| **M5: 性能基线** | 单次完整命盘 + GeJu 全量评估在主流设备上 ≤ 800ms |

## 风险点

| 风险 | 影响 | 缓解 |
|------|------|------|
| Drift schema 演进破坏旧用户数据 | 高 | MUST 走 schemaVersion + onUpgrade，禁止直接改表结构（详见 toolchain.md） |
| `xuan-common` / `persistence_core` 跨仓库版本漂移 | 高 | 走 git 源依赖，version pin；改动联动验证 |
| sweph 在 web/iOS/Android 资源差异 | 中 | example/web/ 已配置；新平台联调时 MUST 验证 ephemeris 文件路径 |
| 七政四余各派对"庙旺喜乐"等术语口径不一 | 中 | 规则以数据表达，UI 显示来源标注；保留 source 字段以便分流 |
| Flutter module 模式下 Provider 单例与原生宿主生命周期错位 | 中 | AppDatabase 维持进程级单例，禁止 dispose；联调阶段补足边界用例 |
| GeJu 条件树深度膨胀导致评估开销 | 低 | 评估器引入条件级缓存与短路；超阈值 SPEC 触发再优化 |

## 与 docs/ai/ 的关系

本文件描述**项目业务计划**；AI 协同规则、SPEC Coding 流程、代码风格、目录约束等**统一规范**详见 [docs/ai/](ai/) 目录。两者各司其职：

- **本文件** = What & Why（项目要做什么、为什么这样组织）
- **docs/ai/** = How（AI 与人协同时遵守的工作流与红线）
