
enum ZhuLuoAlgorithmId {
  /// 方案1: 候星逐宫延交法 (A法·古籍正统)
  /// 标准年限到期不强制换限，继续顺行直到落宫==pNext
  classicForwardUntilTarget,

  /// 方案2: 年限强制切换法 (商用简化)
  /// 标准年限到期直接强制换限
  forceCut,

  /// 方案3: 折返补救交限法 (小众私传，考据否定)
  /// 标准年限到期已过pNext时逆行折返
  retrace,

  /// 方案4: 补桥年限双轨交限法 (B法·西洋改良)
  /// 补桥公式满足时走补桥段，否则强制切换
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
const ZhuLuoAlgorithmConfig classicForwardUntilTargetConfig =
    ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.classicForwardUntilTarget,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案2: 年限强制切换法 (商用简化)
const ZhuLuoAlgorithmConfig forceCutConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.forceCut,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案3: 折返补救交限法 (小众私传，考据否定)
const ZhuLuoAlgorithmConfig retraceConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.retrace,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

/// 方案4: 补桥年限双轨交限法 (B法·西洋改良)
const ZhuLuoAlgorithmConfig bridgeWithFallbackConfig = ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.bridgeWithFallback,
  annualDirection: 1,
  bridgeMode: BridgeMode.nextRulerNumberBridge,
);
