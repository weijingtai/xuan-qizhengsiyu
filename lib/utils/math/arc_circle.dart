// ignore_for_file: comment_references

import 'dart:math' as math;

/// 授时历原始常数
/// 周天 (度) —— 一周天分 3652575
const double zhouTianConst = 365.2575;

/// 二至黄赤道大距 (度)，即黄赤交角 (授时历值, 二十四度弱)
const double daJuConst = 23.9030;

/// 古率 π = 3 (径一周三)，授时历弧矢原用
const double guLvConst = 3.0;

/// 半径 (真圆) —— ≈ 58.13 度 (真圆); 古率下为 60.876
final double radiusConst = zhouTianConst / (2.0 * math.pi);

/// 弧矢割圆术定义域错误。
class GeyuanException implements Exception {
  final String message;

  GeyuanException(this.message);

  @override
  String toString() => "GeyuanException: $message";
}

/// 弧矢割圆术 (Húshǐ Gēyuán Shù) — Arc-Sagitta Circle-Division Method
///
/// 复原《授时历》(郭守敬, 1281) 的弧矢割圆术，含：
/// 1. 会圆术 (沈括《梦溪笔谈·卷十八》) —— 弧 / 弦 / 矢 三者互求的地基公式。
/// 2. 割圆求矢 —— 已知弧长反求矢，古法用增乘开方 (四次方程)，本实现用二分迭代替代 (数值上单调、稳定)。
/// 3. 黄赤道换算 —— 求黄赤道内外度 (赤纬) 与赤道积度 (赤经)，走"相似勾股"比例 p2 = p1 * p_eps / R (见 [declination] / [rightAscension] 方法)。
///
/// 几何约定：
/// 所有量 (弧长 arc、弦 chord、矢 sagitta、半径 r) 采用同一线性单位 (授时历"度")。
/// 圆心角 θ = arc / r (弧度)。半径取 r = 周天 / 6，即古率 π = 3 (径一周三)。
///
/// * [halfChordFromSagitta] = √(v(2r − v))              半弦 (勾股: r² = (r−v)² + 半弦²)
/// * [chordFromSagitta]      = 2·√(v(2r − v))            弦 = 2 倍半弦
/// * [arcFromSagitta]       ≈ chord + v²/r               沈括会圆术弧长近似 (弧 = 弦 + 2·矢²/径, 径 = 2r)
///
/// 会圆术的弧长是"近似"的 —— 与真实弧长 rθ 存在已知误差 (邓可卉 2007 讨论的
/// 古代弧矢近似 vs 现代球面三角的差异根源)，在单元测试中给出该误差的上界。
class HushiGeyuan {
  final double zhouTian;
  final double daJu;
  final double piRatio;

  const HushiGeyuan({
    this.zhouTian = zhouTianConst,
    this.daJu = daJuConst,
    this.piRatio = math.pi,
  });

  /// 半径 = 周天 / (2π)。
  double get r => zhouTian / (2.0 * piRatio);

  /// 径 = 2r。
  double get diameter => 2.0 * r;

  /// 象限 = 周天 / 4 (二至限)。
  double get quadrant => zhouTian / 4.0;

  /// 半周长 = 周天 / 2 = π·r。
  double get halfCircumference => zhouTian / 2.0;

  /// 会圆术前向可及的最大弧 = 3r (对应矢 v=r)。
  ///
  /// 古率下 3r = 半周；真 π 下 3r < 半周 (πr)，会圆术近半周失真，
  /// 但黄赤道换算弧长 ≤ 象限 (≈1.57r)，在此域内精度良好。
  double get huiyuanMaxArc => 3.0 * r;

  // ============================================================
  //  一、会圆术地基：弧 / 弦 / 矢 互求
  // ============================================================

