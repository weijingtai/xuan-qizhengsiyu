
# “七政四余”项目代码架构文档

## 1. 文件结构与主要功能

本项目遵循 **Clean Architecture** 思想，将代码组织为三个主要层次：`presentation`（表现层）、`domain`（领域层）和 `data`（数据层）。

```
qizhengsiyu/
├── lib/
│   ├── main.dart                   # 应用入口，初始化依赖和根Widget。
│   ├── navigator.dart                # 应用的导航和路由管理。
│   │
│   ├── presentation/                 # 表现层 (UI)
│   │   ├── pages/                    # 页面级 Widgets
│   │   │   ├── primary_page.dart     # 主页面，可能是命盘展示页。
│   │   │   └── qi_zheng_si_yu_config_page.dart # 命盘配置页面，用于输入用户信息。
│   │   ├── viewmodels/               # 视图模型
│   │   │   └── qi_zheng_si_yu_viewmodel.dart # 主要的ViewModel，管理UI状态和业务逻辑调用。
│   │   ├── widgets/                  # 可重用的UI组件
│   │   │   ├── rings/                # 命盘中的各种环状UI组件。
│   │   │   └── config/               # 配置页面中的各种输入组件。
│   │   └── models/                   # UI层特定的模型
│   │       └── ui_star_model.dart    # 用于UI展示的星体模型。
│   │
│   ├── domain/                       # 领域层 (核心业务逻辑)
│   │   ├── entities/                 # 核心业务实体
│   │   │   └── models/
│   │   │       ├── QiZhengSiYuPanModel.dart # 核心模型：七政四余命盘。
│   │   │       └── star_angle_speed.dart # 定义星体角速度的模型，用于判断顺行、逆行或留。
│   │   ├── usecases/                 # 用例，封装具体的业务操作
│   │   │   └── calculate_fate_dong_wei_usecase.dart # 计算“命度冬至”等复杂运势的用例。
│   │   ├── services/                 # 领域服务，提供具体的计算或业务能力
│   │   │   ├── generate_base_panel_service.dart # 生成基础命盘的服务。
│   │   │   ├── astro_service.dart    # 天文计算服务。
│   │   │   └── shen_sha_service.dart # 神煞计算服务。
│   │   ├── repositories/             # 仓库接口定义
│   │   │   └── qizhengsiyu_pan_repository.dart # 命盘仓库的抽象接口。
│   │   └── managers/                 # 管理器，组织和协调领域服务
│   │       └── star_position_manager.dart # 星体位置管理器。
│   │
│   ├── data/                         # 数据层 (数据获取与持久化)
│   │   ├── repositories/             # 仓库的具体实现
│   │   │   └── qizhengsiyu_pan_repository.dart # 命盘仓库的实现，与本地数据库交互。
│   │   ├── datasources/              # 数据源
│   │   │   └── local/
│   │   │       ├── app_database.dart # Drift数据库的定义。
│   │   │       ├── daos/             # Data Access Objects
│   │   │       │   └── qizhengsiyu_pan_dao.dart # 命盘表的DAO。
│   │   │       └── shen_sha_local_data_source.dart # 本地神煞数据的来源。
│   │   ├── models/                   # 数据传输对象 (DTOs)
│   │   │   └── converters/           # DTO与Domain Model之间的转换器。
│   │   └── ...
│   │
│   ├── utils/                        # 通用工具类
│   │   ├── coordinate_converter.dart # 包含黄道/赤道等坐标系转换的数学逻辑。
│   │   └── traditional_chinese_equatorial_to_ecliptic.dart # 提供特定的赤道转黄道算法。
│   ├── enums/                        # 枚举类型
│   │   ├── enum_school.dart        # 定义占星流派（如 `guoXue`, `tianChi`）。
│   │   └── enum_panel_system_type.dart # 定义多种坐标和黄道系统（回归/恒星，黄道/赤道）。
│   └── painter/                      # 自定义绘制 (CustomPaint)
│       └── ...
│
├── test/                           # 测试代码
└── pubspec.yaml                    # 项目依赖配置文件
```

## 2. 程序调用结构图（以创建新命盘为例）

下面是一个简化的、基于文本的调用流程图，描述了从用户在UI上输入信息到最终在本地数据库中创建一条命盘记录的完整过程。

```mermaid
graph TD
    subgraph 表现层 (Presentation)
        A[用户在 QiZhengSiYuConfigPage 输入信息] --> B{点击“创建命盘”按钮};
        B --> C[QiZhengSiYuViewModel];
        C --> D[调用 use case];
    end

    subgraph 领域层 (Domain)
        D --> E[GenerateBasePanelUseCase];
        E --> F[AstroService: 计算星体位置];
        E --> G[ShenShaService: 计算神煞];
        E --> H[LifeBodyModelBuilder: 定命宫/身宫];
        F & G & H --> I[生成 QiZhengSiYuPanModel 实例];
        I --> J[SaveCalculatedPanelUseCase];
        J --> K[IQiZhengSiYuPanRepository (接口)];
    end

    subgraph 数据层 (Data)
        K --> L[QiZhengSiYuPanRepositoryImpl (实现)];
        L --> M[QiZhengSiYuPanDao];
        M --> N[AppDatabase (Drift)];
        N --> O[将数据写入SQLite数据库];
    end

    C -- 数据流 --> P[ViewModel 更新UI状态];
    P --> Q[PrimaryPage 显示新命盘];

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#f9f,stroke:#333,stroke-width:2px
    style Q fill:#f9f,stroke:#333,stroke-width:2px
```

### 调用流程说明：

1.  **用户交互 (UI)**: 用户在 `QiZhengSiYuConfigPage` 页面输入出生日期、时间等信息，然后点击“创建命盘”按钮。
2.  **ViewModel 响应**: `QiZhengSiYuViewModel` 接收到UI事件，调用 `GenerateBasePanelUseCase` 这个用例来开始业务逻辑处理。
3.  **领域逻辑处理 (Domain)**:
    *   `GenerateBasePanelUseCase` 是核心的业务流程编排者。
    *   它调用多个领域服务（`AstroService`, `ShenShaService` 等）来执行具体的计算任务。
    *   所有计算完成后，它将结果组装成一个完整的 `QiZhengSiYuPanModel` 领域模型对象。
    *   接着，`SaveCalculatedPanelUseCase` 被调用，它通过 `IQiZhengSiYuPanRepository` 接口请求保存这个模型。
4.  **数据持久化 (Data)**:
    *   `QiZhengSiYuPanRepositoryImpl` 作为接口的实现，接收到保存请求。
    *   它使用 `PanelModelConverter` 将领域模型（`QiZhengSiYuPanModel`）转换为数据库表实体。
    *   然后，它调用 `QiZhengSiYuPanDao`（数据访问对象）来执行数据库写操作。
    *   `Drift` 数据库 (`AppDatabase`) 最终将数据持久化到设备的SQLite文件中。
5.  **UI 更新**: 与此同时，`QiZhengSiYuViewModel` 在接收到成功的结果后，会更新其内部状态。Flutter的响应式UI机制会监听到状态变化，并自动刷新 `PrimaryPage` 页面，从而向用户展示新生成的命盘。

这个架构实现了关注点分离，使得每一层都只关心自己的职责，极大地提高了代码的可测试性、可维护性和可扩展性。
