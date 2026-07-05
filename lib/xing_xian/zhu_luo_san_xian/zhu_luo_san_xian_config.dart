
/// 竹罗三限四套交限方案枚举 (Doc B §4)
///
/// 四套方案的区别在于：当标准年限走完时，如何处理与下一限主星本宫的关系。
enum ZhuLuoAlgorithmId {
  /// 方案1: 候星逐宫延交法 (A法·古籍正统)
  ///
  /// 特点：标准年限到期不强制换限，继续顺行一年一宫，直到落宫==pNext才交限。
  ///
  /// 行为：
  /// - 三场景：
  ///   1. pEnd == pNext：当年交限
  ///   2. 未到 pNext：继续顺行一年一宫，逐年候至落宫==pNext
  ///   3. 已过 pNext：不折返，继续顺行循环十二宫，下一圈重逢 pNext
  /// - 尾段：一串正向顺行段，直到命中 pNext
  /// - 可绕多圈
  classicForwardUntilTarget,

  /// 方案2: 年限强制切换法 (商用简化)
  ///
  /// 特点：标准年限一到，不管有没有走到、有没有错过下一限主星本宫，立刻强制切换。
  ///
  /// 行为：
  /// - 土星初限满26年，到达26岁
  /// - 不看当年落在未宫、去年已经路过午宫这件事，不等待、不回头
  /// - 26岁直接作废土星初限，强制切换为月亮中限
  /// - 25岁午宫错过的交限窗口直接作废，不再处理
  /// - 全程只顺行、不等待
  forceCut,

  /// 方案3: 折返补救交限法 (小众私传，考据否定)
  ///
  /// 特点：年限到期没到下星宫会顺行等候，一旦走过下星宫就逆行倒退回到星宫再交限。
  ///
  /// 行为：
  /// - 土星初限满26年，当年落在未宫，发现已经走过月亮本宫午
  /// - 打破行限只能顺行的规则，流年宫位逆行倒退一格，从未倒回午
  /// - 认定26岁行限实质落在午宫，在当年完成初限转中限
  /// - 交限完成后，往后年份继续恢复顺行流转
  ///
  /// 注意：违背古籍"零年顺转逐宫移"单向规定，主流考据派不认可。
  retrace,

  /// 方案4: 补桥年限双轨交限法 (B法·西洋改良)
  ///
  /// 特点：优先用补桥公式计算，满足则走补桥段，不满足则强制切换。
  ///
  /// 行为：
  /// - 优先触发（补桥）：若满足补桥公式 `剩余年限 = 宫数 × nextStarYears`，
  ///   走完补桥段刚好抵达 pNext，同步交限
  /// - 尾段为一段/多段补桥段（可异色/虚线）
  /// - 兜底触发：不满足补桥条件 → 年限到期强制切换（同方案2）
  bridgeWithFallback,
}

enum BridgeMode {
  none,
  nextRulerNumberBridge,
}

class ZhuLuoAlgorithmConfig {
  final ZhuLuoAlgorithmId id;
  final int annualDirection;
  final BridgeMode bridgeMode;

  const ZhuLuoAlgorithmConfig({
    required this.id,
    required this.annualDirection,
    required this.bridgeMode,
  });
}

/// 方案1: 候星逐宫延交法 (A法·古籍正统)
///
/// 标准年限到期不强制换限，继续顺行直到落宫==pNext。
/// 可绕多圈，直到命中目标。
const ZhuLuoAlgorithmConfig classicForwardUntilTargetConfig =
    ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.classicForwardUntilTarget,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案2: 年限强制切换法 (商用简化)
///
/// 标准年限一到，不管有没有走到、有没有错过下一限主星本宫，立刻强制切换。
/// 全程只顺行、不等待。
const ZhuLuoAlgorithmConfig forceCutConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.forceCut,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案3: 折返补救交限法 (小众私传，考据否定)
///
/// 年限到期没到下星宫会顺行等候，一旦走过下星宫就逆行倒退回到星宫再交限。
/// 违背古籍单向顺行规则。
const ZhuLuoAlgorithmConfig retraceConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.retrace,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案4: 补桥年限双轨交限法 (B法·西洋改良)
///
/// 优先用补桥公式计算，满足则走补桥段，不满足则强制切换。
const ZhuLuoAlgorithmConfig bridgeWithFallbackConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.bridgeWithFallback,
  annualDirection: 1,
  bridgeMode: BridgeMode.nextRulerNumberBridge,
);
