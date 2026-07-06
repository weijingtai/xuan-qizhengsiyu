import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/huang_chi_dao_diff.dart';

/// 黄赤道度差三策略金标测试。
/// 金标值来自 docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md
/// （均为古籍例题逐位复现值，已在文档 §4/§5/§6 验证）。
void main() {
  group('第二种·姚舜辅纪元历公式 JiyuanFormulaDiff (d=C/1000·(101−C))', () {
    const d = JiyuanFormulaDiff();

    test('§5.1 例: C=10 → d=0.91', () {
      expect(d.diff(10), closeTo(0.91, 1e-9));
    });

    test('§5.2 壁宿例: C=8.6 → d=0.7946', () {
      expect(d.diff(8.6), closeTo(0.79464, 1e-5));
    });

    test('§5.2 奎末例: C=25.2 → d=1.9102', () {
      expect(d.diff(25.2), closeTo(1.91016, 1e-5));
    });

    test('界定折返: C>45.655 用 (象限−C)', () {
      const c = 60.0;
      final folded = d.quadrant - c; // 91.3109 − 60
      expect(d.diff(c), closeTo(folded / 1000.0 * (101.0 - folded), 1e-9));
    });

    test('两端(分/至)黄赤道差为 0', () {
      expect(d.diff(0), closeTo(0, 1e-9));
      expect(d.diff(d.quadrant), closeTo(0, 1e-6));
    });
  });

  group('第一种·大衍历进退表 DarenJinTuiDiff (分段线性)', () {
    const d = DarenJinTuiDiff();

    test('节点值: d(5)=0.5, d(45)=3.0, d(91.31)=0', () {
      expect(d.diff(5), closeTo(0.5, 1e-9));
      expect(d.diff(45), closeTo(3.0, 1e-9));
      expect(d.diff(d.quadrant), closeTo(0, 1e-9));
    });

    test('§4.2 牛宿例 分段线性: d(15.48)=1.411', () {
      expect(d.diff(15.48), closeTo(1.411, 2e-3));
    });

    test('§4.2 牛宿例: d(23.48)=1.982', () {
      expect(d.diff(23.48), closeTo(1.982, 2e-3));
    });

    test('最大值在象限中点附近, ≈3° (古法过冲)', () {
      expect(d.diff(45.65), closeTo(3.0, 0.05));
    });
  });
}