  /// 由矢求半弦 (勾股)。
  ///
  /// r² = (r − v)² + 半弦²  ⇒  半弦 = √(v(2r − v))。
  /// 定义域 0 ≤ v ≤ 2r (整圆)；本式对 minor arc 用 0 ≤ v ≤ r。
  double halfChordFromSagitta(double v) {
    if (v < 0.0 || v > diameter) {
      throw GeyuanException("矢 v=$v 超出 [0, 2r=$diameter]");
    }
    final val = v * (diameter - v); // v(2r − v)
    // 数值兜底：避免 -0.0 开方
    return math.sqrt(math.max(val, 0.0));
  }

  /// 由矢求弦：弦 = 2·半弦。
  double chordFromSagitta(double v) {
    return 2.0 * halfChordFromSagitta(v);
  }

  /// 由半弦求矢 (取 minor arc 之矢，v ≤ r)。
  ///
  /// 半弦² = v(2r − v) ⇒ v² − 2r·v + 半弦² = 0
  /// ⇒ v = r − √(r² − 半弦²)  (较小根)。
  double sagittaFromHalfChord(double halfChord) {
    final currentR = r;
    if (halfChord < 0.0 || halfChord > currentR) {
      throw GeyuanException("半弦=$halfChord 超出 minor-arc 域 [0, r=$currentR]");
    }
    return currentR - math.sqrt(math.max(currentR * currentR - halfChord * halfChord, 0.0));
  }

  /// 由弦求矢 (minor arc)。
  double sagittaFromChord(double chord) {
    return sagittaFromHalfChord(chord / 2.0);
  }

  /// 由矢求弧 —— 沈括会圆术：弧 = 弦 + 矢²/半径。
  ///
  /// (弧 = 弦 + 2·矢²/径，径 = 2r ⇒ 2v²/(2r) = v²/r)
  /// 定义域 0 ≤ v ≤ r (minor arc, 弧 ≤ 半周 3r)。
  double arcFromSagitta(double v) {
    final currentR = r;
    if (v < 0.0 || v > currentR) {
      throw GeyuanException("矢 v=$v 超出会圆术 minor-arc 域 [0, r=$currentR]");
    }
    return chordFromSagitta(v) + (v * v) / currentR;
  }

  /// 由弧求弦：先割圆求矢，再由矢求弦。
  double chordFromArc(double arc) {
    return chordFromSagitta(sagittaFromArc(arc));
  }

  // ============================================================
  //  二、割圆求矢：已知弧反求矢 (二分迭代代四次开方)
  // ============================================================

  /// 割圆求矢：已知弧长 arc，反求矢 v。
  ///
  /// 古法 (《明史·历志》割圆求矢) 将
  ///     arc − v²/r = 弦 = 2√(v(2r − v))
  /// 两边平方得关于 v 的四次方程，用增乘开方逐位求解。
  /// 本实现改用二分法：[arcFromSagitta] 在 v ∈ [0, r] 上严格单调递增
  /// (弦项与矢²项导数皆 ≥ 0)，故二分稳定收敛。
  ///
  /// 定义域：0 ≤ arc ≤ 3r (会圆术前向像上界，对应矢 v=r)。
  double sagittaFromArc(double arc, {double tol = 1e-12, int maxIter = 200}) {
    final maxArc = huiyuanMaxArc; // 3r
    if (arc < -1e-12 || arc > maxArc + 1e-9) {
      throw GeyuanException("弧 arc=$arc 超出 [0, 半周=$maxArc]");
    }
    final targetArc = math.min(math.max(arc, 0.0), maxArc);

    double lo = 0.0;
    double hi = r;
    double fLo = arcFromSagitta(lo) - targetArc; // = -arc <= 0
    double fHi = arcFromSagitta(hi) - targetArc; // = 3r - arc >= 0

    // 端点精确命中 (arc=0 或 arc=3r)
    if (fLo.abs() < tol) {
      return lo;
    }
    if (fHi.abs() < tol) {
      return hi;
    }

    for (int i = 0; i < maxIter; i++) {
      final mid = 0.5 * (lo + hi);
      final fMid = arcFromSagitta(mid) - targetArc;
      if (fMid.abs() < tol || (hi - lo) < tol) {
        return mid;
      }
      // 根落在 [lo, mid] (fLo 与 fMid 异号) 则收上界，否则收下界
      if ((fLo < 0.0) != (fMid < 0.0)) {
        hi = mid;
      } else {
        lo = mid;
        fLo = fMid;
      }
    }
    return 0.5 * (lo + hi);
  }

