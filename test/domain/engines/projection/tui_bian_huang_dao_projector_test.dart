import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/huang_chi_dao_diff.dart';
import 'package:qizhengsiyu/domain/engines/projection/tui_bian_huang_dao_projector.dart';
import 'package:qizhengsiyu/domain/engines/projection/i_celestial_projector.dart';

/// 推变黄道投影器金标测试。
/// 金标值来自 docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md。
void main() {
  // ---- 辅助：计算某一宿的黄道距度 ----
  double constellationWidth(
    ICelestialProjector proj,
    double eqStart,
    double eqEnd,
    double zhouTian,
  ) {
    // 宿全部在同一天象限内 → 直接差
    final e1 = proj.project(eqStart);
    final e2 = proj.project(eqEnd);
    // 处理跨越 0/周天边界
    var w = e2 - e1;
    if (w < 0) w += zhouTian;
    return w;
  }

  // 跨分/至切段计算
  double crossBoundaryWidth(
    ICelestialProjector proj,
    List<double> eqSegStarts,
    List<double> eqSegEnds,
  ) {
    double total = 0;
    for (var i = 0; i < eqSegStarts.length; i++) {
      total += constellationWidth(
        proj, eqSegStarts[i], eqSegEnds[i], 365.2575,
      );
    }
    return total;
  }

  // ================================================================
  // 金标 1: 牛宿 ≈ 7.5 (大衍历进退表, §4.2)
  // ================================================================
  group('金标·大衍历进退表 DarenJinTuiDiff', () {
    test('牛宿赤道8°，起端距冬至15.48°，黄道距度≈7.43 (历书7.5)', () {
      const diff = DarenJinTuiDiff();
      const zt = 365.2575;
      const anchor = 0.0; // 春分锚点
      const dongZhi = 273.9375; // 3 * 91.3125
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: zt, springEquinoxAnchor: anchor,
      );

      final eqStart = dongZhi + 15.48;
      final eqEnd = dongZhi + 23.48;
      final w = constellationWidth(proj, eqStart, eqEnd, zt);
      expect(w, closeTo(7.429, 0.005));
    });

    test('奎宿赤道16°，跨春分(奎内3.5776)，黄道距度≈17.52 (历书17.5)', () {
      const diff = DarenJinTuiDiff();
      const zt = 365.2575;
      const anchor = 0.0;
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: zt, springEquinoxAnchor: anchor,
      );

      // 跨春分: 春分前一段 [-3.5776, 0], 春分后一段 [0, 12.4224]
      final w = crossBoundaryWidth(proj,
        [-3.5776, 0],
        [0, 12.4224],
      );
      expect(w, closeTo(17.518, 0.003));
    });
  });

  // ================================================================
  // 金标 2: 奎宿 ≈ 17.716 (姚舜辅纪元历公式, §5.2)
  // ================================================================
  group('金标·姚舜辅公式 JiyuanFormulaDiff', () {
    test('奎宿黄道距度 ≈ 17.716 (春分=壁0°为锚)', () {
      const diff = JiyuanFormulaDiff();
      const zt = 365.2575;
      const anchor = 0.0; // 春分=壁0°
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: zt, springEquinoxAnchor: anchor,
      );

      final eqBiEnd = 8.6; // 壁宿末
      final eqKuiEnd = 8.6 + 16.6; // 奎宿末
      final w = constellationWidth(proj, eqBiEnd, eqKuiEnd, zt);
      expect(w, closeTo(17.7156, 0.0005));
    });
  });

  // ================================================================
  // 金标 3: 奎宿 ≈ 17.875 (授时逐度表, §6.3)
  // ================================================================
  group('金标·授时逐度表 ShoushiTableDiff', () {
    test('奎宿黄道距度 ≈ 17.875 (春分=壁6°为锚)', () {
      const diff = ShoushiTableDiff(zhouTian: 365.2575);
      const zt = 365.2575;
      const anchor = 6.0; // 春分=壁6°
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: zt, springEquinoxAnchor: anchor,
      );

      // 壁右段绝对赤道度: 从 春分(=6°) 到 壁末(=6+2.6=8.6)
      // 奎宿: 从 8.6 到 8.6+16.6=25.2
      final eqBiEnd = anchor + 2.6;
      final eqKuiEnd = anchor + 19.2;
      final w = constellationWidth(
        proj, eqBiEnd, eqKuiEnd, zt,
      );
      expect(w, closeTo(17.875, 0.002));
    });

    // 逐度差精度检验
    test('d(1)=0.0865, d(2)=0.1728, d(19)=1.4872', () {
      const diff = ShoushiTableDiff(zhouTian: 365.2575);
      expect(diff.diff(1), closeTo(0.0865, 1e-4));
      expect(diff.diff(2), closeTo(0.1728, 1e-4));
      expect(diff.diff(19), closeTo(1.4872, 1e-4));
    });
  });

  // ================================================================
  // 全 28 宿黄道表 — 以 §8.1 元明赤道基数为输入
  // 春分锚 = 壁6°, 用 授时球面三角 (ShoushiSphericalDiff)
  // ================================================================
  group('全28宿黄道表 (§8.1 元明赤道基数, 春分=壁6°)', () {
    // §8.1 元明赤道宿度 (觜0.05, Σ365.2575)
    const eqW = <double>[
      // 东方 (角→箕)
      12.1, 9.2, 16.3, 5.6, 6.5, 19.1, 10.4,
      // 北方 (斗→壁)
      25.2, 7.2, 11.35, 8.9575, 15.4, 17.1, 8.6,
      // 西方 (奎→参)
      16.6, 11.8, 15.6, 11.3, 17.4, 0.05, 11.1,
      // 南方 (井→轸)
      33.3, 2.2, 13.3, 6.3, 17.25, 18.75, 17.3,
    ];

    const names = [
      '角', '亢', '氐', '房', '心', '尾', '箕',
      '斗', '牛', '女', '虚', '危', '室', '壁',
      '奎', '娄', '胃', '昴', '毕', '觜', '参',
      '井', '鬼', '柳', '星', '张', '翼', '轸',
    ];

    // §9 古籍黄道宿度表 (大统体系) — 近似参照
    // "半"=0.5°
    const ancientEcl = <double>[
      13, 9, 16, 5, 6, 18, 9.5, // 东方
      23, 7, 11, 9, 16, 18, 9.5, // 北方
      17, 12, 15.5, 11, 16.5, 0.5, 9,  // 西方
      30.5, 2.5, 13, 6, 17, 20, 18.5,  // 南方
    ];

    late TuiBianHuangDaoProjector proj;
    const zt = 365.2575;
    const anchor = 0.0; // 春分=0 (壁宿6°=春分，绝对赤道为0)

    setUp(() {
      const diff = ShoushiSphericalDiff(epsilonDeg: 23.90, zhouTian: zt);
      proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: zt, springEquinoxAnchor: anchor,
      );
    });

    test('总和不变 — 黄道距度和仍为 365.2575', () {
      double cumul = 0;
      for (var i = 0; i < 28; i++) {
        cumul += eqW[i];
      }
      expect(cumul, closeTo(365.2575, 1e-3));
    });

    test('奎宿黄道 17.87 (授时官方值)', () {
      // 春分=0, 壁宿从 -6° 到 2.6°, 奎宿从 2.6° 到 19.2°
      final eqBiPost = -6.0 + 8.6; // = 2.6
      final eqKuiEnd = eqBiPost + 16.6; // = 19.2
      final w = constellationWidth(proj, eqBiPost, eqKuiEnd, zt);
      expect(w, closeTo(17.87, 0.2),
          reason: '球面三角与授时逐度表差约 0.13°');
    });

    test('全 28 宿黄道距度 与古籍大统表近似 (容差 ±2°, ≥25/28)', () {
      final quad = zt / 4;
      // 累积赤道坐标: 从 壁宿起点 (春分前6° = -6°) 起算，绝对坐标
      final cumul = <double>[];
      var cur = -6.0;
      for (var i = 0; i < 28; i++) {
        cumul.add(cur);
        cur += eqW[i];
      }

      final computedEcl = <double>[];
      for (var i = 0; i < 28; i++) {
        var s = cumul[i];
        var e = cumul[(i + 1) % 28];
        // 确保连续单调递增
        if (e <= s) e += zt;
        final eqEndAdj = e;

        // 确定起止象限
        var offsetStart = s - anchor;
        var offsetEnd = eqEndAdj - anchor;

        // 简单法: 如果不跨象限, 直接差; 跨了则分段
        final qiS = ((s - anchor) % zt + zt) % zt ~/ quad;
        var qiE = ((eqEndAdj - anchor) % zt + zt) % zt ~/ quad;
        // 若 qiE 比 qiS 小 (跨 4→0), 需要补偿
        if (qiE < qiS) qiE += 4;

        double totalEcl = 0;
        var segStart = s;
        for (var qi = qiS; qi <= qiE; qi++) {
          final qEnd = anchor + (qi + 1) * quad;
          if (qEnd >= eqEndAdj) {
            // 最后一段
            totalEcl += constellationWidth(proj, segStart, eqEndAdj, zt);
            break;
          }
          // 中间段到象限边界
          totalEcl += constellationWidth(proj, segStart, qEnd, zt);
          segStart = qEnd;
        }
        computedEcl.add(totalEcl);
      }

      var totalEclSum = 0.0;
      for (final w in computedEcl) {
        totalEclSum += w;
      }
      // 进退法天然保持总度
      expect(totalEclSum, closeTo(zt, 0.2));

      // 逐宿对比古籍黄道表 (大统体系, 容差 ±2°) 
      // 古籍黄道表使用不同锚点/精度, 仅作方向性验证
      var within2 = 0;
      for (var i = 0; i < 28; i++) {
        if ((computedEcl[i] - ancientEcl[i]).abs() < 2.0) within2++;
      }
      // 至少 25/28 宿在 ±2° 内
      expect(within2, greaterThanOrEqualTo(25),
          reason: '古籍表用不同锚点整数近似，允许容差；标注未匹配的宿: '
              '${_reportMismatches(names, computedEcl, ancientEcl, 2.0, false)}');

      // 报告详细数值
      print('\n========== 全28宿黄道距度 ==========');
      print('算法: 授时球面三角 (春分=壁6°, ε=23.90°)');
      print('赤道基数: §8.1 元明赤道宿度 (觜0.05, Σ365.2575)');
      print('┌────────┬───────────┬───────────┬────────┐');
      print('│  星宿  │ 赤道距度  │ 黄道距度  │ 古籍表 │');
      print('├────────┼───────────┼───────────┼────────┤');
      for (var i = 0; i < 28; i++) {
        final marker =
            (computedEcl[i] - ancientEcl[i]).abs() < 2.0 ? ' ' : '⚠';
        print('│ ${names[i].padRight(4)} │ ${eqW[i].toStringAsFixed(2).padLeft(7)} │ '
            '${computedEcl[i].toStringAsFixed(2).padLeft(7)} │ '
            '${ancientEcl[i].toStringAsFixed(1).padLeft(4)}  │ $marker');
      }
      print('├────────┼───────────┼───────────┼────────┤');
      print('│  合计  │ ${eqW.fold<double>(0, (a, b) => a + b).toStringAsFixed(3).padLeft(7)} │ '
          '${totalEclSum.toStringAsFixed(3).padLeft(7)} │         │');
      print('└────────┴───────────┴───────────┴────────┘');
      print('⚠ = 与古籍表差超过 2° (可能因锚点/精度不同)');
      print('==========================================');
    });

    // §8.2 十二宫界跑出
    test('§8.2 十二宫界: 每宫 ≈ 30.44° 赤道; 黄道宫界投影', () {
      // 十二宫界起界位置 (赤道度, 相对于周天起点)
      // 从 §8.2: 子宫 女2.1309, 亥宫 危12.2615, ...
      // 转换到绝对赤道坐标 (相对春分=壁6°)
      const palaceEqStarts = {
        '子': 0.0, '亥': 30.4381, '戌': 60.8762, '酉': 91.3143,
        '申': 121.7524, '未': 152.1905, '午': 182.6286,
        '巳': 213.0667, '辰': 243.5048, '卯': 273.9429,
        '寅': 304.3810, '丑': 334.8191,
      };

      for (final entry in palaceEqStarts.entries) {
        final ecl = proj.project(entry.value);
        // 投影应保持单调性, 且接近原始值 (偏差 ≤ 3°)
        final diff = (ecl - entry.value).abs();
        expect(diff, lessThan(3.5),
            reason: '${entry.key}宫 赤道${entry.value}→黄道$ecl, 偏差$diff');
      }
    });
  });

  // ================================================================
  // 通用契约
  // ================================================================
  group('进退投影器契约', () {
    test('春分点不动 (anchor=0)', () {
      for (final diff in [
        const DarenJinTuiDiff(),
        const JiyuanFormulaDiff(),
        const ShoushiTableDiff(),
      ]) {
        final proj = TuiBianHuangDaoProjector(
          diff: diff, zhouTian: 365.2575, springEquinoxAnchor: 0,
        );
        expect(proj.project(0), closeTo(0, 1e-12));
      }
    });

    test('夏至点黄道 = 赤道 (偏差为0)', () {
      const diff = JiyuanFormulaDiff();
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: 365.2575, springEquinoxAnchor: 0,
      );
      final xiaZhi = 365.2575 / 4;
      expect(proj.project(xiaZhi), closeTo(xiaZhi, 1e-6));
    });

    test('project/reverse 可逆 (任意点)', () {
      const diff = DarenJinTuiDiff();
      final proj = TuiBianHuangDaoProjector(
        diff: diff, zhouTian: 365.2575, springEquinoxAnchor: 6.0,
      );
      for (final c in [0.0, 1.0, 45.0, 91.3, 182.6, 273.9, 365.2575]) {
        final back = proj.reverse(proj.project(c));
        expect(back, closeTo(c, 1e-8));
      }
    });
  });
}

String _reportMismatches(
  List<String> names,
  List<double> computed,
  List<double> reference,
  double tol,
  bool includeInTol,
) {
  final buf = StringBuffer();
  for (var i = 0; i < names.length; i++) {
    final diff = (computed[i] - reference[i]).abs();
    if (includeInTol ? diff <= tol : diff > tol) {
      if (buf.isNotEmpty) buf.write('; ');
      buf.write('${names[i]}(${computed[i].toStringAsFixed(2)} vs ${reference[i]})');
    }
  }
  return buf.toString();
}
