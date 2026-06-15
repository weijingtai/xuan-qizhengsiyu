import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/calculation_engine_factory.dart';
import 'package:qizhengsiyu/domain/engines/i_calculation_engine.dart';
import 'package:qizhengsiyu/domain/engines/historical_engine.dart';
import 'package:qizhengsiyu/domain/engines/sweph_engine.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

class _StubEngine implements ICalculationEngine {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubProvider implements ICalculationEngineProvider {
  final ICalculationEngine _engine;
  _StubProvider(this._engine);
  @override
  ICalculationEngine getEngine(BasePanelConfig config) => _engine;
}

void main() {
  setUp(() {
    CalculationEngineFactory.setProvider(_StubProvider(_StubEngine()));
  });

  group('CalculationEngineFactory', () {
    test('should return engine for modern systems', () {
      // Arrange
      final config = BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
        panelSystemType: PanelSystemType.Tropical,
        constellationSystemType: ConstellationSystemType.Modern,
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
      expect(engine, isNotNull);
    });

    test('should return engine for skyEquatorial system', () {
      // Arrange
      final config = BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
        panelSystemType: PanelSystemType.Sidereal, // Historical is a type of sidereal
        constellationSystemType: ConstellationSystemType.Classical,
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
      expect(engine, isNotNull);
    });
  });
}
