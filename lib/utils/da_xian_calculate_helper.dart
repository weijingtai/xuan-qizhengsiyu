import 'package:common/module.dart';

class DaXianCalculateHelper {
  /// 将数字数组转换为列表的列表，遵循特定的规则。
  /// 规则基于处理数字的整数、小数部分以及前一个数字的小数部分对后一个列表开头的影响。

  /// 示例：
  /// [3.25, 3] => [[1,1,1,0.25], [0.75,1,1,0.25]]
  /// [3.25, 3, 4.75] => [[1,1,1,0.25], [0.75,1,1,0.25], [0.75,1,1,1,1]]
  /// [3.75, 3, 4.5] => [[1,1,1,0.75], [0.25,1,1,0.75], [0.25,1,1,1,1,0.25]]
  ///
  /// 逻辑解释：
  /// prevRemFrac: 这个变量是关键。它存储了前一个数字对应的列表的最后一个元素的小数部分。
  /// 循环处理每个数字: 遍历输入的 numbers 数组。
  /// 处理列表开头: 对于除第一个数字之外的每个数字，如果 prevRemFrac 大于 0，就计算 1.0 - prevRemFrac 作为当前列表的第一个元素。这部分值从当前数字的总值 num 中扣除。
  /// 处理整数部分: 将剩余的总值 valueToBreakDown 的整数部分转换为相同数量的 1.0 并添加到列表中。
  /// 处理列表末尾: 将 valueToBreakDown 经过扣除整数部分后剩余的小数部分添加到列表末尾。
  /// 更新 prevRemFrac: 当前列表构建完成后，取其最后一个元素的小数部分，作为 prevRemFrac 传递给下一个数字的处理。
  /// 浮点精度: 考虑到浮点数计算可能不精确，使用了 epsilon 和 (value / quarter).round() * quarter 的方式将计算出的分数调整到最接近的 0.25 的倍数。
  static List<List<double>> transformNumbers(List<double> numbers) {
    List<List<double>> outputLists = [];
    double prevRemFrac = 0.0; // 用于记录前一个列表末尾剩余的小数部分
    final double epsilon = 1e-9; // 用于浮点数比较的阈值
    final double quarter = 0.25; // 明确最小小数单位，用于可能的浮点纠正

    for (int i = 0; i < numbers.length; i++) {
      double num = numbers[i];
      List<double> currentList = [];
      double valueToBreakDown = num; // 当前数字的总值，将逐步分解并添加到 currentList

      // --- 处理列表的开头元素 ---
      // 如果前一个列表有剩余的小数部分 (prevRemFrac > 0)
      // 则当前列表的开头由 1 减去这个小数部分组成
      if (prevRemFrac > epsilon) {
        double startVal = 1.0 - prevRemFrac;
        // 考虑到浮点精度，将计算出的 startVal 调整到最接近的 0.25 的倍数
        startVal = (startVal / quarter).round() * quarter;
        // 只有调整后大于 0 才添加
        if (startVal > epsilon) {
          currentList.add(startVal);
          // 从当前数字的总值中减去这个开头元素的值，因为这部分价值由开头元素体现了
          valueToBreakDown -= startVal;
          // 前一个剩余小数部分被"消耗"了，重置为 0，不会影响再下一个列表的开头
          // 但是，我们更新 prevRemFrac 的逻辑是在当前列表构建完成后，所以这里不需要重置
        }
      }
      // 如果 prevRemFrac <= epsilon，则当前列表没有由前一个小数部分决定的开头元素

      // --- 添加整数个 1 ---
      // 从剩余的 valueToBreakDown 中提取整数部分，转换为 1
      // 注意：这里是对 valueToBreakDown 取整，不是对原始 num 取整
      int fullUnits = valueToBreakDown.floor();
      for (int j = 0; j < fullUnits; j++) {
        currentList.add(1.0);
      }
      // 从 valueToBreakDown 中减去已经转换为 1 的整数部分
      valueToBreakDown -= fullUnits;

      // --- 添加列表末尾的剩余小数部分 ---
      // valueToBreakDown 中剩余的就是原始数字经过开头元素和整数个 1 分解后的小数部分
      if (valueToBreakDown > epsilon) {
        // 将这个剩余小数部分调整到最接近的 0.25 的倍数
        double endFrac = (valueToBreakDown / quarter).round() * quarter;
        // 只有调整后大于 0 才添加
        if (endFrac > epsilon) {
          currentList.add(endFrac);
        }
      }

      // 将构建好的列表添加到结果中
      outputLists.add(currentList);

      // --- 计算下一个列表开头的依据：当前列表末尾的小数部分 ---
      // 下一个列表的 prevRemFrac 取决于当前列表的最后一个元素的小数部分
      if (currentList.isNotEmpty) {
        double lastElement = currentList.last;
        // 获取最后一个元素的小数部分
        prevRemFrac = lastElement - lastElement.floor();

        // 对计算出的小数部分进行调整，确保是 0.25 的倍数，并处理靠近 0 或 1 的浮点精度问题
        prevRemFrac = (prevRemFrac / quarter).round() * quarter;

        if (prevRemFrac.abs() < epsilon) {
          prevRemFrac = 0.0; // 小数部分非常接近 0，视为 0
        } else if ((prevRemFrac - 1.0).abs() < epsilon) {
          prevRemFrac = 0.0; // 小数部分非常接近 1，视为 0 (因为 1.0 的小数部分是 0)
        }
        // 对于大于 0 小于 1 的小数部分，经过上面的 round*quarter 已经处理了
      } else {
        // 如果列表为空（在您的约束条件下数字 >= 3 应该不会发生），则下一个小数部分为 0
        prevRemFrac = 0.0;
      }
    }

    return outputLists;
  }

