import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style_resolver.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_star_palette.dart';
import 'package:qizhengsiyu/painter/painters.dart';
import 'package:qizhengsiyu/painter/star_xiu_ring_painter.dart';
import 'package:qizhengsiyu/presentation/adapters/legacy/qizheng_legacy_board.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/widgets/destiny_twelve_gong_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/panel_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/ring_layer.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_12_dizhi.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_shen_sha_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/star_body_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/star_ring_layer.dart';
import 'package:qizhengsiyu/presentation/widgets/star_track_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_default_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_grid_ring.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:metaphysics_core/models/shen_sha.dart';

/// Renderer mode for the QiZheng board.
enum BoardRenderer {
  /// Original production board composition (from BeautyViewPage.panel()).
  /// Uses the original StarRingLayer / InnerStarTrackRingWidget / etc.
  production,

  /// Refactored legacy adapter board (QiZhengLegacyBoard).
  /// Uses UnifiedStarTrackRing / UnifiedStarBodyRing from metaphysics-chart-ui.
  qiZhengLegacy,
}

/// A switch widget that renders either the old production board or the
/// refactored [QiZhengLegacyBoard] depending on [renderer].
///
/// When [renderer] is [BoardRenderer.production], the widget tree is identical
/// to `BeautyViewPage.panel()` — the original production composition.
///
/// When [renderer] is [BoardRenderer.qiZhengLegacy], the refactored adapter is
/// used, which delegates to `UnifiedStarTrackRing` / `UnifiedStarBodyRing`.
///
/// Set [renderer] to [BoardRenderer.production] as a one-click fallback to the
/// old implementation at any time.
class QiZhengBoardSwitch extends StatelessWidget {
  final BoardRenderer renderer;

  // --- Shared parameters (same as QiZhengLegacyBoard) ---
  final QiZhengSiYuPanSizeDataModel panelSizeDataModel;
  final List<UIStarModel> innerStars;
  final List<UIStarModel> outerStars;
  final Widget centerWidget;
  final ZhouTianModel? zhouTianModel;
  final List<String>? destinyContentList;
  final TextStyle? destinyTextStyle;
  final ValueNotifier<bool>? showTaiJiButtonNotifier;
  final void Function(String gongName)? onSelectTaiJiByGongName;
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
    required this.panelSizeDataModel,
    required this.innerStars,
    required this.outerStars,
    required this.centerWidget,
    this.zhouTianModel,
    this.destinyContentList,
    this.destinyTextStyle,
    this.showTaiJiButtonNotifier,
    this.onSelectTaiJiByGongName,
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
        return _QiZhengProductionBoard(
          panelSizeDataModel: panelSizeDataModel,
          innerStars: innerStars,
          outerStars: outerStars,
          centerWidget: centerWidget,
          zhouTianModel: zhouTianModel,
          destinyContentList: destinyContentList,
          destinyTextStyle: destinyTextStyle,
          innerShenShaMapper: innerShenShaMapper,
          outerShenShaMapper: outerShenShaMapper,
          allStarsShowNotifier: allStarsShowNotifier,
          rotating: rotating,
        );
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
          onSelectTaiJiByGongName: onSelectTaiJiByGongName,
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

// ---------------------------------------------------------------------------
// QiZheng Production Board — exact copy of BeautyViewPage.panel() composition
// ---------------------------------------------------------------------------
class _QiZhengProductionBoard extends StatelessWidget {
  final QiZhengSiYuPanSizeDataModel panelSizeDataModel;
  final List<UIStarModel> innerStars;
  final List<UIStarModel> outerStars;
  final Widget centerWidget;
  final ZhouTianModel? zhouTianModel;
  final List<String>? destinyContentList;
  final TextStyle? destinyTextStyle;
  final Map<EnumTwelveGong, List<ShenSha>>? innerShenShaMapper;
  final Map<EnumTwelveGong, List<ShenSha>>? outerShenShaMapper;
  final ValueNotifier<bool>? allStarsShowNotifier;
  final double rotating;

  const _QiZhengProductionBoard({
    required this.panelSizeDataModel,
    required this.innerStars,
    required this.outerStars,
    required this.centerWidget,
    this.zhouTianModel,
    this.destinyContentList,
    this.destinyTextStyle,
    this.innerShenShaMapper,
    this.outerShenShaMapper,
    this.allStarsShowNotifier,
    this.rotating = 0,
  });

  @override
  Widget build(BuildContext context) {
    final styleResolver = const FallbackChartStyleResolver();
    final chartStyle = styleResolver.resolve(Brightness.light);
    final palette = styleResolver.resolvePalette(Brightness.light);

    final TextStyle firstTextStyle = TextStyle(
      fontSize: 18,
      height: 1.0,
      color: Colors.black87,
      shadows: const [
        Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3),
      ],
    );
    final TextStyle secondTextStyle = TextStyle(
      fontSize: 12,
      height: 1.0,
      color: Colors.black87,
      shadows: const [
        Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 3),
      ],
    );

