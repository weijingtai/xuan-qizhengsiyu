import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/yue_bo_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/zi_qi_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';

class _ConstZiQi implements ZiQiAlgorithm {
  @override String get id => 'c';
  @override double computeLongitude({required double julianDay, required DateTime datetime}) => 88;
}

void main() {
  test('月孛古法平行：顺行产出单星', () {
    final algo = LinearApogeeAlgorithm(core: const LinearParallelCore(
        totalDegree: 360, dailyMotion: 0.111393, direction: 1,
        epochJulianDay: 1000, epochPosition: 0));
    final p = algo.computePositions(julianDay: 1100, datetime: DateTime.utc(2000));
    expect(p.keys, {EnumStars.Bei});
    expect(p[EnumStars.Bei], closeTo(0.111393 * 100, 1e-6));
  });
  test('紫气组包装 ZiQiAlgorithm', () {
    final algo = ZiQiGroupAlgorithm(_ConstZiQi());
    final p = algo.computePositions(julianDay: 5, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Qi], closeTo(88, 1e-9));
  });
}
