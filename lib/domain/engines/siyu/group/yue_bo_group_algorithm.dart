import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'linear_parallel_core.dart';
import 'si_yu_group_algorithm.dart';

class EphemerisApogeeAlgorithm implements SiYuGroupAlgorithm {
  final ISiYuEphemerisSource source;
  const EphemerisApogeeAlgorithm({required this.source});
  @override String get id => 'ephemeris_apogee';
  @override Set<EnumStars> get bodies => {EnumStars.Bei};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Bei: source.meanApogeeLongitude(julianDay)};
}

class LinearApogeeAlgorithm implements SiYuGroupAlgorithm {
  final LinearParallelCore core;
  const LinearApogeeAlgorithm({required this.core});
  @override String get id => 'linear_apogee';
  @override Set<EnumStars> get bodies => {EnumStars.Bei};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Bei: core.positionAt(julianDay)};
}
