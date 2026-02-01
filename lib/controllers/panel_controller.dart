import 'package:flutter/foundation.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/da_xian_panel_model.dart'; // 暂时保留UI层模型
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

/// 面板控制器的抽象接口：统一管理旋转、配置与各层数据通知器。
abstract class PanelController {
  /// 面板旋转角度（度数，顺时针为正）。
  ValueListenable<double> get rotationDeg;

  /// 面板配置：尺寸、显示开关等。
  PanelConfig get config;

  /// 本命盘（基础盘）数据通知器。
  ValueListenable<BasePanelModel?> get basePanel;

  /// 大限盘（行限盘）数据通知器。
  ValueListenable<DaXianPanelModel?> get daXianPanel;

  /// 内圈星体（通常对应本命盘星体）通知器。
  ValueListenable<List<UIStarModel>?> get innerStars;

  /// 外圈星体（通常对应行限盘星体）通知器。
  ValueListenable<List<UIStarModel>?> get outerStars;

  /// 更新旋转角度。
  void setRotation(double deg);

  /// 更新面板配置。
  void updateConfig(PanelConfig newConfig);

  /// 释放资源。
  void dispose();
}

/// 针对七政四余模块的默认控制器实现，直接封装现有 ViewModel 的通知器。
class QiZhengPanelController implements PanelController {
  final ValueNotifier<double> _rotationDeg;
  PanelConfig _config;

  @override
  final ValueListenable<BasePanelModel?> basePanel;

  @override
  final ValueListenable<DaXianPanelModel?> daXianPanel;

  @override
  final ValueListenable<List<UIStarModel>?> innerStars;

  @override
  final ValueListenable<List<UIStarModel>?> outerStars;

  QiZhengPanelController({
    required PanelConfig config,
    required ValueListenable<BasePanelModel?> basePanel,
    required ValueListenable<DaXianPanelModel?> daXianPanel,
    required ValueListenable<List<UIStarModel>?> innerStars,
    required ValueListenable<List<UIStarModel>?> outerStars,
    double rotationDeg = 0,
  })  : _config = config,
        basePanel = basePanel,
        daXianPanel = daXianPanel,
        innerStars = innerStars,
        outerStars = outerStars,
        _rotationDeg = ValueNotifier<double>(rotationDeg);

  @override
  ValueListenable<double> get rotationDeg => _rotationDeg;

  @override
  PanelConfig get config => _config;

  @override
  void setRotation(double deg) {
    _rotationDeg.value = deg;
  }

  @override
  void updateConfig(PanelConfig newConfig) {
    _config = newConfig;
  }

  @override
  void dispose() {
    _rotationDeg.dispose();
  }
}
