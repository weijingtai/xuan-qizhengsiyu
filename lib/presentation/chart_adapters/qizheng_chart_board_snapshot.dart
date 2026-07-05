/// Immutable snapshot of a resolved QiZhengSiYu panel.
///
/// This is the adapter input. It is produced AFTER the collision solver runs
/// and captures the final resolved angles. The adapter MUST NOT trigger or
/// depend on solver mutation; it reads only this frozen snapshot.
library;

import 'package:metaphysics_core/enums.dart';

import '../../enums/enum_panel_system_type.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../domain/entities/models/panel_ui_size.dart';

/// Immutable radial geometry copied from the production panel size model.
class QiZhengRingLayoutSnapshot {
  const QiZhengRingLayoutSnapshot({
    required this.centerRadius,
    required this.diZhiInnerRadius,
    required this.diZhiOuterRadius,
    required this.zodiacInnerRadius,
    required this.zodiacOuterRadius,
    required this.starSequenceInnerRadius,
    required this.starSequenceOuterRadius,
    required this.destinyInnerRadius,
    required this.destinyOuterRadius,
    required this.innerStarInnerRadius,
    required this.innerStarOuterRadius,
    required this.constellationInnerRadius,
    required this.constellationOuterRadius,
    required this.outerStarInnerRadius,
    required this.outerStarOuterRadius,
    required this.innerShenShaInnerRadius,
    required this.innerShenShaOuterRadius,
    required this.outerShenShaInnerRadius,
    required this.outerShenShaOuterRadius,
  });

  const QiZhengRingLayoutSnapshot.productionDefault()
    : centerRadius = 70,
      diZhiInnerRadius = 70,
      diZhiOuterRadius = 120,
      zodiacInnerRadius = 120,
      zodiacOuterRadius = 144,
      starSequenceInnerRadius = 144,
      starSequenceOuterRadius = 144,
      destinyInnerRadius = 144,
      destinyOuterRadius = 214,
      innerStarInnerRadius = 214,
      innerStarOuterRadius = 262,
      constellationInnerRadius = 262,
      constellationOuterRadius = 298,
      outerStarInnerRadius = 298,
      outerStarOuterRadius = 346,
      innerShenShaInnerRadius = 346,
      innerShenShaOuterRadius = 436,
      outerShenShaInnerRadius = 436,
      outerShenShaOuterRadius = 526;

  factory QiZhengRingLayoutSnapshot.fromPanelSize(
    QiZhengSiYuPanSizeDataModel size,
  ) {
    double radius(double diameter) => diameter / 2;
    return QiZhengRingLayoutSnapshot(
      centerRadius: radius(size.centerSize),
      diZhiInnerRadius: radius(size.diZhi12GongInner),
      diZhiOuterRadius: radius(size.diZhi12GongOuter),
      zodiacInnerRadius: radius(size.zodiac12GongSizeInner),
      zodiacOuterRadius: radius(size.zodiac12GongSizeOuter),
      starSequenceInnerRadius: radius(size.starSeq12GongSizeInner),
      starSequenceOuterRadius: radius(size.starSeq12GongSizeOuter),
      destinyInnerRadius: radius(size.destiny12GongSizeInner),
      destinyOuterRadius: radius(size.destiny12GongSizeOuter),
      innerStarInnerRadius: radius(size.innerLifeStarRingInnerSize),
      innerStarOuterRadius: radius(size.innerLifeStarRingOuterSize),
      constellationInnerRadius: radius(size.starXiu28RingSizeInner),
      constellationOuterRadius: radius(size.starXiu28RingSizeOuter),
      outerStarInnerRadius: radius(size.outerLifeStarRingInnerSize),
      outerStarOuterRadius: radius(size.outerLifeStarRingOuterSize),
      innerShenShaInnerRadius: radius(size.innerShenShaSizeInner),
      innerShenShaOuterRadius: radius(size.innerShenShaSizeOuter),
      outerShenShaInnerRadius: radius(size.outerShenShaSizeInner),
      outerShenShaOuterRadius: radius(size.outerShenShaSizeOuter),
    );
  }

  final double centerRadius;
  final double diZhiInnerRadius;
  final double diZhiOuterRadius;
  final double zodiacInnerRadius;
  final double zodiacOuterRadius;
  final double starSequenceInnerRadius;
  final double starSequenceOuterRadius;
  final double destinyInnerRadius;
  final double destinyOuterRadius;
  final double innerStarInnerRadius;
  final double innerStarOuterRadius;
  final double constellationInnerRadius;
  final double constellationOuterRadius;
  final double outerStarInnerRadius;
  final double outerStarOuterRadius;
  final double innerShenShaInnerRadius;
  final double innerShenShaOuterRadius;
  final double outerShenShaInnerRadius;
  final double outerShenShaOuterRadius;

  bool get hasStarSequence => starSequenceOuterRadius > starSequenceInnerRadius;
}

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
    this.ringLayout = const QiZhengRingLayoutSnapshot.productionDefault(),
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

  /// Exact center and radial bands from the production panel.
  final QiZhengRingLayoutSnapshot ringLayout;

  /// Convenience: instance id derived from panel identity.
  String get instanceId =>
      'qizhengsiyu_${panelSystemType.name}_${constellationSystemType.name}';
}
