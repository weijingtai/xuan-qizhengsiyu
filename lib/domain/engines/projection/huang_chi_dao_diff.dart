// ignore_for_file: comment_references

import 'dart:math' as math;

/// 黄赤道度差策略 —— 「推变黄道」三算法的可插拔核心。
///
/// 三种历法算法（大衍进退表 / 姚舜辅公式 / 授时球面三角）都走同一个「进退」外壳：
/// 四象限、两分两至、加减符号、锚点。它们**真正不同的只有一件事**——如何计算
/// 「黄赤道度差」 d(C)。本接口即把这唯一的差异抽出来。
///
/// - [diff] 输入 C = 「距本象限起始二分/二至点的赤道度」，范围 [0, [quadrant]]；
///   返回黄赤道差 d ≥ 0（度）。d 在象限两端（分/至）为 0，象限中点（≈45.66°）最大。
/// - 加减符号、跨分/至切段等由外层「进退框架」负责，与本策略无关。
///
/// 详见 docs/project/architecture/002-赤黄道换算-推黄道术与弧矢割圆术.md。
abstract class HuangChiDaoDiff {
  const HuangChiDaoDiff();

  /// 象限 = 赤道周天 / 4（古历约 91.31°）。
  double get quadrant;

  /// 黄赤道度差 d(C)，C ∈ [0, [quadrant]]，返回 ≥ 0。
  double diff(double c);
}

/// 第二种算法 —— 北宋姚舜辅《纪元历》公式法。
///
/// 术曰：`黄赤道差 = C/1000 · (101 − C)`（式 2-85）。
/// 界定：C < 45.655 直接代入；C > 45.655 以「象限 − C」折到升段再代入。
/// 见 002 §5。
class JiyuanFormulaDiff extends HuangChiDaoDiff {
  const JiyuanFormulaDiff();

  /// 纪元历象限常数（其界定用 91.3109）。
  @override
  double get quadrant => 91.3109;

  @override
  double diff(double c) {
    var x = c.abs();
    // 兜底：折到 [0, quadrant]
    if (x > quadrant) x = quadrant - (x % quadrant);
    // 界定：> 半象限(45.655) 折到升段 [0, 45.655]
    if (x > quadrant / 2.0) x = quadrant - x;
    return x / 1000.0 * (101.0 - x);
  }
}

/// 第一种算法 —— 唐大衍历进退表法（分段线性）。
///
/// 分母 24、每 5 度一限、每限增损 12/24→11/24→…递减。d 在赤道 45° 达最大 3°
/// （现代实测 2.5°，古法过冲）。象限内不足 5 度余量按线性插值。见 002 §4 / 附录 A。
class DarenJinTuiDiff extends HuangChiDaoDiff {
  const DarenJinTuiDiff();

  /// 大衍历象限末节点。
  @override
  double get quadrant => 91.3125;

  /// (赤道度, 黄赤道差) 节点表（大衍历，度）。见 002 §4.1 / 附录 A。
  static const List<List<double>> _nodes = [
    [0, 0],
    [5, 12 / 24],
    [10, 23 / 24],
    [15, 1 + 9 / 24],
    [20, 1 + 18 / 24],
    [25, 2 + 2 / 24],
    [30, 2 + 9 / 24],
    [35, 2 + 15 / 24],
    [40, 2 + 20 / 24],
    [45, 3.0],
    [46.31, 3.0],
    [51.31, 2 + 20 / 24],
    [56.31, 2 + 15 / 24],
    [61.31, 2 + 9 / 24],
    [66.31, 2 + 2 / 24],
    [71.31, 1 + 18 / 24],
    [76.31, 1 + 9 / 24],
    [81.31, 23 / 24],
    [86.31, 12 / 24],
    [91.3125, 0],
  ];

  @override
  double diff(double c) {
    final x = c.abs().clamp(0.0, quadrant);
    for (var i = 0; i < _nodes.length - 1; i++) {
      final x0 = _nodes[i][0], d0 = _nodes[i][1];
      final x1 = _nodes[i + 1][0], d1 = _nodes[i + 1][1];
      if (x >= x0 && x <= x1) {
        return d0 + (d1 - d0) * (x - x0) / (x1 - x0);
      }
    }
    return 0.0;
  }
}

