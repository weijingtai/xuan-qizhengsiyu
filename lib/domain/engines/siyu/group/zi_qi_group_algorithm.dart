import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';
import 'si_yu_group_algorithm.dart';

class ZiQiGroupAlgorithm implements SiYuGroupAlgorithm {
  final ZiQiAlgorithm inner;
  const ZiQiGroupAlgorithm(this.inner);
  @override String get id => 'ziqi_${inner.id}';
  @override Set<EnumStars> get bodies => {EnumStars.Qi};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Qi: inner.computeLongitude(julianDay: julianDay, datetime: datetime)};
}
