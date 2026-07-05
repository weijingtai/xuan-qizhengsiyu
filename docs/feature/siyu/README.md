# 四余天文计算与罗计流派配置模块

## 一、模块结构与职责划分

四余（罗睺、计都、紫气、月孛）的天文位置计算与流派定义已从 `SwephEngine` 中抽离，并独立封装在 [lib/domain/engines/siyu/](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/domain/engines/siyu/) 下，具体结构如下：

1. **[RahuKetuDefinition](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/domain/engines/siyu/rahu_ketu_definition.dart)**：
   * **职责**：纯函数定义层。专门负责将月球平升交点（`northNode`）与降交点映射为命理学上的「罗睺」与「计都」黄经。
   * **作用**：隔离流派分歧，不变量逻辑用强类型单测锁死，防误改。

2. **[SiYuCalculator](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/domain/engines/siyu/si_yu_calculator.dart)**：
   * **职责**：四余天文坐标计算核心。接收 `ISiYuEphemerisSource` 物理星历和 `ZiQiAlgorithm` 紫气算法策略。
   * **作用**：完全不绑定 `Swiss Ephemeris` 运行环境，可注入 Mock 源独立进行内存单测。

3. **[SwephSiYuEphemerisSource](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart)**：
   * **职责**：基于 Swiss Ephemeris (`sweph` 包) 的生产环境星历数据源实现，获取平升交点和远地点。

## 二、罗计流派定义与天文映射

### 1. 天文事实
星历表计算出的月球轨道与黄道面交点：
* **升交点 (Ascending Node, N)**：月球由南向北穿过黄道面的交点。
* **降交点 (Descending Node, N + 180°)**：月球由北向南穿过黄道面的交点。

### 2. 流派约定 ([EnumRahuKetuConvention](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/enums/enum_rahu_ketu_convention.dart))
不同历法和占星体系对罗睺与计都的定义存在分歧：

| 流派标识 | 中文名 | 映射规则 | 史料背景与命理后果 |
| :--- | :--- | :--- | :--- |
| `luoJiangJiSheng` | **罗降计升 (古法)** | 罗睺 = 降交点<br>计都 = 升交点 | **古法正统（本模块默认）**。依据《果老星宗》《开元占经》一行九执历（「交初为罗，交中为计」，即「南罗北计」）。天首=降交点=罗睺。 |
| `luoShengJiJiang` | **罗升计降 (新法)** | 罗睺 = 升交点<br>计都 = 降交点 | **民间/西方/印占**。清后期西方占星传入后民间混用，现代印度占星 (Jyotish) 默认此套，与古法正统相反。 |

> [!WARNING]
> 切换到 **罗升计降（新法）** 时，罗睺与计都的黄经度数和落宫将完全对调，吉凶随之对调。UI 上已加警告警示用户仅供学术比对参考。

## 三、配置与向后兼容设计

* **配置字段**：[BasePanelConfig.rahuKetuConvention](file:///Users/jingtaiwei/Git/Public/xuan-migration/xuan-qizhengsiyu/lib/domain/entities/models/panel_config.dart)
* **向后兼容**：使用 `@JsonKey(defaultValue: EnumRahuKetuConvention.luoJiangJiSheng)` 修饰。旧的、未携带此字段的持久化 JSON 在反序列化时会自动回落到默认的 **罗降计升（古法）**，确保全链路行为零回归，不抛异常。

## 四、已知遗留议题（非本次修改范围）

1. **紫气历元基准问题**：当前过渡期采用的 `_TransitionZiQiAlgorithm` 仍然使用原先以 `Asia/Shanghai 2013-04-09 02:58` 为 0° 的魔数推算，其历史来源与精确度将在 Part B 中重构与校准。
2. **时区一致性**：`sweph_engine.dart` 中在计算儒略日时直取本地 `DateTime`，与紫气算法中的上海时区转换存在潜在的不一致，需在后续时区统一改造中解决。
