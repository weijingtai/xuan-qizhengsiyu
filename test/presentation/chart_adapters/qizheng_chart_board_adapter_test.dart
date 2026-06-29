import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_chart_ui/metaphysics_chart_ui.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'package:qizhengsiyu/presentation/chart_adapters/qizheng_chart_board_adapter.dart';
import 'package:qizhengsiyu/presentation/chart_adapters/qizheng_chart_board_snapshot.dart';

// ---------------------------------------------------------------------------
// Parity fixture: a stable, hand-built panel snapshot used across all tests.
// ---------------------------------------------------------------------------

/// A fixed snapshot that exercises every code path the adapter cares about.
/// Dates and angles are synthetic but deterministic.
///
/// KEY PROPERTY: Both `originalAngle` and `resolvedAngle` are distinct for
/// at least some stars so the parity test can assert both survive unchanged.
QiZhengChartBoardSnapshot buildParityFixture() {
  // 12 gong in ecliptic order (戌 starts at 0°).
  const gongOrder = <EnumTwelveGong>[
    EnumTwelveGong.Xu, // 戌  0°
    EnumTwelveGong.You, // 酉 30°
    EnumTwelveGong.Shen, // 申 60°
    EnumTwelveGong.Wei, // 未 90°
    EnumTwelveGong.Wu, // 午 120°
    EnumTwelveGong.Si, // 巳 150°
    EnumTwelveGong.Chen, // 辰 180°
    EnumTwelveGong.Mao, // 卯 210°
    EnumTwelveGong.Yin, // 寅 240°
    EnumTwelveGong.Chou, // 丑 270°
    EnumTwelveGong.Zi, // 子 300°
    EnumTwelveGong.Hai, // 亥 330°
  ];

  // 11 stars with original and resolved (post-collision) angles.
  // Some have small adjustments, some are unchanged.
  final stars = <StarSnapshot>[
    // Sun in Xu — no collision, original == resolved
    const StarSnapshot(
      star: EnumStars.Sun,
      originalAngle: 15.5,
      resolvedAngle: 15.5,
      priority: 4,
    ),
    // Moon in You — collided, shifted +2°
    const StarSnapshot(
      star: EnumStars.Moon,
      originalAngle: 32.0,
      resolvedAngle: 34.0,
      priority: 4,
    ),
    // Venus in Xu — close to Sun, shifted -3°
    const StarSnapshot(
      star: EnumStars.Venus,
      originalAngle: 12.0,
      resolvedAngle: 9.0,
      priority: 3,
    ),
    // Jupiter in Shen
    const StarSnapshot(
      star: EnumStars.Jupiter,
      originalAngle: 68.3,
      resolvedAngle: 68.3,
      priority: 3,
    ),
    // Mars in Wei
    const StarSnapshot(
      star: EnumStars.Mars,
      originalAngle: 95.7,
      resolvedAngle: 95.7,
      priority: 3,
    ),
    // Saturn in Wu
    const StarSnapshot(
      star: EnumStars.Saturn,
      originalAngle: 128.1,
      resolvedAngle: 128.1,
      priority: 3,
    ),
    // Mercury in Si
    const StarSnapshot(
      star: EnumStars.Mercury,
      originalAngle: 155.4,
      resolvedAngle: 155.4,
      priority: 3,
    ),
    // Ji (north node) in Chen
    const StarSnapshot(
      star: EnumStars.Ji,
      originalAngle: 188.9,
      resolvedAngle: 188.9,
      priority: 2,
    ),
    // Luo (south node) in Mao
    const StarSnapshot(
      star: EnumStars.Luo,
      originalAngle: 215.6,
      resolvedAngle: 215.6,
      priority: 2,
    ),
    // Bei (lilith) in Yin
    const StarSnapshot(
      star: EnumStars.Bei,
      originalAngle: 248.2,
      resolvedAngle: 248.2,
      priority: 2,
    ),
    // Qi in Zi
    const StarSnapshot(
      star: EnumStars.Qi,
      originalAngle: 305.0,
      resolvedAngle: 305.0,
      priority: 1,
    ),
  ];

  // 28 constellation arcs (equal-width for simplicity; real data varies).
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late QiZhengChartBoardSnapshot fixture;
  late ChartBoard board;

  setUp(() {
    fixture = buildParityFixture();
    const adapter = QiZhengChartBoardAdapter();
    board = adapter.buildBoard(
      fixture,
      const ChartBoardAdapterContext(
        moduleId: ModuleId.qizhengsiyu,
        instanceId: 'test-instance-001',
      ),
    );
  });

  // ----- Basic contract tests ----------------------------------------------

  test('moduleId == qizhengsiyu', () {
    expect(board.moduleId, ModuleId.qizhengsiyu);
  });

  test('stable instanceId from context', () {
    expect(board.instanceId, 'test-instance-001');
  });

  test('board layout family is circular', () {
    expect(board.layout.family, BoardLayoutFamily.circular);
  });

  // ----- Layer count and type tests ----------------------------------------

  test('board exposes the complete Legacy twelve-layer inventory', () {
    expect(board.layers.map((layer) => layer.id), [
      'earth-branch-ring',
      'zodiac-ring',
      'star-sequence-ring',
      'destiny-ring',
      'degree-ticks',
      'constellation-ring',
      'inner-star-track-ring',
      'inner-star-body-ring',
      'outer-star-track-ring',
      'outer-star-body-ring',
      'inner-shensha-ring',
      'outer-shensha-ring',
    ]);
  });

  test('layer[0] is the earth-branch SectorLayer', () {
    expect(board.layers[0], isA<SectorLayer>());
    expect(board.layers[0].id, 'earth-branch-ring');
  });

  test('layer[4] is a TickLayer (360 ticks)', () {
    expect(board.layers[4], isA<TickLayer>());
    expect(board.layers[4].id, 'degree-ticks');
  });

  test('layer[5] is an ArcLayer (28 constellations)', () {
    expect(board.layers[5], isA<ArcLayer>());
    expect(board.layers[5].id, 'constellation-ring');
  });

  test('layer[7] is the inner-star body PointLayer', () {
    expect(board.layers[7], isA<PointLayer>());
    expect(board.layers[7].id, 'inner-star-body-ring');
  });

  test('star track rings are whole rings, not twelve sectors', () {
    final innerTrack = board.layers[6];
    final outerTrack = board.layers[8];

    expect(innerTrack.id, 'inner-star-track-ring');
    expect(outerTrack.id, 'outer-star-track-ring');
    expect(innerTrack, isA<ArcLayer>());
    expect(outerTrack, isA<ArcLayer>());
    expect((innerTrack as ArcLayer).arcs, hasLength(1));
    expect((outerTrack as ArcLayer).arcs, hasLength(1));
    expect(innerTrack.arcs.single.sweepAngle, 360);
    expect(outerTrack.arcs.single.sweepAngle, 360);
  });

  test('center and every Legacy ring retain exact production radii', () {
    expect(board.center?.radius, 70);
    expect(board.layers[0].behavior.innerRadius, 70);
    expect(board.layers[0].behavior.outerRadius, 120);
    expect(board.layers[3].behavior.innerRadius, 144);
    expect(board.layers[3].behavior.outerRadius, 214);
    expect(board.layers[11].behavior.innerRadius, 436);
    expect(board.layers[11].behavior.outerRadius, 526);
  });

  test(
    'adapter preserves discontinuous Legacy ring radii without stacking',
    () {
      final discontinuousFixture = QiZhengChartBoardSnapshot(
        totalDegree: fixture.totalDegree,
        panelSystemType: fixture.panelSystemType,
        constellationSystemType: fixture.constellationSystemType,
        gongOrder: fixture.gongOrder,
        stars: fixture.stars,
        constellations: fixture.constellations,
        ringLayout: const QiZhengRingLayoutSnapshot(
          centerRadius: 30,
          diZhiInnerRadius: 40,
          diZhiOuterRadius: 55,
          zodiacInnerRadius: 80,
          zodiacOuterRadius: 94,
          starSequenceInnerRadius: 120,
          starSequenceOuterRadius: 120,
          destinyInnerRadius: 150,
          destinyOuterRadius: 188,
          innerStarInnerRadius: 220,
          innerStarOuterRadius: 248,
          constellationInnerRadius: 300,
          constellationOuterRadius: 318,
          outerStarInnerRadius: 360,
          outerStarOuterRadius: 388,
          innerShenShaInnerRadius: 430,
          innerShenShaOuterRadius: 470,
          outerShenShaInnerRadius: 520,
          outerShenShaOuterRadius: 560,
        ),
      );

      final discontinuousBoard = const QiZhengChartBoardAdapter().buildBoard(
        discontinuousFixture,
        const ChartBoardAdapterContext(
          moduleId: ModuleId.qizhengsiyu,
          instanceId: 'discontinuous-radii',
        ),
      );

      expect(discontinuousBoard.center?.radius, 30);
      expect(discontinuousBoard.layers[0].behavior.innerRadius, 40);
      expect(discontinuousBoard.layers[0].behavior.outerRadius, 55);
      expect(discontinuousBoard.layers[1].behavior.innerRadius, 80);
      expect(discontinuousBoard.layers[1].behavior.outerRadius, 94);
      expect(discontinuousBoard.layers[2].visible, isFalse);
      expect(discontinuousBoard.layers[3].behavior.innerRadius, 150);
      expect(discontinuousBoard.layers[3].behavior.outerRadius, 188);
      expect(discontinuousBoard.layers[5].behavior.innerRadius, 300);
      expect(discontinuousBoard.layers[5].behavior.outerRadius, 318);
      expect(discontinuousBoard.layers[11].behavior.innerRadius, 520);
      expect(discontinuousBoard.layers[11].behavior.outerRadius, 560);
    },
  );

  test(
    'zero-width star-sequence ring keeps identity and order but is skipped',
    () {
      final layer = board.layers[2];
      expect(layer.id, 'star-sequence-ring');
      expect(layer.visible, isFalse);
      expect(layer.metadata['optional'], isTrue);
      expect(layer.metadata['skippedReason'], 'zeroWidth');
    },
  );

  // ----- Palace sector tests -----------------------------------------------

  test('palace layer has 12 sectors', () {
    final palaceLayer = board.layers[0] as SectorLayer;
    expect(palaceLayer.sectors.length, 12);
  });

  test('palace sectors have 30° sweep each', () {
    final palaceLayer = board.layers[0] as SectorLayer;
    for (final sector in palaceLayer.sectors) {
      expect(sector.sweepAngle, 30.0);
    }
  });

  test('palace sectors have stable ids scoped by their ring', () {
    final palaceLayer = board.layers[0] as SectorLayer;
    expect(palaceLayer.sectors.first.id, 'earth-branch-ring:戌');
    expect(palaceLayer.sectors.last.id, 'earth-branch-ring:亥');
  });

  test('palace sectors are ordered correctly (Xu first, Hai last)', () {
    final palaceLayer = board.layers[0] as SectorLayer;
    expect(palaceLayer.sectors.first.label, contains('戌'));
    expect(palaceLayer.sectors.last.label, contains('亥'));
  });

  // ----- Tick layer tests --------------------------------------------------

  test('tick layer has major interval 30, minor 1', () {
    final tickLayer = board.layers[4] as TickLayer;
    expect(tickLayer.majorTickInterval, 30);
    expect(tickLayer.minorTickInterval, 1);
    expect(tickLayer.tickLabelInterval, 10);
  });

  // ----- Constellation arc tests -------------------------------------------

  test('constellation layer has 28 arcs', () {
    final arcLayer = board.layers[5] as ArcLayer;
    expect(arcLayer.arcs.length, 28);
  });

  test('constellation arcs have stable ids like inn:角', () {
    final arcLayer = board.layers[5] as ArcLayer;
    expect(arcLayer.arcs.first.id, startsWith('inn:'));
  });

  test('constellation arcs tile to 360°', () {
    final arcLayer = board.layers[5] as ArcLayer;
    final totalSweep = arcLayer.arcs.fold<double>(
      0,
      (sum, a) => sum + a.sweepAngle,
    );
    expect(totalSweep, closeTo(360.0, 0.01));
  });

  // ----- Star point layer tests --------------------------------------------

  test('star point layer has 11 items', () {
    final pointLayer = board.layers[7] as PointLayer;
    expect(pointLayer.items.length, 11);
  });

  test('each star item is an AngularPoint', () {
    final pointLayer = board.layers[7] as PointLayer;
    for (final item in pointLayer.items) {
      expect(item, isA<AngularPoint>());
    }
  });

  // ----- Parity fixture: angles survive adapter unchanged ------------------

  test('PARITY: originalAngle survives adapter unchanged', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    for (int i = 0; i < fixture.stars.length; i++) {
      final expected = fixture.stars[i].originalAngle;
      final actual = angularPoints[i].originalAngle;
      expect(
        actual,
        expected,
        reason: 'Star ${fixture.stars[i].star.name} originalAngle mismatch',
      );
    }
  });

  test('PARITY: resolvedAngle (displayAngle) survives adapter unchanged', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    for (int i = 0; i < fixture.stars.length; i++) {
      final expected = fixture.stars[i].resolvedAngle;
      final actual = angularPoints[i].displayAngle;
      expect(
        actual,
        expected,
        reason: 'Star ${fixture.stars[i].star.name} displayAngle mismatch',
      );
    }
  });

  test('PARITY: Sun has leader=true (original != resolved)', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    // Sun: original=15.5, resolved=15.5 → leader=false (no collision)
    final sun = angularPoints[0];
    expect(sun.metadata['starId'], 'Sun');
    expect(sun.leader, false);
  });

  test('PARITY: Moon has leader=true (original != resolved)', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    // Moon: original=32.0, resolved=34.0 → leader=true (collision)
    final moon = angularPoints[1];
    expect(moon.metadata['starId'], 'Moon');
    expect(moon.leader, true);
  });

  test('PARITY: Venus has leader=true (original != resolved)', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    // Venus: original=12.0, resolved=9.0 → leader=true (collision)
    final venus = angularPoints[2];
    expect(venus.metadata['starId'], 'Venus');
    expect(venus.leader, true);
  });

  // ----- Stability / idempotency tests ------------------------------------

  test('adapter is const-constructible', () {
    const adapter = QiZhengChartBoardAdapter();
    final board2 = adapter.buildBoard(
      fixture,
      const ChartBoardAdapterContext(
        moduleId: ModuleId.qizhengsiyu,
        instanceId: 'test-instance-001',
      ),
    );
    // Same input → same output (structural equality)
    expect(board2.moduleId, board.moduleId);
    expect(board2.instanceId, board.instanceId);
    expect(board2.layers.length, board.layers.length);
  });

  test('palace sector start angles are deterministic', () {
    final palaceLayer = board.layers[0] as SectorLayer;
    for (int i = 0; i < 12; i++) {
      expect(palaceLayer.sectors[i].startAngle, i * 30.0);
    }
  });

  // ----- Metadata tests ----------------------------------------------------

  test('board metadata contains panel system type', () {
    expect(board.metadata['panelSystemType'], '回归制');
    expect(board.metadata['constellationSystemType'], isNotEmpty);
  });

  test('star items carry starId in metadata', () {
    final pointLayer = board.layers[7] as PointLayer;
    final angularPoints = pointLayer.items.whereType<AngularPoint>().toList();

    final starIds = angularPoints.map((p) => p.metadata['starId']).toList();
    expect(starIds, contains('Sun'));
    expect(starIds, contains('Moon'));
    expect(starIds, contains('Venus'));
    expect(starIds, contains('Jupiter'));
    expect(starIds, contains('Mars'));
    expect(starIds, contains('Saturn'));
    expect(starIds, contains('Mercury'));
    expect(starIds, contains('Ji'));
    expect(starIds, contains('Luo'));
    expect(starIds, contains('Bei'));
    expect(starIds, contains('Qi'));
  });
}
