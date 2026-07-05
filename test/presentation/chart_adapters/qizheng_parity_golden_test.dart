/// Deprecated adapter geometry characterization.
///
/// Verifies that the [QiZhengChartBoardAdapter] produces geometry consistent
/// with the old painter conventions (QiZhengSiYu sector layout):
///
/// - 12 sectors, each exactly 30° sweep
/// - First sector (Xu palace / 戌) starts at 0° engine position
///   (old painter convention: 345° = 12 o'clock − 15°; the adapter encodes
///   this via gong ordering + SectorLayer behavior startAngleOffset)
/// - Sectors ordered: 戌亥子丑寅卯辰巳午未申酉
/// - 360 ticks with major ticks at every 30°
/// - 28 constellation arcs tile to full 360°
/// - Star points have stable angles within their host sectors
/// - Hit-region ids are deterministic across runs
///
/// This is deliberately not acceptance parity evidence. Real visual parity is
/// exercised through BeautyViewPage.panel() in
/// `beauty_view_page_real_parity_test.dart`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/chart_adapters/qizheng_chart_board_adapter.dart';
import 'package:qizhengsiyu/presentation/chart_adapters/qizheng_chart_board_snapshot.dart';

// ---------------------------------------------------------------------------
// Parity fixture: old-painter-convention gong order (戌亥子丑寅卯辰巳午未申酉)
// ---------------------------------------------------------------------------

/// Builds a deterministic snapshot that mirrors the old painter layout.
///
/// Gong order follows the traditional 戌亥子丑寅卯辰巳午未申酉 sequence.
/// SectorLayer uses `startAngleOffset = -15` so that the first sector (戌)
/// begins at 345° (i.e. 12 o'clock − 15°), matching the old painter.
QiZhengChartBoardSnapshot buildOldConventionFixture() {
  // Old-painter gong order: 戌亥子丑寅卯辰巳午未申酉
  const gongOrder = <EnumTwelveGong>[
    EnumTwelveGong.Xu, // 戌  → engine index 0
    EnumTwelveGong.Hai, // 亥  → engine index 1
    EnumTwelveGong.Zi, // 子  → engine index 2
    EnumTwelveGong.Chou, // 丑  → engine index 3
    EnumTwelveGong.Yin, // 寅  → engine index 4
    EnumTwelveGong.Mao, // 卯  → engine index 5
    EnumTwelveGong.Chen, // 辰  → engine index 6
    EnumTwelveGong.Si, // 巳  → engine index 7
    EnumTwelveGong.Wu, // 午  → engine index 8
    EnumTwelveGong.Wei, // 未  → engine index 9
    EnumTwelveGong.Shen, // 申  → engine index 10
    EnumTwelveGong.You, // 酉  → engine index 11
  ];

  // 11 stars placed at representative positions.
  // originalAngle == resolvedAngle for most; some have collision offsets.
  final stars = <StarSnapshot>[
    const StarSnapshot(
      star: EnumStars.Sun,
      originalAngle: 5.5,
      resolvedAngle: 5.5,
      priority: 4,
    ),
    const StarSnapshot(
      star: EnumStars.Moon,
      originalAngle: 38.0,
      resolvedAngle: 40.0,
      priority: 4,
    ),
    const StarSnapshot(
      star: EnumStars.Mercury,
      originalAngle: 72.3,
      resolvedAngle: 72.3,
      priority: 3,
    ),
    const StarSnapshot(
      star: EnumStars.Venus,
      originalAngle: 105.7,
      resolvedAngle: 102.0,
      priority: 3,
    ),
    const StarSnapshot(
      star: EnumStars.Mars,
      originalAngle: 138.1,
      resolvedAngle: 138.1,
      priority: 3,
    ),
    const StarSnapshot(
      star: EnumStars.Jupiter,
      originalAngle: 165.4,
      resolvedAngle: 165.4,
      priority: 3,
    ),
    const StarSnapshot(
      star: EnumStars.Saturn,
      originalAngle: 198.9,
      resolvedAngle: 198.9,
      priority: 3,
    ),
    const StarSnapshot(
      star: EnumStars.Ji,
      originalAngle: 225.6,
      resolvedAngle: 225.6,
      priority: 2,
    ),
    const StarSnapshot(
      star: EnumStars.Luo,
      originalAngle: 258.2,
      resolvedAngle: 258.2,
      priority: 2,
    ),
    const StarSnapshot(
      star: EnumStars.Bei,
      originalAngle: 290.0,
      resolvedAngle: 290.0,
      priority: 2,
    ),
    const StarSnapshot(
      star: EnumStars.Qi,
      originalAngle: 325.0,
      resolvedAngle: 325.0,
      priority: 1,
    ),
  ];

  // 28 constellations: equal-width arcs (≈12.857° each).
  final constellations = Enum28Constellations.values
      .map((c) => ConstellationSnapshot(constellation: c, degree: 360.0 / 28))
      .toList();

  return QiZhengChartBoardSnapshot(
    totalDegree: 360.0,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    gongOrder: gongOrder,
    stars: stars,
    constellations: constellations,
  );
}

