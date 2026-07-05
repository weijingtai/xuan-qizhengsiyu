import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

void main() {
  test('默认项为旧法 luoJiangJiSheng', () {
    expect(EnumRahuKetuConvention.values.first,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('name/description 已填写', () {
    for (final c in EnumRahuKetuConvention.values) {
      expect(c.name.isNotEmpty, isTrue);
      expect(c.description.isNotEmpty, isTrue);
    }
  });
}
