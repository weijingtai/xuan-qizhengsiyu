/// QiZheng ChartBoard adapter: maps resolved domain snapshot to ChartBoard.
///
/// This file is pure mapping code. It reads an immutable snapshot produced
/// by the collision solver and outputs a neutral [ChartBoard].
library;

import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';

import '../../domain/entities/models/panel_ui_size.dart';
import '../../domain/entities/models/zhou_tian_model.dart';
import '../../enums/enum_twelve_gong.dart';
import '../models/ui_star_model.dart';
import 'qizheng_chart_board_snapshot.dart';

ChartBoard buildQiZhengChartBoardFromLegacyInputs({
  required QiZhengSiYuPanSizeDataModel panelSize,
  required List<UIStarModel> innerStars,
  required List<UIStarModel> outerStars,
  required ZhouTianModel? zhouTianModel,
}) {
  final snapshot = QiZhengChartBoardSnapshot(
    totalDegree: zhouTianModel?.totalDegree ?? 360,
    panelSystemType: zhouTianModel?.panelSystemType ?? PanelSystemType.Tropical,
    constellationSystemType:
        zhouTianModel?.constellationSystemType ??
        ConstellationSystemType.Classical,
    gongOrder: zhouTianModel?.gongOrder ?? EnumTwelveGong.listAll,
    stars: [...innerStars, ...outerStars]
        .map(
          (star) => StarSnapshot(
            star: star.star,
            originalAngle: star.originalAngle,
            resolvedAngle: star.angle,
            priority: star.priority,
          ),
        )
        .toList(growable: false),
    constellations:
        zhouTianModel?.starInnDegreeSeq
            .map(
              (entry) => ConstellationSnapshot(
                constellation: entry.constellation,
                degree: entry.degree,
              ),
            )
            .toList(growable: false) ??
        const [],
    ringLayout: QiZhengRingLayoutSnapshot.fromPanelSize(panelSize),
  );
  return const QiZhengChartBoardAdapter().buildBoard(
    snapshot,
    ChartBoardAdapterContext(
      moduleId: ModuleId.qizhengsiyu,
      instanceId: snapshot.instanceId,
    ),
  );
}

// ---------------------------------------------------------------------------
// QiZhengChartBoardAdapter
// ---------------------------------------------------------------------------

