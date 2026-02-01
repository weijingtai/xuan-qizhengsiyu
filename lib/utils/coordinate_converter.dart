class CoordinateConverter {
  /// 将十进制度数 (DD) 转换为度、分、秒 (DMS)
  ///
  /// [decimalDegrees] 十进制度数 (例如 40.7128 或 -74.0060)
  ///
  /// 返回一个包含度 (int)、分 (int)、秒 (double) 的列表
  /// 注意：返回的度、分、秒始终为非负值。方向（正/负）由原始输入决定，
  /// 调用者需要根据原始输入的符号自行判断方向 (N/S, E/W)
  static List<num> ddToDms(double decimalDegrees) {
    // 检查是否为负数，并获取绝对值进行计算
    bool isNegative = decimalDegrees < 0;
    decimalDegrees = decimalDegrees.abs();

    // 提取度
    int degrees = decimalDegrees.floor();

    // 计算剩余的小数部分，并转换为分
    double minutesFloat = (decimalDegrees - degrees) * 60;
    int minutes = minutesFloat.floor();

    // 计算剩余的小数部分，并转换为秒
    double seconds = (minutesFloat - minutes) * 60;

    return [degrees, minutes, seconds];
  }

  /// 将度、分、秒 (DMS) 转换为十进制度数 (DD)
  ///
  /// [degrees] 度数 (int)。可以为负数表示南纬或西经
  /// [minutes] 分数 (int)。应为非负数
  /// [seconds] 秒数 (double)。应为非负数
  ///
  /// 返回十进制度数 (double)
  ///
  /// 如果分数或秒数为负数，将抛出 [ArgumentError]
  static double dmsToDd(int degrees, int minutes, double seconds) {
    if (minutes < 0 || seconds < 0) {
      throw ArgumentError('分数 (minutes) 和 秒数 (seconds) 必须为非负数。');
    }

    // 判断符号
    int sign = degrees < 0 ? -1 : 1;
    degrees = degrees.abs(); // 使用绝对值进行计算

    // 计算十进制度数
    double decimalDegrees = degrees + minutes / 60.0 + seconds / 3600.0;

    // 应用符号
    return sign * decimalDegrees;
  }
}
