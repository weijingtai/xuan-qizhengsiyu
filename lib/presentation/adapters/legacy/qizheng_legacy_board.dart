import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart' hide
    PanelWidget,
    RingLayer,
    StarRingLayer,
    TwelveGongGridRingWidget;
import 'package:qizhengsiyu/presentation/widgets/panel_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/ring_layer.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_grid_ring.dart';
import 'package:metaphysics_core/models/shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_ui_size.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/painter/chart_style/chart_style_resolver.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_chart_style.dart';
import 'package:qizhengsiyu/painter/chart_style/qi_zheng_star_palette.dart';
import 'package:qizhengsiyu/painter/painters.dart';
import 'package:qizhengsiyu/painter/star_body_ring_painter.dart';
import 'package:qizhengsiyu/painter/star_xiu_ring_painter.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';
import 'package:qizhengsiyu/presentation/widgets/destiny_twelve_gong_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_12_dizhi.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_shen_sha_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/star_body.dart';
import 'package:qizhengsiyu/presentation/widgets/twelve_gong_default_ring.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';

class QiZhengLegacyBoard extends StatelessWidget {
  final QiZhengSiYuPanSizeDataModel panelSizeDataModel;
  final List<UIStarModel> innerStars;
  final List<UIStarModel> outerStars;
  final Widget centerWidget;

  // --- 十二地支宫 data ---
  final ZhouTianModel? zhouTianModel;

  // --- 命理十二宫 data ---
  final List<String>? destinyContentList;
  final TextStyle? destinyTextStyle;
  final ValueNotifier<bool>? showTaiJiButtonNotifier;
  final void Function(String gongName)? onSelectTaiJiByGongName;
  final VoidCallback? onUnselectTaiJi;

  // --- 二十八星宿环 data ---
  final QiZhengChartStyle? chartStyle;
  final QiZhengStarPalette? starPalette;
  final double rotating; // rotating angle in degrees for star xiu ring

  // --- 神煞 & Star show notifier ---
  final Map<EnumTwelveGong, List<ShenSha>>? innerShenShaMapper;
  final Map<EnumTwelveGong, List<ShenSha>>? outerShenShaMapper;
  final ValueNotifier<bool>? allStarsShowNotifier;

  const QiZhengLegacyBoard({
    super.key,
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

  // ---------------------------------------------------------------------------
  // Static default data (same as BeautyViewPage)
  // ---------------------------------------------------------------------------

  static const Map<EnumTwelveGong, List<String>> defaultZodiac12GongMapper = {
    EnumTwelveGong.Zi: ["水瓶"],
    EnumTwelveGong.Chou: ["摩羯"],
    EnumTwelveGong.Yin: ["射手"],
    EnumTwelveGong.Mao: ["天蝎"],
    EnumTwelveGong.Chen: ["天枰"],
    EnumTwelveGong.Si: ["处女"],
    EnumTwelveGong.Wu: ["狮子"],
    EnumTwelveGong.Wei: ["巨蟹"],
    EnumTwelveGong.Shen: ["双子"],
    EnumTwelveGong.You: ["金牛"],
    EnumTwelveGong.Xu: ["白羊"],
    EnumTwelveGong.Hai: ["双鱼"],
  };

  static const Map<EnumTwelveGong, List<String>> defaultStarSeq12GongMapper = {
    EnumTwelveGong.Zi: ["玄枵"],
    EnumTwelveGong.Chou: ["星纪"],
    EnumTwelveGong.Yin: ["析木"],
    EnumTwelveGong.Mao: ["大火"],
    EnumTwelveGong.Chen: ["寿星"],
    EnumTwelveGong.Si: ["鹑尾"],
    EnumTwelveGong.Wu: ["鹑火"],
    EnumTwelveGong.Wei: ["鹑首"],
    EnumTwelveGong.Shen: ["实沈"],
    EnumTwelveGong.You: ["大梁"],
    EnumTwelveGong.Xu: ["降娄"],
    EnumTwelveGong.Hai: ["娵訾"],
  };

  static const List<String> defaultDestinyList = <String>[
    "命宫",
    "财帛",
    "兄弟",
    "田宅",
    "男女",
    "奴仆",
    "夫妻",
    "疾厄",
    "迁移",
    "官禄",
    "福德",
    "相貌",
  ];

  // ---------------------------------------------------------------------------
  // Resolved style helpers
  // ---------------------------------------------------------------------------

  QiZhengChartStyle get _effectiveChartStyle =>
      chartStyle ?? const FallbackChartStyleResolver().resolve(Brightness.light);

  QiZhengStarPalette get _effectivePalette =>
      starPalette ??
      const FallbackChartStyleResolver().resolvePalette(Brightness.light);

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      canvasSize: panelSizeDataModel.outerShenShaSizeOuter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Center content (Rotated) ─────────────────────────────
          Transform.rotate(
            angle: -30 * pi / 180,
            child: centerWidget,
          ),

          // ── 1. 十二地支宫 (RingLayer) ─────────────────────────────
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
              return _build12DiZhiGong(
                panelSizeDataModel.diZhi12GongOuter * 0.5,
                panelSizeDataModel.diZhi12GongInner * 0.5,
                zhouTianModel!,
              );
            },
          ),