  // 用于进行换运限的datetime开发
  /// 同 [transformNumbers] 只是将输入输出的参数从 double->int 改为 YearMonth->YearMonth
  /// 输入的 numbers 是 YearMonth 类型的列表，输出的也是 YearMonth 类型的列表列表
  /// 逻辑及目标相同
  static List<List<YearMonth>> transformYearMonths(List<YearMonth> numbers) {
    List<List<YearMonth>> outputLists = [];
    // 用于记录前一个列表末尾不足一年的部分 (只有月数，年为 0)
    YearMonth prevRemMonths = YearMonth(0, 0);

    for (int i = 0; i < numbers.length; i++) {
      YearMonth num = numbers[i]; // 当前需要转换的 YearMonth
      List<YearMonth> currentList = []; // 当前数字对应的输出列表
      // 用于分解和添加到 currentList 的剩余时长，初始为当前数字的总时长
      YearMonth valueToBreakDown = num;

      // --- 处理列表的开头元素 ---
      // 如果前一个列表有剩余不足一年的部分 (prevRemMonths > YearMonth(0, 0))
      // 则当前列表的开头由 YearMonth(1, 0) 减去这个剩余部分组成
      if (prevRemMonths.toTotalMonths() > 0) {
        YearMonth startVal = YearMonth(1, 0) - prevRemMonths;
        // startVal 理论上只会有 3, 6, 9 个月 (12-3=9, 12-6=6, 12-9=3)
        // 添加到当前列表
        currentList.add(startVal);
        // 从当前数字的总值中减去这个开头元素的值
        valueToBreakDown = valueToBreakDown - startVal;
        // prevRemMonths 在逻辑上被“消耗”了，但我们更新 prevRemMonths 的逻辑在当前列表构建完成后，所以这里不修改它
      }
      // 如果 prevRemMonths 是 YearMonth(0, 0)，则当前列表没有这个由前一个结余决定的开头元素

      // --- 添加整年 (YearMonth(1, 0)) 单元 ---
      // 从剩余的 valueToBreakDown 中提取整年部分
      int fullYears = valueToBreakDown.year;
      for (int j = 0; j < fullYears; j++) {
        currentList.add(YearMonth(1, 0)); // 添加 YearMonth(1, 0) 表示一个整年
      }
      // 从 valueToBreakDown 中减去已经转换为 YearMonth(1, 0) 的整年部分
      valueToBreakDown = valueToBreakDown - YearMonth(fullYears, 0);
      // 此时 valueToBreakDown 应该只剩下不足一年的部分 YearMonth(0, month)

      // --- 添加列表末尾的剩余不足一年部分 (月数) ---
      // valueToBreakDown 经过扣除整年后，剩余的就是不足一年的部分 YearMonth(0, month)
      if (valueToBreakDown.toTotalMonths() > 0) {
        // 添加这个剩余的不足一年部分到列表末尾
        // 理论上这里的 valueToBreakDown 的月数只会在 {3, 6, 9} 中
        currentList.add(valueToBreakDown);
      }

      // 将构建好的列表添加到结果中
      outputLists.add(currentList);

      // --- 计算下一个列表开头的依据：当前列表末尾不足一年部分 ---
      // 下一个列表的 prevRemMonths 取决于当前列表的**最后一个元素**的**月数**
      if (currentList.isNotEmpty) {
        YearMonth lastElement = currentList.last;
        // 提取最后一个元素的月数，构建 YearMonth(0, month) 作为下一个的 prevRemMonths
        prevRemMonths = YearMonth(0, lastElement.month);

        // 根据您的约束 "month的值只会在{3,6,9} 这三个正整数之间" (针对输出元素)
        // 理论上这里的 prevRemMonths 的月数只会是 0, 3, 6, 9
        // YearMonth(0,0), YearMonth(0,3), YearMonth(0,6), YearMonth(0,9)
        // 无需额外的浮点数精度处理或 snapping
      } else {
        // 如果列表为空（在您的输入约束下数字 >= 3 YearMonth >= YM(3,0) 不会发生），则下一个结余为 0
        prevRemMonths = YearMonth(0, 0);
      }
    }

    return outputLists;
  }

