import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'i_calculation_engine.dart';

abstract interface class ICalculationEngineProvider {
  ICalculationEngine getEngine(BasePanelConfig config);
}

/// 引擎工厂，由 DI 层初始化提供程序，不再直接硬编码具体引擎类。
class CalculationEngineFactory {
  static ICalculationEngineProvider? _provider;

  static void setProvider(ICalculationEngineProvider provider) {
    _provider = provider;
  }

  static ICalculationEngine create(BasePanelConfig config) {
    if (_provider == null) {
      throw StateError('CalculationEngineFactory has not been initialized with a provider. Call setProvider() first.');
    }
    return _provider!.getEngine(config);
  }
}
