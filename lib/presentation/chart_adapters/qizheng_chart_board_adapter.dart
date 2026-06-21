/// QiZheng ChartBoard adapter: maps resolved domain snapshot to ChartBoard.
///
/// This file is pure mapping code. It reads an immutable snapshot produced
/// by the collision solver and outputs a neutral [ChartBoard].
library;

import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
import 'package:metaphysics_core/enums.dart';

import 'qizheng_chart_board_snapshot.dart';

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
    return ChartBoard(
      moduleId: ModuleId.qizhengsiyu,
      instanceId: context.instanceId,
      layout: BoardLayout(
        family: BoardLayoutFamily.circular,
        metadata: const {'totalDegree': 360.0},
      ),
      layers: [
        _buildPalaceLayer(input),
        _buildTickLayer(input),
        _buildConstellationLayer(input),
        _buildStarPointLayer(input),
      ],
      metadata: {
        'panelSystemType': input.panelSystemType.name,
        'constellationSystemType': input.constellationSystemType.name,
      },
    );
  }

  // ----- Layer builders ----------------------------------------------------

  /// 12-sector palace layer (one sector per 地支 gong).
  ChartLayer _buildPalaceLayer(QiZhengChartBoardSnapshot input) {
    final gongOrder = input.gongOrder;
    final sweepAngle = input.totalDegree / gongOrder.length;

    final sectors = <ChartSector>[];
    for (int i = 0; i < gongOrder.length; i++) {
      final gong = gongOrder[i];
      final startAngle = (i * sweepAngle) % input.totalDegree;
      sectors.add(ChartSector(
        id: 'gong:${gong.name}',
        index: i,
        label: gong.fullname,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        metadata: {
          'zhi': gong.zhi.name,
          'houTianGua': gong.houTianGua.name,
          'sevenZheng': gong.sevenZheng.singleName,
        },
      ));
    }

    return SectorLayer(
      id: 'palace-ring',
      zIndex: 0,
      styleRole: 'palace',
      hitTestMode: HitTestMode.sector,
      semanticsMode: SemanticsMode.group,
      sectors: sectors,
    );
  }

  /// 360-degree tick layer.
  ChartLayer _buildTickLayer(QiZhengChartBoardSnapshot input) {
    return TickLayer(
      id: 'degree-ticks',
      zIndex: 1,
      styleRole: 'ticks',
      majorTickInterval: 30,
      minorTickInterval: 1,
      tickLabelInterval: 10,
      metadata: {'totalDegree': input.totalDegree},
    );
  }

  /// 28-constellation arc layer (non-uniform arc widths).
  ChartLayer _buildConstellationLayer(QiZhengChartBoardSnapshot input) {
    final arcs = <ArcSegment>[];
    double runningAngle = 0;

    for (final entry in input.constellations) {
      arcs.add(ArcSegment(
        id: 'inn:${entry.constellation.starName}',
        startAngle: runningAngle,
        sweepAngle: entry.degree,
        label: entry.constellation.starName,
        metadata: {
          'constellation': entry.constellation.name,
        },
      ));
      runningAngle += entry.degree;
    }

    return ArcLayer(
      id: 'constellation-ring',
      zIndex: 2,
      styleRole: 'constellation',
      arcs: arcs,
    );
  }

  /// Star point layer with dual-angle AngularPoints.
  ///
  /// Each star gets an [AngularPoint] preserving both originalAngle (pre-
  /// collision guide dot) and displayAngle (post-collision holder dot).
  ChartLayer _buildStarPointLayer(QiZhengChartBoardSnapshot input) {
    final items = <ChartItemBase>[];

    for (final star in input.stars) {
      final displayAngle = star.resolvedAngle;
      final needsLeader =
          (displayAngle - star.originalAngle).abs() > 0.01;

      items.add(AngularPoint(
        originalAngle: star.originalAngle,
        displayAngle: displayAngle,
        leader: needsLeader,
        metadata: {
          'starId': star.star.name,
          'starName': star.star.singleName,
          'priority': star.priority,
        },
      ));
    }

    return PointLayer(
      id: 'star-points',
      zIndex: 10,
      styleRole: 'stars',
      hitTestMode: HitTestMode.item,
      semanticsMode: SemanticsMode.perItem,
      items: items,
    );
  }
}
