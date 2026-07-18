import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/passage_year_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/yuan_le_panel_model.dart';
import 'package:qizhengsiyu/domain/services/yuan_le_panel_builder.dart';

/// 垣乐面板装配用例 — Widget 不再直接消费 domain service。
final class BuildYuanLePanelUseCase {
  final YuanLePanelBuilder _builder;

  BuildYuanLePanelUseCase({required YuanLePanelBuilder builder})
      : _builder = builder;

  Future<YuanLePanel> execute(
    BasePanelModel natalPanel, {
    PassageYearPanelModel? transitPanel,
    ZhouTianModel? zhouTianModel,
  }) =>
      _builder.build(
        natalPanel,
        transitPanel: transitPanel,
        zhouTianModel: zhouTianModel,
      );
}