  @Deprecated("请使用 transformNumbers")
  static List<List<double>> convertNumbers(List<double> numbers) {
    List<List<double>> result = [];
    double a_prev = 0.0; // 上一个数字的结束小数

    for (int i = 0; i < numbers.length; i++) {
      double num = numbers[i];
      int integerPart = num.floor();
      double fractionalPart = (num - integerPart).toDouble();

      if (i == 0) {
        // 处理第一个数字
        List<double> firstList = List.filled(integerPart, 1.0, growable: true);
        if (fractionalPart > 0) {
          firstList.add(fractionalPart);
          a_prev = fractionalPart;
        } else {
          a_prev = 0.0;
        }
        result.add(firstList);
      } else {
        // 处理后续数字
        double b = 1.0 - a_prev;
        double s = fractionalPart + a_prev;
        int k = s.floor();
        double a_i = s - k; // 当前数字的结束小数

        List<double> currentList = [b];
        int onesCount = integerPart - 1 + k;

        if (onesCount > 0) {
          currentList.addAll(List.filled(onesCount, 1.0));
        }

        if (a_i > 0) {
          currentList.add(a_i);
        }

        result.add(currentList);
        a_prev = a_i; // 更新结束小数供下一个数字使用
      }
    }

    return result;
  }

  static (bool, double, List<double>, double) proportionalAllocationWithEnds({
    required double first,
    required double last,
    required int kMiddle,
    required double total,
  }) {
    // 验证输入值范围
    const validValues = {"0.25", "0.50", "0.75", "1.00"};
    if (!validValues.contains(first.toStringAsFixed(2))) {
      return (false, 0.0, [], 0.0);
    }
    if (!validValues.contains(last.toStringAsFixed(2))) {
      return (false, 0.0, [], 0.0);
    }

    // 基本单位
    const u = 0.25;

    // 计算单位数
    final nFirst = first / u;
    const nMiddle = 1.0 / u; // 恒为4.0
    final nLast = last / u;

    // 计算总单位数
    final totalUnits = nFirst + kMiddle * nMiddle + nLast;

    // 避免除以零错误
    if (totalUnits <= 0) {
      return (false, 0.0, [], 0.0);
    }

    // 计算单位价值
    final valuePerUnit = total / totalUnits;

    // 计算分配值
    final allocFirst = nFirst * valuePerUnit;
    final allocMiddle = List<double>.filled(kMiddle, nMiddle * valuePerUnit);
    final allocLast = nLast * valuePerUnit;

    return (true, allocFirst, allocMiddle, allocLast);
  }
}