  // ============================================================
  //  二·补、正弦：弧之正弦 r·sinθ (区别于半弦 r·sin(θ/2))
  // ============================================================
  //  球面三角需要弧的"正弦" r·sinθ (θ=全弧圆心角)，而会圆术半弦是
  //  r·sin(θ/2)。两者关系 (倍角):  r·sinθ = 2·半弦·√(r²−半弦²)/r。
  //  邓可卉 2007 指出的"古弧矢近似 vs 现代三角"差异，关键即在这一步
  //  须区分半弦与正弦。

  /// 弧之正弦 r·sinθ (θ = arc/r 为圆心角)。
  ///
  /// 采用精确弦长关系 (勾股本身精确)，与沈括会圆术的"弧长近似"分离，
  /// 以免把会圆术近半周的失真带入黄赤道换算。定义域 0 ≤ arc ≤ 象限。
  double sineOfArc(double arc) {
    if (arc < 0.0 || arc > quadrant + 1e-9) {
      throw GeyuanException("求正弦之弧 arc=$arc 超出 [0, 象限=$quadrant]");
    }
    return r * math.sin(arc / r);
  }

  /// 由正弦 r·sinθ 反求弧 arc (θ ∈ [0, π/2])。
  double arcFromSine(double sine) {
    final currentR = r;
    if (sine < 0.0 || sine > currentR + 1e-9) {
      throw GeyuanException("正弦=$sine 超出 [0, r=$currentR]");
    }
    return currentR * math.asin(math.min(sine / currentR, 1.0));
  }

  /// 弧之正弦的"会圆术近似版" —— 用半弦倍角求 r·sinθ。
  ///
  /// r·sinθ = 2·半弦·√(r²−半弦²)/r，其中半弦经会圆术割圆求矢得到。
  /// 与精确 [sineOfArc] 之差即沈括弧长近似误差 (邓可卉 2007 所论，
  /// 随弧增大而增大)，仅供比对/复原古算之用，不进入黄赤道主流程。
  double sineOfArcHuiyuan(double arc) {
    if (arc < 0.0 || arc > quadrant + 1e-9) {
      throw GeyuanException("求正弦之弧 arc=$arc 超出 [0, 象限=$quadrant]");
    }
    final currentR = r;
    final hc = halfChordFromSagitta(sagittaFromArc(arc)); // r·sin(θ'/2)
    final cosHalf = math.sqrt(math.max(currentR * currentR - hc * hc, 0.0)); // r·cos(θ'/2)
    return 2.0 * hc * cosHalf / currentR;
  }

  // ============================================================
  //  三、黄赤道换算 (弧矢割圆术之应用)
  // ============================================================
  //
  //  球面直角三角形 (春分为直角顶, 交角 = 大距 ε):
  //     黄道积度 λ  (自二分点起算, 弧, 0 ≤ λ ≤ 象限)
  //     赤纬      δ  (黄赤道内外度)
  //     赤道积度 α  (赤经方向弧长)
  //
  //  半弦 (= r·sinθ) 满足勾股比例，正是用户所指 p2 = p1·p_eps/R：
  //     p_λ  = 半弦(λ)          黄道半弦
  //     p_ε  = 半弦(ε)          大距半弦   = r·sinε
  //     p_δ  = p_λ · p_ε / r    内外度半弦 = r·sinδ   ⟺ sinδ = sinε·sinλ
  //  赤道积度:
  //     p_α  = p_λ · √(r²−p_ε²) / √(r²−p_δ²)          ⟺ sinα = sinλ·cosε/cosδ
  // ------------------------------------------------------------