    return PanelWidget(
      canvasSize: panelSizeDataModel.outerShenShaSizeOuter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -30 * pi / 180,
            child: centerWidget,
          ),

          // 1. 十二地支宫
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.diZhi12GongInner,
              outerSize: panelSizeDataModel.diZhi12GongOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (zhouTianModel == null) return const SizedBox();
              return Gong12DiZhiRing(
                zhouTianModel: zhouTianModel!,
                outerRadius: panelSizeDataModel.diZhi12GongOuter * 0.5,
                innerRadius: panelSizeDataModel.diZhi12GongInner * 0.5,
                shenShaMapper: {
                  EnumTwelveGong.Zi: [
                    Text("子", style: firstTextStyle),
                    Text("坎", style: secondTextStyle),
                    Text("土", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Chou: [
                    Text("丑", style: firstTextStyle),
                    Text("艮", style: secondTextStyle),
                    Text("土", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Yin: [
                    Text("寅", style: firstTextStyle),
                    Text("艮", style: secondTextStyle),
                    Text("木", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Mao: [
                    Text("卯", style: firstTextStyle),
                    Text("震", style: secondTextStyle),
                    Text("火", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Chen: [
                    Text("辰", style: firstTextStyle),
                    Text("巽", style: secondTextStyle),
                    Text("金", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Si: [
                    Text("巳", style: firstTextStyle),
                    Text("巽", style: secondTextStyle),
                    Text("水", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Wu: [
                    Text("午", style: firstTextStyle),
                    Text("离", style: secondTextStyle),
                    Text("日", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Wei: [
                    Text("未", style: firstTextStyle),
                    Text("坤", style: secondTextStyle),
                    Text("月", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Shen: [
                    Text("申", style: firstTextStyle),
                    Text("坤", style: secondTextStyle),
                    Text("水", style: secondTextStyle),
                  ],
                  EnumTwelveGong.You: [
                    Text("酉", style: firstTextStyle),
                    Text("兑", style: secondTextStyle),
                    Text("金", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Xu: [
                    Text("戌", style: firstTextStyle),
                    Text("乾", style: secondTextStyle),
                    Text("火", style: secondTextStyle),
                  ],
                  EnumTwelveGong.Hai: [
                    Text("亥", style: firstTextStyle),
                    Text("乾", style: secondTextStyle),
                    Text("木", style: secondTextStyle),
                  ],
                },
              );
            },
          ),

          // 2. 黄道十二宫
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.zodiac12GongSizeInner,
              outerSize: panelSizeDataModel.zodiac12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () => generateDefault12GongRing(
              panelSizeDataModel.zodiac12GongSizeInner * 0.5,
              panelSizeDataModel.zodiac12GongSizeOuter * 0.5,
              QiZhengLegacyBoard.defaultZodiac12GongMapper,
            ),
          ),

          // 3. 星序宫
          if (panelSizeDataModel.starSeq12GongHeight > 0)
            RingLayer(
              showTrack: false,
              showGrid: false,
              gridBuilder: () => TwelveGongGridRingWidget(
                innerSize: panelSizeDataModel.starSeq12GongSizeInner,
                outerSize: panelSizeDataModel.starSeq12GongSizeOuter,
              ),
              bodyRotationAngle: -30 * pi / 180,
              bodyBuilder: () => generateDefault12GongRing(
                panelSizeDataModel.starSeq12GongSizeInner * 0.5,
                panelSizeDataModel.starSeq12GongSizeOuter * 0.5,
                QiZhengLegacyBoard.defaultStarSeq12GongMapper,
              ),
            ),

          // 4. 命理十二宫
          RingLayer(
            showTrack: false,
            showGrid: true,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.destiny12GongSizeInner,
              outerSize: panelSizeDataModel.destiny12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              final contentList =
                  destinyContentList ?? QiZhengLegacyBoard.defaultDestinyList;
              final style = destinyTextStyle ??
                  GoogleFonts.maShanZheng(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  );
              return DestinyTwelveGongRingWidget(
                innerSize: panelSizeDataModel.destiny12GongSizeInner,
                outerSize: panelSizeDataModel.destiny12GongSizeOuter,
                contentList: contentList,
                textStyle: style,
                onSelectTaiJiByGongName: (_) {},
                onUnselectTaiJi: () {},
              );
            },
          ),

          // 5. 二十八星宿环
          RingLayer(
            showTrack: true,
            showGrid: false,
            trackRotationAngle: rotating * pi / 180,
            trackBuilder: () => Container(
              width: panelSizeDataModel.starXiu28RingSizeOuter,
              height: panelSizeDataModel.starXiu28RingSizeOuter,
              alignment: Alignment.center,
              child: CustomPaint(
                size: Size(
                  panelSizeDataModel.starXiu28RingSizeOuter,
                  panelSizeDataModel.starXiu28RingSizeOuter,
                ),
                painter: IndicatorScalePainter(
                  ringWidth: 40,
                  tickLength: 7,
                  indicatorAngle: 45.1,
                  style: chartStyle,
                ),
              ),
            ),
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.starXiu28RingSizeInner,
              outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
            ),
            bodyRotationAngle: rotating * pi / 180,
            bodyBuilder: () => RepaintBoundary(
              child: Container(
                width: panelSizeDataModel.starXiu28RingSizeOuter,
                height: panelSizeDataModel.starXiu28RingSizeOuter,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.4), width: 1),
                  borderRadius: BorderRadius.circular(
                      panelSizeDataModel.starXiu28RingSizeOuter * 0.5),
                ),
                child: CustomPaint(
                  size: Size(
                    panelSizeDataModel.starXiu28RingSizeOuter,
                    panelSizeDataModel.starXiu28RingSizeOuter,
                  ),
                  painter: StarXiuRingPainter(
                    outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
                    innerSize: panelSizeDataModel.starXiu28RingSizeInner,
                    mapper: QiZhengSiYuConstantResources
                        .ZodiacTropicalModernStarsInnSystemMapper,
                    sevenZhengColorMapper: palette.zhengColorMap,
                    style: chartStyle,
                  ),
                ),
              ),
            ),
          ),

          // 6 & 7. Inner Star Track & Body
          StarRingLayer(
            starsListenable: ValueNotifier(innerStars),
            outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
            innerSize: panelSizeDataModel.innerLifeStarRingInnerSize,
            showTrack: true,
            showGrid: false,
            trackRotationAngle: rotating * pi / 180,
            bodyRotationAngle: -(rotating - 90) * pi / 180,
            trackBuilder: (stars) => InnerStarTrackRingWidget(
              stars: stars,
              outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
              innerSize: panelSizeDataModel.innerLifeStarRingInnerSize,
              trackSize: panelSizeDataModel.innerLifeStarRingTrackSize,
            ),
            gridBuilder: twelveGongGridBuilder,
            bodyBuilder: (stars) => InnerStarBodyRotatingWidget(
              stars: stars,
              outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
              trackSize: panelSizeDataModel.innerLifeStarRingTrackSize,
              starBodySize: panelSizeDataModel.starBodyRadius * 2,
              allStarsShowNotifier:
                  allStarsShowNotifier ?? ValueNotifier<bool>(false),
            ),
          ),

          // 8 & 9. Outer Star Track & Body
          StarRingLayer(
            starsListenable: ValueNotifier(outerStars),
            outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
            innerSize: panelSizeDataModel.outerLifeStarRingInnerSize,
            showTrack: true,
            showGrid: false,
            trackRotationAngle: rotating * pi / 180,
            bodyRotationAngle: -(rotating - 90) * pi / 180,
            trackBuilder: (stars) => OuterStarTrackRingWidget(
              stars: stars,
              outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
              innerSize: panelSizeDataModel.outerLifeStarRingInnerSize,
              trackSize: panelSizeDataModel.outerLifeStarRingTrackSize,
            ),
            gridBuilder: twelveGongGridBuilder,
            bodyBuilder: (stars) => OuterStarBodyRotatingWidget(
              stars: stars,
              outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
              trackSize: panelSizeDataModel.outerLifeStarRingTrackSize,
              starBodySize: panelSizeDataModel.starBodyRadius * 2,
              allStarsShowNotifier:
                  allStarsShowNotifier ?? ValueNotifier<bool>(false),
            ),
          ),

          // 10. Inner ShenSha
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.innerShenShaSizeInner,
              outerSize: panelSizeDataModel.innerShenShaSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (innerShenShaMapper == null || zhouTianModel == null) {
                return const SizedBox();
              }
              return AllShenShaRing(
                outerRadius: panelSizeDataModel.innerShenShaSizeOuter * 0.5,
                innerRadius: panelSizeDataModel.innerShenShaSizeInner * 0.5,
                shenShaMapper: innerShenShaMapper!,
                gongOrder: EnumTwelveGong.listAll,
                zhouTianModel: zhouTianModel!,
              );
            },
          ),

          // 11. Outer ShenSha
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.outerShenShaSizeInner,
              outerSize: panelSizeDataModel.outerShenShaSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () {
              if (outerShenShaMapper == null || zhouTianModel == null) {
                return const SizedBox();
              }
              return AllShenShaRing(
                outerRadius: panelSizeDataModel.outerShenShaSizeOuter * 0.5,
                innerRadius: panelSizeDataModel.outerShenShaSizeInner * 0.5,
                shenShaMapper: outerShenShaMapper!,
                gongOrder: EnumTwelveGong.listAll,
                zhouTianModel: zhouTianModel!,
              );
            },
          ),
        ],
      ),
    );
  }
}
