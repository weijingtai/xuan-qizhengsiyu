import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart'; // ISiYuEphemerisSource
import 'linear_parallel_core.dart';
import 'si_yu_group_algorithm.dart';

Map<EnumStars, double> _assign(double node, EnumRahuKetuConvention c) {
  final rk = RahuKetuDefinition.assign(northNode: node, convention: c);
  return {EnumStars.Luo: rk.luo, EnumStars.Ji: rk.ji};
}

/// 罗计·星历版（sweph 平交点）。
class EphemerisNodePairAlgorithm implements SiYuGroupAlgorithm {
  final ISiYuEphemerisSource source;
  final EnumRahuKetuConvention convention;
  const EphemerisNodePairAlgorithm(
      {required this.source, required this.convention});
  @override
  String get id => 'ephemeris_node_pair';
  @override
  Set<EnumStars> get bodies => {EnumStars.Luo, EnumStars.Ji};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      _assign(source.meanNodeLongitude(julianDay), convention);
}

/// 罗计·古法平行版（升交点逆行平行推算）。
class LinearNodePairAlgorithm implements SiYuGroupAlgorithm {
  final LinearParallelCore nodeCore; // 升交点(逆行)
  final EnumRahuKetuConvention convention;
  const LinearNodePairAlgorithm(
      {required this.nodeCore, required this.convention});
  @override
  String get id => 'linear_node_pair';
  @override
  Set<EnumStars> get bodies => {EnumStars.Luo, EnumStars.Ji};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      _assign(nodeCore.positionAt(julianDay), convention);
}
