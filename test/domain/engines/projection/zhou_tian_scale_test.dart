import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/zhou_tian_scale.dart';

/// 周天缩放测试 —— 365.2575 ↔ 360 一级换算。
void main() {
  group('ZhouTianScale 正向：古度→今度', () {
    test('0 古度 = 0 今度', () {
      expect(ZhouTianScale.toModern(0), 0.0);
    });

    test('半周天古度→今度', () {
      final result = ZhouTianScale.toModern(ZhouTianScale.ancientTotal / 2);
      expect(result, closeTo(180.0, 1e-9));
    });

    test('全周天古度→今度', () {
      expect(ZhouTianScale.toModern(ZhouTianScale.ancientTotal),
          closeTo(360.0, 1e-9));
    });

    test('牛宿赤道 7.2 古度→今度 ≈ 7.0964', () {
      expect(ZhouTianScale.toModern(7.2), closeTo(7.0964, 1e-4));
    });

    test('奎宿赤道 16.6 古度→今度 ≈ 16.3611', () {
      expect(ZhouTianScale.toModern(16.6), closeTo(16.3611, 1e-4));
    });
  });

  group('ZhouTianScale 反向：今度→古度', () {
    test('0 今度 = 0 古度', () {
      expect(ZhouTianScale.toAncient(0), 0.0);
    });

    test('180 今度→古度', () {
      final result = ZhouTianScale.toAncient(180);
      expect(result, closeTo(ZhouTianScale.ancientTotal / 2, 1e-9));
    });

    test('360 今度→古度 = 365.2575', () {
      expect(ZhouTianScale.toAncient(360),
          closeTo(ZhouTianScale.ancientTotal, 1e-9));
    });

    test('30 今度→古度 ≈ 30.4381', () {
      expect(ZhouTianScale.toAncient(30), closeTo(30.438125, 1e-5));
    });
  });

  group('ZhouTianScale 可逆性', () {
    test('古度→今度→古度 任意值可逆', () {
      for (final c in [0.0, 1.0, 45.65545, 91.3109, 182.6218, 273.9327,
          299.25, 306.45, 365.2575]) {
        final modern = ZhouTianScale.toModern(c);
        final back = ZhouTianScale.toAncient(modern);
        expect(back, closeTo(c, 1e-12));
      }
    });

    test('今度→古度→今度 任意值可逆', () {
      for (final m in [0.0, 30.0, 90.0, 180.0, 270.0, 360.0]) {
        final ancient = ZhouTianScale.toAncient(m);
        final back = ZhouTianScale.toModern(ancient);
        expect(back, closeTo(m, 1e-12));
      }
    });
  });

  group('ZhouTianScale 标识约定', () {
    test('不隐式取模 — 超过一周天仍按比率缩放', () {
      final result = ZhouTianScale.toModern(ZhouTianScale.ancientTotal * 2);
      expect(result, closeTo(720.0, 1e-9));
    });

    test('不隐式取模 — 大值今度→古度', () {
      final result = ZhouTianScale.toAncient(720);
      expect(result, closeTo(ZhouTianScale.ancientTotal * 2, 1e-9));
    });
  });
}
