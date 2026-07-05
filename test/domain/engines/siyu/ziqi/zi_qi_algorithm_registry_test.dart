import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart';

class _FixedAlgo implements ZiQiAlgorithm {
  final double v;
  final String _id;
  _FixedAlgo(this.v, this._id);
  @override
  String get id => _id;
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) => v;
}

void main() {
  test('resolve 命中对应算法', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
      EnumZiQiAlgorithm.shixian: _FixedAlgo(2, 's'),
    });
    expect(reg.resolve(EnumZiQiAlgorithm.shixian).id, 's');
  });

  test('未注册的算法回落到果老默认', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
    });
    expect(reg.resolve(EnumZiQiAlgorithm.yelvTianguan).id, 'g');
  });

  test('register 可插入新算法（扩展点）', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
    });
    reg.register(EnumZiQiAlgorithm.yelvTianguan, _FixedAlgo(9, 't'));
    expect(reg.resolve(EnumZiQiAlgorithm.yelvTianguan).id, 't');
  });
}