/// Maps a resolved QiZhengSiYu panel snapshot into a neutral [ChartBoard].
///
/// Contract rules:
/// - Imports only module domain models (snapshot) + public ChartBoard API.
/// - Does NOT import package internals.
/// - Does NOT mutate the ChartBoard after creation.
/// - Assigns stable ids for sectors/items.
/// - Preserves both originalAngle and displayAngle via [AngularPoint].
class QiZhengChartBoardAdapter
    extends ChartBoardAdapter<QiZhengChartBoardSnapshot> {
  const QiZhengChartBoardAdapter();

  @override
  ChartBoard buildBoard(
    QiZhengChartBoardSnapshot input,
    ChartBoardAdapterContext context,
  ) {
    final rings = input.ringLayout;
    return ChartBoard(
      moduleId: ModuleId.qizhengsiyu,
      instanceId: context.instanceId,
      center: BoardCenterSpec(
        radius: rings.centerRadius,
        mode: CenterContentMode.widget,
        metadata: const {'legacyRingId': 'center'},
      ),
      layout: BoardLayout(
        family: BoardLayoutFamily.circular,
        metadata: const {'totalDegree': 360.0},
      ),
      layers: [
        _buildPalaceLayer(
          input,
          'earth-branch-ring',
          rings.diZhiInnerRadius,
          rings.diZhiOuterRadius,
          'earthBranch',
        ),
        _buildPalaceLayer(
          input,
          'zodiac-ring',
          rings.zodiacInnerRadius,
          rings.zodiacOuterRadius,
          'zodiac',
        ),
        _buildPalaceLayer(
          input,
          'star-sequence-ring',
          rings.starSequenceInnerRadius,
          rings.starSequenceOuterRadius,
          'starSequence',
          visible: rings.hasStarSequence,
          optional: true,
        ),
        _buildPalaceLayer(
          input,
          'destiny-ring',
          rings.destinyInnerRadius,
          rings.destinyOuterRadius,
          'destiny',
        ),
        _buildTickLayer(input, rings),
        _buildConstellationLayer(input, rings),
        _buildTrackRing(
          'inner-star-track-ring',
          rings.innerStarInnerRadius,
          rings.innerStarOuterRadius,
          6,
        ),
        _buildStarPointLayer(input, rings),
        _buildTrackRing(
          'outer-star-track-ring',
          rings.outerStarInnerRadius,
          rings.outerStarOuterRadius,
          8,
        ),
        OverlayLayer(
          id: 'outer-star-body-ring',
          zIndex: 9,
          behavior: LayerBehavior(
            innerRadius: rings.outerStarInnerRadius,
            outerRadius: rings.outerStarOuterRadius,
            startAngleOffset: 90,
          ),
          metadata: const {
            'ringId': 'outer-star-track-ring',
            'legacyRole': 'body',
          },
        ),
        _buildGuideRing(
          'inner-shensha-ring',
          rings.innerShenShaInnerRadius,
          rings.innerShenShaOuterRadius,
          10,
        ),
        _buildGuideRing(
          'outer-shensha-ring',
          rings.outerShenShaInnerRadius,
          rings.outerShenShaOuterRadius,
          11,
        ),
      ],
      metadata: {
        'panelSystemType': input.panelSystemType.name,
        'constellationSystemType': input.constellationSystemType.name,
      },
    );
  }

  // ----- Layer builders ----------------------------------------------------

  /// 12-sector palace layer (one sector per 地支 gong).
  ChartLayer _buildPalaceLayer(
    QiZhengChartBoardSnapshot input,
    String id,
    double innerRadius,
    double outerRadius,
    String styleRole, {
    bool visible = true,
    bool optional = false,
  }) {
    final gongOrder = input.gongOrder;
    final sweepAngle = input.totalDegree / gongOrder.length;

    final sectors = <ChartSector>[];
    for (int i = 0; i < gongOrder.length; i++) {
      final gong = gongOrder[i];
      final startAngle = (i * sweepAngle) % input.totalDegree;
      sectors.add(
        ChartSector(
          id: '$id:${gong.name}',
          index: i,
          label: gong.fullname,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          metadata: {
            'zhi': gong.zhi.name,
            'houTianGua': gong.houTianGua.name,
            'sevenZheng': gong.sevenZheng.singleName,
          },
        ),
      );
    }

    return SectorLayer(
      id: id,
      zIndex: 0,
      visible: visible,
      styleRole: styleRole,
      hitTestMode: HitTestMode.sector,
      semanticsMode: SemanticsMode.group,
      behavior: LayerBehavior(
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        startAngleOffset: -30,
      ),
      metadata: {
        'legacyOrder': id,
        if (optional) 'optional': true,
        if (optional && !visible) 'skippedReason': 'zeroWidth',
      },
      sectors: sectors,
    );
  }

  /// 360-degree tick layer.
  ChartLayer _buildTickLayer(
    QiZhengChartBoardSnapshot input,
    QiZhengRingLayoutSnapshot rings,
  ) {
    return TickLayer(
      id: 'degree-ticks',
      zIndex: 1,
      styleRole: 'ticks',
      majorTickInterval: 30,
      minorTickInterval: 1,
      tickLabelInterval: 10,
      tickLength: 7,
      behavior: LayerBehavior(
        innerRadius: rings.constellationInnerRadius,
        outerRadius: rings.constellationOuterRadius,
      ),
      metadata: {'totalDegree': input.totalDegree},
    );
  }

  /// 28-constellation arc layer (non-uniform arc widths).
  ChartLayer _buildConstellationLayer(
    QiZhengChartBoardSnapshot input,
    QiZhengRingLayoutSnapshot rings,
  ) {
    final arcs = <ArcSegment>[];
    double runningAngle = 0;

    for (final entry in input.constellations) {
      arcs.add(
        ArcSegment(
          id: 'inn:${entry.constellation.starName}',
          startAngle: runningAngle,
          sweepAngle: entry.degree,
          label: entry.constellation.starName,
          metadata: {'constellation': entry.constellation.name},
        ),
      );
      runningAngle += entry.degree;
    }

    return ArcLayer(
      id: 'constellation-ring',
      zIndex: 2,
      styleRole: 'constellation',
      behavior: LayerBehavior(
        innerRadius: rings.constellationInnerRadius,
        outerRadius: rings.constellationOuterRadius,
      ),
      arcs: arcs,
    );
  }

  /// Star point layer with dual-angle AngularPoints.
  ///
  /// Each star gets an [AngularPoint] preserving both originalAngle (pre-
  /// collision guide dot) and displayAngle (post-collision holder dot).
  ChartLayer _buildStarPointLayer(
    QiZhengChartBoardSnapshot input,
    QiZhengRingLayoutSnapshot rings,
  ) {
    final items = <ChartItemBase>[];

    for (final star in input.stars) {
      final displayAngle = star.resolvedAngle;
      final needsLeader = (displayAngle - star.originalAngle).abs() > 0.01;

      items.add(
        AngularPoint(
          originalAngle: star.originalAngle,
          displayAngle: displayAngle,
          leader: needsLeader,
          metadata: {
            'starId': star.star.name,
            'starName': star.star.singleName,
            'priority': star.priority,
          },
        ),
      );
    }

    return PointLayer(
      id: 'inner-star-body-ring',
      zIndex: 7,
      styleRole: 'stars',
      hitTestMode: HitTestMode.item,
      semanticsMode: SemanticsMode.perItem,
      behavior: LayerBehavior(
        innerRadius: rings.innerStarInnerRadius,
        outerRadius: rings.innerStarOuterRadius,
        startAngleOffset: 90,
      ),
      items: items,
    );
  }

  SectorLayer _buildGuideRing(
    String id,
    double innerRadius,
    double outerRadius,
    int zIndex,
  ) {
    return SectorLayer(
      id: id,
      zIndex: zIndex,
      styleRole: 'ringGuide',
      hitTestMode: HitTestMode.none,
      semanticsMode: SemanticsMode.none,
      behavior: LayerBehavior(
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        startAngleOffset: -30,
      ),
      sectors: List.generate(
        12,
        (index) => ChartSector(id: '$id:$index', index: index),
      ),
    );
  }

  ArcLayer _buildTrackRing(
    String id,
    double innerRadius,
    double outerRadius,
    int zIndex,
  ) {
    return ArcLayer(
      id: id,
      zIndex: zIndex,
      styleRole: 'ringGuide',
      hitTestMode: HitTestMode.none,
      semanticsMode: SemanticsMode.none,
      behavior: LayerBehavior(
        innerRadius: innerRadius,
        outerRadius: outerRadius,
      ),
      arcs: [
        ArcSegment(id: '$id:whole', startAngle: 0, sweepAngle: 360),
      ],
    );
  }
}
