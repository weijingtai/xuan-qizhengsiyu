import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';

void main() {
  test('EnumZeroPointRef 取值与标签', () {
    expect(EnumZeroPointRef.values.length, 2);
    expect(EnumZeroPointRef.chunfen.label, '春分点');
    expect(EnumZeroPointRef.dongzhi.label, '冬至点');
  });

  test('ConstellationOffsetTier 各档默认偏移', () {
    expect(ConstellationOffsetTier.guXiu.defaultOffsetDeg, 0.0);
    expect(ConstellationOffsetTier.adjusted.defaultOffsetDeg, 14.0);
    expect(ConstellationOffsetTier.modern.defaultOffsetDeg, 0.0);
  });
}