/// Builds a [ChartBoard] from the adapter, applying the old-painter
/// `startAngleOffset = -15` so 戌 starts at 345°.
ChartBoard buildParityBoard(QiZhengChartBoardSnapshot fixture) {
  const adapter = QiZhengChartBoardAdapter();
  final rawBoard = adapter.buildBoard(
    fixture,
    const ChartBoardAdapterContext(
      moduleId: ModuleId.qizhengsiyu,
      instanceId: 'parity-golden-001',
    ),
  );

  // The adapter produces sectors at 0°, 30°, 60° … by default.
  // The old painter convention starts 戌 at 345° (= −15°).
  // Keep the historical angle convention while retaining the production ring
  // radii carried by the adapter.
  final patchedLayers = <ChartLayer>[];
  for (final layer in rawBoard.layers) {
    if (layer is SectorLayer && layer.id == 'earth-branch-ring') {
      patchedLayers.add(
        SectorLayer(
          id: layer.id,
          zIndex: layer.zIndex,
          visible: layer.visible,
          styleRole: layer.styleRole,
          hitTestMode: layer.hitTestMode,
          semanticsMode: layer.semanticsMode,
          behavior: LayerBehavior(
            innerRadius: layer.behavior.innerRadius,
            outerRadius: layer.behavior.outerRadius,
            startAngleOffset: -15,
          ),
          metadata: layer.metadata,
          sectors: layer.sectors,
        ),
      );
    } else {
      patchedLayers.add(layer);
    }
  }

  return ChartBoard(
    moduleId: rawBoard.moduleId,
    instanceId: rawBoard.instanceId,
    layout: rawBoard.layout,
    layers: patchedLayers,
    metadata: rawBoard.metadata,
  );
}

// ---------------------------------------------------------------------------
// Historical geometry helper
// ---------------------------------------------------------------------------

