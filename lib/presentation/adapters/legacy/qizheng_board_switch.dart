import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_star_palette.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_legacy_board.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:metaphysics_core/models/shen_sha.dart';

/// Renderer mode for the QiZheng board.
enum BoardRenderer {
  /// Original production board composition — delegated to [productionBuilder].
  /// Uses the original BeautyViewPage.panel() implementation with zero code drift.
  production,

  /// Refactored legacy adapter board (QiZhengLegacyBoard).
  /// Uses UnifiedStarTrackRing / UnifiedStarBodyRing from metaphysics-chart-ui.
  qiZhengLegacy,
}

/// A switch widget that renders either the old production board (via a
/// [productionBuilder] callback) or the refactored [QiZhengLegacyBoard].
///
/// The [productionBuilder] callback **MUST** call the real original
/// `BeautyViewPage.panel()` implementation (or equivalent) — never a copy.
/// This guarantees that the rollback path has zero code drift.
///
/// Usage in production (BeautyViewPage):
/// ```dart
/// QiZhengBoardSwitch(
///   renderer: _currentRenderer,
///   productionBuilder: () => panel(starBodyRadius),
///   ...params for QiZhengLegacyBoard...,
/// )
/// ```
class QiZhengBoardSwitch extends StatelessWidget {
  final BoardRenderer renderer;

  /// Builder for the original production board. Must call the real original
  /// implementation (BeautyViewPage.panel()) — NOT a copy.
  final Widget Function()? productionBuilder;

  // --- Shared parameters (for QiZhengLegacyBoard path) ---
  final QiZhengSiYuPanSizeDataModel panelSizeDataModel;
  final List<UIStarModel> innerStars;
  final List<UIStarModel> outerStars;
  final Widget centerWidget;
  final ZhouTianModel? zhouTianModel;
  final List<String>? destinyContentList;
  final TextStyle? destinyTextStyle;
  final ValueNotifier<bool>? showTaiJiButtonNotifier;
  final ValueListenable<List<String>?>? selectedTaiJiContentListenable;
  final void Function(String gongName)? onSelectTaiJiByGongName;
  final void Function(int selectedIndex)? onSelectTaiJi;
  final VoidCallback? onUnselectTaiJi;
  final QiZhengChartStyle? chartStyle;
  final QiZhengStarPalette? starPalette;
  final double rotating;
  final Map<EnumTwelveGong, List<ShenSha>>? innerShenShaMapper;
  final Map<EnumTwelveGong, List<ShenSha>>? outerShenShaMapper;
  final ValueNotifier<bool>? allStarsShowNotifier;

  const QiZhengBoardSwitch({
    super.key,
    required this.renderer,
    this.productionBuilder,
    required this.panelSizeDataModel,
    required this.innerStars,
    required this.outerStars,
    required this.centerWidget,
    this.zhouTianModel,
    this.destinyContentList,
    this.destinyTextStyle,
    this.showTaiJiButtonNotifier,
    this.selectedTaiJiContentListenable,
    this.onSelectTaiJiByGongName,
    this.onSelectTaiJi,
    this.onUnselectTaiJi,
    this.chartStyle,
    this.starPalette,
    this.rotating = 0,
    this.innerShenShaMapper,
    this.outerShenShaMapper,
    this.allStarsShowNotifier,
  });

  @override
  Widget build(BuildContext context) {
    switch (renderer) {
      case BoardRenderer.production:
        final builder = productionBuilder;
        if (builder == null) {
          throw FlutterError(
            'QiZhengBoardSwitch.production requires productionBuilder.',
          );
        }
        return builder();
      case BoardRenderer.qiZhengLegacy:
        return QiZhengLegacyBoard(
          panelSizeDataModel: panelSizeDataModel,
          innerStars: innerStars,
          outerStars: outerStars,
          centerWidget: centerWidget,
          zhouTianModel: zhouTianModel,
          destinyContentList: destinyContentList,
          destinyTextStyle: destinyTextStyle,
          showTaiJiButtonNotifier: showTaiJiButtonNotifier,
          selectedTaiJiContentListenable: selectedTaiJiContentListenable,
          onSelectTaiJiByGongName: onSelectTaiJiByGongName,
          onSelectTaiJi: onSelectTaiJi,
          onUnselectTaiJi: onUnselectTaiJi,
          chartStyle: chartStyle,
          starPalette: starPalette,
          rotating: rotating,
          innerShenShaMapper: innerShenShaMapper,
          outerShenShaMapper: outerShenShaMapper,
          allStarsShowNotifier: allStarsShowNotifier,
        );
    }
  }
}
