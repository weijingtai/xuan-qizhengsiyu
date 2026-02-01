// 这是一个测试文件
// 用于开发和测试化曜相关功能
import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao.dart';

void main() {
  group("天官化曜", () {
    test('甲年化曜', () {
      Map<EnumStars, EnumGuoLaoHuaYao> mapper =
          EnumGuoLaoHuaYao.calculateHuaYaoMapper(JiaZi.JIA_CHEN);
      expect(mapper[EnumStars.Mars], equals(EnumGuoLaoHuaYao.Lu));
    });
    test('乙年化曜', () {
      Map<EnumStars, EnumGuoLaoHuaYao> mapper =
          EnumGuoLaoHuaYao.calculateHuaYaoMapper(JiaZi.YI_CHOU);
      expect(mapper[EnumStars.Bei], equals(EnumGuoLaoHuaYao.Lu));
      expect(mapper[EnumStars.Mars], equals(EnumGuoLaoHuaYao.Quan));
    });
  });
  group("十神化曜", () {});
}