  /// 大距正弦 p_ε = r·sinε (经会圆术, 保持全程弧矢化)。
  double _epsSine(double? eps) {
    final epsArc = eps ?? daJu;
    return sineOfArc(epsArc);
  }

  /// 求黄赤道内外度 (赤纬 δ)。
  ///
  /// 输入 黄道积度 λ (自二分点起算, 0 ≤ λ ≤ 象限)，返回赤纬 δ (度)。
  /// 比例:  p_δ = p_λ · p_eps / R   (即 sinδ = sinε·sinλ)。
  double declination(double lam, {double? eps}) {
    if (lam < 0.0 || lam > quadrant + 1e-9) {
      throw GeyuanException("黄道积度 λ=$lam 超出 [0, 象限=$quadrant]");
    }
    final currentR = r;
    final pLam = sineOfArc(lam); // p1 = r·sinλ
    final pEps = _epsSine(eps); // p_eps = r·sinε
    final pDec = pLam * pEps / currentR; // p2 = p1·p_eps/R = r·sinδ
    return arcFromSine(pDec);
  }

  /// 求赤道积度 (赤经 α)。
  ///
  /// 输入 黄道积度 λ (自二分点起算)，返回赤道积度 α (度)。
  /// 比例:  sinα = sinλ · cosε / cosδ。
  double rightAscension(double lam, {double? eps}) {
    if (lam < 0.0 || lam > quadrant + 1e-9) {
      throw GeyuanException("黄道积度 λ=$lam 超出 [0, 象限=$quadrant]");
    }
    final currentR = r;
    final pLam = sineOfArc(lam); // r·sinλ
    final pEps = _epsSine(eps); // r·sinε
    final pDec = pLam * pEps / currentR; // r·sinδ
    final cosEps = math.sqrt(math.max(currentR * currentR - pEps * pEps, 0.0)); // r·cosε
    final cosDec = math.sqrt(math.max(currentR * currentR - pDec * pDec, 0.0)); // r·cosδ
    if (cosDec == 0.0) {
      return quadrant;
    }
    double pRa = pLam * cosEps / cosDec; // r·sinα
    pRa = math.min(pRa, currentR); // 数值兜底
    return arcFromSine(pRa);
  }

  /// 黄道积度 → (赤道积度 α, 赤纬 δ)。
  (double, double) eclipticToEquatorial(double lam, {double? eps}) {
    return (rightAscension(lam, eps: eps), declination(lam, eps: eps));
  }

  // ============================================================
  //  四、现代球面三角参照 (仅供比对/验证误差, 非古法)
  // ============================================================
  //  采用与会圆术相同的角度约定 θ = arc / r，从而隔离"会圆术弧长近似"
  //  这一项误差 (排除古率 π=3 的影响)。

  double _theta(double arc) {
    return arc / r;
  }

  /// 现代球面三角赤纬: sinδ = sinε·sinλ (同 θ=arc/r 约定)。
  double declinationModern(double lam, {double? eps}) {
    final epsArc = eps ?? daJu;
    final sinD = math.sin(_theta(epsArc)) * math.sin(_theta(lam));
    return math.asin(math.min(math.max(sinD, -1.0), 1.0)) * r;
  }

  /// 现代球面三角赤经: tanα = cosε·tanλ (同 θ=arc/r 约定)。
  double rightAscensionModern(double lam, {double? eps}) {
    final epsArc = eps ?? daJu;
    final thL = _theta(lam);
    double alpha = math.atan(math.cos(_theta(epsArc)) * math.tan(thL));
    if (alpha < 0.0) {
      alpha += math.pi;
    }
    return alpha * r;
  }
}
