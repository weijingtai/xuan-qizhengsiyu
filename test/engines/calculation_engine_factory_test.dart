import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/engines/historical_engine.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

void main() {
  group('CalculationEngineFactory', () {
    test('should return SwephEngine for modern systems', () {
      // Arrange
      final config = BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
        panelSystemType: PanelSystemType.tropical,
        constellationSystemType: ConstellationSystemType.modern,
        houseDivisionSystem: HouseDivisionSystem.equal,
        settleLifeType: EnumSettleLifeType.Mao,
        lifeCountingToGong: EnumTwelveGong.Mao,
        bodyCountingToGong: EnumTwelveGong.Yin,
        settleBodyType: EnumSettleBodyType.moon,
        islifeGongBySunRealTimeLocation: true,
      );

      // Act
      final engine = CalculationEngineFactory.create(config);

      // Assert
      expect(engine, isA<SwephEngine>());
    });

    test('should return HistoricalEngine for skyEquatorial system', () {
      // Arrange
      final config = BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.skyEquatorial,
        panelSystemType: PanelSystemType.sidereal, // Historical is a type of sidereal
        constellationSystemType: ConstellationSystemType.classical,
        houseDivisionSystem: HouseDivisionSystem.equatorialEqual,
        settleLifeType: EnumSettleLifeType.Mao,
        lifeCountingToGong: EnumTwelveGong.Mao,
        bodyCountingToGong: EnumTwelveGong.Yin,
        settleBodyType: EnumSettleBodyType.moon,
        islifeGongBySunRealTimeLocation: true,
      );

      // Act
      final engine = CalculationEngineFactory.create(config);

      // Assert
      expect(engine, isA<HistoricalEngine>());
    });
  });
}