          // ── 2. 黄道十二宫 (RingLayer) ─────────────────────────────
          RingLayer(
            showTrack: false,
            showGrid: false,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.zodiac12GongSizeInner,
              outerSize: panelSizeDataModel.zodiac12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () => _buildZodiac12GongRing(
              panelSizeDataModel.zodiac12GongSizeInner * 0.5,
              panelSizeDataModel.zodiac12GongSizeOuter * 0.5,
            ),
          ),

          // ── 3. 星序宫 (RingLayer, enabled when starSeq12GongHeight > 0) ─
          if (panelSizeDataModel.starSeq12GongHeight > 0)
            RingLayer(
              showTrack: false,
              showGrid: false,
              gridBuilder: () => TwelveGongGridRingWidget(
                innerSize: panelSizeDataModel.starSeq12GongSizeInner,
                outerSize: panelSizeDataModel.starSeq12GongSizeOuter,
              ),
              bodyRotationAngle: -30 * pi / 180,
              bodyBuilder: () => _buildStarSeq12GongRing(
                panelSizeDataModel.starSeq12GongSizeInner * 0.5,
                panelSizeDataModel.starSeq12GongSizeOuter * 0.5,
              ),
            ),

          // ── 4. 命理十二宫 (RingLayer) ─────────────────────────────
          RingLayer(
            showTrack: false,
            showGrid: true,
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.destiny12GongSizeInner,
              outerSize: panelSizeDataModel.destiny12GongSizeOuter,
            ),
            bodyRotationAngle: -30 * pi / 180,
            bodyBuilder: () => _buildMingLi12GongRing(
              panelSizeDataModel.destiny12GongSizeInner,
              panelSizeDataModel.destiny12GongSizeOuter,
            ),
          ),

          // ── 5. 二十八星宿环 (RingLayer) ───────────────────────────
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
                  style: _effectiveChartStyle,
                ),
              ),
            ),
            gridBuilder: () => TwelveGongGridRingWidget(
              innerSize: panelSizeDataModel.starXiu28RingSizeInner,
              outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
            ),
            bodyRotationAngle: rotating * pi / 180,
            bodyBuilder: () => _buildStarXiuRing(
              panelSizeDataModel.starXiu28RingSizeOuter,
              40,
            ),
          ),

          // ── 5. Inner Star Track Ring ──────────────────────────────
          Transform.rotate(
            angle: rotating * pi / 180,
            child: UnifiedStarTrackRing(
              outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
              trackPainter: InnerLifeStarRangePainter(
                stars: innerStars,
                starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
                outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
                innerSize: panelSizeDataModel.innerLifeStarRingInnerSize,
                trackSize: panelSizeDataModel.innerLifeStarRingTrackSize,
                textStyle: GoogleFonts.notoSans(
                  fontSize: 24.0,
                  height: 1,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                  shadows: [
                    BoxShadow(
                      color: Colors.black38.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
              ),
            ),
          ),

          // ── 6. Inner Star Body Ring ───────────────────────────────
          Transform.rotate(
            angle: -(rotating - 90) * pi / 180,
            child: UnifiedStarBodyRing(
              outerSize: panelSizeDataModel.innerLifeStarRingOuterSize,
              trackSize: panelSizeDataModel.innerLifeStarRingTrackSize,
              starBodySize: panelSizeDataModel.starBodyRadius * 2,
              items: innerStars
                  .map((star) {
                    final textStyle = GoogleFonts.notoSans(
                      fontSize: 24.0,
                      height: 1,
                      color: QiZhengSiYuUIConstantResources.starsColorMap[star.star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(1, 1),
                        )
                      ],
                    );
                    return StarRingItemData(
                      angle: star.angle,
                      child: StarBody(
                        starBody: star,
                        starSize: panelSizeDataModel.starBodyRadius * 2,
                        allStarsShowNotifier: allStarsShowNotifier ?? ValueNotifier<bool>(false),
                        textStyle: textStyle,
                      ),
                    );
                  })
                  .toList(),
            ),
          ),

          // ── 7. Outer Star Track Ring ──────────────────────────────
          Transform.rotate(
            angle: rotating * pi / 180,
            child: UnifiedStarTrackRing(
              outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
              trackPainter: OuterLifeStarRangePainter(
                stars: outerStars,
                starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
                outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
                innerSize: panelSizeDataModel.outerLifeStarRingInnerSize,
                trackSize: panelSizeDataModel.outerLifeStarRingTrackSize,
                textStyle: GoogleFonts.notoSans(
                  fontSize: 24.0,
                  height: 1,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                  shadows: [
                    BoxShadow(
                      color: Colors.black38.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
              ),
            ),
          ),

          // ── 8. Outer Star Body Ring ───────────────────────────────
          Transform.rotate(
            angle: -(rotating - 90) * pi / 180,
            child: UnifiedStarBodyRing(
              outerSize: panelSizeDataModel.outerLifeStarRingOuterSize,
              trackSize: panelSizeDataModel.outerLifeStarRingTrackSize,
              starBodySize: panelSizeDataModel.starBodyRadius * 2,
              items: outerStars
                  .map((star) {
                    final textStyle = GoogleFonts.notoSans(
                      fontSize: 24.0,
                      height: 1,
                      color: QiZhengSiYuUIConstantResources.starsColorMap[star.star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(1, 1),
                        )
                      ],
                    );
                    return StarRingItemData(
                      angle: star.angle,
                      child: StarBody(
                        starBody: star,
                        starSize: panelSizeDataModel.starBodyRadius * 2,
                        allStarsShowNotifier: allStarsShowNotifier ?? ValueNotifier<bool>(false),
                        textStyle: textStyle,
                      ),
                    );
                  })
                  .toList(),
            ),
          ),

          // ── 9. Inner ShenSha Ring (RingLayer) ─────────────────────
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

          // ── 10. Outer ShenSha Ring (RingLayer) ────────────────────
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

  // ---------------------------------------------------------------------------
  // Ring builder: 十二地支宫
  // ---------------------------------------------------------------------------
  Widget _build12DiZhiGong(
    double outerRadius,
    double innerRadius,
    ZhouTianModel zhouTianModel,
  ) {
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
    return Gong12DiZhiRing(
      zhouTianModel: zhouTianModel,
      outerRadius: outerRadius,
      innerRadius: innerRadius,
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
  }

  // ---------------------------------------------------------------------------
  // Ring builder: 黄道十二宫
  // ---------------------------------------------------------------------------
  Widget _buildZodiac12GongRing(double innerSize, double outerSize) {
    return generateDefault12GongRing(
      innerSize,
      outerSize,
      defaultZodiac12GongMapper,
    );
  }

  // ---------------------------------------------------------------------------
  // Ring builder: 星序宫
  // ---------------------------------------------------------------------------
  Widget _buildStarSeq12GongRing(double innerSize, double outerSize) {
    return generateDefault12GongRing(
      innerSize,
      outerSize,
      defaultStarSeq12GongMapper,
    );
  }

  // ---------------------------------------------------------------------------
  // Ring builder: 命理十二宫
  // ---------------------------------------------------------------------------
  Widget _buildMingLi12GongRing(double innerSize, double outerSize) {
    final List<String> contentList =
        destinyContentList ?? defaultDestinyList;
    final TextStyle textStyle = destinyTextStyle ??
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
      innerSize: innerSize,
      outerSize: outerSize,
      contentList: contentList,
      textStyle: textStyle,
      showTaiJiButtonNotifier: showTaiJiButtonNotifier,
      onSelectTaiJiByGongName:
          onSelectTaiJiByGongName ?? (_) {},
      onUnselectTaiJi: onUnselectTaiJi ?? () {},
    );
  }

  // ---------------------------------------------------------------------------
  // Ring builder: 二十八星宿环
  // ---------------------------------------------------------------------------
  Widget _buildStarXiuRing(double size, double ringWidth) {
    final double outerRadius = size / 2;
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: StarXiuRingPainter(
            outerSize: panelSizeDataModel.starXiu28RingSizeOuter,
            innerSize: panelSizeDataModel.starXiu28RingSizeInner,
            mapper: QiZhengSiYuConstantResources
                .ZodiacTropicalModernStarsInnSystemMapper,
            sevenZhengColorMapper: _effectivePalette.zhengColorMap,
            style: _effectiveChartStyle,
          ),
        ),
      ),
    );
  }
}
