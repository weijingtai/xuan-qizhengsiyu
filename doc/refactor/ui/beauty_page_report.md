一、重构目标（UI/组件集中）

- 降低 beauty_view_page.dart 复杂度，将 UI 由“巨石 State 类”拆为若干可复用组件。
- 组件通过明确的入参收数据，不直接读取 ViewModel，避免耦合。
- 统一环组件的接口和样式，实现可复用的 12 宫/地支/星宿/神煞环。
- 保持现有视觉与交互不变（含 Tooltip、旋转、太极选择按钮）。
二、优先级与范围

- 只改 UI 层和组件层，保持 ViewModel/Service/Manager 不动。
- 先拆 panel() 主体和四类环组件（命理十二宫、地支十二宫、二十八宿、周天十二宫），再整合星体绘制层（星体主体/轨迹）。
- 暂不调整业务逻辑（神煞计算、角度避让等），但会抽取 UI 配置与默认 mapper 到 config。
三、目录与文件组织（以现有路径为准）

- 新增 qizhengsiyu/lib/widgets/panel/ 目录存放面板组件：
  - panel_main_widget.dart（原 panel() 主体拆分的入口）
  - center_widget.dart（中心区域/辅助圆）
  - star_layers/
    - star_bodies_layer.dart（统一 life/fate 星体主体绘制）
    - star_trails_layer.dart（星体轨迹绘制）
  - ring_layers/
    - zodiac_12_ring.dart（周天十二宫）
    - destiny_12_ring.dart（命理十二宫）
    - dizhi_12_ring.dart（十二地支宫）
    - starxiu_28_ring.dart（二十八宿环）
    - ruling_ring.dart（指标刻度/执掌环）
- 提取 UI 配置与默认 mapper 到 qizhengsiyu/lib/presentation/config/
  - panel_size_config.dart（尺寸、半径、文字样式）
  - panel_constants.dart（默认文本、颜色常量）
  - mappers.dart（defaultZodiac12GongMapper/defaultDestiny12GongMapper 等）
四、组件拆分与接口定义（关键组件）

1. 1.
   PanelMainWidget（替代原 panel() 主体）
- 作用：组装各环与星体层，维护 Stack/Transform 的组合顺序。
- 入参：
  - sizeConfig（包含各半径、旋转角度、文字样式）
  - basePanel（BasePanelModel，用于各环的数据映射）
  - daXianPanel（DaXianPanelModel，用于大限星体）
  - basicStars（List
    ）
  - fateStars（List
    ）
- 行为：通过 ValueListenableBuilder 在 beauty_view_page.dart 中获取数据，PanelMainWidget 只做组合。
1. 2.
   StarBodiesLayer（统一 lifePanelUIStarDefault/lifePanelStarDefault/fatePanelStar）
- 作用：在指定半径与旋转偏移下，用 MyCirclePainter 绘制星体圆点，并显示 Tooltip。
- 入参：
  - stars（List
    ）
  - starRadius、textStyle、tooltipBuilder
  - rotationDeg（整体旋转角）
  - ringRadius（该层星体所在的环半径）
- 行为：整合原三套方法的重复逻辑，统一绘制与 Tooltip，减少样式分散。
1. 3.
   StarTrailsLayer（整合 innerStarBodyRotating/outerStarBodyRotating/轨迹）
- 作用：使用 StarBodyPainter 绘制星体轨迹、环，接收画图所需的数据。
- 入参：
  - stars（List
    /或轨迹数据）
  - ringRadius、rotationDeg、style（轨迹样式）
1. 4.
   Destiny12Ring（命理十二宫，封装 Normal12GongRing）
- 作用：对 Normal12GongRing 包一层，统一外观和接口；实现“太极点”按钮的显示/隐藏。
- 入参：
  - mapper（Map<EnumTwelveGong, List
    >）
  - outerRadius、innerRadius、baseGongOffsetAngle
  - selectedTaiJiList（ValueListenable<List
    > 或当前选中状态）
