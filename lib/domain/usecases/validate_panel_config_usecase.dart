import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/managers/panel_system_resolver.dart';

/// 面板配置制式校验用例(原 custom_config_section 内联 new PanelSystemResolver)。
final class ValidatePanelConfigUseCase {
  final PanelSystemResolver _resolver = PanelSystemResolver();

  PanelSystemCheck execute(
    BasePanelConfig config, {
    Set<String> availableAssetKeys = const {},
  }) =>
      _resolver.validate(config, availableAssetKeys: availableAssetKeys);
}