/// Wraps a [CircularCanvasBoard] in a MaterialApp for golden testing.
// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late QiZhengChartBoardSnapshot fixture;
  late ChartBoard board;
  late BoardGeometry geometry;

  setUp(() {
    fixture = buildOldConventionFixture();
    board = buildParityBoard(fixture);

    final sectorLayer = board.layers.whereType<SectorLayer>().first;
    final engine = CircularRingLayoutEngine(
      center: const Offset(200, 200),
      innerRadius: 80,
      outerRadius: 180,
      sectorCount: sectorLayer.sectors.length,
    );
    geometry = engine.build(board.layers);
  });

  // ----- Sector layer parity ------------------------------------------------

  group('Sector parity (12 palaces, old convention)', () {
    test('has exactly 12 sectors', () {
      final layer = board.layers.whereType<SectorLayer>().first;
      expect(layer.sectors.length, 12);
    });

    test('each sector has 30° sweep', () {
      final layer = board.layers.whereType<SectorLayer>().first;
      for (final sector in layer.sectors) {
        expect(
          sector.sweepAngle,
          30.0,
          reason: 'Sector ${sector.id} sweep != 30°',
        );
      }
    });

    test('sectors are ordered 戌亥子丑寅卯辰巳午未申酉', () {
      final layer = board.layers.whereType<SectorLayer>().first;
      const expected = [
        '戌',
        '亥',
        '子',
        '丑',
        '寅',
        '卯',
        '辰',
        '巳',
        '午',
        '未',
        '申',
        '酉',
      ];
      for (int i = 0; i < 12; i++) {
        expect(
          layer.sectors[i].label,
          contains(expected[i]),
          reason: 'Sector $i should be ${expected[i]}',
        );
      }
    });

    test('first and last sector ids include the independent ring id', () {
      final layer = board.layers.whereType<SectorLayer>().first;
      expect(layer.sectors.first.id, 'earth-branch-ring:戌');
      expect(layer.sectors.last.id, 'earth-branch-ring:酉');
    });

    test('engine places first sector center at 345° + 15° = 0° (midpoint)', () {
      // With startAngleOffset = -15 and sweep = 30:
      // sector 0 spans [345°, 15°], midpoint = 0° (12 o'clock)
      final anchor = geometry.findAnchor('sector:earth-branch-ring:戌:center');
      expect(anchor, isNotNull);
      // midpoint angle = -15 + 0*30 + 15 = 0°
      expect(anchor!.angle, closeTo(0.0, 0.1));
    });

    test('engine places second sector (亥) at midpoint 30°', () {
      final anchor = geometry.findAnchor('sector:earth-branch-ring:亥:center');
      expect(anchor, isNotNull);
      expect(anchor!.angle, closeTo(30.0, 0.1));
    });
  });

  // ----- Tick layer parity --------------------------------------------------

  group('Tick parity (360° scale)', () {
    test('tick layer exists with id degree-ticks', () {
      final layer = board.layers.whereType<TickLayer>().firstOrNull;
      expect(layer, isNotNull);
      expect(layer!.id, 'degree-ticks');
    });

    test('major tick interval is 30', () {
      final layer = board.layers.whereType<TickLayer>().first;
      expect(layer.majorTickInterval, 30);
    });

    test('minor tick interval is 1', () {
      final layer = board.layers.whereType<TickLayer>().first;
      expect(layer.minorTickInterval, 1);
    });

    test('geometry has major tick anchors at every 30°', () {
      for (int deg = 0; deg < 360; deg += 30) {
        final anchor = geometry.findAnchor('tick:major:$deg');
        expect(anchor, isNotNull, reason: 'Missing major tick anchor at $deg°');
        expect(anchor!.angle, closeTo(deg.toDouble(), 0.1));
      }
    });

    test('geometry has minor tick anchors at every degree', () {
      // Verify a sample of minor ticks
      for (int deg in [1, 2, 15, 45, 100, 200, 359]) {
        final anchor = geometry.findAnchor('tick:$deg');
        expect(anchor, isNotNull, reason: 'Missing minor tick anchor at $deg°');
      }
    });
  });

  // ----- Constellation arc parity -------------------------------------------

  group('Constellation parity (28 arcs)', () {
    test('arc layer has 28 arcs', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      expect(layer.arcs.length, 28);
    });

    test('arc ids start with inn: prefix', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      for (final arc in layer.arcs) {
        expect(arc.id, startsWith('inn:'));
      }
    });

    test('arcs tile to exactly 360°', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      final total = layer.arcs.fold<double>(0, (sum, a) => sum + a.sweepAngle);
      expect(total, closeTo(360.0, 0.01));
    });

    test('arc start angles are contiguous (no gaps)', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      for (int i = 1; i < layer.arcs.length; i++) {
        final prevEnd =
            layer.arcs[i - 1].startAngle + layer.arcs[i - 1].sweepAngle;
        expect(
          layer.arcs[i].startAngle,
          closeTo(prevEnd, 0.01),
          reason: 'Gap between arc ${i - 1} and arc $i',
        );
      }
    });

    test('first arc starts at 0°', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      expect(layer.arcs.first.startAngle, 0.0);
    });

    test('each arc is ~12.857° (360/28)', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      final expectedSweep = 360.0 / 28;
      for (final arc in layer.arcs) {
        expect(arc.sweepAngle, closeTo(expectedSweep, 0.01));
      }
    });

    test('geometry has hit regions for each arc', () {
      final layer = board.layers.whereType<ArcLayer>().first;
      for (final arc in layer.arcs) {
        final regionId = 'arc:${arc.id}';
        final region = geometry.hitRegions
            .where((r) => r.id == regionId)
            .firstOrNull;
        expect(region, isNotNull, reason: 'Missing hit region for ${arc.id}');
      }
    });
  });

  // ----- Star point parity --------------------------------------------------

  group('Star point parity (11 stars)', () {
    test('point layer has 11 items', () {
      final layer = board.layers.whereType<PointLayer>().first;
      expect(layer.items.length, 11);
    });

    test('each item is an AngularPoint', () {
      final layer = board.layers.whereType<PointLayer>().first;
      for (final item in layer.items) {
        expect(item, isA<AngularPoint>());
      }
    });

    test('originalAngle survives adapter unchanged', () {
      final layer = board.layers.whereType<PointLayer>().first;
      final points = layer.items.whereType<AngularPoint>().toList();
      for (int i = 0; i < fixture.stars.length; i++) {
        expect(
          points[i].originalAngle,
          fixture.stars[i].originalAngle,
          reason: 'Star ${fixture.stars[i].star.name} originalAngle mismatch',
        );
      }
    });

    test('displayAngle == resolvedAngle from fixture', () {
      final layer = board.layers.whereType<PointLayer>().first;
      final points = layer.items.whereType<AngularPoint>().toList();
      for (int i = 0; i < fixture.stars.length; i++) {
        expect(
          points[i].displayAngle,
          fixture.stars[i].resolvedAngle,
          reason: 'Star ${fixture.stars[i].star.name} displayAngle mismatch',
        );
      }
    });

    test('leader flag is correct for collision vs non-collision', () {
      final layer = board.layers.whereType<PointLayer>().first;
      final points = layer.items.whereType<AngularPoint>().toList();

      // Sun: original=5.5, resolved=5.5 → no leader
      expect(points[0].metadata['starId'], 'Sun');
      expect(points[0].leader, false);

      // Moon: original=38.0, resolved=40.0 → leader (collision)
      expect(points[1].metadata['starId'], 'Moon');
      expect(points[1].leader, true);

      // Venus: original=105.7, resolved=102.0 → leader (collision)
      expect(points[3].metadata['starId'], 'Venus');
      expect(points[3].leader, true);
    });

    test('star display angles fall within their host sector', () {
      final sectorLayer = board.layers.whereType<SectorLayer>().first;
      final pointLayer = board.layers.whereType<PointLayer>().first;
      final points = pointLayer.items.whereType<AngularPoint>().toList();

      for (int i = 0; i < points.length; i++) {
        final starAngle = points[i].displayAngle;
        final hostSector = _findSectorForAngle(
          starAngle,
          sectorLayer,
          fixture.totalDegree,
        );
        expect(
          hostSector,
          isNotNull,
          reason:
              'Star ${fixture.stars[i].star.name} at $starAngle° has no host sector',
        );
      }
    });

    test('geometry has inner+outer anchors for each star', () {
      for (int i = 0; i < 11; i++) {
        final inner = geometry.findAnchor('point:$i:inner');
        final outer = geometry.findAnchor('point:$i:outer');
        expect(inner, isNotNull, reason: 'Missing inner anchor for star $i');
        expect(outer, isNotNull, reason: 'Missing outer anchor for star $i');
        // inner and outer should be at different positions (unless no collision)
        // but both must exist
      }
    });

    test('leader lines exist only for collided stars', () {
      final pointLayer = board.layers.whereType<PointLayer>().first;
      final points = pointLayer.items.whereType<AngularPoint>().toList();

      for (int i = 0; i < points.length; i++) {
        final leaderPath = geometry.drawPaths['${pointLayer.id}:leader:$i'];
        if (points[i].leader) {
          expect(
            leaderPath,
            isNotNull,
            reason: 'Star $i has leader=true but no leader path',
          );
        } else {
          expect(
            leaderPath,
            isNull,
            reason: 'Star $i has leader=false but leader path exists',
          );
        }
      }
    });
  });

  // ----- Hit region id stability --------------------------------------------

  group('Region id stability', () {
    test('palace hit region ids are stable', () {
      final sectorRegions = geometry.hitRegions
          .where((r) => r.layerId == 'earth-branch-ring')
          .toList();
      expect(sectorRegions.length, 12);

      final ids = sectorRegions.map((r) => r.id).toList();
      expect(ids.first, 'sector:earth-branch-ring:戌');
      expect(ids.last, 'sector:earth-branch-ring:酉');
    });

    test('constellation hit region ids are stable', () {
      final arcRegions = geometry.hitRegions
          .where((r) => r.layerId == 'constellation-ring')
          .toList();
      expect(arcRegions.length, 28);
      expect(arcRegions.first.id, startsWith('arc:inn:'));
    });

    test('star hit region ids are stable', () {
      final pointRegions = geometry.hitRegions
          .where((r) => r.layerId == 'inner-star-body-ring')
          .toList();
      expect(pointRegions.length, 11);
      for (int i = 0; i < 11; i++) {
        expect(pointRegions[i].id, 'point:$i');
      }
    });

    test('total hit region count is deterministic', () {
      // Three visible 12-sector rings + 28 constellations + 11 star points. The
      // zero-width optional star-sequence ring is retained but invisible.
      expect(geometry.hitRegions.length, 75);
    });
  });

  // ----- Metadata parity ----------------------------------------------------

  group('Metadata parity', () {
    test('board metadata has panelSystemType', () {
      expect(board.metadata['panelSystemType'], isNotNull);
    });

    test('board metadata has constellationSystemType', () {
      expect(board.metadata['constellationSystemType'], isNotNull);
    });

    test('star metadata has starId and starName', () {
      final pointLayer = board.layers.whereType<PointLayer>().first;
      for (final item in pointLayer.items.whereType<AngularPoint>()) {
        expect(item.metadata['starId'], isNotNull);
        expect(item.metadata['starName'], isNotNull);
        expect(item.metadata['priority'], isNotNull);
      }
    });

    test('sector metadata has zhi', () {
      final sectorLayer = board.layers.whereType<SectorLayer>().first;
      for (final sector in sectorLayer.sectors) {
        expect(sector.metadata['zhi'], isNotNull);
      }
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Finds the sector that contains [angle], accounting for startAngleOffset.
ChartSector? _findSectorForAngle(
  double angle,
  SectorLayer layer,
  double totalDegree,
) {
  for (final sector in layer.sectors) {
    final start = sector.startAngle ?? 0;
    final sweep = sector.sweepAngle ?? (totalDegree / layer.sectors.length);
    final end = start + sweep;

    if (start <= end) {
      if (angle >= start && angle < end) return sector;
    } else {
      // Wraps around 360°
      if (angle >= start || angle < end) return sector;
    }
  }
  return null;
}
