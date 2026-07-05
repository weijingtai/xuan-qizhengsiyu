import 'package:sweph/sweph.dart';
import 'si_yu_calculator.dart';

/// 基于 Swiss Ephemeris 的四余星历源（方案 A）。
class SwephSiYuEphemerisSource implements ISiYuEphemerisSource {
  const SwephSiYuEphemerisSource();

  @override
  double meanNodeLongitude(double julianDay) => Sweph.swe_calc(
        julianDay,
        HeavenlyBody.SE_MEAN_NODE,
        SwephFlag.SEFLG_SWIEPH,
      ).longitude;

  @override
  double meanApogeeLongitude(double julianDay) => Sweph.swe_calc(
        julianDay,
        HeavenlyBody.SE_MEAN_APOG,
        SwephFlag.SEFLG_SWIEPH,
      ).longitude;
}