/// 第三种算法 —— 元授时历球面三角（勾股 + 会圆术）。
///
/// 数学本质等价于现代球面三角：距星赤经时圈投影到黄道，`tan α = cos ε · tan λ` 之反解。
/// 此处以「黄赤道差 d(C) = 反投影黄经 − 赤经」的形式并入进退框架。授时 ε=23.90°，
/// 最大 d ≈ 2.5°（= 现代实测）。见 002 §6。
class ShoushiSphericalDiff extends HuangChiDaoDiff {
  /// 黄赤交角（大距），授时历值 23.90°。
  final double epsilonDeg;

  /// 赤道周天（授时 365.2575）。
  final double zhouTian;

  const ShoushiSphericalDiff({
    this.epsilonDeg = 23.90,
    this.zhouTian = 365.2575,
  });

  @override
  double get quadrant => zhouTian / 4.0;

  @override
  double diff(double c) {
    final x = c.abs().clamp(0.0, quadrant);
    // C(赤道度, 自本象限二分/二至起算) → 角度(以 360 为周) → 反投影黄经 λ
    final aRad = x / zhouTian * 2 * math.pi;
    final eps = epsilonDeg * math.pi / 180.0;
    // 时圈投影：tan λ = tan α / cos ε  ⇒  λ = atan2(sin α, cos α · cos ε)
    var lamRad = math.atan2(math.sin(aRad), math.cos(aRad) * math.cos(eps));
    if (lamRad < 0) lamRad += 2 * math.pi;
    final lamDeg = lamRad / (2 * math.pi) * zhouTian;
    return (lamDeg - x).abs();
  }
}

/// 第三种算法·表 —— 元授时历逐度表（《明史·大统法原》）。
///
/// 表前 17 行（赤道 0–16°）来自 002 附录 B 原表正文；
/// 第 19 行来自 002 §6.3 例题（黄道积度 20.4872，度率 0.0622）；
/// 其余 17 行及 20–91 行为球面三角 formula 建模插值，**非原表实录**。
/// 金标值（如奎宿 17.875）依赖前 20 行表点，在 002 中已验证无误。
///
/// 补齐全 91 行真表前，请勿将第 18+ 行当作《大统法原》原表引用。
/// 表数据见 002 附录 B + §6.3 例题。
class ShoushiTableDiff extends HuangChiDaoDiff {
  final double zhouTian;

  const ShoushiTableDiff({this.zhouTian = 365.2575});

  @override
  double get quadrant => zhouTian / 4.0;

  static const List<double> _d =
      [0.0, 0.0865, 0.1728, 0.2588, 0.3445, 0.4294, 0.5137, 0.5970, 0.6793,
        0.7605, 0.8406, 0.9192, 0.9964, 1.0719, 1.1459, 1.2179, 1.2883,
        // ↑ 以上 0–16 来自《明史·大统法原》附录 B 原表正文
        1.3571, 1.4245, // ← 17–18 建模插值·待考
        1.4872, 1.5494, // ← 19 来自 §6.3 例题原文；20 由度率 0.0622 推算
        // ↓ 21–91 为球面三角公式建模插值·待考，非原表实录
        1.6082, 1.6646, 1.7186, 1.7703,
        1.8197, 1.8668, 1.9116, 1.9542, 1.9945, 2.0326, 2.0685, 2.1022,
        2.1337, 2.1631, 2.1903, 2.2154, 2.2383, 2.2591, 2.2778, 2.2944,
        2.3089, 2.3213, 2.3316, 2.3398, 2.3459, 2.3500, 2.3520, 2.3520,
        2.3500, 2.3459, 2.3398, 2.3316, 2.3213, 2.3089, 2.2944, 2.2778,
        2.2591, 2.2383, 2.2154, 2.1903, 2.1631, 2.1337, 2.1022, 2.0685,
        2.0326, 1.9945, 1.9542, 1.9116, 1.8668, 1.8197, 1.7703, 1.7186,
        1.6646, 1.6082, 1.5494, 1.4872, 1.4245, 1.3571, 1.2883, 1.2179,
        1.1459, 1.0719, 0.9964, 0.9192, 0.8406, 0.7605, 0.6793, 0.5970,
        0.5137, 0.4294, 0.3445, 0.2588, 0.1728, 0.0865, 0.0];

  static int _len() => _d.length;

  static double _dd(int i) => i < _d.length ? _d[i] : _d[_d.length - 1];

  @override
  double diff(double c) {
    final x = c.abs().clamp(0.0, quadrant);
    if (x <= 0) return 0.0;
    final fi = x.truncate();
    if (fi >= _len() - 1) return _d[_len() - 1];
    final frac = x - fi;
    return _d[fi] + (_dd(fi + 1) - _d[fi]) * frac;
  }
}
