import 'zhu_luo_san_xian_tables.dart';

enum ZhuLuoAlgorithmId {
  classicInverseSections,
  directAnnualWithBridge,
}

enum BridgeMode {
  none,
  nextRulerNumberBridge,
}

class ZhuLuoAlgorithmConfig {
  final ZhuLuoAlgorithmId id;
  final bool usesInverseSections;
  final int sectionLength;
  final int inverseSectionOffset;
  final int annualDirection;
  final BridgeMode bridgeMode;

  const ZhuLuoAlgorithmConfig({
    required this.id,
    required this.usesInverseSections,
    required this.sectionLength,
    required this.inverseSectionOffset,
    required this.annualDirection,
    required this.bridgeMode,
  });
}

const ZhuLuoAlgorithmConfig classicInverseSectionsConfig =
    ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.classicInverseSections,
  usesInverseSections: true,
  sectionLength: 10,
  inverseSectionOffset: -2,
  annualDirection: 1,
  bridgeMode: BridgeMode.none,
);

const ZhuLuoAlgorithmConfig directAnnualWithBridgeConfig =
    ZhuLuoAlgorithmConfig(
  id: ZhuLuoAlgorithmId.directAnnualWithBridge,
  usesInverseSections: false,
  sectionLength: 0,
  inverseSectionOffset: 0,
  annualDirection: 1,
  bridgeMode: BridgeMode.nextRulerNumberBridge,
);
