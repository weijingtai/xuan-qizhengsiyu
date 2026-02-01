import 'dart:math';

// 辅助类型定义
typedef RadialCoordinates = double;

class EquatorialToEcliptic {
  /// 推黄道术，又称“拟黄道术”，
  /// 中国古天文中将赤道定义为365.25度，
  /// 通过将赤道上的星体或星宿角度投影到黄道上，来获取在黄道上的角度

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
