/// Immutable snapshot of a resolved QiZhengSiYu panel.
///
/// This is the adapter input. It is produced AFTER the collision solver runs
/// and captures the final resolved angles. The adapter MUST NOT trigger or
/// depend on solver mutation; it reads only this frozen snapshot.
library;

import 'package:metaphysics_core/enums.dart';

import '../../enums/enum_panel_system_type.dart';
import '../../enums/enum_twelve_gong.dart';

// ---------------------------------------------------------------------------
// StarSnapshot
// ---------------------------------------------------------------------------

/// Immutable snapshot of one star's resolved position.
///
/// [originalAngle] is the pre-collision angle (guide dot anchor).
/// [resolvedAngle] is the post-collision display angle (holder dot anchor).
class StarSnapshot {
  const StarSnapshot({
    required this.star,
    required this.originalAngle,
    required this.resolvedAngle,
    this.priority = 0,
  });

  final EnumStars star;
  final double originalAngle;
  final double resolvedAngle;
  final int priority;
}

// ---------------------------------------------------------------------------
// ConstellationSnapshot
// ---------------------------------------------------------------------------

/// Immutable snapshot of one 28-constellation arc segment.
class ConstellationSnapshot {
  const ConstellationSnapshot({
    required this.constellation,
    required this.degree,
  });

  final Enum28Constellations constellation;
  final double degree;
}

// ---------------------------------------------------------------------------
// QiZhengChartBoardSnapshot
// ---------------------------------------------------------------------------

/// Immutable, fully-resolved snapshot consumed by [QiZhengChartBoardAdapter].
///
/// All fields are read-only. Created from a live panel model after the
/// collision solver has finished. The adapter reads this snapshot only—it
/// never touches the solver or the mutable domain model.
class QiZhengChartBoardSnapshot {
  const QiZhengChartBoardSnapshot({
    required this.totalDegree,
    required this.panelSystemType,
    required this.constellationSystemType,
    required this.gongOrder,
    required this.stars,
    required this.constellations,
  });

  /// Total degree of the circle (360 for ecliptic, 365.25 for equatorial).
  final double totalDegree;

  /// Panel system (tropical / sidereal).
  final PanelSystemType panelSystemType;

  /// Constellation system (classical / modern / adjusted).
  final ConstellationSystemType constellationSystemType;

  /// Ordered 12 gong sequence around the circle.
  final List<EnumTwelveGong> gongOrder;

  /// All stars with both original and resolved angles.
  final List<StarSnapshot> stars;

  /// The 28 constellations with their arc widths in degrees.
  final List<ConstellationSnapshot> constellations;

  /// Convenience: instance id derived from panel identity.
  String get instanceId =>
      'qizhengsiyu_${panelSystemType.name}_${constellationSystemType.name}';
}
