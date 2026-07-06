import 'dart:math';

// 辅助类型定义
typedef RadialCoordinates = double;

class EquatorialToEcliptic {
  /// 现代球面三角赤道→黄道坐标换算（ε 校验参照）。
  ///
  /// 此算法用现代 atan2 球面三角公式；推黄道术（进退+黄赤道差查表/公式）
  /// 与拟黄道术（民间分段多项式）均为古法，与本类的现代三角实现不同。
  /// 本类仅用作古法结果的 ε 校验参照。详见 002 §2.2。

// 黄赤交角（当前值约23.439281度，可根据需要调整）
  static double epsilon = 0.4090925534; // 23.439281 degrees in radians

  /// 将赤道坐标转换为黄道坐标
  /// @param alpha 赤经（弧度）
  /// @param delta 赤纬（弧度）
  /// @return 包含黄经和黄纬的元组（弧度）
  static (RadialCoordinates, RadialCoordinates) equatorialToEcliptic(
    double alpha,
    double delta,
  ) {
    final cosDelta = cos(delta);
    final sinDelta = sin(delta);
    final cosAlpha = cos(alpha);
    final sinAlpha = sin(alpha);
    final cosEpsilon = cos(EquatorialToEcliptic.epsilon);
    final sinEpsilon = sin(EquatorialToEcliptic.epsilon);

    // 计算黄经
    final x = cosDelta * cosAlpha;
    final y = cosDelta * sinAlpha * cosEpsilon + sinDelta * sinEpsilon;
    final lambda = atan2(y, x);

    // 计算黄纬
    final beta = asin(sinDelta * cosEpsilon - cosDelta * sinAlpha * sinEpsilon);

    return (lambda, beta);
  }
}

// 示例使用
// void main() {
//   // 输入赤道坐标（30度赤经，20度赤纬）
//   final alpha = pi / 6; // 30 degrees in radians
//   final delta = pi / 9; // 20 degrees in radians

//   final (lambda, beta) = equatorialToEcliptic(alpha, delta);

//   // 输出黄道坐标（转换为度数）
//   print('黄经: ${lambda * 180 / pi} 度');
//   print('黄纬: ${beta * 180 / pi} 度');
// }