- 行为：内部仍用 GongShenShaRing 分布内外环项目，但“太极点”以 Overlay 或透明按钮层实现。
1. 5.
   DiZhi12Ring（十二地支宫，封装 Gong12DiZhiRing）
- 入参：
  - mapper（Map<EnumTwelveGong, List
    >）
  - outerRadius、innerRadius、layoutStyle、shaTextDirection、isShi/isXu
- 行为：对文字排版风格统一接口（Line/Triangle/AntiTriangle），视觉不变。
1. 6.
   Zodiac12Ring（周天十二宫）
- 入参：
  - mapper（defaultZodiac12GongMapper）
  - outerRadius、innerRadius、baseGongOffsetAngle、textStyle
1. 7.
   StarXiu28Ring（二十八宿）
- 入参：
  - mapper（QiZhengSiYuConstantResources.ZodiacTropicalModernStarsInnSystemMapper）
  - outerRadius、innerRadius、textStyle
- 行为：包装 StarXiuRingPainter，统一与其他环组件的接口风格。
五、UI 常量与默认 mapper 迁移

- 将 defaultZodiac12GongMapper/defaultDestiny12GongMapper 从 beauty_view_page.dart 末尾迁移到 config/mappers.dart。
- 将各层半径（starXiu28RingSizeOuter/Inner、命理十二宫内外环半径、中心圆半径等）迁移至 PanelSizeConfig。
- 将文字样式（宫名红/白文字、Tooltip 文本、星体名称字体）集中到 PanelTextStyles（在 panel_size_config.dart 中或单独 styles.dart）。
六、事件与交互的保留

- 太极选择：保持使用 ValueListenableBuilder，但将逻辑从 beauty_view_page.dart 抽到 TaiJiDestinyLogic（UI 层），组件只读 selectedIndex 或 selectedList，不直接做重排。
- Tooltip：统一通过组件入参传入 tooltipBuilder（或默认实现），避免在组件内部访问 ViewModel。
- 旋转按钮显示：MouseRegion/InkWell 的交互保持原行为，迁移为组件内的 Stateful 逻辑或通过外部状态驱动。
七、实施步骤（UI/组件专注版）

- 第一步：创建 panel_main_widget.dart，先把现有 panel() 按层拆分为占位组件，保持原 Stack/Transform 结构与旋转角。
- 第二步：提取 Destiny12Ring/DiZhi12Ring/Zodiac12Ring/StarXiu28Ring 四个组件，分别接入现有 painter/子环组件，统一入参接口。
- 第三步：提取 StarBodiesLayer 和 StarTrailsLayer 两个星体层组件，合并 life/fate 的重复绘制逻辑。
- 第四步：迁移默认 mapper 与尺寸常量到 config，并修改组件入参使用新的配置/mapper。
- 第五步：beauty_view_page.dart 只保留页面壳与 ValueListenableBuilder，将所有绘制调用替换为 PanelMainWidget。
- 第六步：视觉回归测试（组件化后与原效果对比）
  - 检查文字位置（环内/环外）、颜色、旋转角一致
  - 检查 Tooltip 出现逻辑与内容
  - 检查“太极点”按钮的显示/隐藏与点击动作
八、验收标准（UI/组件）

- 视觉一致：与现版截图对比，环分布、文字样式、星体位置与轨迹基本一致。
- 交互一致：Tooltip 和太极选择交互无回归问题。
- 组件化达成：beauty_view_page.dart < 400 行；PanelMainWidget + 5 个 ring 组件 + 2 个 star 层组件独立存在；默认 mapper 与常量已迁移。
- 低耦合：子组件通过入参获取数据；不直接访问 ViewModel。
九、说明

- 以上改造只涉及 UI 与组件，不触动 ViewModel 计算与 Painter 实现逻辑。风险低，可逐步合并。
- 若您同意该执行方向，我将从“创建 PanelMainWidget 和四类环组件封装”开始，并在每一步提交前后对比预览，确保视觉一致。您也可以指定先改哪一块（例如先拆命理十二宫），我按您的节奏推进。